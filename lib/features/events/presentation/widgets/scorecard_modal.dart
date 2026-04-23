import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/models/course_config.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/domain/match_definition.dart';
import 'course_info_card.dart';
import '../../../competitions/data/scorecard_repository.dart';
import '../../../competitions/presentation/competitions_provider.dart';


class ScorecardModal {
  static void show(
    BuildContext context, 
    WidgetRef ref, {
    required LeaderboardEntry entry,
    required List<Scorecard> scorecards,
    required GolfEvent event,
    required Competition? comp,
    List<Member> membersList = const [],
    int? holeLimit,
    bool isAdmin = false,
    Map<String, String>? teeOverrides, // [NEW] Manual tee overrides
  }) {
    debugPrint("--- SCORECARD MODAL SHOW: ${entry.playerName} ---");
    debugPrint("Entry ID: ${entry.entryId}");
    debugPrint("Mode: ${entry.mode}");
    debugPrint("TeamMemberIds: ${entry.teamMemberIds?.length} -> ${entry.teamMemberIds}");
    debugPrint("TeamMemberNames: ${entry.teamMemberNames?.length} -> ${entry.teamMemberNames}");
    debugPrint("HoleScores provided: ${entry.holeScores != null && entry.holeScores!.any((s) => s != null)}");
    
    // 0. Prioritize scores passed directly from Leaderboard (Fix for Scramble populating)
    Scorecard? scorecard;
    bool isScorecardEmpty = true;

    if (entry.holeScores != null && entry.holeScores!.any((s) => s != null)) {
      debugPrint("Found scores via Direct Bridge");
      scorecard = Scorecard(
        id: 'direct_${entry.entryId}',
        competitionId: event.id,
        roundId: '1',
        entryId: entry.entryId,
        submittedByUserId: 'system',
        status: ScorecardStatus.finalScore,
        holeScores: entry.holeScores!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      isScorecardEmpty = false;
    }

    // 1. Try to find a live scorecard if not found directly
    if (isScorecardEmpty) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == entry.entryId);
      isScorecardEmpty = scorecard == null || scorecard.holeScores.every((s) => s == null);
      if (!isScorecardEmpty) debugPrint("Found scores via Step 1 (Live Scorecard)");
    }
    
    // 1b. Fallback for Team: Try each member ID if the combined team ID lookup fails or is empty
    if (isScorecardEmpty && entry.teamMemberIds != null) {
      for (final memberId in entry.teamMemberIds!) {
        final memberCard = scorecards.firstWhereOrNull((s) => s.entryId == memberId);
        if (memberCard != null && memberCard.holeScores.any((s) => s != null)) {
          scorecard = memberCard;
          isScorecardEmpty = false;
          debugPrint("Found scores via Step 1b (Team Member Scorecard)");
          break;
        }
      }
    }
    
    // 1c. Double Fallback for Seeded Teams (team_N pattern)
    if (isScorecardEmpty && entry.teamIndex != null) {
      final seededTeamId = 'team_${entry.teamIndex}';
      final teamCard = scorecards.firstWhereOrNull((s) => s.entryId == seededTeamId);
      if (teamCard != null && teamCard.holeScores.any((s) => s != null)) {
         scorecard = teamCard;
         isScorecardEmpty = false;
         debugPrint("Found scores via Step 1c (Seeded team_N Scorecard)");
      }
    }

