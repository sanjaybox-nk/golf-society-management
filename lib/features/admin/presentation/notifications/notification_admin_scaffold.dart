
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'notification_history_screen.dart';

class NotificationAdminScaffold extends StatefulWidget {
  const NotificationAdminScaffold({super.key});

  @override
  State<NotificationAdminScaffold> createState() => _NotificationAdminScaffoldState();
}

class _NotificationAdminScaffoldState extends State<NotificationAdminScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return DefaultTabController(
      length: 2,
      child: HeadlessScaffold(
        title: 'Communication Hub',
        subtitle: 'Broadcast history & dispatch logs',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        leading: Center(
          child: BoxyArtGlassIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go('/admin'),
            tooltip: 'Back to Dashboard',
          ),
        ),
        actions: [
          BoxyArtGlassIconButton(
            icon: Icons.add_rounded,
            onPressed: () => context.pushNamed('admin-notifications-compose'),
            tooltip: 'Compose New Broadcast',
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        slivers: [
          // 1. Safe Space before Tabs
          SliverToBoxAdapter(
            child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          ),

          // 2. Tab Bar Header (Pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              const ModernUnderlinedTabBar(
                tabLabels: ['Broadcast Feed', 'Scheduled'],
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
          ),

          // 3. Safe Space after Tabs 
          SliverToBoxAdapter(
            child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          ),

          // 4. Tab Content
          const SliverFillRemaining(
            child: TabBarView(
              children: [
                NotificationHistoryScreen(),
                _ScheduledNotificationsPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledNotificationsPlaceholder extends StatelessWidget {
  const _ScheduledNotificationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          BoxyArtEmptyCard(
            title: 'No Scheduled Dispatch',
            message: 'Drafts and upcoming automated communications will appear here once configured.',
            icon: Icons.schedule_send_rounded,
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
