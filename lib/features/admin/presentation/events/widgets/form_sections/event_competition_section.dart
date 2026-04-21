import 'package:golf_society/domain/models/golf_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
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
            const BoxyArtSectionTitle(title: 'Competition Rules', followsCard: true),
            if (!hasGame || displayComp == null)
              BoxyArtCard(
                child: Column(
                  children: [
                    Text(
                      "No rules applied", 
                      style: AppTypography.labelStrong.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: BoxyArtButton(
                        title: "Add game format",
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
                    onCustomize: () => _handleCustomize(context, ref, state),
                    onRemove: () => ref.read(eventFormNotifierProvider.notifier).updateTemplateId(null),
                    customizeLabel: state.isCustomized ? "Customized" : "Customize",
                  ),
                  const SizedBox(height: AppSpacing.cardToLabel),
                  BoxyArtCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: BoxyArtSwitchField(
                      label: 'Separate Guests in Standings',
                      subtitle: 'By default, guests are merged in Invitationals and separated in Official games.',
                      value: state.separateGuests ?? (!state.isInvitational),
                      onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateSeparateGuests(v),
                    ),
                  ),
                  if (state.isMultiDay && displayComp.rules.roundsCount > 1) ...[
                    const SizedBox(height: AppSpacing.cardToLabel),
                    Text(
                      'Season Standings (OOM/Eclectic)',
                      style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.labelToCard),
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
                              if (index < displayComp.rules.roundsCount - 1) const BoxyArtDivider(),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            

          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
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



  Future<bool?> _showSaveConfirm(BuildContext context) {
    return showBoxyArtDialog<bool>(
      context: context,
      title: "Save Event First?",
      message: "To customize rules, we need to save the basic event details first.",
      confirmText: "Save & Customize",
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
  }
}
