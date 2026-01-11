
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'package:golf_society/models/notification.dart';
import 'package:intl/intl.dart';
import 'admin_notifications_provider.dart';

class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  String _searchQuery = '';
  String _groupBy = 'Date'; // 'Date', 'Category', 'None'

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(adminNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const BoxyArtAppBar(title: 'History', showBack: false),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                BoxyArtSearchBar(
                  hintText: 'Search history...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Group By:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(width: 12),
                    _GroupChip(
                      label: 'Date',
                      isSelected: _groupBy == 'Date',
                      onTap: () => setState(() => _groupBy = 'Date'),
                    ),
                    const SizedBox(width: 8),
                    _GroupChip(
                      label: 'Category',
                      isSelected: _groupBy == 'Category',
                      onTap: () => setState(() => _groupBy = 'Category'),
                    ),
                    const SizedBox(width: 8),
                    _GroupChip(
                      label: 'None',
                      isSelected: _groupBy == 'None',
                      onTap: () => setState(() => _groupBy = 'None'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                // 1. Filter
                final filtered = notifications.where((n) {
                  final term = _searchQuery.toLowerCase();
                  return n.title.toLowerCase().contains(term) || 
                         n.message.toLowerCase().contains(term);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No notifications found', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // 2. Group & Build ListView
                return _buildGroupedList(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<AppNotification> notifications) {
    if (_groupBy == 'None') {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) => _HistoryCard(notification: notifications[index]),
      );
    }

    // Group Logic
    Map<String, List<AppNotification>> groups = {};
    for (var n in notifications) {
      String key = '';
      if (_groupBy == 'Date') {
        final now = DateTime.now();
        final diff = now.difference(n.timestamp).inDays;
        if (diff == 0) {
          key = 'Today';
        } else if (diff == 1) {
          key = 'Yesterday';
        } else if (diff < 7) {
          key = 'Last 7 Days';
        } else {
          key = 'Older';
        }
      } else {
        key = n.category;
      }
      
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(n);
    }

    final sortedKeys = groups.keys.toList(); 
    // If Date, we implicitly trust the order strictly because the source list is ordered by timestamp desc.
    // If Category, we might want alphabetical, but preserving insertion order is fine for now.

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final groupItems = groups[key]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                key.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.grey,
                  letterSpacing: 1.1
                ),
              ),
            ),
            ...groupItems.map((n) => _HistoryCard(notification: n)),
          ],
        );
      },
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AppNotification notification;
  const _HistoryCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BoxyArtFloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(parseDate(notification.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notification.category,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(notification.message, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
  
  String parseDate(DateTime d) {
    return DateFormat('MMM d, h:mm a').format(d);
  }
}
