// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaxScoreConfig _$MaxScoreConfigFromJson(Map<String, dynamic> json) =>
    _MaxScoreConfig(
      type:
          $enumDecodeNullable(_$MaxScoreTypeEnumMap, json['type']) ??
          MaxScoreType.parPlusX,
      value: (json['value'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$MaxScoreConfigToJson(_MaxScoreConfig instance) =>
    <String, dynamic>{
      'type': _$MaxScoreTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$MaxScoreTypeEnumMap = {
  MaxScoreType.fixed: 'fixed',
  MaxScoreType.parPlusX: 'parPlusX',
  MaxScoreType.netDoubleBogey: 'netDoubleBogey',
};

_CompetitionRules _$CompetitionRulesFromJson(
  Map<String, dynamic> json,
) => _CompetitionRules(
  format:
      $enumDecodeNullable(_$CompetitionFormatEnumMap, json['format']) ??
      CompetitionFormat.stableford,
  subtype:
      $enumDecodeNullable(_$CompetitionSubtypeEnumMap, json['subtype']) ??
      CompetitionSubtype.none,
  mode:
      $enumDecodeNullable(_$CompetitionModeEnumMap, json['mode']) ??
      CompetitionMode.singles,
  handicapMode:
      $enumDecodeNullable(_$HandicapModeEnumMap, json['handicapMode']) ??
      HandicapMode.whs,
  handicapCap: (json['handicapCap'] as num?)?.toInt() ?? 28,
  handicapAllowance: (json['handicapAllowance'] as num?)?.toDouble() ?? 0.95,
  useCourseAllowance: json['useCourseAllowance'] as bool? ?? true,
  maxScoreConfig: json['maxScoreConfig'] == null
      ? null
      : MaxScoreConfig.fromJson(json['maxScoreConfig'] as Map<String, dynamic>),
  roundsCount: (json['roundsCount'] as num?)?.toInt() ?? 1,
  aggregation:
      $enumDecodeNullable(_$AggregationMethodEnumMap, json['aggregation']) ??
      AggregationMethod.totalSum,
  tieBreak:
      $enumDecodeNullable(_$TieBreakMethodEnumMap, json['tieBreak']) ??
      TieBreakMethod.back9,
  holeByHoleRequired: json['holeByHoleRequired'] as bool? ?? true,
  minDrivesPerPlayer: (json['minDrivesPerPlayer'] as num?)?.toInt() ?? 0,
  useWHSScrambleAllowance: json['useWHSScrambleAllowance'] as bool? ?? false,
  applyCapToIndex: json['applyCapToIndex'] as bool? ?? true,
  teamBestXCount: (json['teamBestXCount'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$CompetitionRulesToJson(_CompetitionRules instance) =>
    <String, dynamic>{
      'format': _$CompetitionFormatEnumMap[instance.format]!,
      'subtype': _$CompetitionSubtypeEnumMap[instance.subtype]!,
      'mode': _$CompetitionModeEnumMap[instance.mode]!,
      'handicapMode': _$HandicapModeEnumMap[instance.handicapMode]!,
      'handicapCap': instance.handicapCap,
      'handicapAllowance': instance.handicapAllowance,
      'useCourseAllowance': instance.useCourseAllowance,
      'maxScoreConfig': instance.maxScoreConfig?.toJson(),
      'roundsCount': instance.roundsCount,
      'aggregation': _$AggregationMethodEnumMap[instance.aggregation]!,
      'tieBreak': _$TieBreakMethodEnumMap[instance.tieBreak]!,
      'holeByHoleRequired': instance.holeByHoleRequired,
      'minDrivesPerPlayer': instance.minDrivesPerPlayer,
      'useWHSScrambleAllowance': instance.useWHSScrambleAllowance,
      'applyCapToIndex': instance.applyCapToIndex,
      'teamBestXCount': instance.teamBestXCount,
    };

const _$CompetitionFormatEnumMap = {
  CompetitionFormat.stroke: 'stroke',
  CompetitionFormat.stableford: 'stableford',
  CompetitionFormat.maxScore: 'maxScore',
  CompetitionFormat.matchPlay: 'matchPlay',
  CompetitionFormat.scramble: 'scramble',
};

const _$CompetitionSubtypeEnumMap = {
  CompetitionSubtype.none: 'none',
  CompetitionSubtype.texas: 'texas',
  CompetitionSubtype.florida: 'florida',
  CompetitionSubtype.grossStableford: 'grossStableford',
  CompetitionSubtype.fourball: 'fourball',
  CompetitionSubtype.foursomes: 'foursomes',
  CompetitionSubtype.ryderCup: 'ryderCup',
  CompetitionSubtype.teamMatchPlay: 'teamMatchPlay',
};

const _$CompetitionModeEnumMap = {
  CompetitionMode.singles: 'singles',
  CompetitionMode.pairs: 'pairs',
  CompetitionMode.teams: 'teams',
};

const _$HandicapModeEnumMap = {
  HandicapMode.whs: 'whs',
  HandicapMode.local: 'local',
  HandicapMode.none: 'none',
};

const _$AggregationMethodEnumMap = {
  AggregationMethod.singleBest: 'singleBest',
  AggregationMethod.totalSum: 'totalSum',
  AggregationMethod.stablefordSum: 'stablefordSum',
};

const _$TieBreakMethodEnumMap = {
  TieBreakMethod.back9: 'back9',
  TieBreakMethod.back6: 'back6',
  TieBreakMethod.back3: 'back3',
  TieBreakMethod.back1: 'back1',
  TieBreakMethod.playoff: 'playoff',
};

_Competition _$CompetitionFromJson(Map<String, dynamic> json) => _Competition(
  id: json['id'] as String,
  name: json['name'] as String?,
  templateId: json['templateId'] as String?,
  type: $enumDecode(_$CompetitionTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$CompetitionStatusEnumMap, json['status']) ??
      CompetitionStatus.draft,
  rules: CompetitionRules.fromJson(json['rules'] as Map<String, dynamic>),
  startDate: const TimestampConverter().fromJson(json['startDate']),
  endDate: const TimestampConverter().fromJson(json['endDate']),
  publishSettings: json['publishSettings'] as Map<String, dynamic>? ?? const {},
  isDirty: json['isDirty'] as bool? ?? false,
  computeVersion: (json['computeVersion'] as num?)?.toInt(),
  lastComputedAt: const OptionalTimestampConverter().fromJson(
    json['lastComputedAt'],
  ),
  lastComputedBy: json['lastComputedBy'] as String?,
);

Map<String, dynamic> _$CompetitionToJson(_Competition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'templateId': instance.templateId,
      'type': _$CompetitionTypeEnumMap[instance.type]!,
      'status': _$CompetitionStatusEnumMap[instance.status]!,
      'rules': instance.rules.toJson(),
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'publishSettings': instance.publishSettings,
      'isDirty': instance.isDirty,
      'computeVersion': instance.computeVersion,
      'lastComputedAt': const OptionalTimestampConverter().toJson(
        instance.lastComputedAt,
      ),
      'lastComputedBy': instance.lastComputedBy,
    };

const _$CompetitionTypeEnumMap = {
  CompetitionType.game: 'game',
  CompetitionType.event: 'event',
};

const _$CompetitionStatusEnumMap = {
  CompetitionStatus.draft: 'draft',
  CompetitionStatus.open: 'open',
  CompetitionStatus.scoring: 'scoring',
  CompetitionStatus.review: 'review',
  CompetitionStatus.published: 'published',
  CompetitionStatus.closed: 'closed',
};
