import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../admin/providers/admin_ui_providers.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import '../../../events/logic/event_analysis_engine.dart';

class EventAdminManageScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventAdminManageScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventAdminManageScreen> createState() => _EventAdminManageScreenState();
}

class _EventAdminManageScreenState extends ConsumerState<EventAdminManageScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: 'Event Controls',
          subtitle: event.title,
          topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
          showBack: true,
          onBack: () => context.goNamed('admin-events'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: BoxyArtTabBar<int>(
                  selectedValue: _selectedTab,
                  onTabSelected: (val) => setState(() => _selectedTab = val),
                  tabs: const [
                    ModernFilterTab(label: 'Financials', value: 0),
                    ModernFilterTab(label: 'Controls', value: 1),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: spacing?.tabToContent ?? AppSpacing.tabToContent),
            ),
            if (_selectedTab == 0)
              SliverToBoxAdapter(
                child: _FinancialsBody(eventId: widget.eventId),
              )
            else
              SliverToBoxAdapter(
                child: _ControlsBody(eventId: widget.eventId),
              ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Event Controls',
        slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (e, s) => HeadlessScaffold(
        title: 'Error',
        slivers: [SliverFillRemaining(child: Center(child: Text('Error: $e')))],
      ),
    );
  }
}

// ── Financials tab body ────────────────────────────────────────────────────────

class _FinancialsBody extends ConsumerWidget {
  final String eventId;

  const _FinancialsBody({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final config = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        final eventLedgerEntries = config.ledgerEntries
            .where((e) => e.eventId == event.id)
            .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FinancialPnLCard(event: event, eventLedgerEntries: eventLedgerEntries),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
              _buildAddExpenseButton(context, ref, event),
              const SizedBox(height: AppSpacing.hero),
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      )),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }




  void _showLedgerExpenseDialog(BuildContext context, WidgetRef ref, GolfEvent? event, {FinancialEntry? entry}) {
    final labelController = TextEditingController(text: entry?.source);
    final amountController = TextEditingController(text: entry?.amount != null ? entry!.amount.toString() : '');
    String category = entry?.scope ?? 'Misc';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => BoxyArtDialog(
          title: entry == null ? 'Add Expense' : 'Edit Expense',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtFormField(label: 'Description', controller: labelController),
              const SizedBox(height: AppSpacing.lg),
              BoxyArtFormField(label: 'Amount (£)', controller: amountController, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.lg),
              _buildCategorySelector(category, (val) => setDialogState(() => category = val)),
            ],
          ),
          onConfirm: () async {
            final amount = double.tryParse(amountController.text) ?? 0.0;
            if (labelController.text.isNotEmpty && amount > 0) {
              final newEntry = FinancialEntry(
                id: entry?.id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
                type: 'Expenditure',
                source: labelController.text,
                amount: amount,
                date: DateTime.now(),
                scope: category,
                eventId: entry?.eventId ?? event?.id,
              );
              if (entry != null) {
                await ref.read(themeControllerProvider.notifier).updateLedgerEntry(newEntry);
              } else {
                await ref.read(themeControllerProvider.notifier).addLedgerEntry(newEntry);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
      ),
    );
  }


  Widget _buildAddExpenseButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(title: 'Add Expense', icon: Icons.add_rounded, isTinted: true, isPrimary: false, onTap: () => _showLedgerExpenseDialog(context, ref, event), fullWidth: true);
  }

  Widget _buildCategorySelector(String current, ValueChanged<String> onChanged) {
    final categories = ['Venue', 'Food', 'Prize', 'Misc'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.atomic,
          children: categories.map((cat) => ChoiceChip(
            label: Text(cat),
            selected: current == cat,
            onSelected: (selected) => selected ? onChanged(cat) : null,
          )).toList(),
        ),
      ],
    );
  }

}

// ── Financial P&L ─────────────────────────────────────────────────────────────

class _FinancialPnLCard extends StatelessWidget {
  final GolfEvent event;
  final List<FinancialEntry> eventLedgerEntries;

  const _FinancialPnLCard({required this.event, required this.eventLedgerEntries});

