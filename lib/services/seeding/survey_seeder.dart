import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/surveys/presentation/surveys_provider.dart';

class SurveySeeder {
  final Ref ref;
  final Random random;

  SurveySeeder(this.ref, this.random);

  Future<void> seed(List<Member> members) async {
    final surveyRepo = ref.read(surveysRepositoryProvider);
    final now = DateTime.now();
    
    // Helper to generate a participation list (50-60%)
    List<Member> getParticipants() {
      final eligibleMembers = members.where((m) => m.id != 'demo_hero_sanjay').toList();
      final shuffled = List<Member>.from(eligibleMembers)..shuffle(random);
      final rate = 0.5 + (random.nextDouble() * 0.1); 
      final count = (eligibleMembers.length * rate).round();
      return shuffled.take(count).toList();
    }

    // 1. Season 2026 Feedback Survey
    final seasonSurvey = Survey(
      id: 'survey_season_2026',
      title: 'Season 2026 Feedback',
      description: 'We value your input! Help us reach new heights in 2027 by sharing your thoughts on the current season organization and event variety.',
      createdAt: now.subtract(const Duration(days: 5)),
      deadline: now.add(const Duration(days: 20)),
      isPublished: true,
      questions: [
        const SurveyQuestion(
          id: 'q1_org',
          question: 'How would you rate the overall society organization this season?',
          type: SurveyQuestionType.singleChoice,
          options: ['Elite (Flawless)', 'Standard (Reliable)', 'Needs Work', 'Poor'],
        ),
        const SurveyQuestion(
          id: 'q2_events',
          question: 'Which event formats would you like to see more of next year?',
          type: SurveyQuestionType.multipleChoice,
          options: ['Stableford Majors', 'Match Play Grudge Matches', 'Texas Scrambles', 'Multi-Day Tours'],
        ),
        const SurveyQuestion(
          id: 'q3_improve',
          question: 'What is the number one thing we could improve for 2027?',
          type: SurveyQuestionType.text,
        ),
      ],
      responses: {},
    );

    // 2. Apparel Design 2026 Poll
    final apparelSurvey = Survey(
      id: 'survey_apparel_2026',
      title: 'New Apparel Design Poll',
      description: 'Vote for the official society polo shirt design. The winning combination will be our standard uniform for all 2026 Major events.',
      createdAt: now.subtract(const Duration(days: 2)),
      deadline: now.add(const Duration(days: 10)),
      isPublished: true,
      questions: [
        const SurveyQuestion(
          id: 'q1_color',
          question: 'Choose the primary base color for the 2026 Polo:',
          type: SurveyQuestionType.singleChoice,
          options: ['Midnight Navy', 'Forest Green', 'Stealth Charcoal', 'Classic White'],
        ),
        const SurveyQuestion(
          id: 'q2_logo',
          question: 'Where should the secondary society logo be placed?',
          type: SurveyQuestionType.singleChoice,
          options: ['Right Sleeve', 'Left Sleeve', 'Nape of Neck'],
        ),
        const SurveyQuestion(
          id: 'q3_comments',
          question: 'Any specific material or fit suggestions for the committee?',
          type: SurveyQuestionType.text,
        ),
      ],
      responses: {},
    );

    final surveys = [seasonSurvey, apparelSurvey];

    for (var survey in surveys) {
      final participants = getParticipants();
      final Map<String, dynamic> responses = {};
      
      for (var member in participants) {
        final Map<String, dynamic> answers = {};
        for (var q in survey.questions) {
          if (q.type == SurveyQuestionType.singleChoice) {
            answers[q.id] = q.options[random.nextInt(q.options.length)];
          } else if (q.type == SurveyQuestionType.multipleChoice) {
            final selectedCount = random.nextInt(q.options.length) + 1;
            final shuffledOptions = List<String>.from(q.options)..shuffle(random);
            answers[q.id] = shuffledOptions.take(selectedCount).toList();
          } else if (q.type == SurveyQuestionType.text) {
            final comments = [
              'Great season so far, really enjoying the tour events.',
              'More weekend slots please!',
              'Love the new design 4.x branding on the app.',
              'Could we look at more prestige courses next year?',
              'Excellent work by the committee.',
            ];
            answers[q.id] = comments[random.nextInt(comments.length)];
          }
        }
        responses[member.id] = answers;
      }
      
      await surveyRepo.addSurvey(survey.copyWith(responses: responses));
      debugPrint('Seeded survey: ${survey.title} with ${responses.length} responses.');
    }
  }
}
