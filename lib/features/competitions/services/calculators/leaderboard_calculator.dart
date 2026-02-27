import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/scorecard.dart';

abstract class LeaderboardCalculator {
  /// Calculates the standings for a specific leaderboard configuration
  /// based on a list of relevant competitions and their scorecards.
  Future<List<LeaderboardStanding>> calculate({
    required LeaderboardConfig config,
    required List<Competition> competitions,
    required List<Scorecard> scorecards,
    Map<String, Map<String, dynamic>>? groupings, // eventId -> groupingMap
  });
}
