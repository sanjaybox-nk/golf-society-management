// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'golf_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GolfEvent _$GolfEventFromJson(Map<String, dynamic> json) => _GolfEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  location: json['location'] as String,
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  regTime: json['regTime'] == null
      ? null
      : DateTime.parse(json['regTime'] as String),
  teeOffTime: json['teeOffTime'] == null
      ? null
      : DateTime.parse(json['teeOffTime'] as String),
  registrations:
      (json['registrations'] as List<dynamic>?)
          ?.map((e) => EventRegistration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  grouping: json['grouping'] as Map<String, dynamic>? ?? const {},
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  courseConfig: json['courseConfig'] as Map<String, dynamic>? ?? const {},
  flashUpdates:
      (json['flashUpdates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$GolfEventToJson(_GolfEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'location': instance.location,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'regTime': instance.regTime?.toIso8601String(),
      'teeOffTime': instance.teeOffTime?.toIso8601String(),
      'registrations': instance.registrations,
      'grouping': instance.grouping,
      'results': instance.results,
      'courseConfig': instance.courseConfig,
      'flashUpdates': instance.flashUpdates,
    };
