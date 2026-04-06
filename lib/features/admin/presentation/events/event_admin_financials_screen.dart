import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../../events/presentation/events_provider.dart';

class EventAdminFinancialsScreen extends ConsumerWidget {
  final String eventId;

  const EventAdminFinancialsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));

    return eventAsync.when(
      data: (event) {
        return HeadlessScaffold(
          title: 'Event Ledger',
          subtitle: 'Financials & Prizes',
          showBack: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.standard),
                  _buildBalanceOverview(context, event),
                  const BoxyArtSectionTitle(title: 'Expenses'),
                  ...event.expenses.map((e) => _buildExpenseRow(context, ref, event, e)),
                  _buildAddExpenseButton(context, ref, event),
                  const BoxyArtSectionTitle(title: 'Prizes & Awards'),
                  ...event.awards.map((a) => _buildAwardRow(context, ref, event, a)),
                  _buildAddAwardButton(context, ref, event),
                  const SizedBox(height: AppSpacing.pageBottom),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
        Text(
          label, 
          style: AppTypography.micro.copyWith(
            color: AppColors.dark500,
            letterSpacing: AppTypography.lsMicro,
          ),
        ),
        const Spacer(),
        Text(
          value, 
          style: AppTypography.body.copyWith(
            fontWeight: AppTypography.weightHeavy,
          ),
        ),
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
              BoxyArtIconBadge(
                icon: _getCategoryIcon(expense.category),
                color: AppColors.textSecondary,
                isTinted: true,
              ),
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
                    Text(
                      toSentenceCase(expense.category),
                      style: AppTypography.label.copyWith(
                        color: AppColors.dark300,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '£${expense.amount.toStringAsFixed(2)}',
                style: AppTypography.body.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                ),
              ),
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
                Text(
                  '£${award.value.toStringAsFixed(2)}',
                  style: AppTypography.body.copyWith(
                    fontWeight: AppTypography.weightHeavy,
                  ),
                ),
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
    return BoxyArtButton(
      title: 'Add expense',
      onTap: () => _showExpenseDialog(context, ref, event),
      fullWidth: true,
    );
  }

  Widget _buildAddAwardButton(BuildContext context, WidgetRef ref, GolfEvent event) {
    return BoxyArtButton(
      title: 'Add prize slot',
      onTap: () => _showAwardDialog(context, ref, event),
      fullWidth: true,
    );
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
    // Basic winner picker using registrations
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
                ...eligible.map((r) => DropdownMenuItem(
                  value: r.memberId,
                  child: Text(r.memberName),
                )),
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
