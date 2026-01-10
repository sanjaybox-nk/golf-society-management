// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  id: json['id'] as String,
  year: (json['year'] as num).toInt(),
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => GolfEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  agmData: json['agmData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'id': instance.id,
  'year': instance.year,
  'events': instance.events,
  'agmData': instance.agmData,
};
