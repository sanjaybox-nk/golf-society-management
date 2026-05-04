import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/utils/string_utils.dart';
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
    final String displayId = isMeView ? currentUser.id : targetId;
    
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

    return Column(
      children: [
        if (widget.effectiveRules.isUnifiedTeamFormat)
           _buildTeamMembersRow(context, widget.event, widget.effectiveRules),
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onMarkerSelectionTap,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.lime500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            isSelfMarking 
                                ? 'MARKING: SELF' 
                                : (targetEntryId != null 
                                    ? 'MARKING: ${toTitleCase(_getDisplayName(widget.event, targetEntryId).split(' ').first)}' 
                                    : 'MARKING: SELECT'),
                            style: AppTypography.micro.copyWith(
                              color: AppColors.dark400,
                              fontWeight: AppTypography.weightBlack,
                              letterSpacing: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded, 
                          size: 14, 
                          color: AppColors.dark300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
               Row(
                children: [
                  if (displayScoring?.thruLabel != null) ...[
                    BoxyArtIndicator(
                      label: displayScoring!.thruLabel!,
                      dotColor: displayScoring.thruLabel == 'F' ? AppColors.dark900 : AppColors.lime500,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  BoxyArtIndicator.hc(label: _formatHcp(displayBaseHcp)),
                  const SizedBox(width: AppSpacing.md),
                  BoxyArtIndicator.phc(context: context, label: '$displayPlayingHcp${hasSocietyCutActual ? '*' : ''}'),
                ],
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

  String _getDisplayName(GolfEvent event, String entryId) {
    if (entryId.endsWith('_guest')) {
      final hostId = entryId.replaceFirst('_guest', '');
      final groups = event.grouping['groups'] as List?;
      if (groups != null) {
        for (var g in groups) {
          final players = g['players'] as List?;
          final guest = players?.firstWhere((p) => p['registrationMemberId'] == hostId && p['isGuest'] == true, orElse: () => null);
          if (guest != null) return guest['name'] ?? 'Guest';
        }
      }
      return 'Guest';
    }
    final member = ref.watch(allMembersProvider).value?.firstWhereOrNull((m) => m.id == entryId);
    return member?.displayName ?? 'Unknown';
  }

  String _formatHcp(double hcp) {
    if (hcp == hcp.toInt()) return hcp.toInt().toString();
    return hcp.toStringAsFixed(1);
  }
}
