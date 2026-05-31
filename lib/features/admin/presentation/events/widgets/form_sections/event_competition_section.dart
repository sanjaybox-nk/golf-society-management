import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_notifier.dart';
import 'package:golf_society/features/admin/presentation/events/event_form_state.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/competitions/presentation/widgets/competition_shared_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';

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
        final selectedSecondaryTemplate = templates.where((t) => t.id == state.secondaryTemplateId).firstOrNull;

        final hasGame = state.selectedTemplateId != null || state.eventCompetition != null;
        final displayComp = state.eventCompetition ?? selectedTemplate;

        // Lock editing once the event is in play or completed — game rules are set in stone.
        final eventsAsync = ref.watch(adminEventsProvider);
        final liveEvent = eventsAsync.value?.where((e) => e.id == state.eventId).firstOrNull;
        final isLocked = liveEvent?.status == EventStatus.inPlay || liveEvent?.status == EventStatus.completed;

        final hasSecondaryGame = state.secondaryTemplateId != null || state.secondaryCompetition != null;
        // Pairs formats (fourball/foursomes) manage their own pairing — a singles
        // match play overlay would conflict with the built-in pair structure.
        final isPairsFormat = displayComp?.rules.subtype == CompetitionSubtype.fourball ||
            displayComp?.rules.subtype == CompetitionSubtype.foursomes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Competition Rules', followsCard: true),

            // Primary game — always shown
            if (!hasGame || displayComp == null)
              BoxyArtCard(
                child: BoxyArtFormColumn(
                  children: [
                    Text(
                      "No rules applied",
                      style: AppTypography.labelStrong.copyWith(color: AppColors.dark400),
                    ),
                    BoxyArtButton(
                      title: "Add game format",
                      fullWidth: true,
                      onTap: () => _handleAddGame(context, ref, state),
                    ),
                  ],
                ),
              )
            else
              CompetitionRulesCard(
                competition: displayComp,
                eventId: state.eventId ?? "",
                title: "",
                onTap: () async {
                  if (state.eventId != null) {
                    context.push("/admin/events/manage/${Uri.encodeComponent(state.eventId!)}/game-builder");
                  }
                },
                onCustomize: isLocked ? null : () => _handleCustomize(context, ref, state, startingComp: displayComp),
                onRemove: isLocked ? null : () => _confirmRemoveMainGame(context, ref),
                customizeLabel: state.isCustomized ? "Customized" : "Customize",
              ),

            // Secondary game — independent of primary so Remove is always accessible
            if (hasSecondaryGame) ...[
              Builder(builder: (context) {
                final spacing = Theme.of(context).extension<AppSpacingTokens>();
                return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
              }),
              CompetitionRulesCard(
                competition: state.secondaryCompetition ?? selectedSecondaryTemplate,
                eventId: state.eventId ?? "",
                title: "Match Play Overlay",
                isSecondary: true,
                onTap: () async {
                  if (state.eventId != null) {
                    context.push("/admin/events/manage/${Uri.encodeComponent(state.eventId!)}/secondary-game-builder");
                  }
                },
                onCustomize: isLocked ? null : () => _handleCustomize(context, ref, state, isSecondary: true, startingComp: state.secondaryCompetition ?? selectedSecondaryTemplate),
                onRemove: isLocked ? null : () => _confirmRemoveOverlay(context, ref),
                customizeLabel: state.isSecondaryCustomized ? "Customized" : "Customize",
              ),
            ] else if (!isLocked && hasGame && !isPairsFormat) ...[
              Builder(builder: (context) {
                final spacing = Theme.of(context).extension<AppSpacingTokens>();
                return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
              }),
              BoxyArtCard(
                child: BoxyArtFormColumn(
                  children: [
                    Text(
                      "No side game active",
                      style: AppTypography.labelStrong.copyWith(color: AppColors.dark400),
                    ),
                    BoxyArtButton(
                      title: "Add Match Play Overlay",
                      fullWidth: true,
                      isTinted: true,
                      onTap: () => _handleAddGame(context, ref, state, isSecondary: true),
                    ),
                  ],
                ),
              ),
            ],

            // Settings — only relevant when a primary game is configured
            if (hasGame && displayComp != null) ...[
              Builder(builder: (context) {
                final spacing = Theme.of(context).extension<AppSpacingTokens>();
                return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
              }),
              BoxyArtCard(
                child: BoxyArtSwitchField(
                  label: 'Separate Guests in Standings',
                  subtitle: 'By default, guests are merged in Non-Season events and separated in Season games.',
                  value: state.separateGuests ?? (!state.isInvitational),
                  onChanged: (v) => ref.read(eventFormNotifierProvider.notifier).updateSeparateGuests(v),
                ),
              ),
              if (state.isMultiDay && displayComp.rules.roundsCount > 1) ...[
                BoxyArtFormColumn(
                  spacing: Theme.of(context).extension<AppSpacingTokens>()?.labelToCard,
                  children: [
                    Text(
                      'Season Standings (OOM/Eclectic)',
                      style: AppTypography.microStrong.copyWith(color: AppColors.textSecondary),
                    ),
                    BoxyArtCard(
                      child: BoxyArtFormColumn(
                        children: List.generate(displayComp.rules.roundsCount, (index) {
                          final roundId = 'round_${index + 1}';
                          final isExcluded = state.oomExcludedRoundIds.contains(roundId);
                          return BoxyArtFormColumn(
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
                ),
              ],
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
    );
  }



  Future<void> _handleCustomize(BuildContext context, WidgetRef ref, EventFormState state, {bool isSecondary = false, Competition? startingComp}) async {
    final notifier = ref.read(eventFormNotifierProvider.notifier);

    // Ensure the event and competition exist in Firestore before opening the builder.
    final noEventId = state.eventId == null;
    final noComp = isSecondary ? state.secondaryCompetition == null : state.eventCompetition == null;

    if (noEventId) {
      final confirm = await _showSaveConfirm(context);
      if (confirm != true) return;
      await notifier.save();
    } else if (noComp) {
      // Save silently to create the competition document from the selected template.
      await notifier.save();
    }

    if (!context.mounted) return;

    // Reload the now-saved competition into state so we get the correct event-specific object.
    await notifier.refreshCompetition(isSecondary: isSecondary);

    if (!context.mounted) return;

    final freshState = ref.read(eventFormNotifierProvider).value;
    final currentEventId = freshState?.eventId;
    if (currentEventId == null) return;

    // Use the event-specific competition (correct ID = eventId or eventId_secondary).
    // Fall back to startingComp (template) only as a last resort.
    final comp = isSecondary
        ? (freshState?.secondaryCompetition ?? startingComp)
        : (freshState?.eventCompetition ?? startingComp);

    final path = isSecondary ? "secondary-game-builder" : "game-builder";
    await context.push("/admin/events/manage/$currentEventId/$path", extra: comp);

    if (context.mounted) {
      await notifier.refreshCompetition(isSecondary: isSecondary);
    }
  }

  Future<void> _handleAddGame(BuildContext context, WidgetRef ref, EventFormState state, {bool isSecondary = false}) async {
    final notifier = ref.read(eventFormNotifierProvider.notifier);
    if (state.eventId == null) {
      final confirm = await _showSaveConfirm(context);
      if (confirm != true) return;
      await notifier.save();
    }

    if (context.mounted) {
      final currentEventId = ref.read(eventFormNotifierProvider).value?.eventId;
      if (currentEventId != null) {
        // Overlays are always Match Play — skip the type picker and go straight to the gallery.
        final path = isSecondary
            ? "/admin/events/manage/$currentEventId/game-setup/gallery/matchPlay?overlay=true"
            : "/admin/events/manage/$currentEventId/game-setup";
        final result = await context.push<String>(path);
        if (result != null && context.mounted) {
          // Template IDs (from gallery or copy/overlay guard) are Firestore
          // auto-generated and will never equal the event competition ID.
          // Competition IDs from the blank builder are always eventId or eventId_secondary.
          final isEventComp = result == currentEventId || result == '${currentEventId}_secondary';
          if (!isEventComp) {
            if (isSecondary) {
              notifier.updateSecondaryTemplateId(result);
            } else {
              notifier.updateTemplateId(result);
            }
          } else {
            await notifier.refreshCompetition(isSecondary: isSecondary);
          }
        }
      }
    }
  }

  Future<void> _confirmRemoveMainGame(BuildContext context, WidgetRef ref) async {
    final confirmed = await BoxyArtDialog.show<bool>(
      context: context,
      title: 'Remove Game Format?',
      message: 'The competition rules will be detached from this event. Any existing score data is preserved.',
      confirmText: 'REMOVE',
      cancelText: 'CANCEL',
      isDangerous: true,
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed == true) {
      ref.read(eventFormNotifierProvider.notifier).updateTemplateId(null);
    }
  }

  Future<void> _confirmRemoveOverlay(BuildContext context, WidgetRef ref) async {
    final confirmed = await BoxyArtDialog.show<bool>(
      context: context,
      title: 'Remove Match Play Overlay?',
      message: 'The overlay will be detached from this event. Any existing match data is preserved but will no longer display.',
      confirmText: 'REMOVE',
      cancelText: 'CANCEL',
      isDangerous: true,
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed == true) {
      ref.read(eventFormNotifierProvider.notifier).updateSecondaryTemplateId(null);
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
