import '../../../../models/leaderboard_config.dart';
import '../../../../models/leaderboard_standing.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import 'leaderboard_calculator.dart';

class BestOfSeriesCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
  }) async {
    final seriesConfig = config as BestOfSeriesConfig;
    final Map<String, List<double>> playerScores = {};

    // 1. Collect scores per player
    for (var comp in competitions) {
      final compCards = scorecards.where((s) => s.competitionId == comp.id && s.scoringStatus == ScoringStatus.ok).toList();
      
      // Handle Daily Ranking if Ranking Method is Position (or legacy position metric)
      if (seriesConfig.scoringType == ScoringType.position || seriesConfig.metric == BestOfMetric.position) {
         compCards.sort((a, b) {
             // Rank Logic depends on Metric
             if (seriesConfig.metric == BestOfMetric.gross) {
                // Gross = Lower is better
                final grossA = (a.grossTotal != null && a.grossTotal! > 0) ? a.grossTotal! : 9999;
                final grossB = (b.grossTotal != null && b.grossTotal! > 0) ? b.grossTotal! : 9999;
                if (grossA != grossB) return grossA.compareTo(grossB);
                // Countback or Tie break not fully implemented for daily here (using raw score sort)
                return 0; 
             } else {
                // Stableford/Net/Default = Higher Points/Lower Net?
                // For BestOfSeries, 'Metric: Net' usually implies Net Score stroke play (lower is better) or Stableford (higher is better).
                // Assuming 'Metric' defines the sort value.
                if (seriesConfig.metric == BestOfMetric.net) {
                   final netA = (a.netTotal ?? 999);
                   final netB = (b.netTotal ?? 999);
                   return netA.compareTo(netB);
                }
                
                // Fallback / Stableford
                final ptsA = a.points ?? 0;
                final ptsB = b.points ?? 0;
                if (ptsA != ptsB) return ptsB.compareTo(ptsA);
                
                // Tie break with Gross
                final grossA = (a.grossTotal != null && a.grossTotal! > 0) ? a.grossTotal! : 9999;
                final grossB = (b.grossTotal != null && b.grossTotal! > 0) ? b.grossTotal! : 9999;
                return grossA.compareTo(grossB);
             }
         });
      }

      for (int i = 0; i < compCards.length; i++) {
        final card = compCards[i];
        double score = 0;
        
        if (seriesConfig.scoringType == ScoringType.position || seriesConfig.metric == BestOfMetric.position) {
           final rank = i + 1;
           score = (seriesConfig.positionPointsMap[rank] ?? 0).toDouble();
        } else {
           // ScoringType.accumulative
           if (seriesConfig.metric == BestOfMetric.stableford) {
              score = (card.points ?? 0).toDouble();
           } else if (seriesConfig.metric == BestOfMetric.net) {
              score = (card.netTotal ?? 999).toDouble();
           } else {
              score = (card.grossTotal ?? 999).toDouble();
           }
        }
        
        playerScores.putIfAbsent(card.submittedByUserId, () => []).add(score);
      }
    }

    // 2. Aggregate
    List<LeaderboardStanding> standings = [];
    
    playerScores.forEach((memberId, scores) {
      // Sort scores to determine "Best N"
      // If ScoringType is Position, Higher Points is Better (Desc)
      // If ScoringType is Accumulative:
      //    Stableford -> Higher is Better (Desc)
      //    Gross/Net -> Lower is Better (Asc)
      
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
        memberName: 'Unknown', 
        currentHandicap: 0,
        points: totalPoints,
        roundsPlayed: scores.length,
        roundsCounted: countingScores.length,
        history: scores, 
      ));
    });

    // 3. Final Sort
    // Should match the "HigherIsBetter" logic? 
    // Usually LeaderboardStanding.points is generic.
    // However, if we are doing Gross Accumulative, the "points" field actually holds "strokes".
    // So Lower is Better.
    
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
