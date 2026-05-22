import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'leaderboard_calculator.dart';

class MarkerCounterCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
    Map<String, ProcessedEventData>? processedEvents,
  }) async {
    final markerConfig = config as MarkerCounterConfig;
    final Map<String, _PlayerStats> playerStats = {};

    if (processedEvents == null || processedEvents.isEmpty) return [];

    // 1. Process each processed event
    for (var comp in competitions) {
      final processedData = processedEvents[comp.id];
      if (processedData == null) continue;

      final pars = processedData.holePars;

      for (var player in processedData.individualScores) {
        if (player.isGuest) continue;

        if (!playerStats.containsKey(player.playerId)) {
          playerStats[player.playerId] = _PlayerStats(memberId: player.playerId);
        }
        final stats = playerStats[player.playerId]!;

        double roundScore = 0;
        int markersInRound = 0;

        for (int i = 0; i < player.holeScores.length; i++) {
          final gross = player.holeScores[i];
          if (gross == null || gross == 0) continue;

          final holePar = (pars.length > i) ? pars[i] : 4;

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
            roundScore += 1;
            // Track per-hole only for single-type configs
            if (markerConfig.targetTypes.length == 1) {
              final holeKey = (i + 1).toString();
              stats.holeMarkers[holeKey] = (stats.holeMarkers[holeKey] ?? 0) + 1;
            }
          }
        }

        stats.rounds.add(_RoundData(
          totalMarkers: markersInRound,
          score: roundScore,
          totalRoundStableford: player.result.score.toDouble(),
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
        memberName: memberId,
        currentHandicap: 0,
        points: totalPoints,
        roundsPlayed: stats.rounds.length,
        roundsCounted: countToTake,
        history: stats.rounds.map((r) => r.score).toList(),
        holeScores: markerConfig.targetTypes.length == 1 ? stats.holeMarkers : {},
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
  final Map<String, int> holeMarkers = {};
  _PlayerStats({required this.memberId});
}

class _RoundData {
  final int totalMarkers;
  final double score;
  final double totalRoundStableford;
  _RoundData({required this.totalMarkers, required this.score, required this.totalRoundStableford});
}
