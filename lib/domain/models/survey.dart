import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey.freezed.dart';
part 'survey.g.dart';

enum SurveyQuestionType {
  singleChoice,
  multipleChoice,
  text,
}

@freezed
abstract class SurveyQuestion with _$SurveyQuestion {
  const factory SurveyQuestion({
    required String id,
    required String question,
    required SurveyQuestionType type,
    @Default([]) List<String> options,
    @Default(true) bool isRequired,
  }) = _SurveyQuestion;

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) => _$SurveyQuestionFromJson(json);
}

@freezed
abstract class Survey with _$Survey {
  const factory Survey({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    DateTime? deadline,
    @Default(true) bool isPublished,
    @Default([]) List<SurveyQuestion> questions,
    @Default({}) Map<String, dynamic> responses, // userId -> Map<questionId, answer>
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
}
