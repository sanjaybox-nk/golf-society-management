import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/admin/presentation/audit_provider.dart';
import 'package:golf_society/domain/models/audit_activity.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/services/seeding_service.dart';
import 'widgets/dashboard_hero_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: HeadlessScaffold(
        title: 'Admin Console',
        titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: 'Command Center',
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xl),
            child: BoxyArtGlassIconButton(
              icon: Icons.home_rounded,
              onPressed: () => context.go('/home'),
              tooltip: 'Exit to App',
            ),
          ),
        ),
        actions: [
          BoxyArtGlassIconButton(
            icon: Icons.settings_rounded,
            onPressed: () => context.push('/admin/settings'),
            tooltip: 'System Settings',
          ),
        ],
        slivers: [
          // 1. Tab Bar Header (Pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              const ModernUnderlinedTabBar(
                tabLabels: ['Overview', 'Operations'],
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
          ),

          // 2. Tab-switched Content
          const _TabSwitchedSliver(),
        ],
      ),
    );
  }
}

class _TabSwitchedSliver extends StatefulWidget {
  const _TabSwitchedSliver();

  @override
  State<_TabSwitchedSliver> createState() => _TabSwitchedSliverState();
}

class _TabSwitchedSliverState extends State<_TabSwitchedSliver> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = DefaultTabController.maybeOf(context);
    if (newController != _controller) {
      _controller?.removeListener(_handleTick);
      _controller = newController;
      _controller?.addListener(_handleTick);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTick);
    super.dispose();
  }

  void _handleTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return _controller!.index == 0
        ? const _OverviewSlivers()
        : const _OperationsSlivers();
  }
}

class _OverviewSlivers extends ConsumerWidget {
  const _OverviewSlivers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.sm),
          // 1. Next Event Hero
          eventsAsync.when(
            data: (events) {
              final now = DateTime.now();
              final nextEvent = events
                  .where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now))
                  .sortedBy((e) => e.date)
                  .firstOrNull;
              
              if (nextEvent != null) {
                return DashboardHeroCard(
                  event: nextEvent,
                  onTap: () => context.goNamed(
                    'admin-event-manage-tower',
                    pathParameters: {'id': nextEvent.id},
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => BoxyArtCard(child: Center(child: Text('Error: $e'))),
          ),

          const BoxyArtSectionTitle(title: 'Recent Activity'),
          const _ActivityFeed(),
        ]),
      ),
    );
  }
}

class _OperationsSlivers extends ConsumerWidget {
  const _OperationsSlivers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.sm),
          const BoxyArtSectionTitle(title: 'Daily Operations'),
          BoxyArtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BoxyArtNavTile(
                  icon: Icons.handshake_outlined,
                  title: 'Sponsorships & Donations',
                  subtitle: 'Manage partners, supporters & revenue',
                  iconColor: theme.primaryColor,
                  onTap: () => context.pushNamed('admin-sponsorship-hub'),
                ),
                const BoxyArtDivider(),
                BoxyArtNavTile(
                  icon: Icons.autorenew_rounded,
                  title: 'Member Renewals',
                  subtitle: 'Track season rollover & payments',
                  iconColor: theme.primaryColor,
                  onTap: () => context.pushNamed('admin-member-renewal'),
                ),
                const BoxyArtDivider(),
                BoxyArtNavTile(
                  icon: Icons.quiz_outlined,
                  title: 'Society Surveys',
                  subtitle: 'Draft and publish polls',
                  iconColor: theme.primaryColor,
                  onTap: () => context.pushNamed('admin-surveys'),
                ),
                const BoxyArtDivider(),
                BoxyArtNavTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Debt Ledger',
                  subtitle: 'Financial oversight & balances',
                  iconColor: theme.primaryColor,
                  onTap: () => context.pushNamed('admin-debt-ledger'),
                ),
                const BoxyArtDivider(),
                BoxyArtNavTile(
                  icon: Icons.analytics_outlined,
                  title: 'Reports & Insights',
                  subtitle: 'Financials, engagement & trends',
                  iconColor: theme.primaryColor,
                  onTap: () => context.goNamed('admin-reports'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          const BoxyArtSectionTitle(title: 'COMMUNICATIONS'),
          BoxyArtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BoxyArtNavTile(
                  icon: Icons.send_rounded,
                  title: 'Broadcast Center',
                  subtitle: 'Send alerts to all members',
                  iconColor: theme.primaryColor,
                  onTap: () => context.push('/admin/notifications/compose'),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(auditActivitiesProvider(10));
    final theme = Theme.of(context);

    return auditAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const BoxyArtCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: Text('No recent activity recorded.')),
            ),
          );
        }

        return BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: activities.mapIndexed((index, activity) {
              final isLast = index == activities.length - 1;
              final (icon, color) = AuditActivity.getAppearance(activity.type);
              
              return Column(
                children: [
                  ListTile(
                    leading: BoxyArtIconBadge(
                      icon: icon,
                      color: color,
                      showFill: false,
                    ),
                    title: Text(
                      activity.message,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: AppTypography.weightSemibold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      '${activity.userName ?? 'System'} • ${timeago.format(activity.timestamp)}',
                      style: AppTypography.label.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                  if (!isLast) const BoxyArtDivider(),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => Text('Error loading activity: $e'),
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
