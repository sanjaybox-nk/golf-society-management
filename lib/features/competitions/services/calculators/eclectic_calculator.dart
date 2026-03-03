import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'leaderboard_calculator.dart';

class EclecticCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
  }) async {
    final Map<String, Map<String, int>> playerHoleScores = {}; // memberId -> {holeIndex -> score}

    // 1. Iterate all cards
    for (var comp in competitions) {
      final compCards = scorecards.where((s) {
        final isExcluded = comp.rules.oomExcludedRoundIds.contains(s.roundId);
        return s.competitionId == comp.id && s.scoringStatus == ScoringStatus.ok && !isExcluded;
      });
      
      for (var card in compCards) {
        // Init player map
        if (!playerHoleScores.containsKey(card.entryId)) {
          playerHoleScores[card.entryId] = {};
        }
        final holes = playerHoleScores[card.entryId]!;

        // Check each hole
        for (int i = 0; i < card.holeScores.length; i++) {
          final score = card.holeScores[i];
          if (score == null) continue;
          
          final holeKey = (i + 1).toString();
          final currentBest = holes[holeKey];

          // Logic: For strokes, lower is better. For Stableford (if we supported it), higher is better.
          // Eclectic usually assumes Gross/Net Score (Strokes).
          if (currentBest == null || score < currentBest) {
            holes[holeKey] = score;
          }
        }
      }
    }

    // [NEW] Filter out guest players - Season Standings are for Society Members only
    playerHoleScores.removeWhere((id, _) => id.endsWith('_guest'));

    // 2. Create Standings
    List<LeaderboardStanding> standings = [];
    playerHoleScores.forEach((memberId, holes) {
      // Sum best scores
      // Note: If a player hasn't played a hole, what is the score?
      // Usually full handicap or ignored. For now, sum only played holes or treat as 0? 
      // Better to treat as Par or leave incomplete.
      // Let's sum actual values found.
      
      double total = 0;
      holes.forEach((k, v) => total += v);

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: memberId,
        memberName: memberId,
        currentHandicap: 0,
        points: total, // Total Strokes
        roundsPlayed: 0, // Not perfectly applicable for Eclectic, could be rounds processed
        roundsCounted: 0, 
        holeScores: holes,
      ));
    });

    // 3. Sort (Ascending for Strokes)
    standings.sort((a, b) => a.points.compareTo(b.points));

    return standings;
  }
}
