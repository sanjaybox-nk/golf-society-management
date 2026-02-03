import '../../../models/competition.dart';
import '../../../models/scorecard.dart';

abstract class CompetitionsRepository {
  // Competitions
  Stream<List<Competition>> watchCompetitions({CompetitionStatus? status});
  Future<Competition?> getCompetition(String id);
  Future<String> addCompetition(Competition competition);
  Future<void> updateCompetition(Competition competition);
  Future<void> deleteCompetition(String id);

  // Templates
  Stream<List<Competition>> watchTemplates();
  Future<String> addTemplate(Competition template);
  Future<void> updateTemplate(Competition template);
  Future<void> deleteTemplate(String id);

  // Scorecards
  Stream<List<Scorecard>> watchScorecards(String competitionId);
  Future<void> submitScorecard(Scorecard scorecard);
  Future<void> updateScorecard(Scorecard scorecard);
}
