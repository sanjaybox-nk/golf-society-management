import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';

class EventAwardsSection extends ConsumerWidget {
  

  const EventAwardsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;

    return stateAsync.when(
      data: (state) {
        if (state.eventType != EventType.golf) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Prizes & Awards'),
            const SizedBox(height: AppTheme.sectionSpacing),
            BoxyArtCard(
              child: Column(
                children: [
                  BoxyArtSwitchField(
                    label: 'Enable Prize Table',
                    value: state.showAwards,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateShowAwards(v),
                  ),
                  if (state.showAwards) ...[
                    const Divider(height: AppSpacing.x3l),
                    ...state.awards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final award = entry.value;
                      return Column(
                        children: [
                          if (index > 0) const Divider(height: AppSpacing.x3l),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: BoxyArtFormField(
                                  label: 'Award Label',
                                  initialValue: award.label,
                                  onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateAward(index, award.copyWith(label: v)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 1,
                                child: BoxyArtFormField(
                                  label: 'Value ($currency)',
                                  initialValue: award.value == 0 ? '' : award.value.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateAward(index, award.copyWith(value: double.tryParse(v) ?? 0.0)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => ref.read(eventFormNotifierProvider.notifier).removeAward(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: ['Cup', 'Cash', 'Voucher'].map((type) {
                              final isSelected = award.type.toLowerCase() == type.toLowerCase();
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                  child: SizedBox(
                                    height: AppSpacing.x3l,
                                    child: BoxyArtButton(
                                      title: type.toUpperCase(),
                                      onTap: () => ref.read(eventFormNotifierProvider.notifier).updateAward(index, award.copyWith(type: type)),
                                      isGhost: !isSelected,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: AppSpacing.lg),
                    BoxyArtButton(
                      title: 'ADD AWARD',
                      onTap: () => ref.read(eventFormNotifierProvider.notifier).addAward(),
                      isGhost: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
