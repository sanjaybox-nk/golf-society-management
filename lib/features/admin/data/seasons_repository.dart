import '../../../models/season.dart';
import '../../../models/leaderboard_standing.dart';

abstract class SeasonsRepository {
  Stream<List<Season>> watchSeasons();
  Future<List<Season>> getSeasons();
  Future<void> addSeason(Season season);
  Future<void> updateSeason(Season season);
  Future<void> deleteSeason(String seasonId);
  Future<void> closeSeason(String seasonId, Map<String, dynamic> agmData);
  Future<void> setCurrentSeason(String seasonId);
  
  // Leaderboard Standings
  Future<void> updateLeaderboardStandings(String seasonId, String leaderboardId, List<LeaderboardStanding> standings);
  Stream<List<LeaderboardStanding>> watchLeaderboardStandings(String seasonId, String leaderboardId);
}
