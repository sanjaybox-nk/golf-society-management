import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../events/presentation/events_provider.dart';

class EventCostControlScreen extends ConsumerWidget {
  final String eventId;
  const EventCostControlScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Costs & Charges',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: event.title,
        showBack: true,
        onBack: () => context.pop(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const BoxyArtSectionTitle(
                  title: 'Event pricing',
                  isPeeking: true,
                ),
                BoxyArtCard(
                  child: Column(
                    children: [
                      if (event.eventType == EventType.social) ...[
                        BoxyArtFormField(
                          label: 'Event Cost ($currency)',
                          initialValue: event.eventCost?.toString() ?? '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) => _updateEvent(ref, event, eventCost: double.tryParse(v)),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: BoxyArtFormField(
                                label: 'Society Green Fee ($currency)',
                                initialValue: event.societyGreenFee?.toString() ?? '',
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _updateEvent(ref, event, societyGreenFee: double.tryParse(v)),
                              ),
                            ),
                        const SizedBox(width: AppSpacing.lg),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                    SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                    Row(
                      children: [
                        Expanded(
                          child: BoxyArtFormField(
                            label: 'Member Charge ($currency)',
                            initialValue: event.memberCost?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _updateEvent(ref, event, memberCost: double.tryParse(v)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: BoxyArtFormField(
                            label: 'Guest Charge ($currency)',
                            initialValue: event.guestCost?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _updateEvent(ref, event, guestCost: double.tryParse(v)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                    Row(
                      children: [
                        Expanded(
                          child: BoxyArtFormField(
                            label: 'Buggy Cost ($currency)',
                            initialValue: event.buggyCost?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _updateEvent(ref, event, buggyCost: double.tryParse(v)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),
                const BoxyArtSectionTitle(
                  title: 'Meal options',
                  isPeeking: true,
                ),
                BoxyArtCard(
                  child: Column(
                    children: [
                        _buildMealToggle(ref, event, 'Breakfast', event.hasBreakfast, event.societyBreakfastCost, event.breakfastCost, currency,
                          (v) => _updateEvent(ref, event, hasBreakfast: v),
                          (v) => _updateEvent(ref, event, societyBreakfastCost: double.tryParse(v) ?? 0),
                          (v) => _updateEvent(ref, event, breakfastCost: double.tryParse(v) ?? 0),
                        ),
                        const BoxyArtDivider(),
                        _buildMealToggle(ref, event, 'Lunch', event.hasLunch, event.societyLunchCost, event.lunchCost, currency,
                          (v) => _updateEvent(ref, event, hasLunch: v),
                          (v) => _updateEvent(ref, event, societyLunchCost: double.tryParse(v) ?? 0),
                          (v) => _updateEvent(ref, event, lunchCost: double.tryParse(v) ?? 0),
                        ),
                        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                        const BoxyArtDivider(),
                        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                        _buildMealToggle(ref, event, 'Dinner', event.hasDinner, event.societyDinnerCost, event.dinnerCost, currency,
                          (v) => _updateEvent(ref, event, hasDinner: v),
                          (v) => _updateEvent(ref, event, societyDinnerCost: double.tryParse(v) ?? 0),
                          (v) => _updateEvent(ref, event, dinnerCost: double.tryParse(v) ?? 0),
                        ),
                      if (event.hasDinner) ...[
                        SizedBox(height: spacing?.labelToCard ?? AppSpacing.standard),
                        BoxyArtFormField(
                          label: 'Dinner Location',
                          initialValue: event.dinnerLocation,
                          onChanged: (v) => _updateEvent(ref, event, dinnerLocation: v),
                        ),
                        SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
                        BoxyArtFormField(
                          label: 'Dinner Address (Optional)',
                          initialValue: event.dinnerAddress,
                          onChanged: (v) => _updateEvent(ref, event, dinnerAddress: v),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),
                const BoxyArtSectionTitle(
                  title: 'Miscellaneous expenses',
                  isPeeking: true,
                ),
                if (event.expenses.isEmpty)
                  BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No miscellaneous expenses recorded.',
                        style: AppTypography.subtext.copyWith(color: AppColors.dark600),
                      ),
                    ),
                  )
                else
                  ...event.expenses.map((e) => _buildExpenseRow(context, ref, event, e, spacing)),
                
                SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
                BoxyArtButton(
                  title: 'Add expense',
                  onTap: () => _showExpenseDialog(context, ref, event),
                  isTinted: true,
                  fullWidth: true,
                ),
                SizedBox(height: AppSpacing.hero), // Spacing for safe area
              ]),
            ),
          ),
        ],
      ),
      loading: () => const HeadlessScaffold(title: 'Loading...', showBack: true, slivers: []),
      error: (e, _) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverToBoxAdapter(child: Text('Error: $e'))]),
    );
  }

  void _updateEvent(WidgetRef ref, GolfEvent event, {
    double? eventCost,
    double? societyGreenFee,
    double? memberCost,
    double? guestCost,
    double? buggyCost,
    bool? buggyCollectedBySociety,
    bool? hasBreakfast,
    double? societyBreakfastCost,
    double? breakfastCost,
    bool? hasLunch,
    double? societyLunchCost,
    double? lunchCost,
    bool? hasDinner,
    double? societyDinnerCost,
    double? dinnerCost,
    String? dinnerLocation,
    String? dinnerAddress,
  }) {
    ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        eventCost: eventCost ?? event.eventCost,
        societyGreenFee: societyGreenFee ?? event.societyGreenFee,
        memberCost: memberCost ?? event.memberCost,
        guestCost: guestCost ?? event.guestCost,
        buggyCost: buggyCost ?? event.buggyCost,
        buggyCollectedBySociety: buggyCollectedBySociety ?? event.buggyCollectedBySociety,
        hasBreakfast: hasBreakfast ?? event.hasBreakfast,
        societyBreakfastCost: societyBreakfastCost ?? event.societyBreakfastCost,
        breakfastCost: breakfastCost ?? event.breakfastCost,
        hasLunch: hasLunch ?? event.hasLunch,
        societyLunchCost: societyLunchCost ?? event.societyLunchCost,
        lunchCost: lunchCost ?? event.lunchCost,
        hasDinner: hasDinner ?? event.hasDinner,
        societyDinnerCost: societyDinnerCost ?? event.societyDinnerCost,
        dinnerCost: dinnerCost ?? event.dinnerCost,
        dinnerLocation: dinnerLocation ?? event.dinnerLocation,
        dinnerAddress: dinnerAddress ?? event.dinnerAddress,
      ),
    );
  }

  Widget _buildMealToggle(
    WidgetRef ref,
    GolfEvent event,
    String label,
    bool value,
    double? societyCost,
    double? memberCost,
    String currency,
    Function(bool) onToggle,
    Function(String) onSocietyCostChanged,
    Function(String) onMemberCostChanged,
  ) {
    return Column(
      children: [
        BoxyArtSwitchField(label: 'Offer $label', value: value, onChanged: onToggle),
        if (value) ...[
          const SizedBox(height: AppSpacing.x2l),
          BoxyArtFormField(
            label: 'Society $label Cost ($currency)',
            initialValue: societyCost?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: onSocietyCostChanged,
          ),
          const SizedBox(height: AppSpacing.x2l),
          BoxyArtFormField(
            label: 'Member Charge ($currency)',
            initialValue: memberCost?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: onMemberCostChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildExpenseRow(BuildContext context, WidgetRef ref, GolfEvent event, EventExpense expense, AppSpacingTokens? spacing) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(bottom: spacing?.labelToCard ?? AppSpacing.md),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.dark700.withValues(alpha: AppColors.opacityHigh) 
                    : AppColors.dark150.withValues(alpha: AppColors.opacityLow),
                borderRadius: AppShapes.lg,
              ),
              child: Icon(
                _getCategoryIcon(expense.category), 
                size: AppShapes.iconMd, 
                color: isDark ? AppColors.pureWhite : AppColors.dark950,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.label, 
                    style: AppTypography.labelStrong.copyWith(
                      color: isDark ? AppColors.pureWhite : AppColors.dark950,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category.toUpperCase(), 
                    style: AppTypography.micro.copyWith(
                      color: AppColors.dark600, 
                      letterSpacing: 0.5,
                      fontWeight: AppTypography.weightBold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '£${expense.amount.toStringAsFixed(2)}', 
              style: AppTypography.labelStrong.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark950,
                fontWeight: AppTypography.weightBlack,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showExpenseDialog(context, ref, event, expense: expense),
              color: AppColors.dark500,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () => _deleteExpense(ref, event, expense.id),
              color: AppColors.coral500,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Venue': return Icons.park_rounded;
      case 'Food': return Icons.restaurant_rounded;
      case 'Prize': return Icons.emoji_events_outlined;
      default: return Icons.receipt_long_outlined;
    }
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
              BoxyArtFormField(label: 'Amount (£)', controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
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

  Future<void> _deleteExpense(WidgetRef ref, GolfEvent event, String id) async {
    final updatedExpenses = event.expenses.where((e) => e.id != id).toList();
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(expenses: updatedExpenses));
  }
}
