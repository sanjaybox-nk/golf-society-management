import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
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
          title: 'Manage',
          subtitle: event.title,
          topPill: BoxyArtPill.committee(label: 'ADMIN'),
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
        title: 'Manage',
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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceOverview(context, event),
              const BoxyArtSectionTitle(title: 'Expenses'),
              ...event.expenses.map((e) => _buildExpenseRow(context, ref, event, e)),
              _buildAddExpenseButton(context, ref, event),
              const BoxyArtSectionTitle(title: 'Prizes & Awards'),
              ...event.awards.map((a) => _buildAwardRow(context, ref, event, a)),
              _buildAddAwardButton(context, ref, event),
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

  Widget _buildBalanceOverview(BuildContext context, GolfEvent event) {
    final registrationRevenue = event.registrations.fold(0.0, (sum, r) => sum + (r.hasPaid ? r.cost : 0));
    final totalExpenses = event.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final cashPrizes = event.awards.where((a) => a.type == 'Cash').fold(0.0, (sum, a) => sum + a.value);
    final netProfit = registrationRevenue - totalExpenses - cashPrizes;
    final isProfit = netProfit >= 0;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net position',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.dark500,
                      letterSpacing: AppTypography.lsMicro,
                    ),
                  ),
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
                size: 56,
                iconSize: AppShapes.iconLg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          const BoxyArtDivider(),
          const SizedBox(height: AppSpacing.standard),
          _buildMetricRow('Registration Revenue', '£${registrationRevenue.toStringAsFixed(2)}', Icons.payments_outlined),
          const SizedBox(height: AppSpacing.atomic),
          _buildMetricRow('Operational Costs', '-£${totalExpenses.toStringAsFixed(2)}', Icons.receipt_long_outlined),
          const SizedBox(height: AppSpacing.atomic),
          _buildMetricRow('Cash Payouts', '-£${cashPrizes.toStringAsFixed(2)}', Icons.emoji_events_outlined),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconXs, color: AppColors.dark500),
        const SizedBox(width: AppSpacing.atomic),
        Text(label, style: AppTypography.micro.copyWith(color: AppColors.dark500, letterSpacing: AppTypography.lsMicro)),
        const Spacer(),
        Text(value, style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy)),
      ],
    );
  }

  Widget _buildExpenseRow(BuildContext context, WidgetRef ref, GolfEvent event, EventExpense expense) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
      child: GestureDetector(
        onTap: () => _showExpenseDialog(context, ref, event, expense: expense),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Row(
            children: [
              BoxyArtIconBadge(icon: _getCategoryIcon(expense.category), color: AppColors.textSecondary, isTinted: true),
              const SizedBox(width: AppSpacing.standard),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toSentenceCase(expense.label),
                      style: AppTypography.body.copyWith(
                        color: theme.brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: AppTypography.weightBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(toSentenceCase(expense.category), style: AppTypography.label.copyWith(color: AppColors.dark300)),
                  ],
                ),
              ),
              Text('£${expense.amount.toStringAsFixed(2)}', style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy)),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: AppShapes.iconMd, color: AppColors.coral500),
                onPressed: () => _deleteExpense(ref, event, expense.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAwardRow(BuildContext context, WidgetRef ref, GolfEvent event, EventAward award) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.atomic),
      child: GestureDetector(
        onTap: () => _showAwardDialog(context, ref, event, award: award),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.standard),
          child: Row(
            children: [
              BoxyArtIconBadge(
                icon: award.type == 'Cup' ? Icons.emoji_events_rounded : Icons.account_balance_wallet_rounded,
                color: AppColors.lime500,
                isTinted: true,
              ),
              const SizedBox(width: AppSpacing.standard),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toSentenceCase(award.label),
                      style: AppTypography.body.copyWith(
                        color: theme.brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark900,
                        fontWeight: AppTypography.weightBold,
                        fontSize: AppTypography.sizeBody,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      toTitleCase(award.winnerName ?? 'Unassigned'),
                      style: AppTypography.label.copyWith(
                        color: award.winnerName != null ? AppColors.lime500 : AppColors.amber500,
                      ),
                    ),
                  ],
                ),
              ),
              if (award.value > 0)
                Text('£${award.value.toStringAsFixed(2)}', style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy)),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: AppShapes.iconMd, color: AppColors.coral500),
                onPressed: () => _deleteAward(ref, event, award.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddExpenseButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(title: 'Add expense', onTap: () => _showExpenseDialog(context, ref, event), fullWidth: true);
  }

  Widget _buildAddAwardButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(title: 'Add prize slot', onTap: () => _showAwardDialog(context, ref, event), fullWidth: true);
  }

  void _showExpenseDialog(BuildContext context, WidgetRef ref, GolfEvent event, {EventExpense? expense}) {
    final labelController = TextEditingController(text: expense?.label);
    final amountController = TextEditingController(text: expense?.amount.toString());
    String category = expense?.category ?? 'Misc';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BoxyArtDialog(
          title: expense == null ? 'Add Expense' : 'Edit Expense',
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
              final newExpense = EventExpense(
                id: expense?.id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
                label: labelController.text,
                amount: amount,
                category: category,
              );
              final List<EventExpense> updatedExpenses = List.from(event.expenses);
              if (expense != null) {
                final index = updatedExpenses.indexWhere((e) => e.id == expense.id);
                updatedExpenses[index] = newExpense;
              } else {
                updatedExpenses.add(newExpense);
              }
              await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(expenses: updatedExpenses));
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector(String current, ValueChanged<String> onChanged) {
    final categories = ['Venue', 'Food', 'Prize', 'Misc'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: categories.map((cat) => ChoiceChip(
            label: Text(cat),
            selected: current == cat,
            onSelected: (selected) => selected ? onChanged(cat) : null,
          )).toList(),
        ),
      ],
    );
  }

  void _showAwardDialog(BuildContext context, WidgetRef ref, GolfEvent event, {EventAward? award}) {
    final labelController = TextEditingController(text: award?.label);
    final valueController = TextEditingController(text: award?.value.toString());
    String type = award?.type ?? 'Cup';
    String? selectedWinnerId = award?.winnerId;
    String? selectedWinnerName = award?.winnerName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BoxyArtDialog(
          title: award == null ? 'Add Prize Slot' : 'Edit Prize Slot',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxyArtFormField(label: 'Prize Label (e.g. Winner)', controller: labelController),
              const SizedBox(height: AppSpacing.lg),
              BoxyArtFormField(label: 'Cash Value (£)', controller: valueController, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.lg),
              _buildTypeSelector(type, (val) => setDialogState(() => type = val)),
              const SizedBox(height: AppSpacing.lg),
              _buildWinnerPicker(context, event, selectedWinnerId, (id, name) {
                setDialogState(() {
                  selectedWinnerId = id;
                  selectedWinnerName = name;
                });
              }),
            ],
          ),
          onConfirm: () async {
            if (labelController.text.isNotEmpty) {
              final newAward = EventAward(
                id: award?.id ?? 'award_${DateTime.now().millisecondsSinceEpoch}',
                label: labelController.text,
                type: type,
                value: double.tryParse(valueController.text) ?? 0.0,
                winnerId: selectedWinnerId,
                winnerName: selectedWinnerName,
              );
              final List<EventAward> updatedAwards = List.from(event.awards);
              if (award != null) {
                final index = updatedAwards.indexWhere((a) => a.id == award.id);
                updatedAwards[index] = newAward;
              } else {
                updatedAwards.add(newAward);
              }
              await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(awards: updatedAwards));
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String current, ValueChanged<String> onChanged) {
    final types = ['Cup', 'Cash', 'Voucher'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Award Type', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: types.map((t) => ChoiceChip(
            label: Text(t),
            selected: current == t,
            onSelected: (selected) => selected ? onChanged(t) : null,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildWinnerPicker(BuildContext context, GolfEvent event, String? selectedId, Function(String?, String?) onChanged) {
    final eligible = event.registrations.where((r) => r.attendingGolf).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Winner (Optional)', style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedId,
              hint: const Text('Assign Winner'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None / TBD')),
                ...eligible.map((r) => DropdownMenuItem(value: r.memberId, child: Text(r.memberName))),
              ],
              onChanged: (id) {
                final name = eligible.firstWhereOrNull((r) => r.memberId == id)?.memberName;
                onChanged(id, name);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteExpense(WidgetRef ref, GolfEvent event, String id) async {
    final updatedExpenses = event.expenses.where((e) => e.id != id).toList();
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(expenses: updatedExpenses));
  }

  Future<void> _deleteAward(WidgetRef ref, GolfEvent event, String id) async {
    final updatedAwards = event.awards.where((a) => a.id != id).toList();
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(awards: updatedAwards));
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Venue': return Icons.park_rounded;
      case 'Food': return Icons.restaurant_rounded;
      case 'Prize': return Icons.emoji_events_outlined;
      default: return Icons.receipt_long_outlined;
    }
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
              const BoxyArtSectionTitle(title: 'Player visibility', isPeeking: true),
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
                  ],
                ),
              ),

              // Workbench safety section
              const BoxyArtSectionTitle(title: 'Workbench safety', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtSwitchTile(
                      icon: Icons.lock_person_outlined,
                      label: 'Lock Grouping',
                      subtitle: 'Prevent accidental changes to the tee sheet while editing.',
                      value: ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false),
                      onChanged: (val) => _handleLockToggle(event, val),
                    ),
                    const BoxyArtDivider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.xl,
                        vertical: spacing?.cardVerticalPadding ?? AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          BoxyArtButton(
                            title: 'Recalculate Stats',
                            fullWidth: true,
                            isPrimary: true,
                            onTap: () => _recalculateStats(event, scorecardsAsync),
                          ),
                          SizedBox(height: spacing?.cardToCard ?? AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Status:',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              BoxyArtPill.status(
                                label: event.finalizedStats.isNotEmpty ? 'Ready' : 'Never finalized',
                                color: event.finalizedStats.isNotEmpty
                                    ? Theme.of(context).primaryColor
                                    : AppColors.amber500,
                                isAction: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Event configuration section
              const BoxyArtSectionTitle(title: 'Event configuration', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
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
              const BoxyArtSectionTitle(title: 'Event termination', isPeeking: true),
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
