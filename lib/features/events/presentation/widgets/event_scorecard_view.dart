import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/events/presentation/widgets/sliding_course_info_card.dart';
import 'package:golf_society/features/events/presentation/tabs/event_tabs_state.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';

class EventScorecardView extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Competition? comp;
  final ProcessedEventData? scoringData;
  final CompetitionRules effectiveRules;
  final Map<int, int>? optimisticScores;
  final bool optimisticIsVerifier;
  final MarkerTab selectedMarkerTab;
  final VoidCallback? onMarkerSelectionTap;
  final Function(Scorecard)? onSyncFromPartner;
  final String? switchedCardId;

  const EventScorecardView({
    super.key,
    required this.event,
    required this.comp,
    required this.scoringData,
    required this.effectiveRules,
    this.optimisticScores,
    this.optimisticIsVerifier = false,
    required this.selectedMarkerTab,
    this.onMarkerSelectionTap,
    this.onSyncFromPartner,
    this.switchedCardId,
  });

  @override
  ConsumerState<EventScorecardView> createState() => _EventScorecardViewState();
}

class _EventScorecardViewState extends ConsumerState<EventScorecardView> {

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(themeControllerProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final markerSelection = ref.watch(markerSelectionProvider);
    final bool isSelfMarking = markerSelection.isSelfMarking;
    final String? targetEntryId = markerSelection.targetEntryIds.firstOrNull;

    final String targetId = (isSelfMarking || targetEntryId == null)
        ? currentUser.id
        : targetEntryId;

    final allScorecards = ref.watch(scorecardsListProvider(widget.event.id)).asData?.value ?? [];
    final myCard = allScorecards.firstWhereOrNull((s) => s.entryId == currentUser.id);

    final bool isMeView = !isSelfMarking && widget.selectedMarkerTab == MarkerTab.verifier;

    // Pinned switcher (from parent) overrides displayId when set
    final String displayId = widget.switchedCardId ?? (isMeView ? currentUser.id : targetId);

    final members = ref.watch(allMembersProvider).value ?? [];
    final manualTee = markerSelection.teeOverrides[displayId];
    final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
      memberId: displayId,
      event: widget.event,
      membersList: members,
      manualTeeName: manualTee,
    );

    final memberProfile = members.firstWhereOrNull((m) => m.id == displayId);
    final String playerTeeName = manualTee ?? (
      (memberProfile?.gender?.toLowerCase() == 'female')
        ? (widget.event.selectedFemaleTeeName ?? 'Red')
        : (widget.event.selectedTeeName ?? 'Yellow')
    );

