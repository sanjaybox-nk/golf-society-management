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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key('notif_${widget.notification.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(notificationsRepositoryProvider).markAsRead(widget.notification.id);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.x2l),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: AppShapes.lg,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
              SizedBox(height: AppSpacing.xs),
              Text(
                'READ',
                style: TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: AppTypography.sizeCaption,
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: InkWell(
            onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: AppShapes.xl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Squircle Icon with Glow
                Container(
                  width: 52,
                  height: 52,
                  decoration: ShapeDecoration(
                    color: primary.withValues(alpha: AppColors.opacityLow),
                    shape: ContinuousRectangleBorder(
                      borderRadius: AppShapes.x2l,
                    ),
                    shadows: [
                      BoxShadow(
                        color: primary.withValues(alpha: AppColors.opacityLow),
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
                const SizedBox(width: AppSpacing.lg),
                
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
                                fontWeight: AppTypography.weightBold,
                                fontSize: AppTypography.sizeBody,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _formatTimestamp(widget.notification.timestamp),
                            style: TextStyle(
                              fontSize: AppTypography.sizeCaptionStrong,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: AppTypography.weightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedSize(
                        duration: AppAnimations.medium,
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
          fontSize: AppTypography.sizeLabelStrong,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
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