  @override
  Widget build(BuildContext context) {
    // Split ledger entries by type
    final sponsorEntries = eventLedgerEntries.where((e) => e.type == 'Sponsorship' && e.isPaid).toList();
    final donationEntries = eventLedgerEntries.where((e) => e.type == 'Donation' && e.isPaid).toList();
    final ledgerExpenditureEntries = eventLedgerEntries.where((e) => e.type == 'Expenditure').toList();

    // Income
    final paidRegs = event.registrations.where((r) => r.hasPaid && r.cost > 0).toList();
    final paidCount = paidRegs.length;
    // Extra costs are baked into r.cost — back them out to show as separate line items
    final extraCostTotal = event.extraCosts.fold(0.0, (s, e) => s + e.amount) * paidCount;
    final baseRegRevenue = paidRegs.fold(0.0, (s, r) => s + r.cost) - extraCostTotal;
    final regRevenue = baseRegRevenue + extraCostTotal; // total unchanged
    final sponsorTotal = sponsorEntries.fold(0.0, (s, e) => s + e.amount);
    final donationTotal = donationEntries.fold(0.0, (s, e) => s + e.amount);
    final finesTotal = event.registrations.expand((r) => r.fines).fold(0.0, (s, f) => s + f.amount);
    final totalIncome = regRevenue + sponsorTotal + donationTotal + finesTotal;

    // Society-side costs per service
    final paidGolferCount = paidRegs.length;
    final breakfastCount = event.registrations.where((r) => r.attendingBreakfast).length;
    final lunchCount = event.registrations.where((r) => r.attendingLunch).length;
    final dinnerCount = event.registrations.where((r) => r.attendingDinner).length;
    final buggyCount = event.registrations.where((r) => r.needsBuggy).length;

    final greenFeeCost = (event.societyGreenFee ?? 0) * paidGolferCount;
    final societyBreakfastCost = (event.societyBreakfastCost ?? 0) * breakfastCount;
    final societyLunchCost = (event.societyLunchCost ?? 0) * lunchCount;
    final societyDinnerCost = (event.societyDinnerCost ?? 0) * dinnerCount;
    final totalCatering = societyBreakfastCost + societyLunchCost + societyDinnerCost;
    final buggyCost = event.buggyCollectedBySociety ? (event.buggyCost ?? 0) * buggyCount : 0.0;

    // Costs
    final totalExpenses = event.expenses.fold(0.0, (s, e) => s + e.amount);
    final cashPrizes = event.awards.where((a) => a.type == 'Cash').fold(0.0, (s, a) => s + a.value);
    final ledgerExpenditureTotal = ledgerExpenditureEntries.fold(0.0, (s, e) => s + e.amount);
    final totalCosts = totalExpenses + cashPrizes + ledgerExpenditureTotal;

    // Net
    final netProfit = totalIncome - greenFeeCost - totalCatering - buggyCost - totalCosts;
    final isProfit = netProfit >= 0;

    const gap = SizedBox(height: AppSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Net position hero
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Net position', style: AppTypography.micro.copyWith(color: AppColors.dark400)),
                  Text(
                    '${isProfit ? '+' : ''}£${netProfit.toStringAsFixed(2)}',
                    style: AppTypography.display.copyWith(
                      color: isProfit ? AppColors.lime500 : AppColors.coral500,
                    ),
                  ),
                ],
              ),
              BoxyArtIconBadge(
                icon: isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isProfit ? AppColors.lime500 : AppColors.coral500,
                isTinted: true,
              ),
            ],
          ),
        ),

        gap,

        // Registration income (base fees only)
        _FinancialCategoryCard(
          title: 'Registration Income',
          icon: Icons.how_to_reg_rounded,
          total: baseRegRevenue,
          isIncome: true,
          emptyLabel: 'No paid registrations',
          items: paidRegs.map((r) => _PnLItem(
            label: r.memberName,
            sublabel: r.guestName != null ? '+ guest' : null,
            value: r.cost - event.extraCosts.fold(0.0, (s, e) => s + e.amount),
            isIncome: true,
          )).toList(),
        ),

        // Additional costs — one card per cost type
        for (final extra in event.extraCosts) ...[
          gap,
          _FinancialCategoryCard(
            title: toTitleCase(extra.label),
            icon: Icons.add_circle_outline_rounded,
            total: extra.amount * paidCount,
            isIncome: true,
            emptyLabel: 'No paid registrations',
            items: paidCount > 0
                ? [_PnLItem(
                    label: '$paidCount paid registrations',
                    sublabel: '£${extra.amount.toStringAsFixed(2)} each',
                    value: extra.amount * paidCount,
                    isIncome: true,
                  )]
                : [],
          ),
        ],

        gap,

        // Sponsorship (paid only)
        _FinancialCategoryCard(
          title: 'Sponsorship',
          icon: Icons.handshake_rounded,
          total: sponsorTotal,
          isIncome: true,
          emptyLabel: 'No paid event sponsorship recorded',
          items: sponsorEntries.map((e) => _PnLItem(
            label: e.source,
            sublabel: e.description,
            value: e.amount,
            isIncome: true,
          )).toList(),
        ),

        if (donationEntries.isNotEmpty) ...[
          gap,
          _FinancialCategoryCard(
            title: 'Donations',
            icon: Icons.volunteer_activism_rounded,
            total: donationTotal,
            isIncome: true,
            emptyLabel: 'No donations recorded',
            items: donationEntries.map((e) => _PnLItem(
              label: e.source,
              sublabel: e.description,
              value: e.amount,
              isIncome: true,
            )).toList(),
          ),
        ],

        gap,

        // Fines & Penalties
        _FinancialCategoryCard(
          title: 'Fines & Penalties',
          icon: Icons.gavel_rounded,
          total: finesTotal,
          isIncome: true,
          emptyLabel: 'No fines issued',
          items: event.registrations
              .where((r) => r.fines.isNotEmpty)
              .expand((r) => r.fines.map((f) => _PnLItem(
                    label: r.memberName,
                    sublabel: f.reason,
                    value: f.amount,
                    isIncome: true,
                    isPaid: r.finePaid,
                  )))
              .toList(),
        ),

        gap,

        // Green fees (society pays to club)
        if (greenFeeCost > 0) ...[
          _FinancialCategoryCard(
            title: 'Green Fees',
            icon: Icons.golf_course_rounded,
            total: greenFeeCost,
            isIncome: false,
            emptyLabel: 'No green fee configured',
            items: [
              _PnLItem(label: 'Course fees', sublabel: '$paidGolferCount × £${event.societyGreenFee!.toStringAsFixed(2)}', value: greenFeeCost, isIncome: false),
            ],
          ),
          gap,
        ],

        // Catering (society costs — society pays caterer)
        _FinancialCategoryCard(
          title: 'Catering',
          icon: Icons.restaurant_rounded,
          total: totalCatering,
          isIncome: false,
          emptyLabel: 'No catering costs configured',
          items: [
            if (breakfastCount > 0 && (event.societyBreakfastCost ?? 0) > 0)
              _PnLItem(label: 'Breakfast', sublabel: '$breakfastCount × £${event.societyBreakfastCost!.toStringAsFixed(2)}', value: societyBreakfastCost, isIncome: false),
            if (lunchCount > 0 && (event.societyLunchCost ?? 0) > 0)
              _PnLItem(label: 'Lunch', sublabel: '$lunchCount × £${event.societyLunchCost!.toStringAsFixed(2)}', value: societyLunchCost, isIncome: false),
            if (dinnerCount > 0 && (event.societyDinnerCost ?? 0) > 0)
              _PnLItem(label: 'Dinner', sublabel: '$dinnerCount × £${event.societyDinnerCost!.toStringAsFixed(2)}', value: societyDinnerCost, isIncome: false),
          ],
        ),

        gap,

        // Buggies
        _FinancialCategoryCard(
          title: 'Buggies',
          icon: Icons.electric_rickshaw_rounded,
          total: buggyCost,
          isIncome: false,
          emptyLabel: event.buggyCollectedBySociety
              ? 'No buggy bookings'
              : 'Members pay club directly — not tracked here',
          items: event.buggyCollectedBySociety && buggyCount > 0 && (event.buggyCost ?? 0) > 0
              ? [_PnLItem(label: 'Buggy bookings', sublabel: '$buggyCount × £${event.buggyCost!.toStringAsFixed(2)}', value: buggyCost, isIncome: false)]
              : [],
        ),

        gap,

        // Operational expenses — legacy event.expenses + ledger expenditure merged
        _FinancialCategoryCard(
          title: 'Operational Expenses',
          icon: Icons.receipt_long_rounded,
          total: totalExpenses + ledgerExpenditureTotal,
          isIncome: false,
          emptyLabel: 'No expenses recorded',
          items: [
            ...event.expenses.map((e) => _PnLItem(
              label: toSentenceCase(e.label),
              sublabel: toSentenceCase(e.category),
              value: e.amount,
              isIncome: false,
            )),
            ...ledgerExpenditureEntries.map((e) => _PnLItem(
              label: toSentenceCase(e.source),
              sublabel: toSentenceCase(e.scope ?? 'Misc'),
              value: e.amount,
              isIncome: false,
            )),
          ],
        ),

        gap,

        // Cash prizes
        _FinancialCategoryCard(
          title: 'Cash Prizes',
          icon: Icons.emoji_events_rounded,
          total: cashPrizes,
          isIncome: false,
          emptyLabel: 'No cash prizes',
          items: event.awards.where((a) => a.type == 'Cash').map((a) => _PnLItem(
            label: toSentenceCase(a.label),
            sublabel: a.winnerName != null ? toTitleCase(a.winnerName!) : 'Unassigned',
            value: a.value,
            isIncome: false,
          )).toList(),
        ),
      ],
    );
  }
}

