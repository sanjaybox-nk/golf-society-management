import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:collection/collection.dart';
import 'reporting_hub_provider.dart';

enum ReportingTab { overview, treasury, engagement, prizes }

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  ReportingTab _activeTab = ReportingTab.overview;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(reportingHubStatsProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final membersAsync = ref.watch(allMembersProvider);

    return HeadlessScaffold(
      title: 'Society Hub',
      subtitle: 'Operations & Insights',
      showBack: false,
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
          tooltip: 'App Home',
        ),
      ),
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.picture_as_pdf_outlined,
          onPressed: () {
            // Placeholder for PDF export
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing PDF Export...')));
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        BoxyArtGlassIconButton(
          icon: Icons.table_chart_outlined,
          onPressed: () {
            // Placeholder for CSV export
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating CSV Report...')));
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      slivers: [
        // 1. Tab Bar (Standard Position)
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<ReportingTab>(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            tabs: const [
              ModernFilterTab(label: 'OVERVIEW', value: ReportingTab.overview, icon: Icons.dashboard_outlined),
              ModernFilterTab(label: 'TREASURY', value: ReportingTab.treasury, icon: Icons.account_balance_outlined),
              ModernFilterTab(label: 'ENGAGEMENT', value: ReportingTab.engagement, icon: Icons.group_outlined),
              ModernFilterTab(label: 'PRIZES', value: ReportingTab.prizes, icon: Icons.emoji_events_outlined),
            ],
            selectedValue: _activeTab,
            onTabSelected: (tab) => setState(() => _activeTab = tab),
          ),
        ),

        statsAsync.when(
          data: (stats) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTabContent(context, stats, eventsAsync, membersAsync),
                const SizedBox(height: 100),
              ]),
            ),
          ),
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync, AsyncValue<List<Member>> membersAsync) {
    switch (_activeTab) {
      case ReportingTab.overview:
        return _buildOverviewTab(context, stats, eventsAsync);
      case ReportingTab.treasury:
        return _buildTreasuryTab(context, stats, eventsAsync);
      case ReportingTab.engagement:
        return _buildEngagementTab(context, stats, membersAsync);
      case ReportingTab.prizes:
        return _buildPrizesTab(context, stats, eventsAsync, membersAsync);
    }
  }

  Widget _buildOverviewTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeasonProgress(context, stats),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'SOCIETY PULSE'),
        _buildQuickStats(context, stats),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'NEXT MILESTONE'),
        eventsAsync.when(
          data: (events) {
            final now = DateTime.now();
            final next = events.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).sortedBy((e) => e.date).firstOrNull;
            if (next == null) return const Center(child: Text('No upcoming events', style: TextStyle(color: AppColors.textSecondary)));
            return _buildNextEventCard(context, next);
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'FINANCIAL SNAPSHOT'),
        _buildTreasuryOverview(context, stats),
      ],
    );
  }

  Widget _buildSeasonProgress(BuildContext context, ReportingHubStats stats) {
    final theme = Theme.of(context);
    final progress = stats.totalCount == 0 ? 0.0 : stats.completedCount / stats.totalCount;
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEASON PROGRESS', 
                style: AppTypography.label.copyWith(
                  fontSize: AppTypography.sizeLabel, 
                  color: theme.textTheme.bodySmall?.color, 
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%', 
                style: AppTypography.displayHero.copyWith(
                  fontSize: AppTypography.sizeBodySmall, 
                  color: AppColors.lime500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppShapes.xs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle),
              color: AppColors.lime500,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${stats.completedCount} of ${stats.totalCount} Events Completed',
            style: const TextStyle(fontSize: AppTypography.sizeLabelStrong, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNextEventCard(BuildContext context, GolfEvent event) {
    return BoxyArtCard(
      onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/event'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.lime500.withValues(alpha: AppColors.opacityLow), shape: BoxShape.circle),
            child: const Icon(Icons.event_available_rounded, color: AppColors.lime500, size: AppShapes.iconLg),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody)),
                Text(DateFormat.yMMMMd().format(event.date), style: const TextStyle(fontSize: AppTypography.sizeBodySmall, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildTreasuryTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'SEASON BUDGET'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildHubRow('Potential Revenue', '£${stats.totalPotentialRevenue.toStringAsFixed(0)}', Icons.payments_outlined, AppColors.textSecondary),
              const SizedBox(height: AppSpacing.md),
              _buildHubRow('Collected Revenue', '£${stats.totalRevenue.toStringAsFixed(0)}', Icons.check_circle_outline_rounded, AppColors.lime500),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'FINANCIAL HEALTH'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildHubRow('Society Margin', '£${stats.greenFeeMarkup.toStringAsFixed(0)}', Icons.trending_up_rounded, Colors.blueAccent),
              const SizedBox(height: AppSpacing.md),
              _buildHubRow('Avg. Member Spend', '£${stats.averageEventCostPerMember.toStringAsFixed(0)}', Icons.person_pin_circle_outlined, Colors.purpleAccent),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        
        if (stats.uncollectedRevenue > 0) ...[
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundColor: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
            border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityMedium)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.amber500, size: AppShapes.iconMd),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UNCOLLECTED REVENUE', style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeCaptionStrong, color: AppColors.amber500)),
                      Text('£${stats.uncollectedRevenue.toStringAsFixed(2)} is currently outstanding from confirmed registrations.', 
                        style: TextStyle(fontSize: AppTypography.sizeCaptionStrong, color: AppColors.amber500.withValues(alpha: AppColors.opacityHigh))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
        ],

        const BoxyArtSectionTitle(title: 'REVENUE BREAKDOWN'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: stats.revenueBreakdown.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildHubRow(e.key, '£${e.value.toStringAsFixed(0)}', 
                e.key == 'Golf' ? Icons.sports_golf_rounded : e.key == 'Buggies' ? Icons.electric_rickshaw_rounded : Icons.restaurant_rounded, 
                AppColors.textSecondary),
            )).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'EVENT ARCHIVE'),
        _buildEventArchive(context, eventsAsync),
      ],
    );
  }

  Widget _buildEngagementTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<Member>> membersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'RETENTION & GROWTH'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildHubRow('Retention Rate', '${stats.retentionRate.toStringAsFixed(1)}%', Icons.loop_rounded, AppColors.lime500),
              const SizedBox(height: AppSpacing.md),
              _buildHubRow('Ever-Present Members', '${stats.everPresentMemberIds.length}', Icons.auto_awesome_rounded, AppColors.amber500),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'ATTENDANCE LEADERBOARD'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: stats.topMembers.mapIndexed((index, entry) {
              final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
              final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.x2l,
                      height: AppSpacing.x2l,
                      decoration: BoxDecoration(
                        color: index == 0 ? AppColors.amber500.withValues(alpha: AppColors.opacityLow) : AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${index + 1}', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: index == 0 ? AppColors.amber500 : AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(name, style: const TextStyle(fontSize: AppTypography.sizeButton, fontWeight: AppTypography.weightSemibold))),
                    Text('${entry.value} Events', style: const TextStyle(fontSize: AppTypography.sizeBodySmall, fontWeight: AppTypography.weightBlack, color: AppColors.lime500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        if (stats.churnAlertMemberIds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.x3l),
          const BoxyArtSectionTitle(title: 'CHURN ALERTS'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            backgroundColor: AppColors.coral500.withValues(alpha: AppColors.opacitySubtle),
            border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityLow)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconMd),
                    SizedBox(width: AppSpacing.sm),
                    Text('RE-ENGAGEMENT REQUIRED', style: TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeCaptionStrong, color: AppColors.coral500)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ...stats.churnAlertMemberIds.take(3).map((id) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == id);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${id.substring(0, 8)}...';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text('• $name has missed the last 2 events.', style: const TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
                  );
                }),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'SOCIETY ENGAGEMENT'),
        _buildQuickStats(context, stats),
      ],
    );
  }

  Widget _buildPrizesTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync, AsyncValue<List<Member>> membersAsync) {
    final double cashRatio = stats.totalRevenue == 0 ? 0 : (stats.totalCashPrizes / stats.totalRevenue) * 100;

    // Phase 11.4 Data
    final toughest = stats.courseDifficultyIndex.entries.isEmpty 
        ? null 
        : stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).first;
    final easiest = stats.courseDifficultyIndex.entries.isEmpty 
        ? null 
        : stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'PRIZE DISTRIBUTION'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildPrizeOverview(context, stats),
              const Divider(height: AppSpacing.x4l),
              _buildHubRow('Total Cash Payouts', '£${stats.totalCashPrizes.toStringAsFixed(0)}', Icons.payments_outlined, Colors.blueAccent),
              const SizedBox(height: AppSpacing.md),
              _buildHubRow('Payout Ratio', '${cashRatio.toStringAsFixed(1)}% of Revenue', Icons.analytics_outlined, Colors.purpleAccent),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'COMPETITIVE ANALYTICS'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              if (toughest != null)
                _buildHubRow('Toughest Course', '${toughest.key} (${toughest.value.toStringAsFixed(1)} pts)', Icons.terrain_rounded, Colors.redAccent),
              if (easiest != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildHubRow('Easiest Course', '${easiest.key} (${easiest.value.toStringAsFixed(1)} pts)', Icons.wb_sunny_rounded, AppColors.lime500),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'PODIUM CONSISTENCY'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: stats.podiumConsistency.isEmpty 
            ? const Center(child: Text('No podium finishes recorded.', style: TextStyle(color: AppColors.textSecondary)))
            : Column(
                children: stats.podiumConsistency.take(3).mapIndexed((index, entry) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildHubRow(name, '${entry.value} Top 3s', Icons.workspace_premium_outlined, index == 0 ? AppColors.amber500 : AppColors.textSecondary),
                  );
                }).toList(),
              ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const BoxyArtSectionTitle(title: 'AWARD LOG'),
        eventsAsync.when(
          data: (events) {
            final eventsWithPrizes = events
                .where((e) => e.awards.isNotEmpty)
                .sortedBy((e) => e.date)
                .reversed
                .take(10)
                .toList();

            if (eventsWithPrizes.isEmpty) {
              return const Center(child: Text('No awards logged yet.', style: TextStyle(color: AppColors.textSecondary)));
            }

            return Column(
              children: eventsWithPrizes.map((e) => _buildEventAwardRow(context, e)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading awards: $err'),
        ),
      ],
    );
  }

  Widget _buildEventAwardRow(BuildContext context, GolfEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody)),
                Text(DateFormat.yMMMd().format(event.date), style: const TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
              ],
            ),
            const Divider(height: AppSpacing.x2l),
            ...event.awards.map((award) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    award.type == 'Cup' ? Icons.emoji_events_rounded : Icons.monetization_on_rounded,
                    size: AppShapes.iconXs,
                    color: award.type == 'Cup' ? AppColors.amber500 : Colors.blueAccent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(award.label, style: const TextStyle(fontSize: AppTypography.sizeButton, fontWeight: AppTypography.weightMedium)),
                  const Spacer(),
                  if (award.value > 0)
                    Text('£${award.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: AppTypography.sizeButton, fontWeight: AppTypography.weightBlack)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasuryOverview(BuildContext context, ReportingHubStats stats) {
    final isProfit = stats.netTreasury >= 0;
    
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOCIETY BALANCE', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBlack, color: AppColors.textSecondary, letterSpacing: 1.2)),
                  Text(
                    '£${stats.netTreasury.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: AppTypography.sizeDisplayMedium, 
                      fontWeight: AppTypography.weightBlack, 
                      color: isProfit ? AppColors.lime500 : Colors.redAccent,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: (isProfit ? AppColors.lime500 : Colors.redAccent).withValues(alpha: AppColors.opacityLow),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProfit ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                  color: isProfit ? AppColors.lime500 : Colors.redAccent,
                  size: AppShapes.iconLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),
          _buildHubRow('Total Revenue', '£${stats.totalRevenue.toStringAsFixed(2)}', Icons.arrow_upward_rounded, AppColors.lime500),
          const SizedBox(height: AppSpacing.md),
          _buildHubRow('Operating Costs', '-£${stats.totalExpenses.toStringAsFixed(2)}', Icons.arrow_downward_rounded, Colors.redAccent),
          const SizedBox(height: AppSpacing.md),
          _buildHubRow('Cash Payouts', '-£${stats.totalCashPrizes.toStringAsFixed(2)}', Icons.emoji_events_outlined, AppColors.amber500),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ReportingHubStats stats) {
    return Row(
      children: [
        Expanded(
          child: _HubMetricSmall(
            label: 'AVG ATTENDANCE',
            value: stats.averageAttendance.toStringAsFixed(1),
            icon: Icons.people_rounded,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _HubMetricSmall(
            label: 'ROUNDS PLAYED',
            value: stats.totalRoundsPlayed.toString(),
            icon: Icons.sports_golf_rounded,
            color: Colors.purpleAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeOverview(BuildContext context, ReportingHubStats stats) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          _PrizeCircle(count: stats.totalCupsAwarded, label: 'CUPS', icon: Icons.emoji_events_rounded, color: AppColors.amber500),
          const Spacer(),
          const VerticalDivider(),
          const Spacer(),
          _PrizeCircle(count: stats.totalVouchersAwarded, label: 'VOUCHERS', icon: Icons.confirmation_number_rounded, color: Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildEventArchive(BuildContext context, AsyncValue<List<GolfEvent>> eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        final completed = events.where((e) => e.status == EventStatus.completed || e.results.isNotEmpty).sortedBy((e) => e.date).reversed.toList();
        
        if (completed.isEmpty) {
          return const Center(child: Text('No completed events in archive', style: TextStyle(color: AppColors.textSecondary)));
        }

        return Column(
          children: completed.take(10).map((GolfEvent event) {
            final double eventProfit = (event.registrations.where((r) => r.hasPaid).fold(0.0, (sum, r) => sum + r.cost)) - 
                               (event.expenses.fold(0.0, (sum, e) => sum + e.amount)) - 
                               (event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value));

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: InkWell(
                  onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/financials'),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody)),
                          Text(DateFormat.yMMMd().format(event.date), style: const TextStyle(fontSize: AppTypography.sizeLabelStrong, color: AppColors.textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${eventProfit >= 0 ? '+' : ''}£${eventProfit.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: AppTypography.weightBlack, color: eventProfit >= 0 ? AppColors.lime500 : Colors.redAccent),
                          ),
                          Text('${event.results.length} PLYRS', style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppShapes.iconMd),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildHubRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconXs, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: const TextStyle(fontSize: AppTypography.sizeButton, color: AppColors.textSecondary, fontWeight: AppTypography.weightMedium)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: AppTypography.sizeBody, fontWeight: AppTypography.weightBlack)),
      ],
    );
  }
}

class _HubMetricSmall extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HubMetricSmall({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppShapes.iconMd, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: const TextStyle(fontSize: AppTypography.sizeDisplayHeading, fontWeight: AppTypography.weightBlack, letterSpacing: -1)),
          Text(label, style: const TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightBlack, color: AppColors.textSecondary, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _PrizeCircle extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _PrizeCircle({required this.count, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 3,
                color: color.withValues(alpha: AppColors.opacityLow),
              ),
            ),
            Icon(icon, color: color, size: AppShapes.iconLg),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(count.toString(), style: const TextStyle(fontSize: AppTypography.sizeLargeBody, fontWeight: AppTypography.weightBlack)),
        Text(label, style: const TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightBlack, color: AppColors.textSecondary, letterSpacing: 1.0)),
      ],
    );
  }
}
