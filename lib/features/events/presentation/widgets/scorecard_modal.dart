import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/models/course_config.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/domain/match_definition.dart';
import 'course_info_card.dart';


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
    final bool isGuest = entry.isGuest || entry.entryId.endsWith('_guest');

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
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: dynamicInitialSize,
          minChildSize: 0.60,
          maxChildSize: 0.98,
          builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dark400.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Constrain width to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Player Name(s) + Guest Pill
                          // Player Name(s) / Interactive Pills
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isFourball)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setModalState(() => focusedPlayerId = 'team'),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
                                    child: Text(
                                      'TEAM VIEW',
                                      style: AppTypography.label.copyWith(
                                        fontSize: 13, 
                                        color: focusedPlayerId == 'team' ? AppColors.lime500 : AppColors.dark200,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              if (entry.teamMemberNames != null && entry.teamMemberNames!.isNotEmpty)
                                ...entry.teamMemberNames!.asMap().entries.map((e) {
                                  final idx = e.key;
                                  final name = e.value;
                                  final id = entry.teamMemberIds![idx];
                                  final isFocused = id == focusedPlayerId;
                                  final isMemberGuest = id.contains('_guest') || (entry.isGuest && entry.teamMemberIds!.length == 1);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: _buildHeaderPill(
                                      context: context,
                                      label: name,
                                      isFocused: isFocused,
                                      showGuest: isMemberGuest,
                                      onTap: () => setModalState(() => focusedPlayerId = id),
                                    ),
                                  );
                                })
                              else
                                _buildHeaderPill(
                                  context: context,
                                  label: entry.playerName,
                                  isFocused: true,
                                  showGuest: isGuest,
                                  onTap: () {},
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
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
                            final teeColor = _getTeeColor(teeName);

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                BoxyArtPill.hc(label: '${entry.handicap}'),
                                if (entry.playingHandicap != null)
                                  BoxyArtPill.phc(context: context, label: '${entry.playingHandicap}'),
                                BoxyArtPill.tee(label: teeName, teeColor: teeColor),
                              ],
                            );
                          })(),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep minimal width
                      children: [
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: AppColors.lime500),
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
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Builder(
                    builder: (context) {
                      // Resolve effective rules/format for modal
                      final effectiveMaxScore = comp?.rules.maxScoreConfig;

                      // [NEW] Logic for Team/Pairs Display
                      List<CourseScoreRow> additionalRows = [];
                      List<int?>? bestBallPoints;
                      
                      final isFourball = comp?.rules.subtype == CompetitionSubtype.fourball;
                      final isTeam = comp?.rules.mode == CompetitionMode.teams;
                      final isStableford = comp?.rules.format == CompetitionFormat.stableford;
                      final isScrambleFormat = comp?.rules.format == CompetitionFormat.scramble;
                      
                      if (entry.teamMemberIds != null && entry.teamMemberIds!.isNotEmpty) {
                         if (isStableford || comp?.rules.scoringType == 'STABLEFORD') {
                           bestBallPoints = List<int?>.filled(18, null);
                         }

                         for (int i = 0; i < entry.teamMemberIds!.length; i++) {
                             final id = entry.teamMemberIds![i];
                             final name = (entry.teamMemberNames != null && i < entry.teamMemberNames!.length) 
                                 ? entry.teamMemberNames![i] 
                                 : 'Player ${i+1}';
                             
                             Scorecard? card = scorecards.firstWhereOrNull((s) => s.entryId == id);
                             
                             // Fallback for seeded data
                             if (card == null) {
                                final seeded = event.results.firstWhere(
                                  (r) => (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString() == id,
                                  orElse: () => {},
                                );
                                if (seeded.isNotEmpty && seeded['holeScores'] != null) {
                                   card = Scorecard(
                                     id: 'temp_$id',
                                     competitionId: event.id,
                                     roundId: '1',
                                     entryId: id,
                                     submittedByUserId: 'system',
                                     status: ScorecardStatus.finalScore,
                                     holeScores: List<int?>.from(seeded['holeScores']),
                                     createdAt: DateTime.now(),
                                     updatedAt: DateTime.now(),
                                   );
                                }
                             }

                             if (card != null) {
                                final Set<int> memberCountingHoles = {};
                                if (entry.countingMemberIds != null) {
                                   entry.countingMemberIds!.forEach((holeIdx, memberId) {
                                      if (memberId == id) memberCountingHoles.add(holeIdx);
                                   });
                                }

                                 final manualTee = teeOverrides?[id];
                                 final playerConfig = ScoringCalculator.resolvePlayerCourseConfig(
                                   memberId: id, 
                                   event: event, 
                                   membersList: membersList, 
                                   manualTeeName: manualTee,
                                 );
                                 final member = membersList.firstWhereOrNull((m) => m.id == id);
                                final playerPhc = HandicapCalculator.calculatePlayingHandicap(
                                  handicapIndex: member?.handicap ?? 18.0,
                                  rules: comp!.rules,
                                  courseConfig: playerConfig,
                                );

                                additionalRows.add(CourseScoreRow(
                                  id: id,
                                  playerName: name,
                                  scores: card.holeScores,
                                  handicap: playerPhc,
                                  color: i == 0 ? Colors.blue[800] : Colors.green[800],
                                  countingHoles: memberCountingHoles,
                                ));

                                // Calculate contribution to Best Ball points
                                if (isStableford && bestBallPoints != null) {
                                  final playerHoles = playerConfig.holes;
                                  for (int h = 0; h < 18; h++) {
                                    final score = card.holeScores.length > h ? card.holeScores[h] : null;
                                    if (score != null) {
                                      final par = playerHoles.length > h ? playerHoles[h].par : 4;
                                      final si = playerHoles.length > h ? playerHoles[h].si : 18;
                                      
                                      int shots = (playerPhc / 18).floor();
                                      if (playerPhc % 18 >= si) shots++;
                                      
                                      final pts = (par - (score - shots) + 2).clamp(0, 8);
                                      if (bestBallPoints[h] == null || pts > bestBallPoints[h]!) {
                                        bestBallPoints[h] = pts;
                                      }
                                    }
                                  }
                                }
                             }
                         }
                         
                         // Scramble Points Calculation (if not Fourball)
                         if (!isFourball && (isStableford || comp?.rules.scoringType == 'STABLEFORD') && bestBallPoints != null) {
                            final teamPhc = entry.playingHandicap ?? 0;
                             // Use first member's tee context as baseline for team points
                             final firstId = entry.teamMemberIds?.first ?? '';
                             final teamManualTee = teeOverrides?[firstId];
                             final teamTeeConfig = ScoringCalculator.resolvePlayerCourseConfig(
                               memberId: firstId, 
                               event: event, 
                               membersList: membersList, 
                               manualTeeName: teamManualTee,
                             );
                             final teamHoles = teamTeeConfig.holes;
                            
                            for (int h = 0; h < 18; h++) {
                              final score = actualScorecard.holeScores.length > h ? actualScorecard.holeScores[h] : null;
                              if (score != null) {
                                final par = teamHoles.length > h ? teamHoles[h].par : 4;
                                final si = teamHoles.length > h ? teamHoles[h].si : 18;
                                
                                int shots = (teamPhc / 18).floor();
                                if (teamPhc % 18 >= si) shots++;
                                
                                final pts = (par - (score - shots) + 2).clamp(0, 8);
                                bestBallPoints[h] = pts;
                              }
                            }
                         }
                      }

                      final totalPoints = bestBallPoints?.where((p) => p != null).fold<int>(0, (sum, p) => sum + (p as int));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (() {
                             // Context resolution
                             // If 'team' is focused, we use the first player's tee by default for the card (standard for team cards)
                             // OR we use the event baseline. 
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

                             final focusedName = focusedPlayerId == 'team' 
                                 ? 'TEAM'
                                 : ((entry.teamMemberIds != null && entry.teamMemberIds!.contains(focusedPlayerId))
                                     ? entry.teamMemberNames![entry.teamMemberIds!.indexOf(focusedPlayerId)]
                                     : entry.playerName);

                             // Scores to show in MAIN GRID
                             List<int?>? gridScores;
                             int? gridPhc = entry.playingHandicap;

                             if (focusedPlayerId == 'team') {
                               gridScores = actualScorecard.holeScores; // Team aggregate
                             } else {
                               // Find individual card
                               final playerCard = scorecards.firstWhereOrNull((s) => s.entryId == focusedPlayerId);
                               if (playerCard != null) {
                                 gridScores = playerCard.holeScores;
                               } else {
                                 // Seeded fallback
                                 final seeded = event.results.firstWhereOrNull((r) => 
                                   (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? '').toString() == focusedPlayerId
                                 );
                                 if (seeded != null && seeded['holeScores'] != null) {
                                   gridScores = List<int?>.from(seeded['holeScores']);
                                 }
                               }

                               // For Scramble, we always show the team strokes in the main row
                               if (comp?.rules.format == CompetitionFormat.scramble) {
                                  gridScores = actualScorecard.holeScores;
                               }

                               // Resolve individual PHC for grid calculation
                               final member = membersList.firstWhereOrNull((m) => m.id == focusedPlayerId);
                               gridPhc = HandicapCalculator.calculatePlayingHandicap(
                                  handicapIndex: member?.handicap ?? 18.0,
                                  rules: comp!.rules,
                                  courseConfig: playerTeeConfig,
                               );
                             }

                             return Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Padding(
                                   padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
                                   child: Text(
                                     "VIEWING ${focusedName.toUpperCase()}'S SI CONTEXT ($playerTeeName TEES)",
                                     style: AppTypography.label.copyWith(
                                       fontSize: 10,
                                       fontWeight: FontWeight.w900,
                                       color: AppColors.dark200,
                                       letterSpacing: 2.0,
                                     ),
                                   ),
                                 ),
                                 CourseInfoCard(
                                   courseConfig: playerTeeConfig,
                                   selectedTeeName: playerTeeName,
                                   isStableford: isStableford,
                                   isNet: comp?.rules.scoringType != 'GROSS',
                                   format: currentFormat,
                                   maxScoreConfig: effectiveMaxScore,
                                   playerHandicap: gridPhc,
                                   scores: gridScores,
                                   mainRowLabel: focusedPlayerId == 'team' ? (isFourball ? 'BEST BALL' : 'TEAM') : 'Strokes',
                                   additionalRows: const [], // Cleaned up!
                                   holeLimit: holeLimit,
                                   overridePoints: focusedPlayerId == 'team' ? bestBallPoints : null,
                                   overrideTotalPoints: focusedPlayerId == 'team' ? totalPoints : null,
                                 ),
                               ],
                             );
                          })(),
                          const SizedBox(height: 24),
                          // Comparison Footer
                          
                          (() {
                             List<String>? matchPlayResults;
                             String? matchPlaySummary;
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
                                        // 1. Resolve relative strokes for the match
                                        // 1. Resolve relative strokes for the match (Centralized)
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
                                              final member = membersList.firstWhereOrNull((m) => m.id == pid.replaceFirst('_guest', ''));
                                              if (pid.contains('_guest')) {
                                                 final baseId = pid.replaceAll('_guest', '');
                                                 final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
                                                 playerIndices[pid] = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
                                             } else {
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

                                        // 2. Build Virtual Match Definition
                                        final virtualMatch = MatchDefinition(
                                          id: 'virtual_modal_${entry.entryId}',
                                           type: comp.rules.subtype == CompetitionSubtype.fourball ? MatchType.fourball : MatchType.foursomes,
                                          team1Ids: myIds,
                                          team2Ids: oppIds,
                                          strokesReceived: strokesReceived,
                                        );

                                        // 3. Collect all relevant scorecards
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

                                        // 4. Calculate via Authoritative Engine
                                        final result = MatchPlayCalculator.calculate(
                                           match: virtualMatch,
                                           scorecards: sourceCards,
                                           courseConfig: event.courseConfig,
                                           holesToPlay: event.courseConfig.holes.length,
                                         );

                                        // 5. Map to UI expectations
                                        matchPlayResults = result.holeResults.map((r) {
                                            if (r == 1) return 'W';
                                            if (r == -1) return 'L';
                                            return 'H';
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

                             return ScorecardModal.buildUnifiedComparisonFooter(
                               context,
                               event: event,
                               membersList: membersList,
                               teamPoints: bestBallPoints, // Unified team points
                               isScramble: isScrambleFormat,
                               scorecard: actualScorecard,
                               playerName: isFourball == true ? 'TEAM BEST BALL' : (isTeam == true ? 'TEAM SCORE' : entry.playerName),
                               matchPlayResults: matchPlayResults,
                               matchPlaySummary: matchPlaySummary,
                               mode: comp?.rules.mode,
                             );
                          })(),
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
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            isScramble ? "DRIVE ATTRIBUTIONS" : (matchPlayResults != null ? "MATCH PLAY RESULT" : "GROUP SCORE"),
            style: AppTypography.label.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.dark200,
              letterSpacing: 2.0,
            ),
          ),
        ),
        if (isScramble && scorecard != null && scorecard.shotAttributions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lime500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.lime500.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "H$holeNum: $name",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lime500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // Unified Team Row
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 12,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Text(
                    (playerName ?? "TEAM").toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lime500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    matchPlayResults != null 
                        ? "TOTAL: ${matchPlaySummary ?? 'AS'}"
                        : "TOTAL: ${scores.where((s) => s != null).fold<int>(0, (sum, s) => sum + (s as int))}",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                children: [
                  _buildNineHoleRow(context, event, membersList, scores, 0, matchPlayResults: matchPlayResults),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.dark600,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dark500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(9, (i) {
          final hIdx = startIdx + i;
          
          if (matchPlayResults != null) {
              final result = matchPlayResults.length > hIdx ? matchPlayResults[hIdx] : '';
              Color bgColor = Colors.transparent;
              Color textColor = Colors.grey[400]!;
              Color borderColor = Colors.grey[200]!;
              
              if (result == 'W') {
                  bgColor = Colors.green;
                  textColor = Colors.white;
                  borderColor = Colors.green[700]!;
              } else if (result == 'L') {
                  bgColor = Colors.red;
                  textColor = Colors.white;
                  borderColor = Colors.red[700]!;
              } else if (result == 'H') {
                  bgColor = Colors.grey[400]!;
                  textColor = Colors.white;
                  borderColor = Colors.grey[500]!;
              }

              return Expanded(
                child: Container(
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Text(
                    result.isEmpty ? '-' : result,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
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
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: points != null ? AppColors.dark400 : AppColors.dark500,
                  width: 1,
                ),
              ),
              child: Text(
                points?.toString() ?? '-',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: points != null ? FontWeight.w900 : FontWeight.bold,
                  color: points != null ? AppColors.lime500 : AppColors.dark400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  static Widget _buildHeaderPill({
    required BuildContext context,
    required String label,
    required bool isFocused,
    required VoidCallback onTap,
    bool showGuest = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isFocused ? AppColors.lime500.withValues(alpha: 0.1) : AppColors.dark600,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFocused ? AppColors.lime500 : AppColors.dark500,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: isFocused ? AppColors.lime500 : AppColors.dark200,
                letterSpacing: 1.0,
              ),
            ),
            if (showGuest) ...[
              const SizedBox(width: 8),
              const Text(
                'G',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.amber500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _getTeeColor(String teeName) {
    final name = teeName.toLowerCase();
    if (name.contains('white')) return Colors.grey.shade400;
    if (name.contains('yellow')) return const Color(0xFFFFD700);
    if (name.contains('red')) return const Color(0xFFFF4D4D);
    if (name.contains('blue')) return const Color(0xFF1E90FF);
    if (name.contains('black')) return const Color(0xFF2F2F2F);
    return Colors.grey;
  }
}