// ── P&L item model ────────────────────────────────────────────────────────────

class _PnLItem {
  final String label;
  final String? sublabel;
  final double value;
  final bool isIncome;
  final bool? isPaid;
  const _PnLItem({required this.label, this.sublabel, required this.value, required this.isIncome, this.isPaid});
}

// ── Per-category collapsible card ─────────────────────────────────────────────

class _FinancialCategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final double total;
  final bool isIncome;
  final List<_PnLItem> items;
  final String emptyLabel;

  const _FinancialCategoryCard({
    required this.title,
    required this.icon,
    required this.total,
    required this.isIncome,
    required this.items,
    required this.emptyLabel,
  });

  @override
  State<_FinancialCategoryCard> createState() => _FinancialCategoryCardState();
}

class _FinancialCategoryCardState extends State<_FinancialCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = widget.isIncome ? AppColors.lime500 : AppColors.coral500;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.standard,
                vertical: AppSpacing.atomic,
              ),
              child: Row(
                children: [
                  BoxyArtIconBadge(
                    icon: widget.icon,
                    color: valueColor,
                    isTinted: true,
                  ),
                  const SizedBox(width: AppSpacing.standard),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.body.copyWith(
                        fontWeight: AppTypography.weightBold,
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.isIncome ? '+' : '-'}£${widget.total.toStringAsFixed(2)}',
                    style: AppTypography.body.copyWith(
                      fontWeight: AppTypography.weightHeavy,
                      color: valueColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.atomic),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppAnimations.fast,
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: AppShapes.iconSm, color: AppColors.dark400),
                  ),
                ],
              ),
            ),
          ),

          // Expandable line items
          AnimatedSize(
            duration: AppAnimations.medium,
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: [
                      const BoxyArtDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.standard,
                          vertical: AppSpacing.atomic,
                        ),
                        child: widget.items.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                child: Text(widget.emptyLabel, style: AppTypography.bodySmall.copyWith(color: AppColors.dark300)),
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < widget.items.length; i++) ...[
                                    if (i > 0) const Divider(height: 1),
                                    _buildLineItem(context, widget.items[i]),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(BuildContext context, _PnLItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.pureWhite : AppColors.dark900;
    final valueColor = item.isIncome ? AppColors.lime500 : AppColors.coral500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(item.label, style: AppTypography.bodySmall.copyWith(color: textColor))),
                    if (item.isPaid == false) ...[
                      const SizedBox(width: AppSpacing.xs),
                      BoxyArtIndicator(label: 'UNPAID', dotColor: AppColors.amber500, showBackground: true),
                    ],
                  ],
                ),
                if (item.sublabel != null)
                  Text(item.sublabel!, style: AppTypography.micro.copyWith(color: AppColors.dark400)),
              ],
            ),
          ),
          Text(
            '${item.isIncome ? '+' : '-'}£${item.value.toStringAsFixed(2)}',
            style: AppTypography.bodySmall.copyWith(color: valueColor, fontWeight: AppTypography.weightBold),
          ),
        ],
      ),
    );
  }
}

