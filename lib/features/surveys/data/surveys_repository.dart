import 'package:golf_society/domain/models/survey.dart';

abstract class SurveysRepository {
  Stream<List<Survey>> watchSurveys();
  Stream<Survey?> watchSurvey(String id);
  Future<List<Survey>> getSurveys();
  Future<Survey?> getSurvey(String id);
  Future<String> addSurvey(Survey survey);
  Future<void> updateSurvey(Survey survey);
  Future<void> deleteSurvey(String id);
  Future<void> submitResponse(String surveyId, String userId, Map<String, dynamic> answers);
}
