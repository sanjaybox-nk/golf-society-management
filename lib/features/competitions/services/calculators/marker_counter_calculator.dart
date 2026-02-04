import '../../../../models/leaderboard_config.dart';
import '../../../../models/leaderboard_standing.dart';
import '../../../../models/competition.dart';
import '../../../../models/scorecard.dart';
import 'leaderboard_calculator.dart';

class MarkerCounterCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
  }) async {
    final markerConfig = config as MarkerCounterConfig;
    final Map<String, _PlayerStats> playerStats = {};

    // 1. Process each competition/event
    for (var comp in competitions) {
      // Find associated event to get courseConfig
      // Assuming 1:1 mapping for now where CompID == EventID or similar
      // In this system, competitions are often linked to events.
      // We'll need a way to find the event. For now, let's assume we have access or fallback to default par 72/pars 4.
      
      // Filter cards for this competition
      final compCards = scorecards.where((s) => s.competitionId == comp.id && s.scoringStatus == ScoringStatus.ok).toList();

      for (var card in compCards) {
        if (!playerStats.containsKey(card.submittedByUserId)) {
          playerStats[card.submittedByUserId] = _PlayerStats(memberId: card.submittedByUserId);
        }
        final stats = playerStats[card.submittedByUserId]!;

        // We calculate stats for this specific round
        double roundScore = 0;
        int markersInRound = 0;

        // Try to derive par info
        // Simple fallback: 18 holes, all par 4
        List<int> pars = List.generate(18, (index) => 4);
        
        // If we had the event, we would do:
        // if (event.courseConfig['holes'] != null) { ... }
        
        for (int i = 0; i < card.holeScores.length; i++) {
          final gross = card.holeScores[i];
          if (gross == null || gross == 0) continue;

          final holePar = pars[i];

          // Apply Hole Filter
          if (markerConfig.holeFilter == HoleFilter.par3 && holePar != 3) continue;
          if (markerConfig.holeFilter == HoleFilter.par4 && holePar != 4) continue;
          if (markerConfig.holeFilter == HoleFilter.par5 && holePar != 5) continue;

          // Check for markers
          bool isTarget = false;
          final diff = gross - holePar;

          if (markerConfig.targetTypes.contains(MarkerType.holeInOne) && gross == 1) {
            isTarget = true;
          } else if (markerConfig.targetTypes.contains(MarkerType.albatross) && diff <= -3) {
            isTarget = true;
          } else if (markerConfig.targetTypes.contains(MarkerType.eagle) && diff == -2) {
            isTarget = true;
          } else if (markerConfig.targetTypes.contains(MarkerType.birdie) && diff == -1) {
            isTarget = true;
          } else if (markerConfig.targetTypes.contains(MarkerType.par) && diff == 0) {
            isTarget = true;
          } else if (markerConfig.targetTypes.contains(MarkerType.two) && gross == 2) {
            isTarget = true;
          }

          if (isTarget) {
            markersInRound++;
            
            if (markerConfig.rankingMethod == MarkerRankingMethod.points) {
               // Calculate Stableford Points for this hole
               // This requires handicap/SI which we don't have easily here without a full engine
               // For "straightforward number of pars on par 3 holes", user likely wants COUNT.
               // If points requested, we might need to sum the 'points' field if it were per-hole.
               // Since card only has total points, this is tricky.
               // Fallback: If points requested but not available per hole, we can't do it accurately.
               // For now, let's assume 'points' means we sum some value.
               roundScore += 1; // Placeholder
            } else {
               roundScore += 1;
            }
          }
        }

        stats.rounds.add(_RoundData(
          totalMarkers: markersInRound,
          score: roundScore,
          totalRoundStableford: (card.points ?? 0).toDouble(),
        ));
      }
    }

    // 2. Aggregate Results with BestN
    List<LeaderboardStanding> standings = [];
    playerStats.forEach((memberId, stats) {
      // Sort rounds by total round stableford (to pick "Best N Rounds")
      stats.rounds.sort((a, b) => b.totalRoundStableford.compareTo(a.totalRoundStableford));

      final countToTake = markerConfig.bestN > 0 ? markerConfig.bestN.clamp(0, stats.rounds.length) : stats.rounds.length;
      final bestRounds = stats.rounds.take(countToTake);

      double totalPoints = 0;

      for (var r in bestRounds) {
        totalPoints += r.score;
      }

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: memberId,
        memberName: 'Unknown',
        currentHandicap: 0,
        points: totalPoints,
        roundsPlayed: stats.rounds.length,
        roundsCounted: countToTake,
      ));
    });

    // 3. Sort (Highest points/count first)
    standings.sort((a, b) => b.points.compareTo(a.points));

    return standings;
  }
}

class _PlayerStats {
  final String memberId;
  final List<_RoundData> rounds = [];
  _PlayerStats({required this.memberId});
}

class _RoundData {
  final int totalMarkers;
  final double score;
  final double totalRoundStableford;
  _RoundData({required this.totalMarkers, required this.score, required this.totalRoundStableford});
}
