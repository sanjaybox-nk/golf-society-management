// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyQuestion _$SurveyQuestionFromJson(Map<String, dynamic> json) =>
    _SurveyQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      type: $enumDecode(_$SurveyQuestionTypeEnumMap, json['type']),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isRequired: json['isRequired'] as bool? ?? true,
    );

Map<String, dynamic> _$SurveyQuestionToJson(_SurveyQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'type': _$SurveyQuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'isRequired': instance.isRequired,
    };

const _$SurveyQuestionTypeEnumMap = {
  SurveyQuestionType.singleChoice: 'singleChoice',
  SurveyQuestionType.multipleChoice: 'multipleChoice',
  SurveyQuestionType.text: 'text',
};

_Survey _$SurveyFromJson(Map<String, dynamic> json) => _Survey(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  isPublished: json['isPublished'] as bool? ?? true,
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  responses: json['responses'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SurveyToJson(_Survey instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'deadline': instance.deadline?.toIso8601String(),
  'isPublished': instance.isPublished,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'responses': instance.responses,
};
