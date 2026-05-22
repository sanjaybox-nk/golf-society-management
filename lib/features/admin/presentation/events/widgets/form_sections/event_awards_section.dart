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
            const BoxyArtSectionTitle(title: 'Prizes & Awards', followsCard: true),
            BoxyArtCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxyArtSwitchField(
                    label: 'Enable Prize Table',
                    value: state.showAwards,
                    onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateShowAwards(v),
                  ),
                  if (state.showAwards) ...[
                    const BoxyArtDivider(),
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
                  ],
                ],
              ),
            ),
            if (state.showAwards) ...[
              Builder(builder: (context) {
                final spacing = Theme.of(context).extension<AppSpacingTokens>();
                return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
              }),
              BoxyArtButton(
                title: 'Add award',
                fullWidth: true,
                onTap: () => ref.read(eventFormNotifierProvider.notifier).addAward(),
                isTinted: true,
                icon: Icons.add_circle_outline_rounded,
              ),
            ],
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
    return BoxyArtFormColumn(
      children: [
        if (widget.index > 0) const BoxyArtDivider(),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: BoxyArtFormField(
                label: 'Award Label',
                controller: _labelController,
                onChanged: (v) => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(label: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 3,
              child: BoxyArtFormField(
                label: 'Value (${widget.currency})',
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(value: double.tryParse(v) ?? 0.0)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.coral500),
              onPressed: () => widget.ref.read(eventFormNotifierProvider.notifier).removeAward(widget.index),
            ),
          ],
        ),
        Row(
          children: ['Cup', 'Cash', 'Voucher'].map((type) {
            final isSelected = type.toLowerCase() == widget.award.type.toLowerCase();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: type != 'Voucher' ? AppSpacing.sm : 0),
                child: BoxyArtButton(
                  title: type,
                  isTinted: isSelected,
                  isSecondary: !isSelected,
                  isSmall: true,
                  onTap: () => widget.ref.read(eventFormNotifierProvider.notifier).updateAward(widget.index, widget.award.copyWith(type: type)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
