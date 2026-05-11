import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'leaderboard_calculator.dart';

class EclecticCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
    Map<String, ProcessedEventData>? processedEvents,
  }) async {
    final Map<String, Map<String, int>> playerHoleScores = {}; // memberId -> {holeIndex -> score}

    if (processedEvents == null || processedEvents.isEmpty) return [];

    // 1. Iterate all processed events
    for (var comp in competitions) {
      final processedData = processedEvents[comp.id];
      if (processedData == null) continue;

      for (var player in processedData.individualScores) {
        if (player.isGuest) continue;
        if (player.scoringStatus == ScoringStatus.dq) continue; // DQ rounds excluded from eclectic

        final memberId = player.playerId;
        if (!playerHoleScores.containsKey(memberId)) {
          playerHoleScores[memberId] = {};
        }
        final bestHoles = playerHoleScores[memberId]!;

        for (int i = 0; i < player.holeScores.length; i++) {
          final score = player.holeScores[i];
          if (score == null) continue;
          
          final holeKey = (i + 1).toString();
          final currentBest = bestHoles[holeKey];

          // Strokes: lower is better
          if (currentBest == null || score < currentBest) {
            bestHoles[holeKey] = score;
          }
        }
      }
    }

    // 2. Create Standings
    List<LeaderboardStanding> standings = [];
    playerHoleScores.forEach((memberId, holes) {
      double total = 0;
      holes.forEach((k, v) => total += v);

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: memberId,
        memberName: memberId,
        currentHandicap: 0,
        points: total, // Total Strokes
        roundsPlayed: 0,
        roundsCounted: 0, 
        holeScores: holes,
      ));
    });

    // 3. Sort (Ascending for Strokes)
    standings.sort((a, b) => a.points.compareTo(b.points));

    return standings;
  }
}
