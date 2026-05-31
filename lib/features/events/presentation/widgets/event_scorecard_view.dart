import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/scoring/scorecard_factory.dart';
import 'package:golf_society/utils/firestore_normalizer.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:golf_society/features/events/presentation/widgets/course_info_card.dart';
import 'package:golf_society/features/events/presentation/tabs/event_tabs_state.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/features/matchplay/domain/match_play_calculator.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
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

    // Fourball pair resolution — always 2-player pairs (indices [0,1] vs [2,3])
    final isFourball = widget.effectiveRules.subtype == CompetitionSubtype.fourball;
    TeeGroupParticipant? fourballPartner;
    List<TeeGroupParticipant> fourballOpponents = [];
    if (isFourball) {
      final groupData = widget.event.grouping['groups'] as List? ?? [];
      final myGroupData = groupData.firstWhereOrNull(
        (g) => (g['players'] as List).any((p) => p['registrationMemberId'] == currentUser.id));
      if (myGroupData != null) {
        final allGroupPlayers = (myGroupData['players'] as List)
            .map((p) => TeeGroupParticipant.fromJson(p)).toList();
        final myIdx = allGroupPlayers.indexWhere((p) => p.registrationMemberId == currentUser.id);
        if (myIdx >= 0) {
          final myPairStart = (myIdx ~/ 2) * 2;
          final myPair = allGroupPlayers.skip(myPairStart).take(2).toList();
          fourballPartner = myPair.firstWhereOrNull((p) => p.registrationMemberId != currentUser.id);
          final oppPairStart = myPairStart == 0 ? 2 : 0;
          fourballOpponents = allGroupPlayers.skip(oppPairStart).take(2).toList();
        }
      }
    }

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

    final int displayPlayingHcp = displayScoring?.playingHandicap
        ?? displayCard?.playingHandicap
        ?? HandicapCalculator.calculatePlayingHandicap(
             handicapIndex: displayBaseHcp,
             rules: widget.effectiveRules,
             courseConfig: playerTeeConfig,
             societyCut: widget.event.manualCuts[displayId] ?? 0.0,
           );

    final bool hasSocietyCutActual = (displayScoring?.appliedSocietyCut ?? (widget.event.manualCuts[displayId] ?? 0.0)) != 0;

    // For guest players: STR row stays empty (all dashes) until the assignee confirms
    // via the verify tap — which copies playerVerifierScores → holeScores.
    final bool isGuestCard = displayId.endsWith('_guest');
    final bool guestConfirmed = isGuestCard &&
        (displayCard?.holeScores.any((s) => s != null && s > 0) ?? false);

    List<int?> gridScores = (isGuestCard && !guestConfirmed)
        ? List<int?>.filled(18, null)
        : (displayScoring?.holeScores ?? List.generate(18, (i) {
            final live = (displayCard != null && i < displayCard.holeScores.length) ? displayCard.holeScores[i] : null;

            if (!isMeView && displayId == targetId) {
              final myVerifier = myCard?.playerVerifierScores ?? [];
              final mine = i < myVerifier.length ? myVerifier[i] : null;
              return live ?? mine;
            }

            return live;
          }));

    if (widget.optimisticScores != null && widget.optimisticIsVerifier == (widget.selectedMarkerTab == MarkerTab.verifier)) {
      gridScores = List.generate(18, (i) {
        return widget.optimisticScores![i + 1] ?? (i < gridScores.length ? gridScores[i] : null);
      });
    }

    // Conflicts on an approved card are historical — suppress conflict UI
    final conflictedHoles = (displayCard?.status == ScorecardStatus.approved)
        ? const <int>{}
        : (displayCard?.conflictedHoles.toSet() ?? const <int>{});

    final matchPlay = _computeMatchPlay(displayId, allScorecards, members);

    // Fourball pair rows: driven by the bottom ME / OPPONENT tab.
    // ME tab (MarkerTab.verifier) → US pair: me + partner.
    // OPPONENT tab (MarkerTab.player) → THEM pair: targetId + their partner.
    List<CourseScoreRow> fourballAdditionalRows = [];
    Set<int> fourballMainCountingHoles = {};
    String? fourballMainRowLabel;
    if (isFourball) {
      final isStableford = widget.effectiveRules.format == CompetitionFormat.stableford;
      // US view = viewing own card; THEM view = viewing any other card (opponent or switched).
      final isUsView = displayId == currentUser.id;
      String? secondaryId;
      String? secondaryLabel;
      if (isUsView && fourballPartner != null) {
        secondaryId = fourballPartner.registrationMemberId;
        secondaryLabel = fourballPartner.name.split(' ').first;
        fourballMainRowLabel = 'ME';
      } else if (!isUsView && fourballOpponents.isNotEmpty) {
        // displayId = targetId (the opponent I'm marking) — find their pair partner
        final opponentPartner = fourballOpponents.firstWhereOrNull(
          (p) => p.registrationMemberId != displayId,
        );
        if (opponentPartner != null) {
          secondaryId = opponentPartner.registrationMemberId;
          secondaryLabel = opponentPartner.name.split(' ').first;
        }
        fourballMainRowLabel = fourballOpponents
            .firstWhereOrNull((p) => p.registrationMemberId == displayId)
            ?.name.split(' ').first.toUpperCase();
      }
      if (secondaryId != null) {
        final primaryScoring = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == displayId);
        final secondaryScoring = widget.scoringData?.individualScores.firstWhereOrNull((s) => s.playerId == secondaryId);
        final secondaryCard = allScorecards.firstWhereOrNull((s) => s.entryId == secondaryId);
        final Set<int> primaryCountingHoles = {};
        final Set<int> secondaryCountingHoles = {};
        for (int h = 0; h < 18; h++) {
          if (isStableford) {
            final pPts = primaryScoring?.result.holePoints.elementAtOrNull(h);
            final sPts = secondaryScoring?.result.holePoints.elementAtOrNull(h);
            if (pPts != null && pPts > 0 && (sPts == null || pPts > sPts)) {
              primaryCountingHoles.add(h);
            } else if (sPts != null && sPts > 0 && (pPts == null || sPts > pPts)) {
              secondaryCountingHoles.add(h);
            }
            // tie → no dot on either
          } else {
            final pNet = primaryScoring?.result.holeNetScores.elementAtOrNull(h);
            final sNet = secondaryScoring?.result.holeNetScores.elementAtOrNull(h);
            if (pNet != null && (sNet == null || pNet < sNet)) {
              primaryCountingHoles.add(h);
            } else if (sNet != null && (pNet == null || sNet < pNet)) {
              secondaryCountingHoles.add(h);
            }
            // tie → no dot on either
          }
        }
        fourballMainCountingHoles = primaryCountingHoles;
        fourballAdditionalRows.add(CourseScoreRow(
          id: secondaryId,
          playerName: secondaryLabel ?? 'Partner',
          scores: secondaryScoring?.holeScores ?? secondaryCard?.holeScores.cast<int?>() ?? List.filled(18, null),
          netScores: secondaryScoring?.result.holeNetScores.toList(),
          points: secondaryScoring?.result.holePoints.toList(),
          countingHoles: secondaryCountingHoles.isNotEmpty ? secondaryCountingHoles : null,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isFourball && widget.effectiveRules.isUnifiedTeamFormat)
          _buildTeamMembersRow(context, widget.event, widget.effectiveRules),

        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BoxyArtIndicator.hc(label: _formatHcp(displayBaseHcp), hasHorizontalMargin: false),
                  BoxyArtIndicator.phc(label: '$displayPlayingHcp${hasSocietyCutActual ? '*' : ''}'),
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

        CourseInfoCard(
          courseConfig: playerTeeConfig,
          selectedTeeName: playerTeeName,
          distanceUnit: config.distanceUnit,
          isStableford: widget.effectiveRules.format == CompetitionFormat.stableford,
          isNet: widget.effectiveRules.handicapAllowance != 0,
          paged: true,
          holeScores: gridScores,
          playerHandicap: displayPlayingHcp,
          handicapAllowance: widget.effectiveRules.handicapAllowance,
          format: widget.effectiveRules.format,
          maxScoreConfig: widget.effectiveRules.maxScoreConfig,
          matchPlayResults: matchPlay.$1,
          matchPlayStrokesReceived: matchPlay.$2,
          tieBreakLabel: displayScoring?.tieBreakLabel,
          holeTags: displayCard?.holeTags,
          conflictedHoles: conflictedHoles,
          showYardage: true,
          markerVerified: displayCard?.verifiedByMarker ?? false,
          additionalRows: fourballAdditionalRows.isNotEmpty ? fourballAdditionalRows : null,
          mainRowLabel: fourballMainRowLabel,
          mainCountingHoles: fourballMainCountingHoles.isNotEmpty ? fourballMainCountingHoles : null,
          // Show marker's recorded scores on: own card, conflicted cards, or any guest card
          // (guests can't self-enter so playerVerifierScores is the only score record)
          verifierScores: (displayCard?.playerVerifierScores.any((s) => s != null && s > 0) ?? false) &&
                  (displayId == currentUser.id ||
                      displayCard?.markerId == currentUser.id ||
                      (displayCard?.conflictedHoles.isNotEmpty ?? false) ||
                      (displayId.endsWith('_guest')) ||
                      (displayCard?.markerId?.endsWith('_guest') == true))
              ? displayCard!.playerVerifierScores
              : null,
        ),

        // Submitted banner — only on own card, only while awaiting admin approval
        if (displayId == currentUser.id &&
            (displayCard?.status == ScorecardStatus.finalScore ||
             displayCard?.status == ScorecardStatus.reviewed))
          Padding(
            padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.cardToCard),
            child: BoxyArtStatusBanner(
              color: AppColors.amber500,
              icon: Icons.schedule_rounded,
              message: 'Card submitted — awaiting committee approval',
              hasBottomMargin: false,
            ),
          ),

        // Conflict strip — below the card for birds-eye summary
        if (conflictedHoles.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.cardToCard),
            child: _buildConflictStrip(context, conflictedHoles, displayCard),
          ),

        // Score amendments — visible to member when card is approved and has audit entries
        if (displayCard?.status == ScorecardStatus.approved &&
            (displayCard?.holeAuditLog.isNotEmpty ?? false))
          Padding(
            padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.cardToCard),
            child: _buildMemberAuditLog(context, displayCard!.holeAuditLog),
          ),

        // Approved banner — last element, closing confirmation once admin has verified
        if (displayCard?.status == ScorecardStatus.approved)
          Padding(
            padding: EdgeInsets.only(top: spacing?.cardToCard ?? AppSpacing.cardToCard),
            child: BoxyArtStatusBanner(
              color: AppColors.lime500,
              icon: Icons.verified_rounded,
              message: 'Approved by committee',
              hasBottomMargin: false,
            ),
          ),

      ],
    );
  }

  (List<String>?, int?) _computeMatchPlay(
    String displayId,
    List<Scorecard> allScorecards,
    List<dynamic> members,
  ) {
    if (widget.comp == null || widget.comp!.rules.isMatchPlay != true) return (null, null);

    final groupsData = widget.event.grouping['groups'] as List? ?? [];
    List<String>? myGroupIds;
    for (final g in groupsData) {
      final players = g['players'] as List? ?? [];
      final ids = players
          .map((p) => p['registrationMemberId']?.toString())
          .whereType<String>()
          .toList();
      if (ids.contains(displayId)) {
        myGroupIds = ids;
        break;
      }
    }
    if (myGroupIds == null || myGroupIds.length < 2) return (null, null);

    final oppIds = myGroupIds.where((id) => id != displayId).toList();

    final Map<String, double> playerIndices = {};
    final Map<String, CourseConfig> courseConfigs = {};
    for (final pid in myGroupIds) {
      courseConfigs[pid] = ScoringCalculator.resolvePlayerCourseConfig(
        memberId: pid,
        event: widget.event,
        membersList: members.cast(),
        manualTeeName: null,
      );
      if (pid.contains('_guest')) {
        final baseId = pid.replaceAll('_guest', '');
        final reg = widget.event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
        playerIndices[pid] = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
      } else {
        final member = members.firstWhereOrNull((m) => (m as dynamic).id == pid);
        playerIndices[pid] = (member as dynamic)?.handicap ?? 18.0;
      }
    }

    final strokesReceived = MatchPlayCalculator.calculateRelativeStrokes(
      playerIds: myGroupIds,
      playerIndices: playerIndices,
      courseConfigs: courseConfigs,
      rules: widget.effectiveRules,
      baseRating: widget.event.courseConfig.rating ?? 72.0,
    );
    final myStrokes = strokesReceived[displayId];

    final virtualMatch = MatchDefinition(
      id: 'virtual_scorecard_$displayId',
      type: MatchType.singles,
      team1Ids: [displayId],
      team2Ids: oppIds,
      strokesReceived: strokesReceived,
    );

    final List<Scorecard> sourceCards = [];
    for (final pid in myGroupIds) {
      Scorecard? card = allScorecards.firstWhereOrNull((s) => s.entryId == pid);
      if (card == null) {
        final seeded = widget.event.results.firstWhereOrNull(
          (r) => FirestoreNormalizer.resolveMemberId(r) == pid,
        );
        if (seeded != null && seeded['holeScores'] != null) {
          card = ScorecardFactory.fromSeededResult(
            entryId: pid,
            competitionId: widget.event.id,
            result: seeded,
          );
        }
      }
      if (card != null) sourceCards.add(card);
    }

    if (sourceCards.length < 2) return (null, myStrokes);

    final result = MatchPlayCalculator.calculate(
      match: virtualMatch,
      scorecards: sourceCards,
      courseConfig: widget.event.courseConfig,
      holesToPlay: widget.event.courseConfig.holes.length,
    );

    final holeResults = result.holeResults.map((r) {
      if (r == 1) return 'W';
      if (r == -1) return 'L';
      return 'H';
    }).toList();
    return (holeResults, myStrokes);
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
    final teamSize = rules.effectiveTeamSize;
    int teamIdx = playerIdx ~/ teamSize;
    final List<TeeGroupParticipant> teamMembers = players.skip(teamIdx * teamSize).take(teamSize).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: teamMembers.map((p) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.atomic),
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

  String _formatHcp(double hcp) {
    if (hcp == hcp.toInt()) return hcp.toInt().toString();
    return hcp.toStringAsFixed(1);
  }

  Widget _buildMemberAuditLog(BuildContext context, List<HoleAuditEntry> log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxyArtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.edit_note_rounded, size: AppShapes.iconSmall, color: AppColors.amber500),
            const SizedBox(width: AppSpacing.xs),
            Text('Score Amendments', style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold)),
          ]),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < log.length; i++) ...[
            if (i > 0) const Divider(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxyArtNumberBadge(number: log[i].hole, size: 32, isRanking: false),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hole ${log[i].hole} score corrected to ${log[i].resolvedTo}',
                        style: AppTypography.cardTitle,
                      ),
                      if (log[i].reason.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '"${log[i].reason}"',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.dark300 : AppColors.dark400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
