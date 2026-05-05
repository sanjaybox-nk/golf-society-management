import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/features/events/domain/models/processed_event_data.dart';
import 'leaderboard_calculator.dart';

class OOMCalculator implements LeaderboardCalculator {
  @override
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings,
    Map<String, ProcessedEventData>? processedEvents,
  }) async {
    final oomConfig = config as OrderOfMeritConfig;
    
    // Map of Member ID -> List of (Event ID, Points)
    final Map<String, List<_EventScore>> memberScores = {};

    if (processedEvents == null || processedEvents.isEmpty) return [];

    // Process each competition
    for (var comp in competitions) {
      final processedData = processedEvents[comp.id];
      if (processedData == null) continue;

      // Filter out excluded rounds if applicable (though usually OOM captures the whole event)
      // but if an event has multiple rounds, we might need more granular logic.
      // For now, we assume 1 event = 1 leaderboard result.

      for (var entry in processedData.leaderboard) {
        final position = entry.position;

        // Calculate Points
        double pointsEarned = 0;
        if (oomConfig.source == OOMSource.position) {
          pointsEarned = (oomConfig.positionPointsMap[position] ?? 0).toDouble();
        } else if (oomConfig.source == OOMSource.stableford) {
          // If source is stableford, we use the score directly (assuming it's formatted as pts)
          pointsEarned = entry.score.toDouble();
        } else if (oomConfig.source == OOMSource.gross) {
          pointsEarned = entry.score.toDouble();
        }
        
        // Participation points
        pointsEarned += oomConfig.appearancePoints;

        // Attribute points to each member in the entry (handles Pairs/Teams)
        for (var mId in entry.teamMemberIds) {
          if (GuestIdHelper.isGuestId(mId)) continue; // Skip guests in OOM
          
          memberScores.putIfAbsent(mId, () => []);
          memberScores[mId]!.add(_EventScore(comp.id, pointsEarned));
        }
      }
    }

    // Convert scores to Standings, applying Best N rule
    final List<LeaderboardStanding> standings = [];
    for (var entry in memberScores.entries) {
      final mId = entry.key;
      final scores = entry.value;

      // Sort scores descending to take Best N
      scores.sort((a, b) => b.points.compareTo(a.points));

      final int roundsPlayed = scores.length;
      final int bestN = oomConfig.bestN > 0 ? oomConfig.bestN : roundsPlayed;
      final countingScores = scores.take(bestN).toList();
      final double totalPoints = countingScores.fold(0.0, (sum, s) => sum + s.points);

      standings.add(LeaderboardStanding(
        leaderboardId: config.id,
        memberId: mId,
        memberName: mId, // Default to ID, will be updated with real name in service
        currentHandicap: 0.0,
        points: totalPoints,
        roundsPlayed: roundsPlayed,
        roundsCounted: countingScores.length,
      ));
    }

    // Final sorting of standings
    standings.sort((a, b) => b.points.compareTo(a.points));

    return standings;
  }
}

class _EventScore {
  final String eventId;
  final double points;
  _EventScore(this.eventId, this.points);
}
