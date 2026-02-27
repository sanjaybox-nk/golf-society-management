import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import '../../../../domain/grouping/grouping_service.dart';

import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../debug/presentation/state/debug_providers.dart';
// removed unused society_config

import '../../../matchplay/domain/match_definition.dart';
import '../../../matchplay/domain/match_play_calculator.dart';

class EventLeaderboard extends ConsumerStatefulWidget {
  final GolfEvent event;
  final Competition? comp;
  final List<Scorecard> liveScorecards;
  final List<Member> membersList;
  final Map<String, int> playerHoleLimits;
  final Function(LeaderboardEntry)? onPlayerTap;
  final bool showTitles;
  final Map<String, String>? teeOverrides; // [NEW] Manual tee overrides

  const EventLeaderboard({
    super.key,
    required this.event,
    this.comp,
    required this.liveScorecards,
    required this.membersList,
    this.playerHoleLimits = const {},
    this.onPlayerTap,
    this.showTitles = true,
    this.teeOverrides,
  });

  @override
  ConsumerState<EventLeaderboard> createState() => _EventLeaderboardState();
}

class _EventLeaderboardState extends ConsumerState<EventLeaderboard> {
  @override
  Widget build(BuildContext context) {
    // 1. Resolve effective rules/format
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
    final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
    final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);

    final currentFormat = formatOverride ?? (widget.comp?.rules.format ?? CompetitionFormat.stableford);
    
    CompetitionRules effectiveRules = widget.comp?.rules ?? const CompetitionRules();
    if (formatOverride != null) {
      effectiveRules = effectiveRules.copyWith(format: formatOverride);
    }
    
    if (currentFormat == CompetitionFormat.maxScore && maxTypeOverride != null) {
      effectiveRules = effectiveRules.copyWith(
        maxScoreConfig: MaxScoreConfig(
          type: maxTypeOverride,
          value: maxValueOverride ?? (effectiveRules.maxScoreConfig?.value ?? 2),
        ),
      );
    }

    // 2. Merge Live Scorecards with Seeded Results
    final Map<String, dynamic> mergedData = {};
    
    // Fallback Mock data for dev testing if no results at all
    final mockEntries = [
       LeaderboardEntry(entryId: 'm1', playerName: 'PLAYER ONE', score: 36, handicap: 12),
       LeaderboardEntry(entryId: 'm2', playerName: 'PLAYER TWO', score: 34, handicap: 15),
    ];

    final sourceResults = widget.event.results.isNotEmpty 
        ? widget.event.results 
        : (widget.liveScorecards.isEmpty ? mockEntries.map((e) => {
            'memberId': e.entryId,
            'playerName': e.playerName,
            'handicap': e.handicap,
            'points': e.score,
            'netTotal': e.score,
          }).toList() : []);

    for (var r in sourceResults) {
      final id = (r['memberId'] ?? r['userId'] ?? r['playerId'] ?? 'unknown').toString();
      mergedData[id] = {'type': 'seeded', 'data': r};
    }
    
    for (var s in widget.liveScorecards) {
      mergedData[s.entryId] = {'type': 'live', 'data': s};
    }

    // 3. Build Entries
    final List<LeaderboardEntry> finalEntries = [];
    
    // [FIX] Scramble/Team Leaderboard Logic
    int getGroupIndex(String regId) {
       final groupsData = widget.event.grouping['groups'] as List?;
       if (groupsData != null) {
          for (var g in groupsData) {
          final group = TeeGroup.fromJson(g as Map<String, dynamic>);
          if (group.players.any((p) => (p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId) == regId)) {
             return group.index;
          }
       }
       }
       return 999;
    }

    final isTeamCompetition = effectiveRules.effectiveMode == CompetitionMode.teams || 
                             effectiveRules.effectiveMode == CompetitionMode.pairs;
    
