import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/survey.dart';

// Simple Riverpod provider for managing surveys (In-memory/Mock for this phase)
class SurveysNotifier extends Notifier<List<Survey>> {
  @override
  List<Survey> build() {
    return [
      Survey(
        id: '1',
        title: '2026 Season Feedback',
        description: 'Help us improve the society experience for next year.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isPublished: true,
        questions: [
          const SurveyQuestion(
            id: 'q1',
            question: 'How would you rate the choice of courses?',
            type: SurveyQuestionType.singleChoice,
            options: ['Excellent', 'Good', 'Average', 'Poor'],
          ),
          const SurveyQuestion(
            id: 'q2',
            question: 'Suggest one new course for next season:',
            type: SurveyQuestionType.text,
          ),
        ],
      ),
    ];
  }

  void addSurvey(Survey survey) {
    state = [survey, ...state];
  }

  void updateSurvey(Survey survey) {
    state = [
      for (final s in state)
        if (s.id == survey.id) survey else s
    ];
  }

  void deleteSurvey(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final surveysProvider = NotifierProvider<SurveysNotifier, List<Survey>>(SurveysNotifier.new);
