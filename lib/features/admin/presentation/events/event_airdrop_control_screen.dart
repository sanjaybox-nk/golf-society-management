import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:uuid/uuid.dart';
import '../../../events/presentation/events_provider.dart';

class EventAirdropControlScreen extends ConsumerWidget {
  final String eventId;
  const EventAirdropControlScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final societyConfig = ref.watch(themeControllerProvider);
    final currency = societyConfig.currencySymbol;

    return eventAsync.when(
      data: (event) => HeadlessScaffold(
        title: 'Prize Pool & Airdrops',
        topPill: BoxyArtPill.committee(label: 'ADMIN'),
        subtitle: event.title,
        showBack: true,
        onBack: () => context.pop(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const BoxyArtSectionTitle(title: 'Awards configuration'),
                BoxyArtCard(
                  child: Column(
                    children: [
                      BoxyArtSwitchField(
                        label: 'Enable Prize Table',
                        value: event.showAwards,
                        onChanged: (v) => _updateEvent(ref, event, showAwards: v),
                      ),
                      if (event.showAwards) ...[
                        const Divider(height: AppSpacing.x3l),
                        ...event.awards.asMap().entries.map((entry) {
                          final index = entry.key;
                          final award = entry.value;
                          return _AwardRow(
                            key: ValueKey('award_${award.id}'),
                            index: index,
                            award: award,
                            currency: currency,
                            onUpdate: (updated) {
                              final updatedAwards = List<EventAward>.from(event.awards);
                              updatedAwards[index] = updated;
                              _updateEvent(ref, event, awards: updatedAwards);
                            },
                            onRemove: () {
                              final updatedAwards = List<EventAward>.from(event.awards)..removeAt(index);
                              _updateEvent(ref, event, awards: updatedAwards);
                            },
                          );
                        }),
                        const SizedBox(height: AppSpacing.cardToLabel),
                        BoxyArtButton(
                          title: 'Add award',
                          onTap: () {
                            final updatedAwards = List<EventAward>.from(event.awards)
                              ..add(EventAward(id: const Uuid().v4(), label: 'New Award', value: 0));
                            _updateEvent(ref, event, awards: updatedAwards);
                          },
                          isTinted: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      loading: () => const HeadlessScaffold(title: 'Loading...', showBack: true, slivers: []),
      error: (e, _) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverToBoxAdapter(child: Text('Error: $e'))]),
    );
  }

  void _updateEvent(WidgetRef ref, GolfEvent event, {bool? showAwards, List<EventAward>? awards}) {
    ref.read(eventsRepositoryProvider).updateEvent(
      event.copyWith(
        showAwards: showAwards ?? event.showAwards,
        awards: awards ?? event.awards,
      ),
    );
  }
}

class _AwardRow extends StatefulWidget {
  final int index;
  final EventAward award;
  final String currency;
  final Function(EventAward) onUpdate;
  final VoidCallback onRemove;

  const _AwardRow({
    super.key,
    required this.index,
    required this.award,
    required this.currency,
    required this.onUpdate,
    required this.onRemove,
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
                onChanged: (v) => widget.onUpdate(widget.award.copyWith(label: v)),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 1,
              child: BoxyArtFormField(
                label: 'Value (${widget.currency})',
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => widget.onUpdate(widget.award.copyWith(value: double.tryParse(v) ?? 0.0)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: widget.onRemove,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardToLabel),
        Row(
          children: ['Cup', 'Cash', 'Voucher'].map((type) {
            final isSelected = widget.award.type.toLowerCase() == type.toLowerCase();
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: SizedBox(
                  height: AppSpacing.x3l,
                  child: BoxyArtButton(
                    title: type,
                    onTap: () => widget.onUpdate(widget.award.copyWith(type: type)),
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
