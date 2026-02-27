// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderOfMeritConfig _$OrderOfMeritConfigFromJson(Map<String, dynamic> json) =>
    OrderOfMeritConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      source:
          $enumDecodeNullable(_$OOMSourceEnumMap, json['source']) ??
          OOMSource.position,
      rankingBasis:
          $enumDecodeNullable(_$OOMRankingBasisEnumMap, json['rankingBasis']) ??
          OOMRankingBasis.stableford,
      positionPointsMap:
          (json['positionPointsMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
          ) ??
          const {},
      appearancePoints: (json['appearancePoints'] as num?)?.toInt() ?? 0,
      bestN: (json['bestN'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$OrderOfMeritConfigToJson(OrderOfMeritConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'source': _$OOMSourceEnumMap[instance.source]!,
      'rankingBasis': _$OOMRankingBasisEnumMap[instance.rankingBasis]!,
      'positionPointsMap': instance.positionPointsMap.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
      'appearancePoints': instance.appearancePoints,
      'bestN': instance.bestN,
      'runtimeType': instance.$type,
    };

const _$OOMSourceEnumMap = {
  OOMSource.position: 'position',
  OOMSource.stableford: 'stableford',
  OOMSource.gross: 'gross',
};

const _$OOMRankingBasisEnumMap = {
  OOMRankingBasis.stableford: 'stableford',
  OOMRankingBasis.gross: 'gross',
};

BestOfSeriesConfig _$BestOfSeriesConfigFromJson(Map<String, dynamic> json) =>
    BestOfSeriesConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      bestN: (json['bestN'] as num?)?.toInt() ?? 8,
      metric:
          $enumDecodeNullable(_$BestOfMetricEnumMap, json['metric']) ??
          BestOfMetric.stableford,
      scoringType:
          $enumDecodeNullable(_$ScoringTypeEnumMap, json['scoringType']) ??
          ScoringType.accumulative,
      tiePolicy:
          $enumDecodeNullable(_$TiePolicyEnumMap, json['tiePolicy']) ??
          TiePolicy.countback,
      positionPointsMap:
          (json['positionPointsMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
          ) ??
          const {},
      appearancePoints: (json['appearancePoints'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$BestOfSeriesConfigToJson(BestOfSeriesConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bestN': instance.bestN,
      'metric': _$BestOfMetricEnumMap[instance.metric]!,
      'scoringType': _$ScoringTypeEnumMap[instance.scoringType]!,
      'tiePolicy': _$TiePolicyEnumMap[instance.tiePolicy]!,
      'positionPointsMap': instance.positionPointsMap.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
      'appearancePoints': instance.appearancePoints,
      'runtimeType': instance.$type,
    };

const _$BestOfMetricEnumMap = {
  BestOfMetric.gross: 'gross',
  BestOfMetric.net: 'net',
  BestOfMetric.stableford: 'stableford',
  BestOfMetric.position: 'position',
};

const _$ScoringTypeEnumMap = {
  ScoringType.accumulative: 'accumulative',
  ScoringType.position: 'position',
};

const _$TiePolicyEnumMap = {
  TiePolicy.countback: 'countback',
  TiePolicy.shared: 'shared',
  TiePolicy.playoff: 'playoff',
};

EclecticConfig _$EclecticConfigFromJson(Map<String, dynamic> json) =>
    EclecticConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      metric:
          $enumDecodeNullable(_$EclecticMetricEnumMap, json['metric']) ??
          EclecticMetric.strokes,
      handicapPercentage: (json['handicapPercentage'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$EclecticConfigToJson(EclecticConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'metric': _$EclecticMetricEnumMap[instance.metric]!,
      'handicapPercentage': instance.handicapPercentage,
      'runtimeType': instance.$type,
    };

const _$EclecticMetricEnumMap = {
  EclecticMetric.strokes: 'strokes',
  EclecticMetric.stableford: 'stableford',
};

MarkerCounterConfig _$MarkerCounterConfigFromJson(Map<String, dynamic> json) =>
    MarkerCounterConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      targetTypes: (json['targetTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$MarkerTypeEnumMap, e))
          .toSet(),
      holeFilter:
          $enumDecodeNullable(_$HoleFilterEnumMap, json['holeFilter']) ??
          HoleFilter.all,
      rankingMethod:
          $enumDecodeNullable(
            _$MarkerRankingMethodEnumMap,
            json['rankingMethod'],
          ) ??
          MarkerRankingMethod.count,
      bestN: (json['bestN'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$MarkerCounterConfigToJson(
  MarkerCounterConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetTypes': instance.targetTypes
      .map((e) => _$MarkerTypeEnumMap[e]!)
      .toList(),
  'holeFilter': _$HoleFilterEnumMap[instance.holeFilter]!,
  'rankingMethod': _$MarkerRankingMethodEnumMap[instance.rankingMethod]!,
  'bestN': instance.bestN,
  'runtimeType': instance.$type,
};

const _$MarkerTypeEnumMap = {
  MarkerType.birdie: 'birdie',
  MarkerType.eagle: 'eagle',
  MarkerType.albatross: 'albatross',
  MarkerType.holeInOne: 'holeInOne',
  MarkerType.two: 'two',
  MarkerType.par: 'par',
};

const _$HoleFilterEnumMap = {
  HoleFilter.all: 'all',
  HoleFilter.par3: 'par3',
  HoleFilter.par4: 'par4',
  HoleFilter.par5: 'par5',
};

const _$MarkerRankingMethodEnumMap = {
  MarkerRankingMethod.count: 'count',
  MarkerRankingMethod.points: 'points',
};