// ── Controls tab body ──────────────────────────────────────────────────────────

class _ControlsBody extends ConsumerStatefulWidget {
  final String eventId;

  const _ControlsBody({required this.eventId});

  @override
  ConsumerState<_ControlsBody> createState() => _ControlsBodyState();
}

class _ControlsBodyState extends ConsumerState<_ControlsBody> {
  final Map<String, bool> _optimisticToggles = {};

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final scorecardsAsync = ref.watch(scorecardsListProvider(widget.eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        _optimisticToggles.removeWhere((key, val) {
          if (key == 'isStatsReleased') return val == event.isStatsReleased;
          if (key == 'isGroupingPublished') return val == event.isGroupingPublished;
          if (key == 'showRegistrationButton') return val == event.showRegistrationButton;
          if (key == 'isScoringLocked') return val == event.isScoringLocked;
          return false;
        });

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scoring section (moved from Scores screen)
              const BoxyArtSectionTitle(title: 'Scoring', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtSwitchTile(
                      icon: Icons.lock_outline,
                      label: 'Lock Scoring',
                      subtitle: 'Prevent further score changes. Scorecards are finalised in their current state.',
                      value: _optimisticToggles['isScoringLocked'] ?? event.isScoringLocked,
                      onChanged: (val) {
                        setState(() => _optimisticToggles['isScoringLocked'] = val);
                        ref.read(eventsRepositoryProvider).updateEvent(
                          event.copyWith(isScoringLocked: val),
                        );
                      },
                    ),
                    const BoxyArtDivider(),
                    BoxyArtSwitchTile(
                      icon: Icons.bar_chart_rounded,
                      label: 'Publish Standings',
                      subtitle: 'Make final standings visible to all members.',
                      value: _optimisticToggles['isStatsReleased'] ?? (event.isStatsReleased == true),
                      onChanged: (val) {
                        setState(() => _optimisticToggles['isStatsReleased'] = val);
                        ref.read(eventsRepositoryProvider).updateEvent(
                          event.copyWith(isStatsReleased: val),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Player visibility section
              const BoxyArtSectionTitle(title: 'Player visibility', followsCard: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtSwitchTile(
                      icon: Icons.app_registration_rounded,
                      label: 'Show Registration Button',
                      subtitle: 'Make the event visible and joinable on the member home screen.',
                      value: _optimisticToggles['showRegistrationButton'] ?? (event.showRegistrationButton == true),
                      onChanged: (val) {
                        setState(() => _optimisticToggles['showRegistrationButton'] = val);
                        ref.read(eventsRepositoryProvider).updateEvent(
                          event.copyWith(showRegistrationButton: val),
                        );
                      },
                    ),
                    const BoxyArtDivider(),
                    BoxyArtSwitchTile(
                      icon: Icons.cloud_done_outlined,
                      label: 'Show Tee Times to Members',
                      subtitle: 'Publish the grouping and tee times to the member event hub.',
                      value: _optimisticToggles['isGroupingPublished'] ?? (event.isGroupingPublished == true),
                      onChanged: (val) {
                        setState(() => _optimisticToggles['isGroupingPublished'] = val);
                        ref.read(eventsRepositoryProvider).updateEvent(
                          event.copyWith(isGroupingPublished: val),
                        );
                      },
                    ),
                    const BoxyArtDivider(),
                    BoxyArtSwitchTile(
                      icon: Icons.analytics_outlined,
                      label: 'Show Live Stats to Players',
                      subtitle: 'Allow players to see calculated analytics during the event.',
                      value: _optimisticToggles['isLiveStatsReleased'] ?? (event.isStatsReleased == true),
                      onChanged: (val) {
                        setState(() => _optimisticToggles['isLiveStatsReleased'] = val);
                        ref.read(eventsRepositoryProvider).updateEvent(
                          event.copyWith(isStatsReleased: val),
                        );
                      },
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.sync_rounded,
                      title: 'Recalculate Stats',
                      subtitle: 'Reprocess all scorecards and update results.',
                      trailing: BoxyArtButton(
                        title: event.finalizedStats.isNotEmpty ? 'Ready' : 'Never Run',
                        isTinted: true,
                        isSmall: true,
                        onTap: () => _recalculateStats(event, scorecardsAsync),
                      ),
                      onTap: () => _recalculateStats(event, scorecardsAsync),
                    ),
                  ],
                ),
              ),

              // Event configuration section
              const BoxyArtSectionTitle(title: 'Event configuration', followsCard: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      title: 'Grouping & Tee Times',
                      subtitle: 'Build groups, assign tees, release to members',
                      icon: Icons.golf_course_rounded,
                      onTap: () => context.push(
                        '/admin/events/manage/${event.id}/grouping',
                      ),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtSwitchTile(
                      icon: Icons.lock_person_outlined,
                      label: 'Lock Grouping',
                      subtitle: 'Prevent accidental changes to the tee sheet while editing.',
                      value: ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false),
                      onChanged: (val) => _handleLockToggle(event, val),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Edit Event Details',
                      subtitle: 'Change venue, date, or title',
                      icon: Icons.settings_applications_outlined,
                      onTap: () => context.pushNamed(
                        'admin-event-edit',
                        pathParameters: {'id': event.id},
                        extra: event,
                      ),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Fines & Charity',
                      subtitle: 'Record ad-hoc penalties & collections',
                      icon: Icons.gavel_rounded,
                      onTap: () => context.pushNamed('admin-event-fines', pathParameters: {'id': event.id}),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Society Cuts',
                      subtitle: 'Apply manual handicap overrides',
                      icon: Icons.content_cut_rounded,
                      onTap: () => context.goNamed('admin-event-manual-cuts', pathParameters: {'id': event.id}),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Match Play Draw',
                      subtitle: 'Generate and manage tournament brackets',
                      icon: Icons.account_tree_outlined,
                      onTap: () => context.pushNamed('admin-event-matchplay-draw', pathParameters: {'id': event.id}),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Costs & Charges',
                      subtitle: 'Manage member/guest fees & meal options',
                      icon: Icons.payments_outlined,
                      onTap: () => context.pushNamed('admin-event-costs', pathParameters: {'id': event.id}),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Prize Pool & Airdrops',
                      subtitle: 'Configure the prize table & award types',
                      icon: Icons.emoji_events_outlined,
                      onTap: () => context.pushNamed('admin-event-airdrops', pathParameters: {'id': event.id}),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      title: 'Event Comms',
                      subtitle: 'Manage notifications & feed items',
                      icon: Icons.campaign_rounded,
                      onTap: () => context.goNamed('admin-event-broadcast', pathParameters: {'id': event.id}),
                    ),
                  ],
                ),
              ),

              // Event termination section
              const BoxyArtSectionTitle(title: 'Event termination', followsCard: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: BoxyArtSwitchTile(
                  icon: Icons.lock_outline,
                  label: 'Close Event & Finalize',
                  subtitle: 'Lock scorecards and finalize society statistics.',
                  value: event.status == EventStatus.completed,
                  onChanged: (val) {
                    if (val) {
                      _closeEvent(event, scorecardsAsync);
                    } else {
                      _reopenEvent(event);
                    }
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.pageBottom),
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      )),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Future<Map<String, dynamic>?> _recalculateStats(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final scorecards = scorecardsAsync.value;
    if (scorecards == null || scorecards.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No scores available to calculate stats.')),
        );
      }
      return null;
    }

