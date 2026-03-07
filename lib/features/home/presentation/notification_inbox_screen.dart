import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/notification.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'home_providers.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(homeNotificationsProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: AppTypography.sizeDisplayMedium,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                    notificationsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (notifications) {
                        return notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 60),
                                    Icon(Icons.notifications_none_rounded, size: AppShapes.iconMassive, color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMedium)),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text('No notifications found', style: TextStyle(color: AppColors.dark500)),
                                  ],
                                ),
                              )
                            : Column(
                                children: notifications.map((notification) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: Dismissible(
                                      key: Key('inbox_notif_${notification.id}'),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        ref.read(notificationsRepositoryProvider).deleteNotification(notification.id);
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: AppSpacing.x2l),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE74C3C),
                                          borderRadius: AppShapes.xl,
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete_sweep_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
                                            SizedBox(height: AppSpacing.xs),
                                            Text(
                                              'DELETE',
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
                                      child: _InboxNotificationCard(notification: notification),
                                    ),
                                  );
                                }).toList(),
                              );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
          
          // Header Bar with Back Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.x4l,
                      height: AppSpacing.x4l,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.softScale,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, size: AppShapes.iconMd, color: Colors.black.withValues(alpha: 0.87)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    final primary = Theme.of(context).primaryColor;
    final accent = isUrgent ? AppColors.coral500 : primary;

    return BoxyArtCard(
      onTap: () {
        // Handle tap - deep link or dialog
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: AppColors.opacityLow),
              borderRadius: AppShapes.md,
            ),
            child: Icon(
              isUrgent ? Icons.warning_rounded : Icons.info_rounded,
              color: accent,
              size: AppShapes.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBody),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildMessageContent(context),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: AppShapes.iconXs, color: AppColors.dark400),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(color: AppColors.dark400, fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMessageContent(BuildContext context) {
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
      return Text(
        notification.message,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: AppTypography.sizeBodySmall,
          height: 1.3,
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
