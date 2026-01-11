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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap ?? () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // Subtle shadow as requested (or none)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Circular Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red.shade50 : Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUrgent ? Icons.error_outline_rounded : Icons.info_outline_rounded,
                  color: isUrgent ? Colors.red : Colors.amber.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              
              // Middle: Title and Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Right: Timestamp
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
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
