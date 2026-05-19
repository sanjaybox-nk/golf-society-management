import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/admin/presentation/audit_provider.dart';
import 'package:golf_society/domain/models/audit_activity.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/admin/presentation/treasury/controllers/debt_ledger_controller.dart';
import 'package:golf_society/features/admin/presentation/reports/reporting_hub_provider.dart';
import 'widgets/dashboard_hero_card.dart';

// ---------------------------------------------------------------------------
// Dashboard summary model + provider
// ---------------------------------------------------------------------------

class _DashboardSummary {
  final int activeMembers;
  final int rosterCount;       // active + pending + suspended + grace + expired (excludes archived/left)
  final int completedEvents;
  final int upcomingEvents;
  final int inPlayEvents;
  final double netTreasury;
  final double outstandingFees;
  final int membersWithDebt;
  final int renewalAlerts;
  final String currencySymbol;

  const _DashboardSummary({
    required this.activeMembers,
    required this.rosterCount,
    required this.completedEvents,
    required this.upcomingEvents,
    required this.inPlayEvents,
    required this.netTreasury,
    required this.outstandingFees,
    required this.membersWithDebt,
    required this.renewalAlerts,
    required this.currencySymbol,
  });
}

final _dashboardSummaryProvider = Provider.autoDispose<AsyncValue<_DashboardSummary>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);
  final membersAsync = ref.watch(allMembersProvider);
  final statsAsync = ref.watch(reportingHubStatsProvider);
  final debtList = ref.watch(debtSummariesProvider(''));
  final config = ref.watch(themeControllerProvider);

  if (eventsAsync.isLoading || membersAsync.isLoading || statsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (eventsAsync.hasError) return AsyncValue.error(eventsAsync.error!, eventsAsync.stackTrace!);
  if (membersAsync.hasError) return AsyncValue.error(membersAsync.error!, membersAsync.stackTrace!);

  final events = eventsAsync.value ?? [];
  final members = membersAsync.value ?? [];
  final stats = statsAsync.value;
  final now = DateTime.now();

  final activeMembers = members.where((m) =>
    m.status == MemberStatus.active || m.status == MemberStatus.member,
  ).length;

  // Roster = everyone except historical records (archived / left)
  final rosterCount = members.where((m) =>
    m.status != MemberStatus.archived && m.status != MemberStatus.left,
  ).length;

  final renewalAlerts = members.where((m) =>
    m.status == MemberStatus.gracePeriod || m.status == MemberStatus.expired,
  ).length;

  final upcomingEvents = events.where((e) =>
    e.status == EventStatus.published && e.date.isAfter(now),
  ).length;

  final inPlayEvents = events.where((e) => e.status == EventStatus.inPlay).length;

  final debtMembers = debtList.where((d) => d.totalDebt > 0).toList();
  final totalOwed = debtMembers.fold(0.0, (sum, d) => sum + d.totalDebt);

  return AsyncValue.data(_DashboardSummary(
    activeMembers: activeMembers,
    rosterCount: rosterCount,
    completedEvents: stats?.completedCount ?? 0,
    upcomingEvents: upcomingEvents,
    inPlayEvents: inPlayEvents,
    netTreasury: stats?.netTreasury ?? 0,
    outstandingFees: totalOwed,
    membersWithDebt: debtMembers.length,
    renewalAlerts: renewalAlerts,
    currencySymbol: config.currencySymbol,
  ));
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);
    final summaryAsync = ref.watch(_dashboardSummaryProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Dashboard',
      subtitle: 'Command Center',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
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
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.lg,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // 1. Pulse KPI row
              summaryAsync.when(
                loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
                data: (s) => _PulseRow(summary: s),
              ),

              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // 2. Action alerts
              summaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (s) => _ActionAlerts(summary: s),
              ),

              // 3. Next event hero
              eventsAsync.when(
                data: (events) {
                  final now = DateTime.now();
                  final nextEvent = events
                      .where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now))
                      .sortedBy((e) => e.date)
                      .firstOrNull;
                  if (nextEvent == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                      DashboardHeroCard(
                        event: nextEvent,
                        onTap: () => context.goNamed(
                          'admin-event-manage-tower',
                          pathParameters: {'id': nextEvent.id},
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => const SizedBox.shrink(),
              ),

              // 4. Recent activity
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
              const BoxyArtSectionTitle(title: 'Recent Activity', isPeeking: true),
              const _ActivityFeed(),

              SizedBox(height: AppSpacing.pageBottom),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pulse KPI row
// ---------------------------------------------------------------------------

class _PulseRow extends StatelessWidget {
  final _DashboardSummary summary;
  const _PulseRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        BoxyArtStatCard(
          label: 'Members',
          value: '${summary.activeMembers}',
          sub: 'of ${summary.rosterCount} roster',
          icon: Icons.people_rounded,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        BoxyArtStatCard(
          label: 'Season Events',
          value: '${summary.completedEvents}',
          sub: '${summary.upcomingEvents} upcoming',
          icon: Icons.calendar_today_rounded,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        BoxyArtStatCard(
          label: 'Treasury',
          value: summary.netTreasury >= 0
              ? '${summary.currencySymbol}${summary.netTreasury.toStringAsFixed(0)}'
              : '-${summary.currencySymbol}${summary.netTreasury.abs().toStringAsFixed(0)}',
          sub: summary.netTreasury >= 0 ? 'net position' : 'in deficit',
          icon: Icons.account_balance_rounded,
          color: summary.netTreasury >= 0 ? AppColors.lime500 : AppColors.coral500,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action alerts
// ---------------------------------------------------------------------------

class _ActionAlerts extends ConsumerWidget {
  final _DashboardSummary summary;
  const _ActionAlerts({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    final alerts = <Widget>[];

    if (summary.inPlayEvents > 0) {
      alerts.add(BoxyArtStatusBanner(
        icon: Icons.sports_golf_rounded,
        color: AppColors.lime500,
        message: '${summary.inPlayEvents} event${summary.inPlayEvents > 1 ? 's' : ''} in play',
        subtitle: 'Scoring is live — monitor progress',
        hasBottomMargin: false,
        onTap: () => context.goNamed('admin-events'),
      ));
    }

    if (summary.outstandingFees > 0) {
      alerts.add(BoxyArtStatusBanner(
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.coral500,
        message: '${summary.currencySymbol}${summary.outstandingFees.toStringAsFixed(2)} due',
        subtitle: '${summary.membersWithDebt} member${summary.membersWithDebt > 1 ? 's' : ''} with unpaid fees',
        hasBottomMargin: false,
        onTap: () => context.pushNamed('admin-debt-ledger'),
      ));
    }

    if (summary.renewalAlerts > 0) {
      alerts.add(BoxyArtStatusBanner(
        icon: Icons.autorenew_rounded,
        color: AppColors.coral500,
        message: '${summary.renewalAlerts} member${summary.renewalAlerts > 1 ? 's' : ''} need renewal',
        subtitle: 'Grace period or expired — action required',
        hasBottomMargin: false,
        onTap: () => context.pushNamed('admin-member-renewal'),
      ));
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts
          .expandIndexed((i, w) => [
                w,
                if (i < alerts.length - 1)
                  SizedBox(height: spacing?.cardToCard ?? AppSpacing.atomic),
              ])
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity feed
// ---------------------------------------------------------------------------

class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(auditActivitiesProvider(10));
    final theme = Theme.of(context);

    return auditAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const BoxyArtEmptyCard(
            title: 'No Recent Activity',
            message: 'Your society command center is calm. Administrative actions and system updates will appear here.',
            icon: Icons.bolt_rounded,
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
                      iconColor: color,
                      showFill: true,
                      size: 40,
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
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text('Error loading activity: $e'),
    );
  }
}
