import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'leaderboard_calculator.dart';

class BestOfSeriesCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
    Map<String, ProcessedEventData>? processedEvents,
  }) async {
    final seriesConfig = config as BestOfSeriesConfig;
    final Map<String, List<double>> playerScores = {};

    if (processedEvents == null || processedEvents.isEmpty) return [];

    // 1. Collect scores per player
    for (var comp in competitions) {
      final processedData = processedEvents[comp.id];
      if (processedData == null) continue;

      for (var entry in processedData.leaderboard) {
        if (entry.scoringStatus == ScoringStatus.dq) continue;

        double score = 0;
        
        if (seriesConfig.scoringType == ScoringType.position || seriesConfig.metric == BestOfMetric.position) {
           final rank = entry.position;
           score = (seriesConfig.positionPointsMap[rank] ?? 0).toDouble();
        } else {
           // ScoringType.accumulative
           // We assume the pre-calculated score in ProcessedLeaderboardEntry 
           // already reflects the Metric (Gross, Net, or Stableford)
           score = entry.score.toDouble();
        }
        
        for (var mId in entry.teamMemberIds) {
          if (mId.endsWith('_guest')) continue;
          playerScores.putIfAbsent(mId, () => []).add(score);
        }
      }
    }

    // 2. Aggregate
    List<LeaderboardStanding> standings = [];
    
    playerScores.forEach((memberId, scores) {
      bool higherIsBetter = (seriesConfig.scoringType == ScoringType.position || 
                             seriesConfig.metric == BestOfMetric.position || 
                             seriesConfig.metric == BestOfMetric.stableford);

      if (higherIsBetter) {
        scores.sort((a, b) => b.compareTo(a));
      } else {
        scores.sort((a, b) => a.compareTo(b));
      }

      final countingScores = scores.take(seriesConfig.bestN).toList();
      double totalPoints = countingScores.fold(0.0, (sum, val) => sum + val);

      // Add Appearance Points
      totalPoints += (scores.length * seriesConfig.appearancePoints);

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: memberId,
        memberName: memberId, 
        currentHandicap: 0,
        points: totalPoints,
        roundsPlayed: scores.length,
        roundsCounted: countingScores.length,
        history: scores, 
      ));
    });

    // 3. Final Sort
    bool finalSortHigherIsBetter = (seriesConfig.scoringType == ScoringType.position || 
                                    seriesConfig.metric == BestOfMetric.position || 
                                    seriesConfig.metric == BestOfMetric.stableford);

    if (finalSortHigherIsBetter) {
      standings.sort((a, b) => b.points.compareTo(a.points));
    } else {
      standings.sort((a, b) => a.points.compareTo(b.points));
    }

    return standings;
  }
}
