import 'dart:math' as math;
import '../../../models/golf_event.dart';
import '../../../models/scorecard.dart';
import '../../../models/competition.dart';
import '../../../models/event_registration.dart';

class EventAnalysisEngine {
  static Map<String, dynamic> calculateFinalStats({
    required List<Scorecard> scorecards,
    required GolfEvent event,
    required Competition? competition,
    bool isStableford = true,
  }) {
    final holes = event.courseConfig['holes'] as List? ?? [];
    final totalPlayers = scorecards.length;

    if (totalPlayers == 0) return {};

    // 1. Field Distribution & Hole Averages
    Map<int, double> holeAverages = {};
    Map<int, int> holeCounts = {};
    int fieldEagles = 0;
    int fieldBirdies = 0;
    int fieldPars = 0;
    int fieldBogeys = 0;
    int fieldBlobs = 0;
    List<int?> eclecticRound = List.generate(18, (_) => null);

    Map<String, int> stablefordBuckets = {'<20': 0, '20-25': 0, '26-30': 0, '31-35': 0, '36+': 0};
    
    
    Map<int, double> parTypeSums = {3: 0, 4: 0, 5: 0};
    Map<int, int> parTypeCounts = {3: 0, 4: 0, 5: 0};

    for (var s in scorecards) {
      // Stableford Buckets
      final pts = s.points ?? 0;
      if (pts < 20) {
        stablefordBuckets['<20'] = stablefordBuckets['<20']! + 1;
      } else if (pts <= 25) {
        stablefordBuckets['20-25'] = stablefordBuckets['20-25']! + 1;
      } else if (pts <= 30) {
        stablefordBuckets['26-30'] = stablefordBuckets['26-30']! + 1;
      } else if (pts <= 35) {
        stablefordBuckets['31-35'] = stablefordBuckets['31-35']! + 1;
      } else {
        stablefordBuckets['36+'] = stablefordBuckets['36+']! + 1;
      }

      for (int i = 0; i < 18; i++) {
        final score = s.holeScores.length > i ? s.holeScores[i] : null;
        if (score != null) {
          holeAverages[i] = (holeAverages[i] ?? 0) + score;
          holeCounts[i] = (holeCounts[i] ?? 0) + 1;

          final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
          final diff = score - par;
          if (diff <= -2) {
            fieldEagles++;
          } else if (diff == -1) {
            fieldBirdies++;
          } else if (diff == 0) {
            fieldPars++;
          } else if (diff == 1) {
            fieldBogeys++;
          } else if (diff >= 2) {
            fieldBlobs++;
          }

          if (parTypeSums.containsKey(par)) {
            parTypeSums[par] = parTypeSums[par]! + diff;
            parTypeCounts[par] = parTypeCounts[par]! + 1;
          }

          if (eclecticRound[i] == null || score < (eclecticRound[i]!)) {
            eclecticRound[i] = score;
          }
        }
      }
    }

    holeAverages.forEach((key, value) {
      if (holeCounts[key]! > 0) {
        holeAverages[key] = value / holeCounts[key]!;
      }
    });

    Map<int, double> parTypeAverages = {};
    parTypeSums.forEach((key, value) {
      if (parTypeCounts[key]! > 0) {
        parTypeAverages[key] = value / (parTypeCounts[key]! / totalPlayers);
      }
    });

    int toughestIdx = 0;
    double maxDiff = -999;
    holeAverages.forEach((idx, avg) {
      final par = holes.length > idx ? (holes[idx]['par'] as int? ?? 4).toDouble() : 4.0;
      final diff = avg - par;
      if (diff > maxDiff) {
        maxDiff = diff;
        toughestIdx = idx;
      }
    });

    // 2. Awards Logic
    String hotStreakPlayer = 'None';
    int maxStreak = 0;
    String bounceBackPlayer = 'None';
    int maxBounceBacks = 0;
    String finisherPlayer = 'None';
    int bestFinishScore = isStableford ? -999 : 999;
    String blobKingPlayer = 'None';
    int maxBlobs = 0;
    String grinderPlayer = 'None';
    int maxParsPlayer = 0;
    String sniperPlayer = 'None';
    int maxBirdsPlayer = 0;
    String rollercoasterPlayer = 'None';
    double maxVariance = 0;

    for (var s in scorecards) {
      final reg = event.registrations.firstWhere(
        (r) => r.memberId == s.entryId.replaceFirst('_guest', ''),
        orElse: () => EventRegistration(memberId: '', memberName: 'Unknown', attendingGolf: true),
      );
      final name = s.entryId.endsWith('_guest') ? (reg.guestName ?? 'Guest') : reg.memberName;

      // Hot Streak
      int currentStreak = 0;
      int playerMaxStreak = 0;
      for (int i = 0; i < 18; i++) {
        final score = s.holeScores.length > i ? s.holeScores[i] : null;
        if (score != null) {
          final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
          if (score <= par) {
            currentStreak++;
            playerMaxStreak = math.max(playerMaxStreak, currentStreak);
          } else {
            currentStreak = 0;
          }
        }
      }
      if (playerMaxStreak > maxStreak) {
        maxStreak = playerMaxStreak;
        hotStreakPlayer = name;
      }

      // Bounce Back
      int playerBounceBacks = 0;
      for (int i = 1; i < 18; i++) {
        final score = s.holeScores.length > i ? s.holeScores[i] : null;
        final prevScore = s.holeScores.length > (i - 1) ? s.holeScores[i - 1] : null;
        if (score != null && prevScore != null) {
           final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
           final prevPar = holes.length > (i - 1) ? (holes[i - 1]['par'] as int? ?? 4) : 4;
           if (prevScore > prevPar && score <= par) {
             playerBounceBacks++;
           }
        }
      }
      if (playerBounceBacks > maxBounceBacks) {
        maxBounceBacks = playerBounceBacks;
        bounceBackPlayer = name;
      }

      // Finisher
      if (s.holeScores.length >= 18 && s.holeScores[15] != null && s.holeScores[16] != null && s.holeScores[17] != null) {
        int playerFinishScore = 0;
        if (isStableford) {
          final phc = reg.playingHandicap ?? 0;
          for (int i = 15; i < 18; i++) {
            final score = s.holeScores[i]!;
            final par = holes[i]['par'] as int? ?? 4;
            final si = holes[i]['si'] as int? ?? 18;
            int shots = (phc ~/ 18);
            if (si <= (phc % 18)) shots++;
            final netScore = score - shots;
            playerFinishScore += (2 + (par - netScore)).clamp(0, 10).toInt();
          }
          if (playerFinishScore > bestFinishScore) {
            bestFinishScore = playerFinishScore;
            finisherPlayer = name;
          }
        } else {
          playerFinishScore = s.holeScores[15]! + s.holeScores[16]! + s.holeScores[17]!;
          if (playerFinishScore < bestFinishScore) {
            bestFinishScore = playerFinishScore;
            finisherPlayer = name;
          }
        }
      }

      // Banter Calcs
      int playerBlobs = 0;
      int playerPars = 0;
      int playerBirds = 0;
      List<double> diffs = [];
      for (int i = 0; i < 18; i++) {
        final score = s.holeScores.length > i ? s.holeScores[i] : null;
        if (score != null) {
          final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
          final diff = score - par;
          if (diff >= 3) playerBlobs++;
          if (diff == 0) playerPars++;
          if (diff < 0) playerBirds++;
          diffs.add(diff.toDouble());
        }
      }
      if (playerBlobs > maxBlobs) {
        maxBlobs = playerBlobs;
        blobKingPlayer = name;
      }
      if (playerPars > maxParsPlayer) {
        maxParsPlayer = playerPars;
        grinderPlayer = name;
      }
      if (playerBirds > maxBirdsPlayer) {
        maxBirdsPlayer = playerBirds;
        sniperPlayer = name;
      }
      if (diffs.length > 5) {
        double mean = diffs.fold<num>(0, (a, b) => a + b).toDouble() / diffs.length;
        double variance = diffs.map((d) => math.pow(d.toDouble() - mean, 2)).fold<double>(0.0, (a, b) => a + b) / diffs.length;
        if (variance > maxVariance) {
          maxVariance = variance;
          rollercoasterPlayer = name;
        }
      }
    }

    // Advanced Field Totals
    double totalVariance = 0;
    double totalNet = 0;
    int netCount = 0;
    double totalBounceBackRate = 0;
    int bounceBackCount = 0;

    for (var s in scorecards) {
      List<double> diffs = [];
      for (int i = 0; i < 18; i++) {
        final score = s.holeScores.length > i ? s.holeScores[i] : null;
        if (score != null) {
          final par = holes.length > i ? (holes[i]['par'] as int? ?? 4) : 4;
          diffs.add((score - par).toDouble());
        }
      }
      if (diffs.length > 5) {
        double mean = diffs.fold<num>(0, (a, b) => a + b).toDouble() / diffs.length;
        double variance = diffs.map((d) => math.pow(d.toDouble() - mean, 2)).fold<double>(0.0, (a, b) => a + b) / diffs.length;
        totalVariance += variance;
      }
      if (s.netTotal != null) {
        totalNet += s.netTotal!;
        netCount++;
      }
      int pBB = 0;
      int pOpportunities = 0;
      for (int i = 1; i < 18; i++) {
        final s1 = s.holeScores.length > i ? s.holeScores[i] : null;
        final s0 = s.holeScores.length > (i - 1) ? s.holeScores[i - 1] : null;
        if (s1 != null && s0 != null) {
          final par1 = (holes.length > i) ? (holes[i]['par'] as int? ?? 4) : 4;
          final par0 = (holes.length > i - 1) ? (holes[i - 1]['par'] as int? ?? 4) : 4;
          if (s0 > par0) {
            pOpportunities++;
            if (s1 <= par1) pBB++;
          }
        }
      }
      if (pOpportunities > 0) {
        totalBounceBackRate += (pBB / pOpportunities);
        bounceBackCount++;
      }
    }

    return {
      'fieldEagles': fieldEagles,
      'fieldBirdies': fieldBirdies,
      'fieldPars': fieldPars,
      'fieldBogeys': fieldBogeys,
      'fieldBlobs': fieldBlobs,
      'stablefordBuckets': stablefordBuckets,
      'holeAverages': holeAverages,
      'parTypeAverages': parTypeAverages,
      'toughestIdx': toughestIdx,
      'toughestName': 'Hole ${toughestIdx + 1}',
      'maxDiff': maxDiff,
      'hotStreakPlayer': hotStreakPlayer,
      'maxStreak': maxStreak,
      'bounceBackPlayer': bounceBackPlayer,
      'maxBounceBacks': maxBounceBacks,
      'finisherPlayer': finisherPlayer,
      'bestFinishScore': bestFinishScore,
      'blobKingPlayer': blobKingPlayer,
      'maxBlobs': maxBlobs,
      'grinderPlayer': grinderPlayer,
      'maxParsPlayer': maxParsPlayer,
      'sniperPlayer': sniperPlayer,
      'maxBirdsPlayer': maxBirdsPlayer,
      'rollercoasterPlayer': rollercoasterPlayer,
      'maxVariance': maxVariance,
      'fieldAvgVar': totalVariance / (totalPlayers > 0 ? totalPlayers : 1),
      'fieldAvgNetScore': totalNet / (netCount > 0 ? netCount : 1),
      'fieldAvgBB': totalBounceBackRate / (bounceBackCount > 0 ? bounceBackCount : 1),
      'eclecticRound': eclecticRound,
      'totalPlayers': totalPlayers,
      'totalHolesPlayed': totalPlayers * holes.length,
    };
  }
}
