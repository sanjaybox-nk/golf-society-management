import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import '../home_providers.dart';

class HomeNotificationCard extends ConsumerStatefulWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const HomeNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  ConsumerState<HomeNotificationCard> createState() => _HomeNotificationCardState();
}

class _HomeNotificationCardState extends ConsumerState<HomeNotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.notification.category == 'Urgent';
    final primary = isUrgent ? const Color(0xFFE74C3C) : const Color(0xFFF39C12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('notif_${widget.notification.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(notificationsRepositoryProvider).markAsRead(widget.notification.id);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all_rounded, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'READ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Squircle Icon with Glow
                Container(
                  width: 52,
                  height: 52,
                  decoration: ShapeDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    shadows: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isUrgent ? Icons.campaign_rounded : Icons.info_rounded,
                    color: primary,
                    size: 26,
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
                              widget.notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(widget.notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _buildMessageContent(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    try {
      final List<dynamic> deltaJson = jsonDecode(widget.notification.message);
      final controller = quill.QuillController(
        document: quill.Document.fromJson(deltaJson),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );

      return quill.QuillEditor.basic(
        controller: controller,
        config: quill.QuillEditorConfig(
          scrollable: false,
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          showCursor: false,
          enableInteractiveSelection: false,
          // Limit lines if not expanded
          maxHeight: _isExpanded ? null : 40, 
        ),
      );
    } catch (_) {
      // Fallback to plain text
      return Text(
        widget.notification.message,
        maxLines: _isExpanded ? null : 2,
        overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          height: 1.4,
        ),
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
