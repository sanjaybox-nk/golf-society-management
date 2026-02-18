import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/member.dart';
import '../../../../models/event_registration.dart';
import '../../../../core/utils/handicap_calculator.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../debug/presentation/state/debug_providers.dart';

class EventLeaderboard extends ConsumerWidget {
  final GolfEvent event;
  final Competition? comp;
  final List<Scorecard> liveScorecards;
  final List<Member> membersList;
  final Map<String, int> playerHoleLimits;
  final Function(LeaderboardEntry)? onPlayerTap;
  final bool showTitles;

  const EventLeaderboard({
    super.key,
    required this.event,
    this.comp,
    required this.liveScorecards,
    required this.membersList,
    this.playerHoleLimits = const {},
    this.onPlayerTap,
    this.showTitles = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Resolve effective rules/format
    final formatOverride = ref.watch(gameFormatOverrideProvider);
    final maxTypeOverride = ref.watch(maxScoreTypeOverrideProvider);
    final maxValueOverride = ref.watch(maxScoreValueOverrideProvider);
    final simulationHoles = ref.watch(simulationHoleCountOverrideProvider);

    final currentFormat = formatOverride ?? (comp?.rules.format ?? CompetitionFormat.stableford);
    
    CompetitionRules effectiveRules = comp?.rules ?? const CompetitionRules();
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

    final sourceResults = event.results.isNotEmpty 
        ? event.results 
        : (liveScorecards.isEmpty ? mockEntries.map((e) => {
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
    
    for (var s in liveScorecards) {
      mergedData[s.entryId] = {'type': 'live', 'data': s};
    }

    // 3. Build Entries
    final List<LeaderboardEntry> finalEntries = [];
    
    // [FIX] Scramble/Team Leaderboard Logic
    final isTeamCompetition = effectiveRules.effectiveMode == CompetitionMode.teams || 
                             effectiveRules.effectiveMode == CompetitionMode.pairs;
    
    if (isTeamCompetition) {
       final groupsData = event.grouping['groups'] as List?;
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
                    event: event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                  ));
                }
                
                // Pair B (3 & 4)
                final pairB = group.players.skip(2).take(2).toList();
                if (pairB.isNotEmpty && pairB.any((p) => mergedData.containsKey(p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId))) {
                   finalEntries.add(_buildTeamEntry(
                    teamPlayers: pairB,
                    event: event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                  ));
                }
             } else {
               // Full Team (Scramble)
               final team = group.players;
               if (team.isNotEmpty) {
                  finalEntries.add(_buildTeamEntry(
                    teamPlayers: team,
                    event: event,
                    mergedData: mergedData,
                    effectiveRules: effectiveRules,
                    membersList: membersList,
                    currentFormat: currentFormat,
                    holeLimit: simulationHoles,
                  ));
               }
             }
          }
       }
    } else {
      // Individual Leaderboard
      for (var reg in event.registrations) {
        if (!reg.attendingGolf) continue;
        
        final id = reg.memberId;
        final isGuest = reg.isGuest;
        final regId = isGuest ? '${id}_guest' : id;

        if (mergedData.containsKey(regId)) {
          finalEntries.add(_buildEntry(
            id: regId,
            reg: reg,
            source: mergedData[regId]!,
            event: event,
            effectiveRules: effectiveRules,
            membersList: membersList,
            currentFormat: currentFormat,
            holeLimit: playerHoleLimits[regId] ?? simulationHoles,
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
            event: event,
            effectiveRules: effectiveRules,
            membersList: membersList,
            currentFormat: currentFormat,
            holeLimit: playerHoleLimits[key] ?? simulationHoles,
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

    if (isStableford) {
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
        if (members.isNotEmpty) ...[
          if (showTitles) const BoxyArtSectionTitle(title: 'MEMBERS LEADERBOARD'),
          LeaderboardWidget(
            entries: members, 
            format: currentFormat,
            onPlayerTap: onPlayerTap,
          ),
        ],
        if (guests.isNotEmpty) ...[
          const SizedBox(height: 32),
          if (showTitles) const BoxyArtSectionTitle(title: 'GUEST LEADERBOARD'),
          LeaderboardWidget(
            entries: guests, 
            format: currentFormat,
            onPlayerTap: onPlayerTap,
          ),
        ],
      ],
    );
  }

  LeaderboardEntry _copyWithNoTieBreak(LeaderboardEntry e) {
    return LeaderboardEntry(
      entryId: e.entryId,
      playerName: e.playerName,
      score: e.score,
      scoreLabel: e.scoreLabel,
      handicap: e.handicap,
      playingHandicap: e.playingHandicap,
      holesPlayed: e.holesPlayed,
      isGuest: e.isGuest,
      secondaryPlayerName: e.secondaryPlayerName,
      teamMemberNames: e.teamMemberNames,
      tieBreakDetails: null,
      adjustedGrossScore: e.adjustedGrossScore,
      tieBreakMetrics: e.tieBreakMetrics,
    );
  }

  LeaderboardEntry _buildTeamEntry({
    required List<TeeGroupParticipant> teamPlayers,
    required GolfEvent event,
    required Map<String, dynamic> mergedData,
    required CompetitionRules effectiveRules,
    required List<Member> membersList,
    required CompetitionFormat currentFormat,
    int? holeLimit,
  }) {
     final names = teamPlayers.map((p) => p.name).toList();
     final ids = teamPlayers.map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId).toList(); // [NEW] Track IDs
     
     // [FIX] Detect Fourball (Better Ball) vs Scramble
     final isFourball = effectiveRules.subtype == CompetitionSubtype.fourball;
   
     if (isFourball) {
        // FOURBALL LOGIC: Best Net Score of Partners per Hole
        // 1. Calculate Individual PHCs
        final Map<String, int> playerPhcs = {};
        
        // Override allowance for Fourball to 85% if using default 10%
        final fourballRules = effectiveRules.handicapAllowance == 0.10 
            ? effectiveRules.copyWith(handicapAllowance: 0.85) 
            : effectiveRules;
  
        for (var p in teamPlayers) {
           final id = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
           
           double index;
           if (p.isGuest) {
              final reg = event.registrations.firstWhereOrNull((r) => r.memberId == p.registrationMemberId);
              index = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
           } else {
              final member = membersList.firstWhereOrNull((m) => m.id == p.registrationMemberId);
              index = member?.handicap ?? 18.0;
           }
  
           // Individual PHC
           final playerTeeConfig = _resolvePlayerCourseConfig(id, event, membersList);
           final baseRating = _parseValue(event.courseConfig['rating'] ?? 72.0);

           playerPhcs[id] = HandicapCalculator.calculatePlayingHandicap(
             handicapIndex: index, 
             rules: fourballRules, 
             courseConfig: playerTeeConfig,
             baseRating: baseRating,
           );
        }
        
        // 2. Calculate Team Best Ball Score
        int teamScore = 0;
        int maxHolesPlayed = 0;
        final isStableford = currentFormat == CompetitionFormat.stableford;
        final holes = event.courseConfig['holes'] as List;
  
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
               } else if (data is Map && data['data'] != null && data['data']['holeScores'] != null) {
                 scores = List<int?>.from(data['data']['holeScores']);
               }
               pScores[id] = scores;
           }
        }
  
        // 3. Compare partners hole by hole
        for (int i = 0; i < 18; i++) {
           if (holeLimit != null && i >= holeLimit) break;
  
           int? holeBestScore;
           bool someValid = false;
  
           for (var pid in pScores.keys) {
              final scores = pScores[pid]!;
              if (i < scores.length && scores[i] != null) {
                 final rawVal = scores[i]!;
                 final phc = playerPhcs[pid] ?? 0;
                 final si = holes[i]['si'] as int? ?? 18;
                 final par = holes[i]['par'] as int? ?? 4;
  
                 // Calculate hole net/points
                 final strokes = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
                 final net = rawVal - strokes;
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
              maxHolesPlayed = i + 1;
           }
        }
  
        return LeaderboardEntry(
           entryId: ids.join('_'),
           playerName: names.first,
           secondaryPlayerName: names.length > 1 ? names[1] : null,
           score: teamScore,
           handicap: 0,
           playingHandicap: 0,
           holesPlayed: maxHolesPlayed,
           mode: CompetitionMode.pairs,
        );
     }
  
     // SCRAMBLE LOGIC: Single Scorecard with Team Handicap
     final teamId = ids.join('_');
     final List<int?> teamScores = [];
     if (mergedData.containsKey(teamId)) {
        final data = mergedData[teamId]!;
        if (data is Scorecard) {
          teamScores.addAll(data.holeScores);
        } else if (data is Map && data['data'] != null && data['data']['holeScores'] != null) {
          teamScores.addAll(List<int?>.from(data['data']['holeScores']));
        }
     }
  
     // Team Handicap
     final teamIndex = teamPlayers.map((p) {
        if (p.isGuest) {
          final reg = event.registrations.firstWhereOrNull((r) => r.memberId == p.registrationMemberId);
          return double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
        }
        final m = membersList.firstWhereOrNull((mem) => mem.id == p.registrationMemberId);
        return m?.handicap ?? 18.0;
     }).toList();
  
     final teamPHC = HandicapCalculator.calculateTeamHandicap(
       individualIndices: teamIndex, 
       rules: effectiveRules, 
       courseConfig: event.courseConfig
     );
  
     int totalScore = 0;
     int holesPlayed = 0;
     final holes = event.courseConfig['holes'] as List;
  
     for (int i = 0; i < teamScores.length; i++) {
        if (holeLimit != null && i >= holeLimit) break;
        final score = teamScores[i];
        if (score != null && i < holes.length) {
           totalScore += score;
           holesPlayed = i + 1;
        }
     }
  
     // Final Net
     final netTotal = totalScore - teamPHC;
     final coursePar = holes.fold<int>(0, (a, b) => a + (b['par'] as int? ?? 4));
     final scoreToPar = netTotal - coursePar;
  
     return LeaderboardEntry(
        entryId: teamId,
        playerName: names.first,
        teamMemberNames: names,
        score: scoreToPar,
        scoreLabel: scoreToPar == 0 ? 'E' : (scoreToPar > 0 ? '+$scoreToPar' : '$scoreToPar'),
        handicap: 0,
        playingHandicap: teamPHC,
        holesPlayed: holesPlayed,
        mode: CompetitionMode.teams,
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

    // Mixed Tee Resolution
    final baseRating = _parseValue(event.courseConfig['rating'] ?? 72.0);
    final playerTeeConfig = _resolvePlayerCourseConfig(id, event, membersList);

    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: handicapIndex, 
      rules: effectiveRules, 
      courseConfig: playerTeeConfig,
      baseRating: baseRating,
    );

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
    
    final int holesPlayed = scoresToCalculate.where((sc) => sc != null).length;
    final holes = playerTeeConfig['holes'] as List? ?? [];

    int displayScore = 0;
    int adjustedGrossTotal = 0;
    String? scoreLabel;

    if (currentFormat == CompetitionFormat.stableford) {
      int totalPoints = 0;
      for (int i = 0; i < 18; i++) {
         final score = i < scoresToCalculate.length ? scoresToCalculate[i] : null;
         if (i < holes.length) {
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            final strokes = phc.round();
            final freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
            
            if (score != null) {
              final netScore = score - freeShots;
              final points = (par - netScore + 2).clamp(0, 10);
              totalPoints += points;
              
              final ndbCap = par + 2 + freeShots;
              adjustedGrossTotal += score > ndbCap ? ndbCap : score;
            } else {
              // WHS Pick-up: Treat as Net Double Bogey for Adjusted Gross
              final ndbCap = par + 2 + freeShots;
              adjustedGrossTotal += ndbCap;
            }
         }
      }
      displayScore = totalPoints;
      scoreLabel = displayScore.toString();
    } else if (currentFormat == CompetitionFormat.matchPlay) {
       int holesUp = 0;
       for (int i = 0; i < scoresToCalculate.length; i++) {
         final score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            final strokes = phc.round();
            final freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
            final netScore = score - freeShots;
            if (netScore < par) {
              holesUp++;
            } else if (netScore > par) {
              holesUp--;
            }
            
            final ndbCap = par + 2 + freeShots;
            adjustedGrossTotal += score > ndbCap ? ndbCap : score;
         }
       }
       displayScore = holesUp;
       if (displayScore == 0) {
         scoreLabel = 'AS';
       } else if (displayScore > 0) {
         scoreLabel = '+$displayScore';
       } else {
         scoreLabel = '$displayScore';
       }
    } else {
      int grossTotal = 0;
      int parTotal = 0;
      final maxScoreConfig = effectiveRules.maxScoreConfig;
      final isStrokePlay = currentFormat == CompetitionFormat.stroke;

      for (int i = 0; i < scoresToCalculate.length; i++) {
         int? score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            
            int whsScore = score;
            
            // WHS Cap is ALWAYS Net Double Bogey
            final strokes = phc.round();
            final holeStrokes = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
            final ndbCap = par + 2 + holeStrokes;
            if (whsScore > ndbCap) whsScore = ndbCap;

            if (currentFormat == CompetitionFormat.maxScore && maxScoreConfig != null) {
               int compCap;
               if (maxScoreConfig.type == MaxScoreType.fixed) {
                 compCap = maxScoreConfig.value;
               } else if (maxScoreConfig.type == MaxScoreType.parPlusX) {
                 compCap = par + maxScoreConfig.value;
               } else {
                 compCap = ndbCap;
               }
               if (score > compCap) score = compCap;
            }
            grossTotal += score;
            adjustedGrossTotal += whsScore;
            parTotal += par;
         }
      }
      
      if (holesPlayed > 0) {
         if (isStrokePlay && holesPlayed < 18) {
           displayScore = 999;
           scoreLabel = 'NR';
         } else {
           final partialPhc = (phc * (holesPlayed / 18));
           final netScore = grossTotal - partialPhc;
           final toPar = netScore - parTotal;
           displayScore = toPar.round();
           if (displayScore == 0) {
             scoreLabel = 'E';
           } else if (displayScore > 0) {
             scoreLabel = '+$displayScore';
           } else {
             scoreLabel = '$displayScore';
           }
         }
      } else {
        displayScore = 999;
        scoreLabel = '-';
      }
    }

    return LeaderboardEntry(
      entryId: id,
      playerName: isGuest ? (reg.guestName ?? 'Guest') : reg.memberName,
      secondaryPlayerName: !isGuest && reg.guestName != null ? reg.guestName : null,
      score: displayScore,
      scoreLabel: scoreLabel,
      handicap: handicapIndex.toInt(),
      playingHandicap: phc,
      holesPlayed: holesPlayed,
      isGuest: isGuest,
      mode: CompetitionMode.singles,
      tieBreakDetails: _calculateTieBreakDetails(scoresToCalculate, effectiveRules, event.courseConfig, phc),
      adjustedGrossScore: adjustedGrossTotal,
      tieBreakMetrics: _calculateTieBreakMetrics(scoresToCalculate, effectiveRules, event.courseConfig, phc),
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

  Map<String, dynamic> _resolvePlayerCourseConfig(String memberId, GolfEvent event, List<Member> membersList) {
    // 1. If courseConfig has no tees list, just return it as is (legacy/flat)
    final tees = event.courseConfig['tees'] as List?;
    if (tees == null || tees.isEmpty) return event.courseConfig;

    // 2. Identify Player Gender for automatic selection if not explicitly assigned
    final member = membersList.firstWhereOrNull((m) => m.id == memberId);
    final gender = member?.gender?.toLowerCase() ?? 'male';
    
    // Simple logic: If female, look for 'Red' or 'Lady' or 'Female' tee. 
    // Otherwise look for 'White' or 'Yellow' or 'Standard'.
    Map<String, dynamic>? selectedTee;
    
    if (gender == 'female') {
       selectedTee = (tees.firstWhereOrNull((t) => 
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