    // 2. Fallback: Reconstruct from seeded results if live scorecard is missing or empty
    if (isScorecardEmpty) {
      // 2a. Direct Match
      var seededResult = event.results.firstWhereOrNull(
        (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == entry.entryId,
      );
      
      // 2b. Fallback for Team Seeded: Try each member
      if (seededResult == null && entry.teamMemberIds != null) {
        for (final memberId in entry.teamMemberIds!) {
          final s = event.results.firstWhereOrNull(
            (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == memberId
          );
          if (s != null && s['holeScores'] != null && (s['holeScores'] as List).any((score) => score != null)) {
            seededResult = s;
            break;
          }
        }
      }

      // 2c. Last Resort: Try team index pattern in results (if stored there)
      if (seededResult == null && entry.teamIndex != null) {
        final seededTeamId = 'team_${entry.teamIndex}';
        seededResult = event.results.firstWhereOrNull(
          (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == seededTeamId,
        );
      }

      if (seededResult != null && seededResult['holeScores'] != null) {
        debugPrint("Found scores via Step 2 (Seeded Results map)");
        // Reconstruct temporary scorecard object
        scorecard = Scorecard(
          id: 'temp_${entry.entryId}',
          competitionId: event.id,
          roundId: '1',
          entryId: entry.entryId,
          submittedByUserId: 'system',
          status: ScorecardStatus.finalScore,
          holeScores: List<int?>.from(seededResult['holeScores']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          points: seededResult['points'] is num ? (seededResult['points'] as num).toInt() : null,
          netTotal: seededResult['netTotal'] is num ? (seededResult['netTotal'] as num).toInt() : null,
        );
        isScorecardEmpty = false;
      }
    }

    // 3. Final Bail if truly missing (but allow empty modal for groups with NO scores yet)
    scorecard ??= Scorecard(
        id: 'empty_${entry.entryId}',
        competitionId: event.id,
        roundId: '1',
        entryId: entry.entryId,
        submittedByUserId: 'system',
        status: ScorecardStatus.draft,
        holeScores: List.generate(18, (index) => null),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

    final actualScorecard = scorecard;
    
    // Respect Lab Mode override
    final currentFormat = comp?.rules.format ?? CompetitionFormat.stableford;
    // Determine if this entry is a guest

    // Dynamic Height Adjustment for Team/Multiple Names
    final nameCount = entry.teamMemberNames?.length ?? 1;
    final isTeamDisplay = nameCount > 1;
    
    // "Come out further" -> Increase initial height to fit full scorecard
    final double dynamicInitialSize = isTeamDisplay ? 0.95 : 0.90;

    // Initial focused player for mixed tee context
    // If team mode, default to 'team' if it's a cumulative format, else if mixed tee choice matters, stay on first player.
    // Let's default to the first player now (as per user request)
    final isFourball = comp?.rules.subtype == CompetitionSubtype.fourball;
    String focusedPlayerId = (entry.teamMemberIds != null && entry.teamMemberIds!.isNotEmpty)
        ? entry.teamMemberIds!.first
        : entry.entryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use branch navigator so the global bottom nav bar stays visible behind the sheet.
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: dynamicInitialSize,
          minChildSize: 0.60,
          maxChildSize: 0.92, // Cap below 1.0 so the nav bar is never fully occluded
          builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: AppShapes.sheet,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: AppSpacing.x4l,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: AppColors.dark400.withValues(alpha: AppColors.opacityMedium),
                  borderRadius: AppShapes.grabber,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Constrain width to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (() {
                            final effectiveFocusId = focusedPlayerId == 'team' 
                                ? (entry.teamMemberIds?.first ?? entry.entryId) 
                                : focusedPlayerId;
                            final manualTee = teeOverrides?[effectiveFocusId];
                            final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                              memberId: effectiveFocusId, 
                              event: event, 
                              membersList: membersList, 
                              manualTeeName: manualTee,
                            );
                            final teeName = manualTee ?? (playerTeeConfig.selectedTeeName ?? (event.selectedTeeName ?? 'Yellow'));
                            final teeColor = _getTeeColor(teeName, playerTeeConfig.tees);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          toTitleCase(entry.playerName),
                                          style: AppTypography.display.copyWith(
                                            color: AppColors.dark900,
                                            fontWeight: AppTypography.weightHeavy,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isAdmin && actualScorecard.status == ScorecardStatus.submitted)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.lime500),
                                            tooltip: 'Approve Scorecard',
                                            onPressed: () async {
                                              final confirmed = await showBoxyArtDialog<bool>(
                                                context: context,
                                                title: 'Approve Scorecard?',
                                                message: 'Mark this scorecard as Reviewed.',
                                                confirmText: 'Approve',
                                              );
                                              if (confirmed == true) {
                                                await ref.read(scorecardRepositoryProvider).updateScorecardStatus(actualScorecard.id, ScorecardStatus.reviewed);
                                                if (context.mounted) Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        if (isAdmin)
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, color: AppColors.lime500),
                                            tooltip: 'Edit Scores',
                                            onPressed: () {
                                              Navigator.pop(context); // Close modal
                                              context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/scores/${entry.entryId}');
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: AppColors.dark150),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isFourball || (entry.teamMemberNames != null && entry.teamMemberNames!.length > 1)) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (isFourball)
                                        _buildViewPill(
                                          label: 'Team View',
                                          isSelected: focusedPlayerId == 'team',
                                          onTap: () => setModalState(() => focusedPlayerId = 'team'),
                                        ),
                                      ...entry.teamMemberNames!.asMap().entries.map((e) {
                                        final idx = e.key;
                                        final name = e.value;
                                        final id = entry.teamMemberIds![idx];
                                        return _buildViewPill(
                                          label: name,
                                          isSelected: focusedPlayerId == id,
                                          onTap: () => setModalState(() => focusedPlayerId = id),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    BoxyArtIndicator.hc(label: entry.handicapIndex.toStringAsFixed(1)),
                                    if (entry.playingHandicap != null) ...[
                                      const SizedBox(width: AppSpacing.md),
                                      BoxyArtIndicator.phc(context: context, label: '${entry.playingHandicap}'),
                                    ],
                                    const Spacer(),
                                    BoxyArtIndicator.tee(label: teeName, teeColor: teeColor),
                                  ],
                                ),
                                if (entry.thruLabel != null || entry.tieBreakLabel != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (entry.thruLabel != null)
                                        BoxyArtPill.status(label: entry.thruLabel!, color: AppColors.lime500),
                                      if (entry.tieBreakLabel != null)
                                        BoxyArtPill.status(label: entry.tieBreakLabel!, color: AppColors.dark400),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          })(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100.0),
                  child: Builder(
                    builder: (context) {
                      if (comp == null) return const Center(child: CircularProgressIndicator());
                      // Resolve effective rules/format for modal
                      final effectiveMaxScore = comp.rules.maxScoreConfig;

                      // [NEW] Logic for Team/Pairs Display
                      List<CourseScoreRow> additionalRows = [];
                      List<int?>? bestBallPoints;
                      
                      final isFourball = comp?.rules.subtype == CompetitionSubtype.fourball;
                      final isTeam = comp?.rules.mode == CompetitionMode.teams;
                      final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                      final isScrambleFormat = comp?.rules.format == CompetitionFormat.scramble;
                      
                      if ((isStableford || comp?.rules.scoringType == 'STABLEFORD') && (isFourball || isTeam)) {
                        bestBallPoints = entry.holePoints;
                      }

                      final totalPoints = entry.holePoints?.whereType<int>().fold<int>(0, (a, b) => a + b);

                      // --- [NEW] AUTHORITATIVE MATCH PLAY CALCULATION ---
                      List<String>? matchPlayResults;
                      String? matchPlaySummary;
                      int? conclusionHole;
                      if (currentFormat == CompetitionFormat.matchPlay) {
                        final myIds = entry.teamMemberIds ?? [entry.entryId];
                        List<String>? myGroupIds;
                        final groupsData = event.grouping["groups"] as List? ?? [];
                        for (var g in groupsData) {
                          final players = g['players'] as List? ?? [];
                          final playerIds = players.map((p) => p['registrationMemberId']?.toString()).whereType<String>().toList();
                          if (playerIds.any((id) => myIds.contains(id))) {
                            myGroupIds = playerIds;
                            break;
                          }
                        }
                        if (myGroupIds != null) {
                          final oppIds = myGroupIds.where((id) => !myIds.contains(id)).toList();
                          if (oppIds.isNotEmpty) {
                            final Map<String, double> playerIndices = {};
                            final Map<String, CourseConfig> courseConfigs = {};
                            for (final pid in myGroupIds) {
                              final manualTee = teeOverrides?[pid];
                              courseConfigs[pid] = ScoringCalculator.resolvePlayerCourseConfig(
                                memberId: pid, 
                                event: event, 
                                membersList: membersList, 
                                manualTeeName: manualTee,
                              );
                              if (pid.contains('_guest')) {
                                final baseId = pid.replaceAll('_guest', '');
                                final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
                                playerIndices[pid] = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
                              } else {
                                final member = membersList.firstWhereOrNull((m) => m.id == pid);
                                playerIndices[pid] = member?.handicap ?? 18.0;
                              }
                            }

                            final baseRating = event.courseConfig.rating ?? 72.0;
                            final strokesReceived = MatchPlayCalculator.calculateRelativeStrokes(
                              playerIds: myGroupIds,
                              playerIndices: playerIndices,
                              courseConfigs: courseConfigs,
                              rules: comp!.rules,
                              baseRating: baseRating,
                            );

                            final virtualMatch = MatchDefinition(
                              id: 'virtual_modal_${entry.entryId}',
                              type: comp.rules.subtype == CompetitionSubtype.fourball ? MatchType.fourball : MatchType.foursomes,
                              team1Ids: myIds,
                              team2Ids: oppIds,
                              strokesReceived: strokesReceived,
                            );

                            final List<Scorecard> sourceCards = [];
                            for (var pid in myGroupIds) {
                              Scorecard? card = scorecards.firstWhereOrNull((s) => s.entryId == pid);
                              if (card == null) {
                                final seeded = event.results.firstWhereOrNull((r) => 
                                  (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? '').toString() == pid
                                );
                                if (seeded != null && seeded['holeScores'] != null) {
                                  card = Scorecard(
                                    id: 'temp_$pid', competitionId: event.id, roundId: '1', entryId: pid, submittedByUserId: 'system',
                                    status: ScorecardStatus.finalScore, holeScores: List<int?>.from(seeded['holeScores']),
                                    createdAt: DateTime.now(), updatedAt: DateTime.now()
                                  );
                                }
                              }
                              if (card != null) sourceCards.add(card);
                            }

                            final result = MatchPlayCalculator.calculate(
                              match: virtualMatch,
                              scorecards: sourceCards,
                              courseConfig: event.courseConfig,
                              holesToPlay: event.courseConfig.holes.length,
                            );

                            conclusionHole = result.isFinal ? result.holesPlayed : null;

                            matchPlayResults = result.holeResults.map((r) {
                              if (r == 1) return 'W';
                              if (r == -1) return 'L';
                              if (r == 0) return 'H';
                              return ''; 
                            }).toList();
                            
                            if (result.score == 0) {
                              matchPlaySummary = result.holesPlayed == 0 ? 'AS' : (result.isFinal ? 'HALVED' : 'AS');
                            } else if (result.score > 0) {
                              matchPlaySummary = result.isFinal ? 'WIN ${result.status}' : '${result.status} (UP)';
                            } else {
                              matchPlaySummary = result.isFinal ? 'LOSS ${result.status}' : '${result.status} (DN)';
                            }
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (() {
                             // Context resolution
                             final effectiveFocusId = focusedPlayerId == 'team' 
                                 ? (entry.teamMemberIds?.first ?? entry.entryId) 
                                 : focusedPlayerId;

                             final manualTee = teeOverrides?[effectiveFocusId];
                             final playerTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                               memberId: effectiveFocusId, 
                               event: event, 
                               membersList: membersList, 
                               manualTeeName: manualTee,
                             );
                             final playerTeeName = manualTee ?? (playerTeeConfig.selectedTeeName ?? (event.selectedTeeName ?? 'Yellow'));

                             return CourseInfoCard(
                               courseConfig: playerTeeConfig,
                               selectedTeeName: playerTeeName,
                               isStableford: isStableford,
                               isNet: comp?.rules.scoringType != 'GROSS',
                               format: currentFormat,
                               maxScoreConfig: effectiveMaxScore,
                               holeScores: entry.holeScores,
                               holeNetScores: entry.holeNetScores,
                               holePoints: entry.holePoints,
                               holePars: event.courseConfig.holes.map((h) => h.par).toList(),
                               holeSIs: event.courseConfig.holes.map((h) => h.si).toList(),
                               holeDistances: event.courseConfig.holes.map((h) => h.yardage ?? 0).toList(),
                               mainRowLabel: focusedPlayerId == 'team' ? (isFourball ? 'BEST BALL' : 'TEAM') : 'Strokes',
                               additionalRows: additionalRows, 
                               holeLimit: holeLimit,
                               overrideTotalPoints: totalPoints,
                               matchPlayResults: matchPlayResults,
                               conclusionHole: conclusionHole,
                             );
                          })(),
                          const SizedBox(height: AppSpacing.x2l),
                          ScorecardModal.buildUnifiedComparisonFooter(
                            context,
                            event: event,
                            membersList: membersList,
                            teamPoints: bestBallPoints,
                            isScramble: isScrambleFormat,
                            scorecard: actualScorecard,
                            playerName: isFourball == true ? 'TEAM BEST BALL' : (isTeam == true ? 'TEAM SCORE' : entry.playerName),
                            matchPlayResults: matchPlayResults,
                            matchPlaySummary: matchPlaySummary,
                            mode: comp?.rules.mode,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  static Widget buildUnifiedComparisonFooter(
    BuildContext context, {
    required GolfEvent event,
    required List<Member> membersList,
    required bool isScramble,
    Scorecard? scorecard,
    List<int?>? teamPoints,
    String? playerName,
    List<String>? matchPlayResults,
    String? matchPlaySummary,
    CompetitionMode? mode,
  }) {
    final List<int?> scores = teamPoints ?? scorecard?.holeScores ?? [];
    
    // REDUNDANCY CHECK: 
    // If it's not a Team game, not Match Play, and not showing Scramble attributions, 
    // then showing a "Group Score" summary of the SAME player is redundant.
    final bool isTeamGame = teamPoints != null || (mode != null && mode != CompetitionMode.singles);
    final bool hasMatchPlay = matchPlayResults != null;
    final bool hasScrambleAttributions = isScramble && (scorecard?.shotAttributions.isNotEmpty ?? false);

    if (!isTeamGame && !hasMatchPlay && !hasScrambleAttributions) {
      return const SizedBox.shrink();
    }

    if (matchPlayResults == null && (scores.isEmpty || scores.every((s) => s == null))) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            (isScramble ? "DRIVE ATTRIBUTIONS" : (matchPlayResults != null ? "MATCH PLAY RESULT" : "GROUP SCORE")),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (isScramble && scorecard != null && scorecard.shotAttributions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: scorecard.shotAttributions.entries.map((attr) {
                final holeNum = attr.key + 1;
                final memberId = attr.value;
                // Note: additionalRows removed from signature, we'll try to find name from membersList
                final member = membersList.firstWhereOrNull((m) => m.id == memberId);
                final name = member?.displayName.split(' ').first ?? 'Player';
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                    borderRadius: AppShapes.xs,
                    border: Border.all(color: AppColors.lime500.withValues(alpha: AppColors.opacityMuted)),
                  ),
                  child: Text(
                    "H$holeNum: $name",
                    style: const TextStyle(
                      fontSize: AppTypography.sizeCaption,
                      fontWeight: AppTypography.weightBlack,
                      color: AppColors.lime500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // Unified Team Row
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: AppSpacing.md,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teamA,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Text(
                    toTitleCase(playerName ?? "Team"),
                    style: TextStyle(
                      fontSize: AppTypography.sizeCaption,
                      fontWeight: AppTypography.weightBlack,
                      color: AppColors.lime500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    matchPlayResults != null 
                        ? "Total: ${matchPlaySummary ?? 'AS'}"
                        : "Total: ${scores.where((s) => s != null).fold<int>(0, (sum, s) => sum + (s as int))}",
                    style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                children: [
                  _buildNineHoleRow(context, event, membersList, scores, 0, matchPlayResults: matchPlayResults),
                  const SizedBox(height: AppSpacing.xs),
                  _buildNineHoleRow(context, event, membersList, scores, 9, matchPlayResults: matchPlayResults),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildNineHoleRow(
    BuildContext context, 
    GolfEvent event, 
    List<Member> membersList, 
    List<int?> scores, 
    int startIdx, {
    List<String>? matchPlayResults,
  }) {
    // We use the event course config by default for the UNIFIED view

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.dark600,
        borderRadius: AppShapes.sm,
        border: Border.all(color: AppColors.dark500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(9, (i) {
          final hIdx = startIdx + i;
          
          if (matchPlayResults != null) {
              final result = matchPlayResults.length > hIdx ? matchPlayResults[hIdx] : '';
              Color bgColor = Colors.transparent;
              Color textColor = AppColors.textSecondary;
              Color borderColor = AppColors.textSecondary;
              
              if (result == 'W') {
                  bgColor = AppColors.lime500;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.lime500;
              } else if (result == 'L') {
                  bgColor = AppColors.coral500;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.coral500;
              } else if (result == 'H') {
                  bgColor = AppColors.textSecondary;
                  textColor = AppColors.pureWhite;
                  borderColor = AppColors.textSecondary;
              }

              return Expanded(
                child: Container(
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppShapes.sm,
                    border: Border.all(color: borderColor, width: AppShapes.borderThin),
                  ),
                  child: Text(
                    result.isEmpty ? '-' : result,
                      style: AppTypography.label.copyWith(
                        fontWeight: AppTypography.weightHeavy,
                        color: textColor,
                      ),
                  ),
                ),
              );
          }

          final score = scores.length > hIdx ? scores[hIdx] : null;

          // Points Calculation (Assuming Stableford for unified view unless it's Medal)
          
          final points = score; // We assume the passed 'scores' are already points if it's Fourball

          return Expanded(
            child: Container(
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: points != null ? AppColors.dark500 : Colors.transparent,
                borderRadius: AppShapes.sm,
                border: Border.all(
                  color: points != null ? AppColors.dark400 : AppColors.dark500,
                  width: AppShapes.borderThin,
                ),
              ),
              child: Text(
                points?.toString() ?? '-',
                style: TextStyle(
                  fontSize: AppTypography.sizeCaptionStrong,
                  fontWeight: points != null ? AppTypography.weightBlack : AppTypography.weightBold,
                  color: points != null ? AppColors.lime500 : AppColors.dark400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }



  static Widget _buildViewPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime500.withValues(alpha: AppColors.opacityLow) : Colors.transparent,
          borderRadius: AppShapes.pill,
          border: Border.all(
            color: isSelected ? AppColors.lime500 : AppColors.dark500,
            width: AppShapes.borderThin,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.micro.copyWith(
            fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightStrong,
            color: isSelected ? AppColors.lime500 : AppColors.dark300,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  static Color _getTeeColor(String teeName, [List<TeeConfig>? teeConfigs]) {
    return AppColors.getTeeColor(teeName, teeConfigs);
  }
}

// Helper functions moved from string_utils for stability
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  final lower = text.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
