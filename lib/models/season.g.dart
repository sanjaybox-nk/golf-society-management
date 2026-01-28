// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  id: json['id'] as String,
  name: json['name'] as String,
  year: (json['year'] as num).toInt(),
  status:
      $enumDecodeNullable(_$SeasonStatusEnumMap, json['status']) ??
      SeasonStatus.active,
  isCurrent: json['isCurrent'] as bool? ?? false,
  agmData: json['agmData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'year': instance.year,
  'status': _$SeasonStatusEnumMap[instance.status]!,
  'isCurrent': instance.isCurrent,
  'agmData': instance.agmData,
};

const _$SeasonStatusEnumMap = {
  SeasonStatus.active: 'active',
  SeasonStatus.closed: 'closed',
};
