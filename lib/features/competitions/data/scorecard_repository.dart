// Forced refresh for repository interface
import 'package:golf_society/domain/models/scorecard.dart';

abstract class ScorecardRepository {
  Future<void> addScorecard(Scorecard scorecard);
  Future<void> updateScorecard(Scorecard scorecard);
  Future<void> updateScorecardStatus(String id, ScorecardStatus status);
  Future<void> deleteScorecard(String id);
  Stream<List<Scorecard>> watchScorecards(String competitionId);
  Stream<List<Scorecard>> watchMemberScorecards(String memberId);
  Future<Scorecard?> getScorecard(String id);
  Future<void> deleteAllScorecards(String competitionId);
  Future<List<Scorecard>> getScorecards(String competitionId);
}
