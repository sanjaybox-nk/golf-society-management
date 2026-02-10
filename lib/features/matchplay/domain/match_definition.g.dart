// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchDefinition _$MatchDefinitionFromJson(Map<String, dynamic> json) =>
    _MatchDefinition(
      id: json['id'] as String,
      type: $enumDecode(_$MatchTypeEnumMap, json['type']),
      team1Ids: (json['team1Ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      team2Ids: (json['team2Ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      strokesReceived:
          (json['strokesReceived'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      groupId: json['groupId'] as String?,
      round:
          $enumDecodeNullable(_$MatchRoundTypeEnumMap, json['round']) ??
          MatchRoundType.group,
      bracketId: json['bracketId'] as String?,
      nextMatchId: json['nextMatchId'] as String?,
      bracketOrder: (json['bracketOrder'] as num?)?.toInt(),
      team1Name: json['team1Name'] as String?,
      team2Name: json['team2Name'] as String?,
    );

Map<String, dynamic> _$MatchDefinitionToJson(_MatchDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MatchTypeEnumMap[instance.type]!,
      'team1Ids': instance.team1Ids,
      'team2Ids': instance.team2Ids,
      'strokesReceived': instance.strokesReceived,
      'groupId': instance.groupId,
      'round': _$MatchRoundTypeEnumMap[instance.round]!,
      'bracketId': instance.bracketId,
      'nextMatchId': instance.nextMatchId,
      'bracketOrder': instance.bracketOrder,
      'team1Name': instance.team1Name,
      'team2Name': instance.team2Name,
    };

const _$MatchTypeEnumMap = {
  MatchType.singles: 'singles',
  MatchType.fourball: 'fourball',
  MatchType.foursomes: 'foursomes',
  MatchType.scramble: 'scramble',
};

const _$MatchRoundTypeEnumMap = {
  MatchRoundType.group: 'group',
  MatchRoundType.roundOf32: 'roundOf32',
  MatchRoundType.roundOf16: 'roundOf16',
  MatchRoundType.quarterFinal: 'quarterFinal',
  MatchRoundType.semiFinal: 'semiFinal',
  MatchRoundType.finalRound: 'finalRound',
};

_MatchResult _$MatchResultFromJson(Map<String, dynamic> json) => _MatchResult(
  matchId: json['matchId'] as String,
  winningTeamIndex: (json['winningTeamIndex'] as num).toInt(),
  status: json['status'] as String,
  score: (json['score'] as num).toInt(),
  holeResults: (json['holeResults'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  holesPlayed: (json['holesPlayed'] as num).toInt(),
  isFinal: json['isFinal'] as bool? ?? false,
);

Map<String, dynamic> _$MatchResultToJson(_MatchResult instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'winningTeamIndex': instance.winningTeamIndex,
      'status': instance.status,
      'score': instance.score,
      'holeResults': instance.holeResults,
      'holesPlayed': instance.holesPlayed,
      'isFinal': instance.isFinal,
    };
