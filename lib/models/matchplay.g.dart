// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matchplay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchplayResult _$MatchplayResultFromJson(Map<String, dynamic> json) =>
    _MatchplayResult(
      winnerId: json['winnerId'] as String,
      scoreDisplay: json['scoreDisplay'] as String,
      holeWins:
          (json['holeWins'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      isWalkover: json['isWalkover'] as bool? ?? false,
    );

Map<String, dynamic> _$MatchplayResultToJson(_MatchplayResult instance) =>
    <String, dynamic>{
      'winnerId': instance.winnerId,
      'scoreDisplay': instance.scoreDisplay,
      'holeWins': instance.holeWins,
      'isWalkover': instance.isWalkover,
    };

_MatchplayMatch _$MatchplayMatchFromJson(Map<String, dynamic> json) =>
    _MatchplayMatch(
      id: json['id'] as String,
      playerAId: json['playerAId'] as String,
      playerBId: json['playerBId'] as String,
      playerAName: json['playerAName'] as String?,
      playerBName: json['playerBName'] as String?,
      playerAHandicap: (json['playerAHandicap'] as num).toDouble(),
      playerBHandicap: (json['playerBHandicap'] as num).toDouble(),
      strokesReceived: (json['strokesReceived'] as num).toInt(),
      status:
          $enumDecodeNullable(_$MatchplayStatusEnumMap, json['status']) ??
          MatchplayStatus.scheduled,
      result: json['result'] == null
          ? null
          : MatchplayResult.fromJson(json['result'] as Map<String, dynamic>),
      eventId: json['eventId'] as String?,
      playedDate: const OptionalTimestampConverter().fromJson(
        json['playedDate'],
      ),
    );

Map<String, dynamic> _$MatchplayMatchToJson(
  _MatchplayMatch instance,
) => <String, dynamic>{
  'id': instance.id,
  'playerAId': instance.playerAId,
  'playerBId': instance.playerBId,
  'playerAName': instance.playerAName,
  'playerBName': instance.playerBName,
  'playerAHandicap': instance.playerAHandicap,
  'playerBHandicap': instance.playerBHandicap,
  'strokesReceived': instance.strokesReceived,
  'status': _$MatchplayStatusEnumMap[instance.status]!,
  'result': instance.result?.toJson(),
  'eventId': instance.eventId,
  'playedDate': const OptionalTimestampConverter().toJson(instance.playedDate),
};

const _$MatchplayStatusEnumMap = {
  MatchplayStatus.scheduled: 'scheduled',
  MatchplayStatus.live: 'live',
  MatchplayStatus.completed: 'completed',
  MatchplayStatus.walkover: 'walkover',
  MatchplayStatus.cancelled: 'cancelled',
};

_MatchplayRound _$MatchplayRoundFromJson(Map<String, dynamic> json) =>
    _MatchplayRound(
      id: json['id'] as String,
      name: json['name'] as String,
      matches:
          (json['matches'] as List<dynamic>?)
              ?.map((e) => MatchplayMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deadline: const TimestampConverter().fromJson(json['deadline'] as Object),
    );

Map<String, dynamic> _$MatchplayRoundToJson(_MatchplayRound instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'matches': instance.matches.map((e) => e.toJson()).toList(),
      'deadline': const TimestampConverter().toJson(instance.deadline),
    };

_MatchplayComp _$MatchplayCompFromJson(Map<String, dynamic> json) =>
    _MatchplayComp(
      id: json['id'] as String,
      title: json['title'] as String,
      isActive: json['isActive'] as bool? ?? true,
      rounds:
          (json['rounds'] as List<dynamic>?)
              ?.map((e) => MatchplayRound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      handicapAllowance: (json['handicapAllowance'] as num?)?.toDouble() ?? 1.0,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Object,
      ),
    );

Map<String, dynamic> _$MatchplayCompToJson(_MatchplayComp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isActive': instance.isActive,
      'rounds': instance.rounds.map((e) => e.toJson()).toList(),
      'handicapAllowance': instance.handicapAllowance,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
