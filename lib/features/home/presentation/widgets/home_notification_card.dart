import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:golf_society/domain/models/notification.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../home_providers.dart';

class HomeNotificationCard extends ConsumerWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final void Function(DismissDirection)? onDismissed;

  const HomeNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = _resolveStyle(notification);
    final shapes = Theme.of(context).extension<AppShapeTokens>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key('notif_${notification.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: onDismissed ??
            (_) => ref.read(notificationsRepositoryProvider).markAsRead(notification.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.x2l),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: shapes?.card ?? AppShapes.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.done_all_rounded,
                  color: AppColors.pureWhite, size: AppShapes.iconLg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'READ',
                style: AppTypography.micro.copyWith(
                  color: AppColors.pureWhite,
                  letterSpacing: AppTypography.lsLabel,
                ),
              ),
            ],
          ),
        ),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          onTap: onTap ??
              (notification.actionUrl != null
                  ? () => context.push(notification.actionUrl!)
                  : null),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxyArtIconBadge(
                icon: style.icon,
                color: style.color,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.cardTitle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildMessage(context),
                    if (notification.actionUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: notification.actionUrl!.contains('members')
                            ? BoxyArtButton(
                                title: 'Renew Now',
                                isSecondary: true,
                                isPrimary: false,
                                fullWidth: false,
                                isSmall: true,
                                onTap: () => context.push(notification.actionUrl!),
                              )
                            : GestureDetector(
                                onTap: () => context.push(notification.actionUrl!),
                                child: Text(
                                  'View Details →',
                                  style: AppTypography.label.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: AppTypography.lsLabel,
                                  ),
                                ),
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

  ({Color color, IconData icon}) _resolveStyle(AppNotification n) {
    final title = n.title.toLowerCase();
    final category = n.category.toLowerCase();

    if (category == 'urgent') {
      return (color: AppColors.coral500, icon: Icons.campaign_rounded);
    }
    if (title.contains('verified') || title.contains('approved') ||
        title.contains('confirmed') || title.contains('promoted')) {
      return (color: AppColors.lime600, icon: Icons.check_circle_rounded);
    }
    if (title.contains('unlocked') || title.contains('reset') ||
        title.contains('re-verify')) {
      return (color: AppColors.amber500, icon: Icons.lock_open_rounded);
    }
    if (title.contains('conflict') || title.contains('dq') ||
        title.contains('disqualif')) {
      return (color: AppColors.coral500, icon: Icons.warning_rounded);
    }
    if (category == 'scoring') {
      return (color: AppColors.amber500, icon: Icons.sports_score_rounded);
    }
    if (category == 'membership') {
      return (color: AppColors.dark400, icon: Icons.person_rounded);
    }
    return (color: AppColors.dark400, icon: Icons.info_rounded);
  }

  Widget _buildMessage(BuildContext context) {
    final bodyStyle = AppTypography.bodySmall.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );

    try {
      final List<dynamic> deltaJson = jsonDecode(notification.message);
      final controller = quill.QuillController(
        document: quill.Document.fromJson(deltaJson),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      return quill.QuillEditor.basic(
        controller: controller,
        config: const quill.QuillEditorConfig(
          scrollable: false,
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          showCursor: false,
          enableInteractiveSelection: false,
        ),
      );
    } catch (_) {
      return Text(notification.message, style: bodyStyle);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(timestamp);
  }
}