    final compAsync = ref.read(competitionDetailProvider(event.id));
    final competition = compAsync.value;
    if (competition == null) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculating stats...'), duration: Duration(seconds: 1)),
    );

    final stats = EventAnalysisEngine.calculateFinalStats(
      event: event,
      competition: competition,
      scorecards: scorecards,
    );

    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        finalizedStats: stats,
        results: (stats['results'] as List?)?.cast<Map<String, dynamic>>() ?? event.results,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stats recalculated and saved!')),
      );
    }
    return stats;
  }

  Future<void> _closeEvent(GolfEvent event, AsyncValue<List<Scorecard>> scorecardsAsync) async {
    final scorecards = scorecardsAsync.value ?? [];
    final pending = scorecards.where((s) => s.status == ScorecardStatus.submitted).length;
    final incomplete = scorecards.where((s) => s.scoringStatus == ScoringStatus.incomplete).length;

    String warning = 'This will lock all scorecards, finalize the results, and mark the event as completed.';
    if (pending > 0 || incomplete > 0) {
      warning = 'WARNING: There are still $pending pending reviews and $incomplete incomplete scorecards.\n\nClosing the event will lock these in their current state.';
    }

    final confirmed = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Close Event?',
      message: warning,
      confirmText: 'Close & Finalize',
      isDangerous: true,
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () async {
        Navigator.of(context, rootNavigator: true).pop(true);
      },
    );

    if (confirmed == true) {
      final stats = await _recalculateStats(event, scorecardsAsync);
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(
          status: EventStatus.completed,
          isScoringLocked: true,
          finalizedStats: stats ?? {},
        ),
      );

      if (event.secondaryTemplateId != null) {
        final secondaryComp = ref.read(competitionDetailProvider(event.secondaryTemplateId!)).value;
        if (secondaryComp != null && secondaryComp.rules.subtype == CompetitionSubtype.matchPlaySeason) {
          if (mounted) {
            final startNextRound = await showBoxyArtDialog<bool>(
              context: context,
              title: 'Round Complete!',
              message: 'This event included a Match Play Season Overlay. Would you like to generate the draw for the next round now?',
              confirmText: 'GENERATE NEXT ROUND',
              cancelText: 'LATER',
              onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
            );
            if (startNextRound == true && mounted) {
              context.pushNamed(
                'admin-event-matchplay-draw',
                pathParameters: {'id': event.id},
                queryParameters: {'progress': 'true'},
              );
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event Closed & Stats Finalized')),
        );
      }
    }
  }

  Future<void> _reopenEvent(GolfEvent event) async {
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(status: EventStatus.inPlay, isScoringLocked: false),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Reopened')),
      );
    }
  }

  Future<void> _handleLockToggle(GolfEvent event, bool val) async {
    if (!val) {
      ref.read(groupingIsLockedProvider.notifier).setLocked(false);
      return;
    }

    final members = ref.read(allMembersProvider).value ?? [];
    final societyConfig = ref.read(themeControllerProvider);
    final comp = ref.read(competitionDetailProvider(event.id)).value;

    final groupsData = event.grouping['groups'] as List?;
    final groups = groupsData?.map((g) => TeeGroup.fromJson(g)).toList() ?? [];

    final pool = GroupingService.getUnassignedPlayers(
      event: event,
      groups: groups,
      memberHandicaps: {for (var m in members) m.id: m.handicap},
      rules: comp?.rules,
      useWhs: societyConfig.useWhsHandicaps,
      manualCuts: event.manualCuts,
    );

    if (pool.isNotEmpty) {
      final names = pool.map((p) => p.name).join(', ');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => BoxyArtDialog(
          title: 'Unassigned Players Found',
          message: 'The following confirmed players are not in any group: $names.\n\nWould you like to auto-fill them into vacancies before locking?',
          confirmText: 'Auto-fill & lock',
          cancelText: 'Just lock',
          onConfirm: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false),
        ),
      );

      if (confirmed == null) return;

      if (confirmed) {
        final updatedGroups = GroupingService.autoFillVacancies(groups: groups, pool: pool);
        await ref.read(eventsRepositoryProvider).updateEvent(
          event.copyWith(
            grouping: {
              ...event.grouping,
              'groups': updatedGroups.map((g) => g.toJson()).toList(),
              'locked': true,
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ),
        );
        ref.read(groupingIsLockedProvider.notifier).setLocked(true);
        ref.read(groupingLocalGroupsProvider.notifier).setGroups(updatedGroups);
        return;
      }
    }

    ref.read(groupingIsLockedProvider.notifier).setLocked(true);
    await ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(grouping: {...event.grouping, 'locked': true}),
    );
  }
}
