import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_state.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/competitions/presentation/widgets/competition_shared_widgets.dart';

class EventCompetitionSection extends ConsumerWidget {
  

  const EventCompetitionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(eventFormNotifierProvider);
    
    return stateAsync.when(
      data: (state) {
        if (state.eventType != EventType.golf) return const SizedBox.shrink();

        final templatesAsync = ref.watch(templatesListProvider);
        final templates = templatesAsync.value ?? [];
        final selectedTemplate = templates.where((t) => t.id == state.selectedTemplateId).firstOrNull;
        
        final hasGame = state.selectedTemplateId != null || state.eventCompetition != null;
        final displayComp = state.eventCompetition ?? selectedTemplate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'COMPETITION RULES'),
            const SizedBox(height: 12),
            if (!hasGame || displayComp == null)
              BoxyArtCard(
                child: Column(
                  children: [
                    const Text("NO RULES APPLIED", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Center(
                      child: BoxyArtButton(
                        title: "ADD GAME FORMAT",
                        onTap: () async {
                          final result = await context.push<String>("/admin/events/competitions/new");
                          if (result != null) {
                            ref.read(eventFormNotifierProvider.notifier).updateTemplateId(result);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CompetitionRulesCard(
                    competition: displayComp,
                    eventId: state.eventId ?? "",
                    title: "",
                    onTap: () async {
                      if (state.eventId != null) {
                        context.push("/admin/events/competitions/edit/${Uri.encodeComponent(state.eventId!)}");
                      }
                    },
                  ),
                  if (state.isMultiDay && displayComp.rules.roundsCount > 1) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'SEASON STANDINGS (OOM/ECLECTIC)',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    BoxyArtCard(
                      child: Column(
                        children: List.generate(displayComp.rules.roundsCount, (index) {
                          final roundId = 'round_${index + 1}';
                          final isExcluded = state.oomExcludedRoundIds.contains(roundId);
                          return Column(
                            children: [
                              BoxyArtSwitchField(
                                label: 'Include Round ${index + 1}',
                                value: !isExcluded,
                                onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).toggleOomRound(roundId, v),
                              ),
                              if (index < displayComp.rules.roundsCount - 1) const Divider(height: 24),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _handleCustomize(context, ref, state),
                        icon: Icon(state.isCustomized ? Icons.edit_note : Icons.tune, size: 18),
                        label: Text(state.isCustomized ? "CUSTOMIZED" : "CUSTOMIZE RULES"),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateTemplateId(null),
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        label: const Text("REMOVE", style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            
            // Secondary Game (Match Play)
            _buildSecondaryGame(context, ref, state, templates),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildSecondaryGame(BuildContext context, WidgetRef ref, EventFormState state, List<Competition> templates) {
    final displayComp = state.eventCompetition ?? templates.where((t) => t.id == state.selectedTemplateId).firstOrNull;
    if (displayComp == null) return const SizedBox.shrink();

    final format = displayComp.rules.format;
    if (format != CompetitionFormat.stableford && format != CompetitionFormat.stroke) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'SECONDARY GAME (OVERLAY)'),
        const SizedBox(height: 12),
        BoxyArtCard(
          child: state.secondaryTemplateId == null
            ? Center(
                child: BoxyArtButton(
                  title: 'ADD MATCH PLAY OVERLAY',
                  onTap: () async {
                    final result = await context.push<String>('/admin/events/competitions/new?format=matchPlay');
                    if (result != null) {
                      ref.read(eventFormNotifierProvider.notifier).updateSecondaryTemplateId(result);
                    }
                  },
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        child: const Icon(Icons.compare_arrows, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MATCH PLAY OVERLAY', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              (state.isSecondaryCustomized && state.secondaryCompetition?.name != null)
                                  ? state.secondaryCompetition!.name!.toUpperCase()
                                  : templates.where((t) => t.id == state.secondaryTemplateId).firstOrNull?.name?.toUpperCase() ?? 'MATCH PLAY',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateSecondaryTemplateId(null),
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  BoxyArtButton(
                    title: state.isSecondaryCustomized ? 'CUSTOMIZED' : 'CUSTOMIZE RULES',
                    onTap: () => _handleSecondaryCustomize(context, ref, state),
                    isGhost: true,
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Future<void> _handleCustomize(BuildContext context, WidgetRef ref, EventFormState state) async {
    final notifier = ref.read(eventFormNotifierProvider.notifier);
    if (state.eventId == null) {
      final confirm = await _showSaveConfirm(context);
      if (confirm != true) return;
      await notifier.save();
    }
    if (context.mounted) {
      final currentEventId = ref.read(eventFormNotifierProvider).value?.eventId;
      if (currentEventId != null) {
        context.push("/admin/events/competitions/edit/$currentEventId");
      }
    }
  }

  Future<void> _handleSecondaryCustomize(BuildContext context, WidgetRef ref, EventFormState state) async {
    final notifier = ref.read(eventFormNotifierProvider.notifier);
    if (state.eventId == null) {
      final confirm = await _showSaveConfirm(context);
      if (confirm != true) return;
      await notifier.save();
    }
    if (context.mounted) {
      final currentEventId = ref.read(eventFormNotifierProvider).value?.eventId;
      if (currentEventId != null) {
        context.push("/admin/events/competitions/edit/${currentEventId}_secondary");
      }
    }
  }

  Future<bool?> _showSaveConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Event First?"),
        content: const Text("To customize rules, we need to save the basic event details first."),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => context.pop(true), child: const Text("Save & Customize")),
        ],
      ),
    );
  }
}
