// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardStanding _$LeaderboardStandingFromJson(Map<String, dynamic> json) =>
    _LeaderboardStanding(
      leaderboardId: json['leaderboardId'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      currentHandicap: (json['currentHandicap'] as num).toDouble(),
      points: (json['points'] as num).toDouble(),
      roundsPlayed: (json['roundsPlayed'] as num).toInt(),
      roundsCounted: (json['roundsCounted'] as num).toInt(),
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      holeScores:
          (json['holeScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      stats:
          (json['stats'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$LeaderboardStandingToJson(
  _LeaderboardStanding instance,
) => <String, dynamic>{
  'leaderboardId': instance.leaderboardId,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'avatarUrl': instance.avatarUrl,
  'currentHandicap': instance.currentHandicap,
  'points': instance.points,
  'roundsPlayed': instance.roundsPlayed,
  'roundsCounted': instance.roundsCounted,
  'history': instance.history,
  'holeScores': instance.holeScores,
  'stats': instance.stats,
};