    if (isTeamCompetition) {
       final groupsData = widget.event.grouping['groups'] as List?;
       if (groupsData != null) {
          final List<TeeGroup> groups = groupsData.map((g) => TeeGroup.fromJson(g)).toList();
          
          for (var group in groups) {
             // Identify partners (usually 1+2 and 3+4 in a 4-ball group)
             if (effectiveRules.effectiveMode == CompetitionMode.pairs) {
                // Pair A (1 & 2)
                final pairA = group.players.take(2).toList();
                if (pairA.isNotEmpty && pairA.any((p) => mergedData.containsKey(p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId))) {
                  finalEntries.add(_buildTeamEntry(
                    teamPlayers: pairA,
                    teamIndex: group.index, // [NEW] Pass group index
                    event: widget.event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: widget.membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                    teeOverrides: widget.teeOverrides,
                  ));
                }
                
                // Pair B (3 & 4)
                final pairB = group.players.skip(2).take(2).toList();
                if (pairB.isNotEmpty && pairB.any((p) => mergedData.containsKey(p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId))) {
                   finalEntries.add(_buildTeamEntry(
                    teamPlayers: pairB,
                    teamIndex: group.index, // [NEW] Pass group index
                    event: widget.event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: widget.membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                    teeOverrides: widget.teeOverrides,
                  ));
                }
             } else {
               // Full Team (Scramble)
               final team = group.players;
               if (team.isNotEmpty) {
                  finalEntries.add(_buildTeamEntry(
                    teamPlayers: team,
                    teamIndex: group.index, // [NEW] Pass group index
                    event: widget.event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: widget.membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                    teeOverrides: widget.teeOverrides,
                  ));
               }
              }
          }
       }
    } else {
      // Individual Leaderboard
      for (var reg in widget.event.registrations) {
        if (!reg.attendingGolf) continue;
        
        final id = reg.memberId;
        final isGuest = reg.isGuest;
        final regId = isGuest ? '${id}_guest' : id;

        if (mergedData.containsKey(regId)) {
          finalEntries.add(_buildEntry(
            id: regId,
            reg: reg,
            source: mergedData[regId]!,
            event: widget.event,
            effectiveRules: effectiveRules,
            membersList: widget.membersList,
            currentFormat: currentFormat,
            holeLimit: widget.playerHoleLimits[regId] ?? simulationHoles,
            teamIndex: getGroupIndex(regId),
            manualTeeName: widget.teeOverrides?[regId],
          ));
        }
      }

      // Fallback for dangling data (e.g. pure mock/seeded without reg)
      if (finalEntries.isEmpty && mergedData.isNotEmpty) {
        mergedData.forEach((key, value) {
          finalEntries.add(_buildEntry(
            id: key,
            reg: EventRegistration(memberId: key, memberName: value['data']['playerName'] ?? 'Unknown', attendingGolf: true),
            source: value,
            event: widget.event,
            effectiveRules: effectiveRules,
            membersList: widget.membersList,
            currentFormat: currentFormat,
            holeLimit: widget.playerHoleLimits[key] ?? simulationHoles,
            teamIndex: getGroupIndex(key),
            manualTeeName: widget.teeOverrides?[key],
          ));
        });
      }
    }

