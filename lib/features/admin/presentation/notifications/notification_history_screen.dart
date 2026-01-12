
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'package:golf_society/models/campaign.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const BoxyArtAppBar(title: 'History', showBack: false),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                BoxyArtSearchBar(
                  hintText: 'Search history...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Group By:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
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

  Widget _buildGroupedList(List<Campaign> campaigns) {
    if (_groupBy == 'None') {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) => _HistoryCard(campaign: campaigns[index]),
      );
    }

    // Group Logic
    Map<String, List<Campaign>> groups = {};
    for (var c in campaigns) {
      String key = '';
      if (_groupBy == 'Date') {
        final now = DateTime.now();
        final diff = now.difference(c.timestamp).inDays;
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
        key = c.category;
      }
      
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(c);
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
            ...groupItems.map((c) => _HistoryCard(campaign: c)),
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
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Campaign campaign;
  const _HistoryCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BoxyArtFloatingCard(
        onTap: () => _showCampaignDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(parseDate(campaign.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    campaign.category,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                if (campaign.recipientCount > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.people, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('${campaign.recipientCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(campaign.message, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
  
  void _showCampaignDetails(BuildContext context) {
    showBoxyArtDialog(
      context: context,
      title: 'Campaign Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailRow(label: 'Sent To', value: '${campaign.targetType} (${campaign.recipientCount} recipients)'),
          if (campaign.targetDescription != null) 
             _DetailRow(label: 'Target', value: campaign.targetDescription!),
          const SizedBox(height: 12),
          _DetailRow(label: 'Category', value: campaign.category),
          _DetailRow(label: 'Date', value: parseDate(campaign.timestamp)),
          const SizedBox(height: 16),
          const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: Colors.grey.shade100,
               borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(campaign.message),
              ],
            ),
          ),
          if (campaign.actionUrl != null) ...[
             const SizedBox(height: 12),
             _DetailRow(label: 'Action', value: campaign.actionUrl!),
          ],
        ],
      ),
      confirmText: 'Type to Send Again', // Future feature maybe?
      onConfirm: () => Navigator.pop(context), 
    );
  }
  
  String parseDate(DateTime d) {
    return DateFormat('MMM d, h:mm a').format(d);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
