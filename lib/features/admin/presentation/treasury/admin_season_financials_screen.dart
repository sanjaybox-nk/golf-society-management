import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _SeasonSummary {
  final double startingBalance;
  final double registrationRevenue;
  final double outstandingFees;
  final double operationalCosts;
  final double cashPrizes;
  final double sponsorshipIncome;
  final double charityPot;
  final List<_EventLine> eventLines;
  final String currencySymbol;

  double get netActual =>
      startingBalance + registrationRevenue + sponsorshipIncome + charityPot - operationalCosts - cashPrizes;

  double get netProjected => netActual + outstandingFees;

  const _SeasonSummary({
    required this.startingBalance,
    required this.registrationRevenue,
    required this.outstandingFees,
    required this.operationalCosts,
    required this.cashPrizes,
    required this.sponsorshipIncome,
    required this.charityPot,
    required this.eventLines,
    required this.currencySymbol,
  });
}

class _EventLine {
  final String name;
  final DateTime date;
  final double revenue;
  final double outstanding;
  final double costs;
  final double prizes;

  double get net => revenue - costs - prizes;
  double get projectedNet => net + outstanding;

  const _EventLine({
    required this.name,
    required this.date,
    required this.revenue,
    required this.outstanding,
    required this.costs,
    required this.prizes,
  });
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _seasonFinancialsProvider = Provider.autoDispose<AsyncValue<_SeasonSummary>>((ref) {
  final eventsAsync = ref.watch(adminEventsProvider);
  final config = ref.watch(themeControllerProvider);

  return eventsAsync.whenData((events) {
    final seasonEvents = events.where((e) => e.eventType != EventType.social).toList();

    double totalRevenue = 0;
    double totalOutstanding = 0;
    double totalCosts = 0;
    double totalPrizes = 0;
    double totalCharity = 0;
    final lines = <_EventLine>[];

    for (final event in seasonEvents) {
      final revenue = event.registrations.fold(0.0, (sum, r) => sum + (r.hasPaid ? r.cost : 0.0));
      final outstanding = event.registrations.fold(0.0, (sum, r) => sum + (!r.hasPaid ? r.cost : 0.0));
      final costs = event.expenses.fold(0.0, (sum, e) => sum + e.amount);
      final prizes = event.awards
          .where((a) => a.type == 'Cash')
          .fold(0.0, (sum, a) => sum + a.value);

      totalRevenue += revenue;
      totalOutstanding += outstanding;
      totalCosts += costs;
      totalPrizes += prizes;
      totalCharity += event.charityPot;

      lines.add(_EventLine(
        name: event.title,
        date: event.date,
        revenue: revenue,
        outstanding: outstanding,
        costs: costs,
        prizes: prizes,
      ));
    }

    final sponsorship = config.ledgerEntries.fold(0.0, (sum, e) => sum + (e.isPaid ? e.amount : 0.0));

    return _SeasonSummary(
      startingBalance: config.startingBalance,
      registrationRevenue: totalRevenue,
      outstandingFees: totalOutstanding,
      operationalCosts: totalCosts,
      cashPrizes: totalPrizes,
      sponsorshipIncome: sponsorship,
      charityPot: totalCharity,
      eventLines: lines..sort((a, b) => b.date.compareTo(a.date)),
      currencySymbol: config.currencySymbol,
    );
  });
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AdminSeasonFinancialsScreen extends ConsumerWidget {
  const AdminSeasonFinancialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(_seasonFinancialsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Season Financials',
      subtitle: 'Rolling P&L',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      slivers: [
        summaryAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: BoxyArtEmptyCard(
              title: 'Unable to load financials',
              message: e.toString(),
              icon: Icons.error_outline_rounded,
            ),
          ),
          data: (summary) => SliverPadding(
            padding: EdgeInsets.only(
              top: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _NetPositionCard(summary: summary),
                SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

                const BoxyArtSectionTitle(title: 'Event Breakdown', isPeeking: true),
                if (summary.eventLines.isEmpty)
                  const BoxyArtEmptyCard(
                    title: 'No events this season',
                    message: 'Financial data will appear once season events have been created.',
                    icon: Icons.calendar_today_rounded,
                  )
                else
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: summary.eventLines.asMap().entries.map((entry) {
                        final isLast = entry.key == summary.eventLines.length - 1;
                        return Column(
                          children: [
                            _EventFinancialRow(line: entry.value, symbol: summary.currencySymbol),
                            if (!isLast) const BoxyArtDivider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.x4l),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Net Position Card
// ---------------------------------------------------------------------------

class _NetPositionCard extends StatelessWidget {
  final _SeasonSummary summary;

  const _NetPositionCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final shadows = Theme.of(context).extension<AppShadows>();
    final s = summary.currencySymbol;
    final isActualPositive = summary.netActual >= 0;
    final isProjectedPositive = summary.netProjected >= 0;
    final actualColor = isActualPositive ? AppColors.lime500 : AppColors.coral500;
    final projectedColor = isProjectedPositive ? AppColors.lime500 : AppColors.coral500;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dark700 : AppColors.lightSurface,
        borderRadius: shapes?.card ?? BorderRadius.circular(18),
        boxShadow: shadows?.softScale,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dual net position row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actual',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.dark200 : AppColors.dark400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${isActualPositive ? '+' : ''}$s${summary.netActual.toStringAsFixed(2)}',
                      style: AppTypography.display.copyWith(
                        color: actualColor,
                        fontWeight: AppTypography.weightHeavy,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: (isDark ? AppColors.dark500 : AppColors.lightBorder),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.dark200 : AppColors.dark400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${isProjectedPositive ? '+' : ''}$s${summary.netProjected.toStringAsFixed(2)}',
                      style: AppTypography.display.copyWith(
                        color: projectedColor,
                        fontWeight: AppTypography.weightHeavy,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: projectedColor.withValues(alpha: AppColors.opacityLow),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isProjectedPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: projectedColor,
                  size: AppShapes.iconMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.md),
          if (summary.startingBalance != 0) ...[
            _SummaryRow(
              icon: Icons.account_balance_rounded,
              label: 'Opening Balance',
              value: '$s${summary.startingBalance.toStringAsFixed(2)}',
              color: isDark ? AppColors.dark150 : AppColors.dark600,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _SummaryRow(
            icon: Icons.receipt_outlined,
            label: 'Registration Revenue',
            value: '$s${summary.registrationRevenue.toStringAsFixed(2)}',
            color: isDark ? AppColors.dark150 : AppColors.dark600,
          ),
          if (summary.outstandingFees > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              icon: Icons.hourglass_top_rounded,
              label: 'Outstanding Fees',
              value: '$s${summary.outstandingFees.toStringAsFixed(2)}',
              color: AppColors.amber500,
            ),
          ],
          if (summary.sponsorshipIncome > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              icon: Icons.handshake_outlined,
              label: 'Sponsorship & Donations',
              value: '$s${summary.sponsorshipIncome.toStringAsFixed(2)}',
              color: isDark ? AppColors.dark150 : AppColors.dark600,
            ),
          ],
          if (summary.charityPot > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              icon: Icons.volunteer_activism_outlined,
              label: 'Charity Pot',
              value: '$s${summary.charityPot.toStringAsFixed(2)}',
              color: isDark ? AppColors.dark150 : AppColors.dark600,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            icon: Icons.receipt_long_outlined,
            label: 'Operational Costs',
            value: '-$s${summary.operationalCosts.toStringAsFixed(2)}',
            color: AppColors.coral400,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            icon: Icons.emoji_events_outlined,
            label: 'Cash Prizes',
            value: '-$s${summary.cashPrizes.toStringAsFixed(2)}',
            color: AppColors.coral400,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: AppShapes.iconSm, color: isDark ? AppColors.dark300 : AppColors.dark400),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.dark200 : AppColors.dark500,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.label.copyWith(
            color: color,
            fontWeight: AppTypography.weightBold,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Per-event row
// ---------------------------------------------------------------------------

class _EventFinancialRow extends StatelessWidget {
  final _EventLine line;
  final String symbol;

  const _EventFinancialRow({required this.line, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = line.net >= 0;
    final netColor = isPositive ? AppColors.lime500 : AppColors.coral500;
    final spacing = theme.extension<AppSpacingTokens>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: spacing?.cardVerticalPadding ?? AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: AppTypography.labelStrong.copyWith(
                    color: isDark ? AppColors.dark60 : AppColors.dark900,
                    fontWeight: AppTypography.weightSemibold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${line.date.day.toString().padLeft(2, '0')}/${line.date.month.toString().padLeft(2, '0')}/${line.date.year}  ·  $symbol${line.revenue.toStringAsFixed(0)} in  ·  $symbol${(line.costs + line.prizes).toStringAsFixed(0)} out',
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}$symbol${line.net.toStringAsFixed(2)}',
                style: AppTypography.label.copyWith(
                  color: netColor,
                  fontWeight: AppTypography.weightBold,
                ),
              ),
              if (line.outstanding > 0)
                Text(
                  '+$symbol${line.outstanding.toStringAsFixed(0)} owed',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.amber500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
