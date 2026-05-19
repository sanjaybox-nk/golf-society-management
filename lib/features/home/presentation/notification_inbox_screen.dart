import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'home_providers.dart';
import 'widgets/home_notification_card.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(homeNotificationsProvider);

    return HeadlessScaffold(
      title: 'Notifications',
      showMenu: false,
      showBack: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 100),
          sliver: notificationsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: true),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'Inbox Unavailable',
                message: err.toString(),
                icon: Icons.error_outline_rounded,
              ),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BoxyArtIconBadge(
                        icon: Icons.notifications_none_rounded,
                        color: AppColors.dark500,
                        isTinted: true,
                        size: 64,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No notifications',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.dark400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notification = notifications[index];
                    return HomeNotificationCard(
                      notification: notification,
                      onDismissed: (_) => ref
                          .read(notificationsRepositoryProvider)
                          .deleteNotification(notification.id),
                    );
                  },
                  childCount: notifications.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
