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
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.picture_as_pdf_outlined,
          onPressed: () {
            // Placeholder for PDF export
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing PDF Export...')));
          },
        ),
        const SizedBox(width: 8),
        BoxyArtGlassIconButton(
          icon: Icons.table_chart_outlined,
          onPressed: () {
            // Placeholder for CSV export
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating CSV Report...')));
          },
        ),
        const SizedBox(width: 8),
      ],
      slivers: [
        // 1. Tab Bar (Standard Position)
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<ReportingTab>(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'SOCIETY PULSE'),
        _buildQuickStats(context, stats),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'NEXT MILESTONE'),
        eventsAsync.when(
          data: (events) {
            final now = DateTime.now();
            final next = events.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).sortedBy((e) => e.date).firstOrNull;
            if (next == null) return const Center(child: Text('No upcoming events', style: TextStyle(color: Colors.grey)));
            return _buildNextEventCard(context, next);
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'FINANCIAL SNAPSHOT'),
        _buildTreasuryOverview(context, stats),
      ],
    );
  }

  Widget _buildSeasonProgress(BuildContext context, ReportingHubStats stats) {
    final theme = Theme.of(context);
    final progress = stats.totalCount == 0 ? 0.0 : stats.completedCount / stats.totalCount;
    return BoxyArtCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEASON PROGRESS', 
                style: AppTypography.label.copyWith(
                  fontSize: 12, 
                  color: theme.textTheme.bodySmall?.color, 
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%', 
                style: AppTypography.displayHero.copyWith(
                  fontSize: 14, 
                  color: AppColors.lime500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: AppColors.lime500,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.completedCount} of ${stats.totalCount} Events Completed',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNextEventCard(BuildContext context, GolfEvent event) {
    return BoxyArtCard(
      onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/event'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.lime500.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.event_available_rounded, color: AppColors.lime500, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(DateFormat.yMMMMd().format(event.date), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHubRow('Potential Revenue', '£${stats.totalPotentialRevenue.toStringAsFixed(0)}', Icons.payments_outlined, Colors.grey),
              const SizedBox(height: 12),
              _buildHubRow('Collected Revenue', '£${stats.totalRevenue.toStringAsFixed(0)}', Icons.check_circle_outline_rounded, AppColors.lime500),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'FINANCIAL HEALTH'),
        BoxyArtCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHubRow('Society Margin', '£${stats.greenFeeMarkup.toStringAsFixed(0)}', Icons.trending_up_rounded, Colors.blueAccent),
              const SizedBox(height: 12),
              _buildHubRow('Avg. Member Spend', '£${stats.averageEventCostPerMember.toStringAsFixed(0)}', Icons.person_pin_circle_outlined, Colors.purpleAccent),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        if (stats.uncollectedRevenue > 0) ...[
          BoxyArtCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.amber.withValues(alpha: 0.1),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UNCOLLECTED REVENUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber)),
                      Text('£${stats.uncollectedRevenue.toStringAsFixed(2)} is currently outstanding from confirmed registrations.', 
                        style: TextStyle(fontSize: 11, color: Colors.amber.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        const BoxyArtSectionTitle(title: 'REVENUE BREAKDOWN'),
        BoxyArtCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: stats.revenueBreakdown.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildHubRow(e.key, '£${e.value.toStringAsFixed(0)}', 
                e.key == 'Golf' ? Icons.sports_golf_rounded : e.key == 'Buggies' ? Icons.electric_rickshaw_rounded : Icons.restaurant_rounded, 
                Colors.grey),
            )).toList(),
          ),
        ),
        const SizedBox(height: 32),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHubRow('Retention Rate', '${stats.retentionRate.toStringAsFixed(1)}%', Icons.loop_rounded, AppColors.lime500),
              const SizedBox(height: 12),
              _buildHubRow('Ever-Present Members', '${stats.everPresentMemberIds.length}', Icons.auto_awesome_rounded, Colors.amber),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'ATTENDANCE LEADERBOARD'),
        BoxyArtCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: stats.topMembers.mapIndexed((index, entry) {
              final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
              final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.amber.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${index + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: index == 0 ? Colors.amber : Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                    Text('${entry.value} Events', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.lime500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        if (stats.churnAlertMemberIds.isNotEmpty) ...[
          const SizedBox(height: 32),
          const BoxyArtSectionTitle(title: 'CHURN ALERTS'),
          BoxyArtCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.red.withValues(alpha: 0.05),
            border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('RE-ENGAGEMENT REQUIRED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
                ...stats.churnAlertMemberIds.take(3).map((id) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == id);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${id.substring(0, 8)}...';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $name has missed the last 2 events.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                }),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPrizeOverview(context, stats),
              const Divider(height: 40),
              _buildHubRow('Total Cash Payouts', '£${stats.totalCashPrizes.toStringAsFixed(0)}', Icons.payments_outlined, Colors.blueAccent),
              const SizedBox(height: 12),
              _buildHubRow('Payout Ratio', '${cashRatio.toStringAsFixed(1)}% of Revenue', Icons.analytics_outlined, Colors.purpleAccent),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'COMPETITIVE ANALYTICS'),
        BoxyArtCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (toughest != null)
                _buildHubRow('Toughest Course', '${toughest.key} (${toughest.value.toStringAsFixed(1)} pts)', Icons.terrain_rounded, Colors.redAccent),
              if (easiest != null) ...[
                const SizedBox(height: 12),
                _buildHubRow('Easiest Course', '${easiest.key} (${easiest.value.toStringAsFixed(1)} pts)', Icons.wb_sunny_rounded, AppColors.lime500),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
        const BoxyArtSectionTitle(title: 'PODIUM CONSISTENCY'),
        BoxyArtCard(
          padding: const EdgeInsets.all(20),
          child: stats.podiumConsistency.isEmpty 
            ? const Center(child: Text('No podium finishes recorded.', style: TextStyle(color: Colors.grey)))
            : Column(
                children: stats.podiumConsistency.take(3).mapIndexed((index, entry) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildHubRow(name, '${entry.value} Top 3s', Icons.workspace_premium_outlined, index == 0 ? Colors.amber : Colors.grey),
                  );
                }).toList(),
              ),
        ),
        const SizedBox(height: 32),
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
              return const Center(child: Text('No awards logged yet.', style: TextStyle(color: Colors.grey)));
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
      padding: const EdgeInsets.only(bottom: 12),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(DateFormat.yMMMd().format(event.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Divider(height: 24),
            ...event.awards.map((award) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    award.type == 'Cup' ? Icons.emoji_events_rounded : Icons.monetization_on_rounded,
                    size: 14,
                    color: award.type == 'Cup' ? Colors.amber : Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(award.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (award.value > 0)
                    Text('£${award.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOCIETY BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                  Text(
                    '£${stats.netTreasury.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
                      color: isProfit ? AppColors.lime500 : Colors.redAccent,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isProfit ? AppColors.lime500 : Colors.redAccent).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProfit ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                  color: isProfit ? AppColors.lime500 : Colors.redAccent,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          _buildHubRow('Total Revenue', '£${stats.totalRevenue.toStringAsFixed(2)}', Icons.arrow_upward_rounded, AppColors.lime500),
          const SizedBox(height: 12),
          _buildHubRow('Operating Costs', '-£${stats.totalExpenses.toStringAsFixed(2)}', Icons.arrow_downward_rounded, Colors.redAccent),
          const SizedBox(height: 12),
          _buildHubRow('Cash Payouts', '-£${stats.totalCashPrizes.toStringAsFixed(2)}', Icons.emoji_events_outlined, Colors.orange),
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
        const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _PrizeCircle(count: stats.totalCupsAwarded, label: 'CUPS', icon: Icons.emoji_events_rounded, color: Colors.amber),
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
          return const Center(child: Text('No completed events in archive', style: TextStyle(color: Colors.grey)));
        }

        return Column(
          children: completed.take(10).map((GolfEvent event) {
            final double eventProfit = (event.registrations.where((r) => r.hasPaid).fold(0.0, (sum, r) => sum + r.cost)) - 
                               (event.expenses.fold(0.0, (sum, e) => sum + e.amount)) - 
                               (event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value));

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BoxyArtCard(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/financials'),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Text(DateFormat.yMMMd().format(event.date), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${eventProfit >= 0 ? '+' : ''}£${eventProfit.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.w900, color: eventProfit >= 0 ? AppColors.lime500 : Colors.redAccent),
                          ),
                          Text('${event.results.length} PLYRS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.8)),
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
                color: color.withValues(alpha: 0.1),
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 12),
        Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
      ],
    );
  }
}
