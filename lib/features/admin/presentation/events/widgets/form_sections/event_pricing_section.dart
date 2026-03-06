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
    final currency = societyConfig.currencySymbol;

    return stateAsync.when(
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event Costs'),
          const SizedBox(height: AppTheme.sectionSpacing),
          BoxyArtCard(
            child: Column(
              children: [
                if (state.eventType == EventType.social) ...[
                  BoxyArtFormField(
                    label: 'Event Cost ($currency)',
                    initialValue: state.eventCost?.toString() ?? '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateEventCost(double.tryParse(v)),
                  ),
                ] else ...[
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
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                      const SizedBox(width: 16),
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
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const BoxyArtSectionTitle(title: 'Meal Options & Costs'),
          const SizedBox(height: AppTheme.sectionSpacing),
          BoxyArtCard(
            child: Column(
              children: [
                _buildMealToggle(ref, 'Breakfast', state.hasBreakfast, state.societyBreakfastCost, state.breakfastCost, currency, 
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateHasBreakfast(v),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyBreakfastCost(double.tryParse(v) ?? 0),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateBreakfastCost(double.tryParse(v) ?? 0),
                ),
                const Divider(height: 32),
                _buildMealToggle(ref, 'Lunch', state.hasLunch, state.societyLunchCost, state.lunchCost, currency, 
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateHasLunch(v),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyLunchCost(double.tryParse(v) ?? 0),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateLunchCost(double.tryParse(v) ?? 0),
                ),
                const Divider(height: 32),
                _buildMealToggle(ref, 'Dinner', state.hasDinner, state.societyDinnerCost, state.dinnerCost, currency, 
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateHasDinner(v),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateSocietyDinnerCost(double.tryParse(v) ?? 0),
                  (v) => ref.read(eventFormNotifierProvider.notifier).updateDinnerCost(double.tryParse(v) ?? 0),
                ),
                if (state.hasDinner) ...[
                  const SizedBox(height: 16),
                  BoxyArtFormField(
                    label: 'Dinner Location',
                    initialValue: state.dinnerLocation,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateDinnerLocation(v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          BoxyArtFormField(
            label: 'Society $label Cost ($currency)',
            initialValue: societyCost?.toString() ?? '',
            keyboardType: TextInputType.number,
            onChanged: onSocietyCostChanged,
          ),
          const SizedBox(height: 12),
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