    if (finalEntries.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('Standings will appear once scoring starts.', style: TextStyle(color: Colors.grey)),
      ));
    }

    // 4. Handle Ties and Sorting
    final scoreCounts = <int, int>{};
    for (var e in finalEntries) {
      scoreCounts[e.score] = (scoreCounts[e.score] ?? 0) + 1;
    }

    final finalizedEntries = finalEntries.map((e) {
      if ((scoreCounts[e.score] ?? 0) <= 1) {
        return _copyWithNoTieBreak(e);
      }
      return e;
    }).toList();

    final isStableford = currentFormat == CompetitionFormat.stableford;

    if (currentFormat == CompetitionFormat.matchPlay) {
      finalizedEntries.sort((a, b) {
        int res = (a.teamIndex ?? 999).compareTo(b.teamIndex ?? 999);
        if (res == 0) {
          res = b.score.compareTo(a.score); // Match Play score: larger is better
        }
        return res;
      });
    } else if (isStableford) {
      finalizedEntries.sort((a, b) {
        int res = b.score.compareTo(a.score);
        if (res == 0 && effectiveRules.tieBreak != TieBreakMethod.playoff && a.tieBreakMetrics != null && b.tieBreakMetrics != null) {
          for (int i = 0; i < a.tieBreakMetrics!.length; i++) {
            res = b.tieBreakMetrics![i].compareTo(a.tieBreakMetrics![i]);
            if (res != 0) break;
          }
        }
        return res;
      });
    } else {
      finalizedEntries.sort((a, b) {
        int res = a.score.compareTo(b.score);
        if (res == 0 && effectiveRules.tieBreak != TieBreakMethod.playoff && a.tieBreakMetrics != null && b.tieBreakMetrics != null) {
          for (int i = 0; i < a.tieBreakMetrics!.length; i++) {
            res = a.tieBreakMetrics![i].compareTo(b.tieBreakMetrics![i]);
            if (res != 0) break;
          }
        }
        return res;
      });
    }

    final members = finalizedEntries.where((e) => !e.isGuest).toList();
    final guests = finalizedEntries.where((e) => e.isGuest).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeaderboardWidget(
          entries: members,
          format: currentFormat,
          onPlayerTap: widget.onPlayerTap,
        ),
        if (guests.isNotEmpty) ...[
          const SizedBox(height: 24),
          LeaderboardWidget(
            entries: guests,
            format: currentFormat,
            onPlayerTap: widget.onPlayerTap,
          ),
        ],
      ],
    );
  }

  LeaderboardEntry _copyWithNoTieBreak(LeaderboardEntry e) {
    return e.copyWith(tieBreakDetails: null);
  }

  LeaderboardEntry _buildTeamEntry({
    required List<TeeGroupParticipant> teamPlayers,
    required int teamIndex, // [NEW] Accept group index
    required GolfEvent event,
    required Map<String, dynamic> mergedData,
    required CompetitionRules effectiveRules,
    required List<Member> membersList,
    required CompetitionFormat currentFormat,
    int? holeLimit,
    Map<String, String>? teeOverrides, // [NEW] Overrides passed from parent
  }) {
     final names = teamPlayers.map((p) => p.name).toList();
     final ids = teamPlayers.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList(); // [NEW] Track IDs
     
     // [FIX] Detect Fourball (Better Ball) vs Scramble
     final isFourball = effectiveRules.subtype == CompetitionSubtype.fourball;
   
     if (isFourball) {
        // FOURBALL LOGIC: Best Net Score of Partners per Hole
        // 1. Calculate Individual PHCs
        final Map<String, int> playerPhcs = {};
        
  
        for (var p in teamPlayers) {
           final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;

           // Single Source of Truth: Check Scorecard first (submitted rounds),
           // then grouping data. Never calculate on-the-fly.
           int? storedPhc;
           
           // A. Check Scorecard first (submitted rounds may store PHC snapshot)
           final entrySource = mergedData[id];
           if (entrySource != null && entrySource['data'] is Scorecard) {
              storedPhc = (entrySource['data'] as Scorecard).playingHandicap;
           }

           // B. Grouping data is the authoritative source
           if (storedPhc == null || storedPhc == 0) {
              storedPhc = HandicapCalculator.getStoredPhc(event.grouping, p.registrationMemberId);
           }

           playerPhcs[id] = storedPhc;
        }
        
        // 2. Calculate Team Best Ball Score
        int teamScore = 0;
        int maxHolesPlayed = 0;
        int teamPar = 0; // [NEW] Track Par for holes played
        final isStableford = currentFormat == CompetitionFormat.stableford;
        // Removed unused holes
  
        // Prepare individual scorecards
        final Map<String, List<int?>> pScores = {};
        
        for (var p in teamPlayers) {
           final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
           if (mergedData.containsKey(id)) {
              final data = mergedData[id]!;
              List<int?> scores = [];
               if (data is Scorecard) {
                 scores = data.holeScores;
               } else if (data is Map && data['holeScores'] != null) {
                 scores = List<int?>.from(data['holeScores']);
               } else if (data is Map && data['data'] != null) {
                 final inner = data['data'];
                 if (inner is Scorecard) {
                   scores = inner.holeScores;
                 } else if (inner is Map && inner['holeScores'] != null) {
                   scores = List<int?>.from(inner['holeScores']);
                 }
               }
               pScores[id] = scores;
           }
        }
          // 3. Compare partners hole by hole or use Best Team Card
          // Resolve holes list for calculator - needs to be per-player in Fourball
          // For Team Par/Context, we might need a baseline, but calculations are per-player.

         for (int i = 0; i < 18; i++) {
            if (holeLimit != null && i >= holeLimit) break;
   
            int? holeBestScore;
            bool someValid = false;
   
            for (var pid in pScores.keys) {
               final scores = pScores[pid]!;
               if (i < scores.length && scores[i] != null) {
                  final manualTee = teeOverrides?[pid];
                  final playerTeeConfig = _resolvePlayerCourseConfig(pid, event, membersList, manualTeeName: manualTee);
                  final playerHoles = playerTeeConfig['holes'] as List? ?? [];
                  final si = playerHoles.length > i ? (playerHoles[i]['si'] as int? ?? 18) : 18;
                  final par = playerHoles.length > i ? (playerHoles[i]['par'] as int? ?? 4) : 4;
   
                  final int rawVal = scores[i]!;
                  final phc = playerPhcs[pid] ?? 0;
   
                  // Calculate hole net/points
                  final int freeShots = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
                  final net = rawVal - freeShots;
                  final points = (par - net + 2).clamp(0, 10);
   
                  if (isStableford) {
                     if (holeBestScore == null || points > holeBestScore) holeBestScore = points;
                  } else {
                     if (holeBestScore == null || net < holeBestScore) holeBestScore = net;
                  }
                  someValid = true;
               }
            }
            if (someValid) {
               teamScore += (holeBestScore ?? 0);
               // Baseline Par for team aggregate (using first player's tee config)
               final firstId = teamPlayers.first.registrationMemberId;
               final firstConfig = _resolvePlayerCourseConfig(firstId, event, membersList, manualTeeName: teeOverrides?[firstId]);
               final firstHoles = firstConfig['holes'] as List? ?? [];
               teamPar += (firstHoles.length > i ? (firstHoles[i]['par'] as int? ?? 4) : 4);
               maxHolesPlayed = i + 1;
            }
         } // closing for i loop
  
         // [NEW] Resolve correct score and scoreLabel based on format
         int finalScore = teamScore;
         String? scoreLabel;
         if (currentFormat == CompetitionFormat.matchPlay) {
            final matchSummary = _calculateMatchPlaySummary(
              event: event,
              myIds: ids,
              mergedData: mergedData,
              membersList: membersList,
              rules: effectiveRules,
            );
            finalScore = matchSummary['score'] as int;
            scoreLabel = matchSummary['label'] as String;
         } else if (!isStableford) {
            final int netToPar = teamScore - teamPar;
            finalScore = netToPar; // Stroke play leaderboard sorts by net relation to par
            scoreLabel = netToPar == 0 ? 'E' : (netToPar > 0 ? '+$netToPar' : '$netToPar');
         } else {
            scoreLabel = finalScore.toString();
         }
        return LeaderboardEntry(
           entryId: ids.join('_'),
           playerName: names.join(' / '),
           secondaryPlayerName: names.length > 1 ? names[1] : null,
           teamMemberIds: ids,
           teamMemberNames: names,
           score: finalScore,
           scoreLabel: scoreLabel,
           handicap: 0,
           playingHandicap: 0,
           individualHandicaps: teamPlayers.map((p) {
              if (p.isGuest) {
                 final reg = event.registrations.firstWhereOrNull((r) => r.memberId == p.registrationMemberId);
                 return double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
              }
              final m = membersList.firstWhereOrNull((mem) => mem.id == p.registrationMemberId);
              return m?.handicap ?? 18.0;
           }).toList(),
           individualPlayingHandicaps: ids.map((id) => playerPhcs[id] ?? 0).toList(),
           holesPlayed: maxHolesPlayed,
           mode: CompetitionMode.pairs,
           // holeScores for pairs is complex (best ball), let the modal reconstruct from individual cards
         );
     }
  
     // SCRAMBLE LOGIC: Usually scored on one team member's card
      final teamId = ids.join('_');
      final seededTeamId = 'team_$teamIndex'; // [NEW] Match SeedingService pattern
      List<int?> teamScores = [];
      
      // 1. Try team ID first (Scramble card)
      // Check both Joined ID and Seeded ID
      final entrySource = mergedData[teamId] ?? mergedData[seededTeamId];
      if (entrySource != null) {
         final actualData = entrySource['data'];
         if (actualData is Scorecard) {
           teamScores = actualData.holeScores;
         } else if (actualData is Map && actualData['holeScores'] != null) {
           teamScores = List<int?>.from(actualData['holeScores']);
         }
      }

     // 2. Fallback: Try each team member (common in Scramble/Fourball)
     if (teamScores.where((s) => s != null).isEmpty) {
        for (var p in teamPlayers) {
           final pid = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
           if (mergedData.containsKey(pid)) {
              final entryData = mergedData[pid]!;
              final actualData = entryData['data'];
              List<int?> scores = [];
              
              if (actualData is Scorecard) {
                scores = actualData.holeScores;
              } else if (actualData is Map && actualData['holeScores'] != null) {
                scores = List<int?>.from(actualData['holeScores']);
              }

              if (scores.where((s) => s != null).isNotEmpty) {
                 teamScores = scores;
                 break;
              }
           }
        }
     }
  
     // Team Handicap
     final teamHaps = teamPlayers.map((p) {
        if (p.isGuest) {
          final reg = event.registrations.firstWhereOrNull((r) => r.memberId == p.registrationMemberId);
          return double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
        }
        final m = membersList.firstWhereOrNull((mem) => mem.id == p.registrationMemberId);
        return m?.handicap ?? 18.0;
     }).toList();
  
     final teamPHC = HandicapCalculator.calculateTeamHandicap(
       individualIndices: teamHaps, 
       rules: effectiveRules, 
       courseConfig: event.courseConfig
     );

     // [NEW] Calculate 100% baseline Team Course Handicap for display (so it's not 0)
     final teamCH = HandicapCalculator.calculateTeamHandicap(
       individualIndices: teamHaps, 
       rules: effectiveRules.copyWith(handicapAllowance: 1.0), 
       courseConfig: event.courseConfig
     );

     // Use ScoringCalculator for Scramble
     final rawHoles = event.courseConfig['holes'] as List? ?? [];
     final List<Map<String, dynamic>> holesData = rawHoles.map((h) => Map<String, dynamic>.from(h)).toList();

     final result = ScoringCalculator.calculate(
       holeScores: teamScores, 
       holes: holesData, 
       playingHandicap: teamPHC.toDouble(), 
       format: effectiveRules.format,
       maxScoreConfig: effectiveRules.maxScoreConfig,
     );
   
     return LeaderboardEntry(
        entryId: teamId,
        playerName: names.join(' / '),
        teamMemberNames: names,
        teamMemberIds: ids,
        score: result.score,
        scoreLabel: result.label,
        handicap: teamCH, // Show 100% Team CH instead of 0
        playingHandicap: teamPHC,
        individualHandicaps: teamHaps,
        holesPlayed: result.holesPlayed,
        mode: CompetitionMode.teams,
        adjustedGrossScore: result.adjustedGrossScore,
        holeScores: teamScores,
        teamIndex: teamIndex, // [NEW] Pass for group card lookup
     );
  }

  LeaderboardEntry _buildEntry({
    required String id,
    required EventRegistration reg,
    required dynamic source,
    required GolfEvent event,
    required CompetitionRules effectiveRules,
    required List<Member> membersList,
    required CompetitionFormat currentFormat,
    int? holeLimit,
    int? teamIndex,
    String? manualTeeName, 
  }) {
    final data = source['data'];
    final isGuest = reg.memberId.contains('_guest') || reg.isGuest;
    
    double handicapIndex;
    if (isGuest) {
      handicapIndex = double.tryParse(reg.guestHandicap ?? '18') ?? 18.0;
    } else {
      final member = membersList.firstWhereOrNull((m) => m.id == reg.memberId);
      handicapIndex = member?.handicap ?? 18.0;
    }

    // Course config is still needed for hole data and tie-break calculations
    final playerTeeConfig = _resolvePlayerCourseConfig(id, event, membersList, manualTeeName: manualTeeName);


    // Single Source of Truth: Scorecard snapshot → Grouping data
    int? authoritativePhc;
    
    // A. Check Scorecard first (submitted rounds)
    if (data is Scorecard) {
       authoritativePhc = data.playingHandicap;
    }

    // B. Grouping data is the authoritative source
    if (authoritativePhc == null || authoritativePhc == 0) {
       authoritativePhc = HandicapCalculator.getStoredPhc(event.grouping, id.replaceFirst('_guest', ''));
    }

    final phc = authoritativePhc;

    List<int?> rawScores = [];
    if (data is Scorecard) {
      rawScores = data.holeScores;
    } else if (data is Map) {
      final r = data;
      if (r['holeScores'] != null) {
        rawScores = List<int?>.from(r['holeScores']);
      }
    }

    final List<int?> scoresToCalculate = [];
    for (int i = 0; i < rawScores.length; i++) {
      if (holeLimit != null && i >= holeLimit) break;
      scoresToCalculate.add(rawScores[i]);
    }
    
    // Removed unused holesPlayed and holes

    // Use ScoringCalculator for individual entries
    final rawHoles = playerTeeConfig['holes'] as List? ?? [];
    final List<Map<String, dynamic>> holesData = rawHoles.map((h) => Map<String, dynamic>.from(h)).toList();

    final result = ScoringCalculator.calculate(
      holeScores: scoresToCalculate, 
      holes: holesData, 
      playingHandicap: phc.toDouble(), 
      format: currentFormat,
      maxScoreConfig: effectiveRules.maxScoreConfig,
    );

    return LeaderboardEntry(
      entryId: id,
      playerName: isGuest ? (reg.guestName ?? 'Guest') : reg.memberName,
      secondaryPlayerName: !isGuest && reg.guestName != null ? reg.guestName : null,
      score: result.score,
      scoreLabel: result.label,
      handicap: handicapIndex.toInt(),
      playingHandicap: phc,
      holesPlayed: result.holesPlayed,
      isGuest: isGuest,
      mode: CompetitionMode.singles,
      tieBreakDetails: _calculateTieBreakDetails(scoresToCalculate, effectiveRules, playerTeeConfig, phc),
      adjustedGrossScore: result.adjustedGrossScore,
      tieBreakMetrics: _calculateTieBreakMetrics(scoresToCalculate, effectiveRules, playerTeeConfig, phc),
      holeScores: scoresToCalculate,
      teamIndex: teamIndex,
    );
  }

  String? _calculateTieBreakDetails(List<int?> holeScores, CompetitionRules rules, Map<String, dynamic> courseConfig, int phc) {
    if (holeScores.every((hole) => hole == null) || holeScores.where((hole) => hole != null).length < 18) {
      return null;
    }
    final holes = courseConfig['holes'] as List?;
    if (holes == null || holes.length < 18) return null;

    int back9Points = 0;
    int back9Gross = 0;
    for (int i = 9; i < 18; i++) {
       final score = holeScores[i];
       if (score == null) continue;
       final hole = holes[i] as Map<String, dynamic>;
       final par = hole['par'] as int? ?? 4;
       final si = hole['si'] as int? ?? 18;
       final strokesReceived = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
       final netScore = score - strokesReceived;
       final points = (par - netScore + 2).clamp(0, 10);
       back9Points += points;
       back9Gross += score;
    }

    if (rules.format == CompetitionFormat.stableford) {
      return "Back 9: $back9Points pts";
    } else {
      int back9Par = 0;
      for (int i = 9; i < 18; i++) {
        back9Par += (holes[i]['par'] as int? ?? 4);
      }
      final diff = back9Gross - (phc ~/ 2) - back9Par;
      final label = diff == 0 ? "E" : (diff > 0 ? "+$diff" : "$diff");
      return "Back 9: $label";
    }
  }

  List<int>? _calculateTieBreakMetrics(List<int?> holeScores, CompetitionRules rules, Map<String, dynamic> courseConfig, int phc) {
    if (holeScores.where((h) => h != null).length < 18) return null;
    final holes = courseConfig['holes'] as List?;
    if (holes == null || holes.length < 18) return null;

    final isStableford = rules.format == CompetitionFormat.stableford;
    
    // Recursive metrics: Back 9, 6, 3, 1
    final segments = [9, 12, 15, 17]; // Start indices for last 9, 6, 3, 1 holes
    final List<int> metrics = [];

    for (var startIdx in segments) {
      int segmentTotal = 0;
      for (int i = startIdx; i < 18; i++) {
        final score = holeScores[i];
        if (score == null) continue;
        final hole = holes[i] as Map<String, dynamic>;
        final par = hole['par'] as int? ?? 4;
        final si = hole['si'] as int? ?? 18;
        final strokesReceived = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
        final netScore = score - strokesReceived;

        if (isStableford) {
          final points = (par - netScore + 2).clamp(0, 10);
          segmentTotal += points;
        } else {
          segmentTotal += netScore;
        }
      }
      metrics.add(segmentTotal);
    }
    return metrics;
  }

  Map<String, dynamic> _calculateMatchPlaySummary({
    required GolfEvent event,
    required List<String> myIds,
    required Map<String, dynamic> mergedData,
    required List<Member> membersList,
    required CompetitionRules rules,
    Map<String, String>? teeOverrides,
  }) {
      List<String>? myGroupIds;
      final groupsData = event.grouping['groups'] as List? ?? [];
      for (var g in groupsData) {
          final players = g['players'] as List? ?? [];
          final playerIds = players.map((p) {
              final pid = p['registrationMemberId']?.toString();
              return p['isGuest'] == true ? '${pid}_guest' : pid;
          }).whereType<String>().toList();
          
          if (playerIds.any((id) => myIds.contains(id))) {
              myGroupIds = playerIds;
              break;
          }
      }

      if (myGroupIds == null) return {'score': 0, 'label': 'AS'};
      
      final oppIds = myGroupIds.where((id) => !myIds.contains(id)).toList();
      if (oppIds.isEmpty) return {'score': 0, 'label': 'AS'}; // No opponent

      // 1. Build Virtual Match Definition
      // 1. Resolve relative strokes for the match (Centralized)
      final Map<String, double> playerIndices = {};
      final Map<String, Map<String, dynamic>> courseConfigs = {};
      
      for (final pid in myGroupIds) {
          courseConfigs[pid] = _resolvePlayerCourseConfig(pid, event, membersList, manualTeeName: teeOverrides?[pid]);
          final member = membersList.firstWhereOrNull((m) => m.id == pid.replaceFirst('_guest', ''));
          if (pid.contains('_guest')) {
              final baseId = pid.replaceAll('_guest', '');
              final reg = event.registrations.firstWhereOrNull((r) => r.memberId == baseId);
              playerIndices[pid] = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
          } else {
              playerIndices[pid] = member?.handicap ?? 18.0;
          }
      }

      final baseRating = _parseValue(event.courseConfig['rating'] ?? 72.0);
      final strokesReceived = MatchPlayCalculator.calculateRelativeStrokes(
        playerIds: myGroupIds,
        playerIndices: playerIndices,
        courseConfigs: courseConfigs,
        rules: rules,
        baseRating: baseRating,
      );

      final virtualMatch = MatchDefinition(
        id: 'virtual_leaderboard',
        type: rules.subtype == CompetitionSubtype.fourball ? MatchType.fourball : MatchType.foursomes,
        team1Ids: myIds,
        team2Ids: oppIds,
        strokesReceived: strokesReceived,
      );

      // 2. Build Scorecards
      final List<Scorecard> sourceCards = [];
      for (var pid in myGroupIds) {
          if (mergedData.containsKey(pid)) {
              final data = mergedData[pid]!;
              if (data['type'] == 'live') {
                  sourceCards.add(data['data'] as Scorecard);
              } else if (data['type'] == 'seeded') {
                  sourceCards.add(Scorecard(
                    id: 'temp_$pid',
                    competitionId: event.id,
                    roundId: '1',
                    entryId: pid,
                    submittedByUserId: 'system',
                    status: ScorecardStatus.finalScore,
                    holeScores: List<int?>.from(data['data']['holeScores'] ?? []),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ));
              }
          }
      }

      // 3. Calculate via Authoritative Engine
      final result = MatchPlayCalculator.calculate(
        match: virtualMatch,
        scorecards: sourceCards,
        courseConfig: event.courseConfig,
        holesToPlay: event.courseConfig['holes']?.length ?? 18,
      );

      // 4. Map back to Leaderboard Expectation
      String label = result.status;
      
      // The MatchPlayCalculator sets status like "4 & 3", but if Team 2 won, 
      // the status implies the winner. Leaderboard needs to be relative to "myIds".
      // If result.winningTeamIndex == 0 (myIds), they won.
      // If result.winningTeamIndex == 1 (oppIds), they lost.
      // If score > 0, T1 is UP. If score < 0, T1 is DN.

      if (result.score == 0) {
        label = 'AS';
      } else if (result.score > 0) {
        // T1 (My team) is UP
        label = result.isFinal ? 'WIN ${result.status}' : '${result.status} (UP)';
      } else {
        // T1 is DN (Opp is UP)
        label = result.isFinal ? 'LOSS ${result.status}' : '${result.status} (DN)';
      }

      // Special case: `result.status` might just say "1 UP" etc.
      // E.g., if +1, it says "1 UP". Wait, if it's "4 & 3", the string `label` becomes "WIN 4 & 3".

      return {'score': result.score, 'label': label};
  }

  // Helper to resolve course config per player (gender + event defaults + manual override)
  static Map<String, dynamic> _resolvePlayerCourseConfig(String memberId, GolfEvent event, List<Member> membersList, {String? manualTeeName}) {
    // 1. If courseConfig has no tees list, just return it as is (legacy/flat)
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.courseConfig;

    final member = membersList.firstWhereOrNull((m) => m.id == memberId.replaceFirst('_guest', ''));
    final gender = member?.gender?.toLowerCase() ?? 'male';
    
    Map<String, dynamic>? selectedTee;

    // 2. Manual Override logic (Matches HoleByHoleScoringWidget logic)
    if (manualTeeName != null) {
      selectedTee = (tees.firstWhereOrNull((t) => 
        (t['name'] ?? '').toString().toLowerCase() == manualTeeName.toLowerCase()
      ) as Map<String, dynamic>?);
    }

    if (selectedTee == null) {
      if (gender == 'female') {
        // A) Explicit selection priority
        if (event.selectedFemaleTeeName != null) {
          selectedTee = (tees.firstWhereOrNull((t) => 
            (t['name'] ?? '').toString().toLowerCase() == event.selectedFemaleTeeName!.toLowerCase()
          ) as Map<String, dynamic>?);
        }
        
        // B) Heuristic fallback
        selectedTee ??= (tees.firstWhereOrNull((t) => 
          (t['name'] ?? '').toString().toLowerCase().contains('red') || 
          (t['name'] ?? '').toString().toLowerCase().contains('lady') ||
          (t['name'] ?? '').toString().toLowerCase().contains('female')
        ) as Map<String, dynamic>?);
      }
      
      // Fallback or default choice
      selectedTee ??= (tees.firstWhereOrNull((t) => 
        (t['name'] ?? '').toString().toLowerCase() == (event.selectedTeeName ?? 'white').toLowerCase()
      ) as Map<String, dynamic>?);

      // Final fallback: First tee
      selectedTee ??= (tees.first as Map<String, dynamic>);
    }

    // Merge tee data into a clean config for the calculator
    return {
       ...event.courseConfig,
       'par': selectedTee['par'] ?? selectedTee['holePars']?.fold(0, (a, b) => (a as int) + (b as int)) ?? 72,
       'rating': selectedTee['rating'] ?? 72.0,
       'slope': selectedTee['slope'] ?? 113,
       'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': (selectedTee!['holePars'] as List?)?.elementAt(i) ?? 4,
          'si': (selectedTee['holeSIs'] as List?)?.elementAt(i) ?? 18,
       }),
    };
  }

  static double _parseValue(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
