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
                      return _AwardRow(
                        key: ValueKey('award_${index}_${award.id}'),
                        index: index,
                        award: award,
                        currency: currency,
                        ref: ref,
                      );
                    }),
                    const SizedBox(height: AppSpacing.x2l),
                    BoxyArtButton(
                      title: 'ADD AWARD',
                      onTap: () => ref.read(eventFormNotifierProvider.notifier).addAward(),
                      isGhost: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _AwardRow extends StatefulWidget {
  final int index;
  final EventAward award;
  final String currency;
  final WidgetRef ref;

  const _AwardRow({
    super.key,
    required this.index,
    required this.award,
    required this.currency,
    required this.ref,
  });

  @override
  State<_AwardRow> createState() => _AwardRowState();
}

class _AwardRowState extends State<_AwardRow> {
  late final TextEditingController _labelController;
  late final TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.award.label);
    _valueController = TextEditingController(text: widget.award.value == 0 ? '' : widget.award.value.toString());
  }

  @override
  void didUpdateWidget(_AwardRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.award.label != oldWidget.award.label && widget.award.label != _labelController.text) {
      _labelController.text = widget.award.label;
    }
    
    final newValueStr = widget.award.value == 0 ? '' : widget.award.value.toString();
    if (widget.award.value != oldWidget.award.value && 
        newValueStr != _valueController.text && 
        double.tryParse(_valueController.text) != widget.award.value) {
      _valueController.text = newValueStr;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.index > 0) const Divider(height: AppSpacing.x3l),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: BoxyArtFormField(
                label: 'Award Label',
                controller: _labelController,
                onChanged: (v) => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(label: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.x2l),
            Expanded(
              flex: 1,
              child: BoxyArtFormField(
                label: 'Value (${widget.currency})',
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(value: double.tryParse(v) ?? 0.0)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => widget.ref.read(eventFormNotifierProvider.notifier).removeAward(widget.index),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2l),
        Row(
          children: ['Cup', 'Cash', 'Voucher'].map((type) {
            final isSelected = widget.award.type.toLowerCase() == type.toLowerCase();
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: SizedBox(
                  height: AppSpacing.x3l,
                  child: BoxyArtButton(
                    title: type.toUpperCase(),
                    onTap: () => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(type: type)),
                    isGhost: !isSelected,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