    final displayScoring = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == displayId);
    final double displayBaseHcp = displayScoring?.handicapIndex ?? (isMeView ? currentUser.handicap : 18.0);
    final displayCard = allScorecards.firstWhereOrNull((s) => s.entryId == displayId);

    final int displayPlayingHcp = displayScoring?.playingHandicap ?? (
      HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: displayBaseHcp,
        rules: widget.effectiveRules,
        courseConfig: playerTeeConfig,
        societyCut: widget.event.manualCuts[displayId] ?? 0.0,
      )
    );

    final bool hasSocietyCutActual = (displayScoring?.appliedSocietyCut ?? (widget.event.manualCuts[displayId] ?? 0.0)) != 0;

    List<int?> gridScores = displayScoring?.holeScores ?? List.generate(18, (i) {
      final live = (displayCard != null && i < displayCard.holeScores.length) ? displayCard.holeScores[i] : null;

      if (!isMeView && displayId == targetId) {
        final myVerifier = myCard?.playerVerifierScores ?? [];
        final mine = i < myVerifier.length ? myVerifier[i] : null;
        return live ?? mine;
      }

      return live;
    });

    if (widget.optimisticScores != null && widget.optimisticIsVerifier == (widget.selectedMarkerTab == MarkerTab.verifier)) {
      gridScores = List.generate(18, (i) {
        return widget.optimisticScores![i + 1] ?? (i < gridScores.length ? gridScores[i] : null);
      });
    }

    final conflictedHoles = _computeConflictedHoles(displayCard);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.effectiveRules.isUnifiedTeamFormat)
          _buildTeamMembersRow(context, widget.event, widget.effectiveRules),

        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BoxyArtIndicator.hc(label: _formatHcp(displayBaseHcp), hasHorizontalMargin: false),
                  BoxyArtIndicator.phc(context: context, label: '$displayPlayingHcp${hasSocietyCutActual ? '*' : ''}'),
                ],
              ),
              if (displayScoring?.thruLabel != null)
                BoxyArtIndicator(
                  label: displayScoring!.thruLabel!,
                  dotColor: displayScoring.thruLabel == 'F' ? AppColors.dark900 : AppColors.lime500,
                  hasHorizontalMargin: false,
                ),
            ],
          ),
        ),

        SlidingCourseInfoCard(
          courseConfig: playerTeeConfig,
          selectedTeeName: playerTeeName,
          distanceUnit: config.distanceUnit,
          isStableford: widget.effectiveRules.format == CompetitionFormat.stableford,
          playerHandicap: displayPlayingHcp,
          scores: gridScores,
          tieBreakLabel: displayScoring?.tieBreakLabel,
          headerColor: isMeView ? AppColors.amber500.withValues(alpha: AppColors.opacityMuted) : null,
          holeTags: displayCard?.holeTags,
          conflictedHoles: conflictedHoles,
          handicapAllowance: widget.effectiveRules.handicapAllowance,
        ),

        // Conflict strip — below the card for birds-eye summary
        if (conflictedHoles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _buildConflictStrip(context, conflictedHoles, displayCard),
          ),

      ],
    );
  }

  Widget _buildConflictStrip(BuildContext context, Set<int> conflictedHoles, Scorecard? card) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    final sortedHoles = conflictedHoles.toList()..sort();

    return Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: AppShapes.iconXs, color: AppColors.coral500),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedHoles.map((holeNum) {
                  final idx = holeNum - 1;
                  final playerScore = (card != null && idx < card.holeScores.length) ? card.holeScores[idx] : null;
                  final markerScore = (card != null && idx < card.playerVerifierScores.length) ? card.playerVerifierScores[idx] : null;

                  final label = playerScore != null && markerScore != null
                      ? 'H$holeNum · ${playerScore}v$markerScore'
                      : 'H$holeNum';

                  return Container(
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.atomic,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
                      borderRadius: shapes?.pill ?? BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.coral500.withValues(alpha: AppColors.opacityMuted),
                        width: AppShapes.borderThin,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.micro.copyWith(
                        color: AppColors.coral500,
                        fontWeight: AppTypography.weightBold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildTeamMembersRow(BuildContext context, GolfEvent event, CompetitionRules rules) {
    final currentUser = ref.watch(effectiveUserProvider);
    final groupData = event.grouping['groups'] as List?;
    final myGroup = groupData?.firstWhereOrNull((g) => (g['players'] as List).any((p) => p['registrationMemberId'] == currentUser.id));
    if (myGroup == null) return const SizedBox.shrink();

    final List<TeeGroupParticipant> players = (myGroup['players'] as List).map((p) => TeeGroupParticipant.fromJson(p)).toList();
    final playerIdx = players.indexWhere((p) => p.registrationMemberId == currentUser.id);
    final teamSize = rules.teamSize;
    int teamIdx = playerIdx ~/ teamSize;
    final List<TeeGroupParticipant> teamMembers = players.skip(teamIdx * teamSize).take(teamSize).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: teamMembers.map((p) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: BoxyArtCard(
              padding: const EdgeInsets.all(8),
              child: Text(
                p.name.split(' ').first,
                textAlign: TextAlign.center,
                style: AppTypography.micro.copyWith(
                  fontWeight: p.registrationMemberId == currentUser.id ? AppTypography.weightBold : AppTypography.weightRegular,
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Set<int> _computeConflictedHoles(Scorecard? card) {
    if (card == null) return const {};
    final Set<int> result = {};
    final verifier = card.playerVerifierScores;
    for (int i = 0; i < card.holeScores.length && i < verifier.length; i++) {
      final player = card.holeScores[i];
      final marker = verifier[i];
      if (player != null && marker != null && player != marker) {
        result.add(i + 1);
      }
    }
    return result;
  }

  String _formatHcp(double hcp) {
    if (hcp == hcp.toInt()) return hcp.toInt().toString();
    return hcp.toStringAsFixed(1);
  }
}
