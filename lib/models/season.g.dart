// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  id: json['id'] as String,
  name: json['name'] as String,
  year: (json['year'] as num).toInt(),
  startDate: const TimestampConverter().fromJson(json['startDate'] as Object),
  endDate: const TimestampConverter().fromJson(json['endDate'] as Object),
  status:
      $enumDecodeNullable(_$SeasonStatusEnumMap, json['status']) ??
      SeasonStatus.active,
  isCurrent: json['isCurrent'] as bool? ?? false,
  leaderboards:
      (json['leaderboards'] as List<dynamic>?)
          ?.map((e) => LeaderboardConfig.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  agmData: json['agmData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'year': instance.year,
  'startDate': const TimestampConverter().toJson(instance.startDate),
  'endDate': const TimestampConverter().toJson(instance.endDate),
  'status': _$SeasonStatusEnumMap[instance.status]!,
  'isCurrent': instance.isCurrent,
  'leaderboards': instance.leaderboards.map((e) => e.toJson()).toList(),
  'agmData': instance.agmData,
};

const _$SeasonStatusEnumMap = {
  SeasonStatus.active: 'active',
  SeasonStatus.closed: 'closed',
};
