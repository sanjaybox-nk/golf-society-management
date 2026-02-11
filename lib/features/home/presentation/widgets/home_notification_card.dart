import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/notification.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class HomeNotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const HomeNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = notification.category == 'Urgent';
    final primary = isUrgent ? const Color(0xFFE74C3C) : const Color(0xFFF39C12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap ?? () => _handleTap(context),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Left: Circular Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isUrgent ? Icons.campaign_rounded : Icons.info_rounded,
                  color: primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Middle: Title and Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      // In a real app, use GoRouter or a deep link handler
      // context.push(notification.actionUrl!);
    } else {
      showBoxyArtDialog(
        context: context,
        title: notification.title,
        message: notification.message,
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return DateFormat('MMM d').format(timestamp);
  }
}
