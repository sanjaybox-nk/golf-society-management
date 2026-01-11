import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/notification.dart';
import 'home_providers.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(homeNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const BoxyArtAppBar(
        title: 'Notifications',
        showBack: true,
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (notifications) {
          return notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
                       const SizedBox(height: 16),
                       Text('No notifications found', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InboxNotificationCard(notification: notification),
                    );
                  },
                );
        },
      ),
    );
  }
}

class _InboxNotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _InboxNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isUrgent = notification.category == 'Urgent';
    
    return BoxyArtFloatingCard(
      onTap: () {
        // Handle tap - deep link or dialog
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.warning_rounded : Icons.info_rounded,
              color: isUrgent ? Colors.red : Colors.amber.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return DateFormat('MMM d').format(timestamp);
  }
}
