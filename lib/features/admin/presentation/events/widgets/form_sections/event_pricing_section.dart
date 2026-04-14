import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

class EventPricingSection extends ConsumerWidget {
  

  const EventPricingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final currency = societyConfig.currencySymbol;

    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoxyArtSectionTitle(
            title: state.eventType == EventType.social ? 'Event Costs' : 'Playing Costs',
          ),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                if (state.eventType == EventType.golf) ...[
                  Row(
                    children: [
                      Expanded(
                        child: BoxyArtFormField(
                          label: 'Society Green Fee ($currency)',
                          initialValue: state.societyGreenFee?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyFee(double.tryParse(v)),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BoxyArtFormField(
                          label: 'Member Charge ($currency)',
                          initialValue: state.memberCost?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateMemberCost(double.tryParse(v)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: BoxyArtFormField(
                          label: 'Guest Charge ($currency)',
                          initialValue: state.guestCost?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateGuestCost(double.tryParse(v)),
                        ),
                      ),
                    ],
                  ),
                  BoxyArtFormField(
                    label: 'Indicative Buggy Cost ($currency)',
                    initialValue: state.buggyCost?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateBuggyCost(double.tryParse(v)),
                  ),
                ],
                // Dynamic Costs
                if (state.extraCosts.isNotEmpty) ...[
                  const BoxyArtDivider(),
                  ...state.extraCosts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cost = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: BoxyArtFormField(
                              label: 'Cost Label',
                              initialValue: cost.label,
                              onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateCost(index, cost.copyWith(label: v)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 3,
                            child: BoxyArtFormField(
                              label: 'Amount ($currency)',
                              initialValue: cost.amount == 0 ? '' : cost.amount.toString(),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateCost(index, cost.copyWith(amount: double.tryParse(v) ?? 0.0)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => ref.read(eventFormNotifierProvider.notifier).removeCost(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                BoxyArtButton(
                  title: 'Add cost',
                  onTap: () => ref.read(eventFormNotifierProvider.notifier).addCost(),
                  isSecondary: true,
                  isPrimary: false,
                  icon: Icons.add_circle_outline_rounded,
                  fullWidth: true,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
          BoxyArtSectionTitle(
            title: state.eventType == EventType.social ? 'Event Details' : 'Meal Options & Costs',
          ),
          BoxyArtCard(
            child: Column(
              children: [
                if (state.eventType == EventType.golf) ...[
                  _buildMealToggle(ref, 'Breakfast', state.hasBreakfast, state.societyBreakfastCost, state.breakfastCost, currency, 
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateHasBreakfast(v),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyBreakfastCost(double.tryParse(v) ?? 0),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateBreakfastCost(double.tryParse(v) ?? 0),
                  ),
                  const Divider(height: AppSpacing.x3l),
                  _buildMealToggle(ref, 'Lunch', state.hasLunch, state.societyLunchCost, state.lunchCost, currency, 
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateHasLunch(v),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyLunchCost(double.tryParse(v) ?? 0),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateLunchCost(double.tryParse(v) ?? 0),
                  ),
                  const Divider(height: AppSpacing.x3l),
                  _buildMealToggle(ref, 'Dinner', state.hasDinner, state.societyDinnerCost, state.dinnerCost, currency, 
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateHasDinner(v),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyDinnerCost(double.tryParse(v) ?? 0),
                    (v) => ref.read(eventFormNotifierProvider.notifier).updateDinnerCost(double.tryParse(v) ?? 0),
                  ),
                ],
                if (state.hasDinner || state.eventType == EventType.social) ...[
                  if (state.eventType == EventType.golf) const SizedBox(height: AppSpacing.lg),
                  BoxyArtFormField(
                    label: state.eventType == EventType.social ? 'Event Location' : 'Dinner Location',
                    initialValue: state.dinnerLocation,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateDinnerLocation(v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BoxyArtFormField(
                    label: state.eventType == EventType.social ? 'Event Address' : 'Dinner Address (Optional)',
                    initialValue: state.dinnerAddress,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateDinnerAddress(v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildMealToggle(
    WidgetRef ref, 
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
          const SizedBox(height: AppSpacing.lg),
          BoxyArtFormField(
            label: 'Society $label Cost ($currency)',
            initialValue: societyCost?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: onSocietyCostChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
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
}
