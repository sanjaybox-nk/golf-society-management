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
  pointsMode:
      $enumDecodeNullable(_$PointsModeEnumMap, json['pointsMode']) ??
      PointsMode.position,
  bestN: (json['bestN'] as num?)?.toInt() ?? 8,
  tiePolicy:
      $enumDecodeNullable(_$TiePolicyEnumMap, json['tiePolicy']) ??
      TiePolicy.countback,
  participationPointsRules:
      json['participationPointsRules'] as Map<String, dynamic>? ?? const {},
  eclecticRules: json['eclecticRules'] as Map<String, dynamic>? ?? const {},
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
  'pointsMode': _$PointsModeEnumMap[instance.pointsMode]!,
  'bestN': instance.bestN,
  'tiePolicy': _$TiePolicyEnumMap[instance.tiePolicy]!,
  'participationPointsRules': instance.participationPointsRules,
  'eclecticRules': instance.eclecticRules,
  'agmData': instance.agmData,
};

const _$SeasonStatusEnumMap = {
  SeasonStatus.active: 'active',
  SeasonStatus.closed: 'closed',
};

const _$PointsModeEnumMap = {
  PointsMode.position: 'position',
  PointsMode.stableford: 'stableford',
  PointsMode.combined: 'combined',
};

const _$TiePolicyEnumMap = {
  TiePolicy.countback: 'countback',
  TiePolicy.shared: 'shared',
  TiePolicy.playoff: 'playoff',
};
