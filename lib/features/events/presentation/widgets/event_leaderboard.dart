import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import '../../../../models/member.dart';
import '../../../../models/event_registration.dart';
import '../../../../core/utils/handicap_calculator.dart';
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
    final isStableford = currentFormat == CompetitionFormat.stableford;
    
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
    for (var reg in event.registrations) {
      if (mergedData.containsKey(reg.memberId)) {
        finalEntries.add(_buildEntry(
          id: reg.memberId, 
          reg: reg, 
          source: mergedData[reg.memberId]!, 
          event: event, 
          effectiveRules: effectiveRules,
          membersList: membersList,
          currentFormat: currentFormat,
          holeLimit: playerHoleLimits[reg.memberId] ?? simulationHoles,
        ));
      }
      
      final guestId = '${reg.memberId}_guest';
      if (reg.guestName != null && mergedData.containsKey(guestId)) {
        finalEntries.add(_buildEntry(
          id: guestId, 
          reg: reg, 
          source: mergedData[guestId]!, 
          event: event, 
          effectiveRules: effectiveRules,
          membersList: membersList,
          currentFormat: currentFormat,
          isGuest: true,
          holeLimit: playerHoleLimits[guestId] ?? simulationHoles,
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

    if (isStableford) {
      finalizedEntries.sort((a, b) => b.score.compareTo(a.score));
    } else {
      finalizedEntries.sort((a, b) => a.score.compareTo(b.score));
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
      tieBreakDetails: null,
    );
  }

  LeaderboardEntry _buildEntry({
    required String id,
    required EventRegistration reg,
    required Map<String, dynamic> source,
    required GolfEvent event,
    required CompetitionRules effectiveRules,
    required List<Member> membersList,
    required CompetitionFormat currentFormat,
    int? holeLimit,
    bool isGuest = false,
  }) {
    final data = source['data'];
    final holes = event.courseConfig['holes'] as List? ?? [];
    
    double? handicapIndex;
    if (data is Map && data.containsKey('handicap')) {
       final raw = data['handicap'];
       if (raw is num) {
         handicapIndex = raw.toDouble();
       } else if (raw is String) {
         handicapIndex = double.tryParse(raw);
       }
    } 

    if (handicapIndex == null || (handicapIndex == 0.0 && !isGuest)) {
      if (isGuest) {
        handicapIndex = double.tryParse(reg.guestHandicap ?? '18') ?? 18.0;
      } else {
        final member = membersList.where((m) => m.id == reg.memberId).firstOrNull;
        if (member != null && member.handicap != 0.0) {
           handicapIndex = member.handicap;
        } else {
           handicapIndex = 18.0; 
        }
      }
    }

    final phc = HandicapCalculator.calculatePlayingHandicap(
      handicapIndex: handicapIndex, 
      rules: effectiveRules, 
      courseConfig: event.courseConfig,
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

    int displayScore = 0;
    String? scoreLabel;

    if (currentFormat == CompetitionFormat.stableford) {
      int totalPoints = 0;
      for (int i = 0; i < scoresToCalculate.length; i++) {
         final score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
           final par = holes[i]['par'] as int? ?? 4;
           final si = holes[i]['si'] as int? ?? 18;
           final strokes = phc.round();
           final freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
           final netScore = score - freeShots;
           final points = (par - netScore + 2).clamp(0, 10);
           totalPoints += points;
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

      for (int i = 0; i < scoresToCalculate.length; i++) {
         int? score = scoresToCalculate[i];
         if (score != null && i < holes.length) {
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            
            if (currentFormat == CompetitionFormat.maxScore && maxScoreConfig != null) {
               int cap;
               if (maxScoreConfig.type == MaxScoreType.fixed) {
                 cap = maxScoreConfig.value;
               } else if (maxScoreConfig.type == MaxScoreType.parPlusX) {
                 cap = par + maxScoreConfig.value;
               } else {
                 final strokes = phc.round();
                 final holeStrokes = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
                 cap = par + 2 + holeStrokes;
               }
               if (score > cap) score = cap;
            }
            grossTotal += score;
            parTotal += par;
         }
      }
      
      if (holesPlayed > 0) {
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
      } else {
        displayScore = 999;
        scoreLabel = '-';
      }
    }

    return LeaderboardEntry(
      entryId: id,
      playerName: isGuest ? (reg.guestName ?? 'Guest') : reg.memberName,
      score: displayScore,
      scoreLabel: scoreLabel,
      handicap: handicapIndex.toInt(),
      playingHandicap: phc,
      holesPlayed: holesPlayed,
      isGuest: isGuest,
      tieBreakDetails: _calculateTieBreakDetails(scoresToCalculate, effectiveRules, event.courseConfig, phc),
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
       final si = hole['si'] as int? ?? 9;
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
}
