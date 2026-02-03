import '../../../models/scorecard.dart';

abstract class ScorecardRepository {
  Future<void> addScorecard(Scorecard scorecard);
  Future<void> updateScorecard(Scorecard scorecard);
  Stream<List<Scorecard>> watchScorecards(String competitionId);
  Future<Scorecard?> getScorecard(String id);
}
