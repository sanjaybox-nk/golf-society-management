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
            const SizedBox(height: AppSpacing.md),
            if (!hasGame || displayComp == null)
              BoxyArtCard(
                child: Column(
                  children: [
                    const Text("NO RULES APPLIED", style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold)),
                    const SizedBox(height: AppSpacing.md),
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
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'SEASON STANDINGS (OOM/ECLECTIC)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightBold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                              if (index < displayComp.rules.roundsCount - 1) const Divider(height: AppSpacing.x2l),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _handleCustomize(context, ref, state),
                        icon: Icon(state.isCustomized ? Icons.edit_note : Icons.tune, size: AppShapes.iconSm),
                        label: Text(state.isCustomized ? "CUSTOMIZED" : "CUSTOMIZE RULES"),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                          side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityMedium)),
                          shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateTemplateId(null),
                        icon: const Icon(Icons.delete_outline, size: AppShapes.iconSm, color: AppColors.textSecondary),
                        label: const Text("REMOVE", style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            
            // Secondary Game (Match Play)
            _buildSecondaryGame(context, ref, state, templates),
            const SizedBox(height: AppSpacing.x2l),
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
        const SizedBox(height: AppSpacing.x2l),
        const BoxyArtSectionTitle(title: 'SECONDARY GAME (OVERLAY)'),
        const SizedBox(height: AppSpacing.md),
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
                        backgroundColor: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                        child: const Icon(Icons.compare_arrows, color: AppColors.amber500),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MATCH PLAY OVERLAY', style: TextStyle(color: AppColors.amber500, fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightBold)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              (state.isSecondaryCustomized && state.secondaryCompetition?.name != null)
                                  ? state.secondaryCompetition!.name!.toUpperCase()
                                  : templates.where((t) => t.id == state.secondaryTemplateId).firstOrNull?.name?.toUpperCase() ?? 'MATCH PLAY',
                              style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBody),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(eventFormNotifierProvider.notifier).updateSecondaryTemplateId(null),
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.x3l),
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
