import '../../../models/season.dart';

abstract class SeasonsRepository {
  Future<void> addSeason(Season season);
  Future<void> updateSeason(Season season);
  Stream<List<Season>> watchSeasons();
  Future<Season?> getActiveSeason();
  Future<void> setCurrentSeason(String seasonId);
}
