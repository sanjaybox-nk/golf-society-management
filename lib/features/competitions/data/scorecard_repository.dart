import '../../../models/scorecard.dart';

abstract class ScorecardRepository {
  Future<void> addScorecard(Scorecard scorecard);
  Future<void> updateScorecard(Scorecard scorecard);
  Future<void> updateScorecardStatus(String id, ScorecardStatus status);
  Future<void> deleteScorecard(String id);
  Stream<List<Scorecard>> watchScorecards(String competitionId);
  Future<Scorecard?> getScorecard(String id);
  Future<void> deleteAllScorecards(String competitionId);
}
