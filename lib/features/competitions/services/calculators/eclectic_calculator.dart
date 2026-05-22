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
    final eclecticConfig = config as EclecticConfig;
    final isStableford = eclecticConfig.metric == EclecticMetric.stableford;

    final Map<String, Map<String, int>> playerHoleScores = {}; // memberId -> {holeIndex -> bestScore}

    if (processedEvents == null || processedEvents.isEmpty) return [];

    // 1. Iterate all processed events
    for (var comp in competitions) {
      final processedData = processedEvents[comp.id];
      if (processedData == null) continue;

      final entries = isStableford
          ? processedData.leaderboard
              .where((e) => !e.isGuest && e.scoringStatus != ScoringStatus.dq)
              .map((e) => (id: e.entryId, scores: e.holePoints ?? e.holeScores ?? <int?>[]))
              .toList()
          : processedData.individualScores
              .where((p) => !p.isGuest && p.scoringStatus != ScoringStatus.dq)
              .map((p) => (id: p.playerId, scores: p.holeScores))
              .toList();

      for (final entry in entries) {
        playerHoleScores.putIfAbsent(entry.id, () => {});
        final bestHoles = playerHoleScores[entry.id]!;

        for (int i = 0; i < entry.scores.length; i++) {
          final score = entry.scores[i];
          if (score == null) continue;
          final holeKey = (i + 1).toString();
          final current = bestHoles[holeKey];
          if (current == null || (isStableford ? score > current : score < current)) {
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
        points: total,
        roundsPlayed: 0,
        roundsCounted: 0,
        holeScores: holes,
      ));
    });

    // 3. Sort — Stableford: descending (more points = better). Strokes: ascending.
    standings.sort((a, b) => isStableford
        ? b.points.compareTo(a.points)
        : a.points.compareTo(b.points));

    return standings;
  }
}
