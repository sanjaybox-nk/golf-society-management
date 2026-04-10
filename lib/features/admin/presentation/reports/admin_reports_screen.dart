import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'reporting_hub_provider.dart';

enum ReportingTab { financials, competition, pulse }

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  ReportingTab _activeTab = ReportingTab.financials;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(reportingHubStatsProvider);
    final eventsAsync = ref.watch(adminEventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Society Hub',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
            isExpanded: true,
            tabs: const [
              ModernFilterTab(label: 'Financials', value: ReportingTab.financials),
              ModernFilterTab(label: 'Competition', value: ReportingTab.competition),
              ModernFilterTab(label: 'Pulse', value: ReportingTab.pulse),
            ],
            selectedValue: _activeTab,
            onTabSelected: (tab) => setState(() => _activeTab = tab),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel)),

        statsAsync.when(
          data: (stats) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                KeyedSubtree(
                  key: ValueKey(_activeTab),
                  child: _buildTabContent(context, stats, eventsAsync, membersAsync),
                ),
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
      case ReportingTab.financials:
        return _buildFinancialsTab(context, stats, eventsAsync);
      case ReportingTab.competition:
        return _buildCompetitionTab(context, stats, membersAsync, eventsAsync);
      case ReportingTab.pulse:
        return _buildPulseTab(context, stats, eventsAsync, membersAsync);
    }
  }

  Widget _buildFinancialsTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync) {
    if (stats.totalCount == 0 && stats.ledgerEntries.isEmpty && stats.startingBalance == 0) {
      return const Padding(
        padding: EdgeInsets.zero,
        child: BoxyArtEmptyCard(
          title: 'No Financial Activity',
          message: 'Society balances, revenue, and expenses will appear here once you start organizing events or recording transactions.',
          icon: Icons.account_balance_rounded,
        ),
      );
    }

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(
          title: 'Balance summary',
          isPeeking: true,
        ),
        _buildTreasuryOverview(context, stats),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Season budget',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: [
              _buildHubRow('Potential revenue', '£${(stats.totalPotentialRevenue + stats.totalUnpaidLedgerRevenue).toStringAsFixed(0)}', Icons.payments_outlined),
              const SizedBox(height: AppSpacing.atomic),
              _buildHubRow('Collected revenue', '£${(stats.totalRevenue + stats.totalLedgerRevenue).toStringAsFixed(0)}', Icons.check_circle_outline_rounded),
            ],
          ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Financial health',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: [
              _buildHubRow('Net margin', '£${stats.greenFeeMarkup.toStringAsFixed(0)}', Icons.trending_up_rounded),
              const SizedBox(height: AppSpacing.standard),
              _buildHubRow('Prize payouts', '£${stats.totalCashPrizes.toStringAsFixed(0)}', Icons.auto_awesome_rounded),
              if (stats.totalLedgerRevenue > 0) ...[
                const SizedBox(height: AppSpacing.standard),
                _buildHubRow('Ledger revenue', '£${stats.totalLedgerRevenue.toStringAsFixed(0)}', Icons.handshake_rounded),
              ],
              if (stats.totalVoucherValue > 0) ...[
                const SizedBox(height: AppSpacing.standard),
                _buildHubRow('Voucher liabilities', '£${stats.totalVoucherValue.toStringAsFixed(0)}', Icons.confirmation_number_outlined),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Revenue breakdown',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: stats.revenueBreakdown.entries.where((e) => e.value > 0).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
              child: _buildHubRow(e.key, '£${e.value.toStringAsFixed(0)}', 
                e.key == 'Golf' ? Icons.sports_golf_rounded : 
                e.key == 'Buggies' ? Icons.electric_rickshaw_rounded : 
                e.key == 'Catering' ? Icons.restaurant_rounded :
                e.key == 'Sponsorships' ? Icons.handshake_rounded :
                e.key == 'Donations' ? Icons.volunteer_activism_rounded :
                Icons.payments_outlined),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitionTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<Member>> membersAsync, AsyncValue<List<GolfEvent>> eventsAsync) {
    if (stats.totalCount == 0) {
      return const Padding(
        padding: EdgeInsets.zero,
        child: BoxyArtEmptyCard(
          title: 'No Competition Data',
          message: 'Leaderboards, prize payouts, and competitive analytics will sync here once your first event results are finalized.',
          icon: Icons.emoji_events_rounded,
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(
          title: 'Prize distribution',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: [
              _buildPrizeOverview(context, stats),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.standard),
                child: BoxyArtDivider(),
              ),
              _buildHubRow('Total cash payouts', '£${stats.totalCashPrizes.toStringAsFixed(0)}', Icons.payments_outlined),
              const SizedBox(height: AppSpacing.atomic),
              _buildHubRow('Payout ratio', '${((stats.totalRevenue == 0 ? 0 : stats.totalCashPrizes / stats.totalRevenue) * 100).toStringAsFixed(1)}%', Icons.analytics_outlined),
            ],
          ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Attendance leaderboard',
          isPeeking: true,
        ),
        BoxyArtCard(
          onTap: () => _showFullAttendanceModal(context, stats, membersAsync, isDark),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
          child: Column(
            children: stats.topMembers.take(3).mapIndexed((index, entry) {
              final isLast = index == stats.topMembers.take(3).length - 1;
              return _buildLeaderboardRow(index, entry, membersAsync, isDark, showDivider: !isLast);
            }).toList(),
          ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Competitive analytics',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: [
              if (stats.courseDifficultyIndex.entries.isNotEmpty) ...[ 
                _buildHubRow('Toughest course', '${stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).first.key} (${stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).first.value.toStringAsFixed(1)} pts)', Icons.terrain_rounded),
                const SizedBox(height: AppSpacing.atomic),
                _buildHubRow('Easiest course', '${stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).last.key} (${stats.courseDifficultyIndex.entries.sortedBy((e) => e.value).last.value.toStringAsFixed(1)} pts)', Icons.wb_sunny_rounded),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Podium consistency',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: stats.podiumConsistency.isEmpty 
            ? const BoxyArtEmptyCard(
                title: 'No Podium Records',
                message: 'Points and podium finishes will appear here once competition results are finalized.',
                icon: Icons.workspace_premium_outlined,
              )
            : Column(
                children: stats.podiumConsistency.take(3).mapIndexed((index, entry) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
                  final isLast = index == (stats.podiumConsistency.take(3).length - 1);
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.standard),
                    child: _buildHubRow(name, '${entry.value} top 3s', Icons.workspace_premium_outlined),
                  );
                }).toList(),
              ),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Award log',
          isPeeking: true,
        ),
        eventsAsync.when(
          data: (events) {
            final eventsWithPrizes = events
                .where((e) => e.awards.isNotEmpty)
                .sortedBy((e) => e.date)
                .reversed
                .toList();

            if (eventsWithPrizes.isEmpty) {
              return const BoxyArtEmptyCard(
                title: 'No Awards Logged',
                message: 'Your society trophy cabinet is currently empty.',
                icon: Icons.emoji_events_rounded,
              );
            }

            return BoxyArtCard(
              onTap: () => _showFullAwardsModal(context, eventsWithPrizes, isDark),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
              child: Column(
                children: eventsWithPrizes.take(3).mapIndexed((index, e) {
                  final isLast = index == (eventsWithPrizes.take(3).length - 1);
                  return _buildAwardRow(context, e, isDark, showDivider: !isLast, isDetailed: false);
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading awards: $err'),
        ),
      ],
    );
  }

  Widget _buildPulseTab(BuildContext context, ReportingHubStats stats, AsyncValue<List<GolfEvent>> eventsAsync, AsyncValue<List<Member>> membersAsync) {
    if (stats.totalCount == 0) {
      return const Padding(
        padding: EdgeInsets.zero,
        child: BoxyArtEmptyCard(
          title: 'Pulse Analytics Pending',
          message: 'Season progress, engagement trends, and member retention metrics will populate as you complete fixtures.',
          icon: Icons.analytics_rounded,
        ),
      );
    }
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeasonProgress(context, stats),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Next milestone',
          isPeeking: true,
        ),
        eventsAsync.when(
          data: (events) {
            final now = DateTime.now();
            final next = events.where((e) => e.date.isAfter(now) || DateUtils.isSameDay(e.date, now)).sortedBy((e) => e.date).firstOrNull;
            if (next == null) {
              return const BoxyArtEmptyCard(
                title: 'No Upcoming Events',
                message: 'Check back soon for the next fixture on the society calendar.',
                icon: Icons.calendar_today_rounded,
              );
            }
            return _buildNextEventCard(context, next);
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Retention & growth',
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Column(
            children: [
              _buildHubRow('RETENTION RATE', '${stats.retentionRate.toStringAsFixed(1)}%', Icons.loop_rounded),
              const SizedBox(height: AppSpacing.atomic),
              _buildHubRow('EVER-PRESENT MEMBERS', '${stats.everPresentMemberIds.length}', Icons.auto_awesome_rounded),
            ],
          ),
        ),
        if (stats.churnAlertMemberIds.isNotEmpty) ...[ 
          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          const BoxyArtSectionTitle(
            title: 'Churn alerts',
            isPeeking: true,
          ),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.standard),
            backgroundColor: AppColors.coral500.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.coral500.withValues(alpha: 0.4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BoxyArtIconBadge(
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.coral500,
                      isTinted: true,
                    ),
                    const SizedBox(width: AppSpacing.standard),
                    Text('Re-engagement required', 
                      style: AppTypography.micro.copyWith(
                        fontWeight: AppTypography.weightHeavy, 
                        color: AppColors.dark700,
                        letterSpacing: AppTypography.lsMicro,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.standard),
                ...stats.churnAlertMemberIds.take(3).map((id) {
                  final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == id);
                  final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${id.substring(0, 8)}...';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text('• $name has missed the last 2 events.', 
                      style: AppTypography.body.copyWith(
                        color: AppColors.dark700,
                        fontWeight: AppTypography.weightBold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Society engagement',
          isPeeking: true,
        ),
        _buildQuickStats(context, stats),
        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        const BoxyArtSectionTitle(
          title: 'Event archive',
          isPeeking: true,
        ),
        _buildEventArchive(context, eventsAsync),
      ],
    );
  }

  Widget _buildSeasonProgress(BuildContext context, ReportingHubStats stats) {
    final progress = stats.totalCount == 0 ? 0.0 : stats.completedCount / stats.totalCount;
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Season progress', 
                style: AppTypography.micro.copyWith(
                  color: AppColors.dark500,
                  letterSpacing: AppTypography.lsMicro,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%', 
                style: AppTypography.headline.copyWith(
                  color: AppColors.lime500,
                  fontWeight: AppTypography.weightHeavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          ClipRRect(
            borderRadius: AppShapes.xs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lime500.withValues(alpha: 0.15),
              color: AppColors.lime500,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.standard),
          Text(
            '${stats.completedCount} of ${stats.totalCount} events completed',
            style: AppTypography.micro.copyWith(
              color: AppColors.dark500,
              letterSpacing: AppTypography.lsMicro,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullAwardsModal(BuildContext context, List<GolfEvent> events, bool isDark) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Awards Roll Call',
      child: Column(
        children: events.mapIndexed((index, e) {
          final isLast = index == events.length - 1;
          return _buildAwardRow(context, e, isDark, showDivider: !isLast, isDetailed: true);
        }).toList(),
      ),
    );
  }

  Widget _buildNextEventCard(BuildContext context, GolfEvent event) {
    return BoxyArtCard(
      onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/event'),
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Row(
        children: [
          BoxyArtIconBadge(
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF0EA5E9), // Sky/teal brand color
            isTinted: true,
          ),
          const SizedBox(width: AppSpacing.standard),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title, 
                  style: AppTypography.body.copyWith(
                    fontWeight: AppTypography.weightHeavy,
                  ),
                ),
                Text(
                  DateFormat.yMMMMd().format(event.date), 
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTypography.weightRegular,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAwardRow(BuildContext context, GolfEvent event, bool isDark, {bool showDivider = true, bool isDetailed = false}) {
    // Group awards by position (1st, 2nd, 3rd)
    final firstPlace = event.awards.where((a) => a.label.contains('1st')).toList();
    final secondPlace = event.awards.where((a) => a.label.contains('2nd')).toList();
    final thirdPlace = event.awards.where((a) => a.label.contains('3rd')).toList();

    String formatAward(List<EventAward> awards) {
      if (awards.isEmpty) return 'No Winner';
      final winner = awards.first.winnerName ?? 'Member';
      final details = awards.map((a) {
        if (a.value > 0) return '£${a.value.toStringAsFixed(0)} ${a.type}';
        return a.type;
      }).join(', ');
      return '$winner ($details)';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.standard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title, 
                      style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(event.date), 
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark500,
                      letterSpacing: AppTypography.lsMicro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.atomic),
              if (!isDetailed)
                Text(
                  formatAward(firstPlace), 
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                    fontWeight: AppTypography.weightSemibold,
                  ),
                ),
              if (isDetailed) ...[
                _buildPodiumLine('1st', formatAward(firstPlace), isDark),
                if (secondPlace.isNotEmpty) _buildPodiumLine('2nd', formatAward(secondPlace), isDark),
                if (thirdPlace.isNotEmpty) _buildPodiumLine('3rd', formatAward(thirdPlace), isDark),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1, 
            color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
          ),
      ],
    );
  }

  Widget _buildPodiumLine(String pos, String detail, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(pos, style: AppTypography.micro.copyWith(
              color: pos == '1st' ? AppColors.amber500 : (isDark ? AppColors.dark400 : AppColors.dark500),
              fontWeight: AppTypography.weightHeavy,
            )),
          ),
          Expanded(
            child: Text(detail, style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.dark100 : AppColors.dark600,
              fontWeight: AppTypography.weightMedium,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuryOverview(BuildContext context, ReportingHubStats stats) {
    final isProfit = stats.netTreasury >= 0;
    
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                       'Balance', 
                       style: AppTypography.micro.copyWith(
                         color: AppColors.dark400,
                         letterSpacing: AppTypography.lsMicro,
                         fontWeight: AppTypography.weightStrong,
                       ),
                     ),
                    Text(
                      '£${stats.netTreasury.toStringAsFixed(2)}',
                      style: AppTypography.display.copyWith(
                        color: isProfit ? AppColors.lime500 : AppColors.coral500,
                        fontWeight: AppTypography.weightHeavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
               ),
               const SizedBox(width: AppSpacing.standard),
              BoxyArtIconBadge(
                icon: isProfit ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                color: isProfit ? AppColors.lime500 : AppColors.coral500,
                isTinted: true,
                size: 64,
                iconSize: AppShapes.iconLg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.standard),
          _buildHubRow('Opening balance', '£${stats.startingBalance.toStringAsFixed(0)}', Icons.input_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Session revenue', '£${stats.totalRevenue.toStringAsFixed(0)}', Icons.arrow_upward_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Sponsorships & donations', '£${stats.totalLedgerRevenue.toStringAsFixed(0)}', Icons.handshake_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Collected fines', '£${stats.totalCollectedFines.toStringAsFixed(0)}', Icons.gavel_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Charity collection', '£${stats.totalCharity.toStringAsFixed(0)}', Icons.favorite_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Event costs', '-£${stats.totalSocietyCosts.toStringAsFixed(0)}', Icons.arrow_downward_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Society expenses', '-£${stats.totalExpenses.toStringAsFixed(0)}', Icons.info_outline_rounded),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow('Cash payouts', '-£${stats.totalCashPrizes.toStringAsFixed(0)}', Icons.emoji_events_outlined),
          const SizedBox(height: AppSpacing.standard),
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.standard),
          _buildHubRow(
            'Yet to collect', 
            '£${(stats.uncollectedRevenue + stats.totalUnpaidFines + stats.totalUnpaidLedgerRevenue).toStringAsFixed(0)}', 
            Icons.hourglass_empty_rounded, 
          ),
          const SizedBox(height: AppSpacing.atomic),
          _buildHubRow(
            'Projected position', 
            '£${(stats.netTreasury + stats.uncollectedRevenue + stats.totalUnpaidFines + stats.totalUnpaidLedgerRevenue).toStringAsFixed(0)}', 
            Icons.account_balance_rounded, 
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ReportingHubStats stats) {
    return Row(
      children: [
        Expanded(
          child: _HubMetricSmall(
            label: 'Avg attendance',
            value: stats.averageAttendance.toStringAsFixed(1),
            icon: Icons.people_rounded,
            color: AppColors.lime500,
          ),
        ),
        const SizedBox(width: AppSpacing.standard),
        Expanded(
          child: _HubMetricSmall(
            label: 'Rounds played',
            value: stats.totalRoundsPlayed.toString(),
            icon: Icons.sports_golf_rounded,
            color: AppColors.amber500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrizeOverview(BuildContext context, ReportingHubStats stats) {
    return Column(
      children: [
        Row(
          children: [
            _PrizeBadge(value: stats.totalCupsAwarded.toString(), label: 'Cups', icon: Icons.emoji_events_rounded, color: AppColors.amber500),
            const SizedBox(width: AppSpacing.standard),
            _PrizeBadge(value: stats.totalVouchersAwarded.toString(), label: 'Vouchers', icon: Icons.confirmation_number_rounded, color: AppColors.lime500),
          ],
        ),
        const SizedBox(height: AppSpacing.standard),
        Row(
          children: [
            _PrizeBadge(value: stats.totalCashAwardsCount.toString(), label: 'Cash wins', icon: Icons.payments_rounded, color: AppColors.lime500),
            const SizedBox(width: AppSpacing.standard),
            _PrizeBadge(value: stats.totalUniqueWinners.toString(), label: 'Unique winners', icon: Icons.people_outline_rounded, color: AppColors.amber500),
          ],
        ),
      ],
    );
  }

  Widget _buildEventArchive(BuildContext context, AsyncValue<List<GolfEvent>> eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        final completed = events.where((e) => e.status == EventStatus.completed || e.results.isNotEmpty).sortedBy((e) => e.date).reversed.toList();
        
        if (completed.isEmpty) {
          return const BoxyArtEmptyCard(
            title: 'Empty Archive',
            message: 'Historical fixtures and finalized results will be archived here.',
            icon: Icons.history_rounded,
          );
        }

        return Column(
          children: completed.take(10).map((GolfEvent event) {
            final double eventProfit = (event.registrations.where((r) => r.hasPaid).fold(0.0, (sum, r) => sum + r.cost)) - 
                               (event.expenses.fold(0.0, (sum, e) => sum + e.amount)) - 
                               (event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value));

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.standard),
              child: BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.standard),
                child: InkWell(
                    onTap: () => context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/financials'),
                    child: Row(
                      children: [
                        BoxyArtIconBadge(
                          icon: Icons.history_rounded,
                          color: AppColors.lime500,
                          isTinted: true,
                        ),
                        const SizedBox(width: AppSpacing.standard),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title, 
                                style: AppTypography.body.copyWith(fontWeight: AppTypography.weightStrong),
                              ),
                              Text(
                                DateFormat.yMMMd().format(event.date), 
                                style: AppTypography.micro.copyWith(color: AppColors.dark500, letterSpacing: AppTypography.lsMicro),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.standard),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${eventProfit >= 0 ? '+' : ''}£${eventProfit.toStringAsFixed(0)}',
                              style: AppTypography.body.copyWith(
                                color: eventProfit >= 0 ? AppColors.lime500 : AppColors.coral500,
                                fontWeight: AppTypography.weightHeavy,
                              ),
                            ),
                            Text(
                              '${event.results.length} Plyrs', 
                              style: AppTypography.micro.copyWith(
                                color: AppColors.dark500,
                                fontWeight: AppTypography.weightHeavy,
                                letterSpacing: AppTypography.lsMicro,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.atomic),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.dark300, size: AppShapes.iconMd),
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

  void _showFullAttendanceModal(BuildContext context, ReportingHubStats stats, AsyncValue<List<Member>> membersAsync, bool isDark) {
    final allMembers = membersAsync.asData?.value ?? [];
    
    // Build a complete roll call list of all members, sorted by attendance
    final rollCall = allMembers.map((m) {
      final count = stats.attendanceMap[m.id] ?? 0;
      return MapEntry<String, int>(m.id, count);
    }).sortedBy<num>((e) => e.value).reversed.toList();

    BoxyArtBottomSheet.show(
      context: context,
      title: 'Member Roll Call',
      child: Column(
        children: rollCall.mapIndexed((index, entry) {
          final isLast = index == rollCall.length - 1;
          return _buildLeaderboardRow(index, entry, membersAsync, isDark, showDivider: !isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboardRow(int index, MapEntry<String, int> entry, AsyncValue<List<Member>> membersAsync, bool isDark, {bool showDivider = true}) {
    final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == entry.key);
    final name = member != null ? '${member.firstName} ${member.lastName}' : 'Member ID: ${entry.key.substring(0, 8)}...';
    final initials = member != null ? '${member.firstName.characters.take(1)}${member.lastName.characters.take(1)}' : '?';

    return Column(
      children: [
        BoxyArtMemberRow(
          name: name,
          initials: initials,
          avatarUrl: member?.avatarUrl,
          ranking: index + 1,
          useCard: false,
          showChevron: false,
          trailing: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Text(
              '${entry.value} events', 
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.dark200 : AppColors.dark500,
                fontWeight: AppTypography.weightSemibold,
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1, 
            color: isDark ? AppColors.dark500 : AppColors.lightBorder, 
            indent: 52, // Align with the start of the name (Avatar width 44 + Spacing)
          ),
      ],
    );
  }

  Widget _buildHubRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.standard),
        Expanded(
          child: Text(
            toSentenceCase(label), 
            style: AppTypography.body.copyWith(
              color: AppColors.dark600,
              fontWeight: AppTypography.weightStrong,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.standard),
        Text(
          value, 
          style: AppTypography.body.copyWith(
            fontWeight: AppTypography.weightHeavy,
            color: AppColors.dark900,
          ),
        ),
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
    const cyanBg = Color(0xFFE0F7FA);
    const cyanBorder = Color(0xFF26C6DA);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.standard),
        decoration: BoxDecoration(
          color: isDark ? cyanBorder.withValues(alpha: 0.15) : cyanBg,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: cyanBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(), 
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.dark200 : AppColors.dark950,
                fontWeight: AppTypography.weightExtraBold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value, 
              style: AppTypography.displaySmall.copyWith(
                fontWeight: AppTypography.weightHeavy,
                color: isDark ? AppColors.dark60 : AppColors.dark950,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrizeBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _PrizeBadge({
    required this.value, 
    required this.label, 
    required this.icon, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const cyanBg = Color(0xFFE0F7FA);
    const cyanBorder = Color(0xFF26C6DA);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.standard),
        decoration: BoxDecoration(
          color: isDark ? cyanBorder.withValues(alpha: 0.15) : cyanBg,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: cyanBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value, 
              style: AppTypography.displaySmall.copyWith(
                fontWeight: AppTypography.weightHeavy,
                color: isDark ? AppColors.dark60 : AppColors.dark950,
              ),
            ),
            Text(
              label.toUpperCase(), 
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.dark200 : AppColors.dark950,
                fontWeight: AppTypography.weightExtraBold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
