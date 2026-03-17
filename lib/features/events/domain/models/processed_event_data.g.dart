// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processed_event_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProcessedPlayerScore _$ProcessedPlayerScoreFromJson(
  Map<String, dynamic> json,
) => _ProcessedPlayerScore(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  isGuest: json['isGuest'] as bool,
  handicapIndex: (json['handicapIndex'] as num).toDouble(),
  courseHandicap: (json['courseHandicap'] as num?)?.toDouble() ?? 0.0,
  playingHandicap: (json['playingHandicap'] as num).toInt(),
  appliedSocietyCut: (json['appliedSocietyCut'] as num?)?.toDouble() ?? 0.0,
  teeName: json['teeName'] as String,
  holeScores: (json['holeScores'] as List<dynamic>)
      .map((e) => (e as num?)?.toInt())
      .toList(),
  result: ScoringResult.fromJson(json['result'] as Map<String, dynamic>),
  tieBreakLabel: json['tieBreakLabel'] as String?,
  thruLabel: json['thruLabel'] as String?,
  scoringStatus:
      $enumDecodeNullable(_$ScoringStatusEnumMap, json['scoringStatus']) ??
      ScoringStatus.ok,
);

Map<String, dynamic> _$ProcessedPlayerScoreToJson(
  _ProcessedPlayerScore instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'isGuest': instance.isGuest,
  'handicapIndex': instance.handicapIndex,
  'courseHandicap': instance.courseHandicap,
  'playingHandicap': instance.playingHandicap,
  'appliedSocietyCut': instance.appliedSocietyCut,
  'teeName': instance.teeName,
  'holeScores': instance.holeScores,
  'result': instance.result.toJson(),
  'tieBreakLabel': instance.tieBreakLabel,
  'thruLabel': instance.thruLabel,
  'scoringStatus': _$ScoringStatusEnumMap[instance.scoringStatus]!,
};

const _$ScoringStatusEnumMap = {
  ScoringStatus.ok: 'ok',
  ScoringStatus.incomplete: 'incomplete',
  ScoringStatus.nr: 'nr',
  ScoringStatus.wd: 'wd',
  ScoringStatus.dq: 'dq',
};

_ProcessedGroupResult _$ProcessedGroupResultFromJson(
  Map<String, dynamic> json,
) => _ProcessedGroupResult(
  groupIndex: (json['groupIndex'] as num).toInt(),
  label: json['label'] as String,
  totalScore: (json['totalScore'] as num).toInt(),
  tieBreakMetrics: (json['tieBreakMetrics'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ProcessedGroupResultToJson(
  _ProcessedGroupResult instance,
) => <String, dynamic>{
  'groupIndex': instance.groupIndex,
  'label': instance.label,
  'totalScore': instance.totalScore,
  'tieBreakMetrics': instance.tieBreakMetrics,
};

_ProcessedLeaderboardEntry _$ProcessedLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => _ProcessedLeaderboardEntry(
  entryId: json['entryId'] as String,
  playerName: json['playerName'] as String,
  score: (json['score'] as num).toInt(),
  scoreLabel: json['scoreLabel'] as String,
  holesPlayed: (json['holesPlayed'] as num).toInt(),
  isGuest: json['isGuest'] as bool,
  teamMemberIds: (json['teamMemberIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  teamMemberNames:
      (json['teamMemberNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  individualPlayingHandicaps:
      (json['individualPlayingHandicaps'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  holeNetScores: (json['holeNetScores'] as List<dynamic>)
      .map((e) => (e as num?)?.toInt())
      .toList(),
  individualHoleScores: (json['individualHoleScores'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
      )
      .toList(),
  individualHoleNetScores: (json['individualHoleNetScores'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
      )
      .toList(),
  individualHolePoints: (json['individualHolePoints'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>).map((e) => (e as num?)?.toInt()).toList(),
      )
      .toList(),
  holeScores: (json['holeScores'] as List<dynamic>?)
      ?.map((e) => (e as num?)?.toInt())
      .toList(),
  holePoints: (json['holePoints'] as List<dynamic>?)
      ?.map((e) => (e as num?)?.toInt())
      .toList(),
  hasSocietyCut: json['hasSocietyCut'] as bool? ?? false,
  position: (json['position'] as num).toInt(),
  tieBreakMetrics:
      (json['tieBreakMetrics'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  scoringStatus:
      $enumDecodeNullable(_$ScoringStatusEnumMap, json['scoringStatus']) ??
      ScoringStatus.ok,
  handicapIndex: (json['handicapIndex'] as num?)?.toDouble(),
  tieBreakLabel: json['tieBreakLabel'] as String?,
);

Map<String, dynamic> _$ProcessedLeaderboardEntryToJson(
  _ProcessedLeaderboardEntry instance,
) => <String, dynamic>{
  'entryId': instance.entryId,
  'playerName': instance.playerName,
  'score': instance.score,
  'scoreLabel': instance.scoreLabel,
  'holesPlayed': instance.holesPlayed,
  'isGuest': instance.isGuest,
  'teamMemberIds': instance.teamMemberIds,
  'teamMemberNames': instance.teamMemberNames,
  'individualPlayingHandicaps': instance.individualPlayingHandicaps,
  'holeNetScores': instance.holeNetScores,
  'individualHoleScores': instance.individualHoleScores,
  'individualHoleNetScores': instance.individualHoleNetScores,
  'individualHolePoints': instance.individualHolePoints,
  'holeScores': instance.holeScores,
  'holePoints': instance.holePoints,
  'hasSocietyCut': instance.hasSocietyCut,
  'position': instance.position,
  'tieBreakMetrics': instance.tieBreakMetrics,
  'scoringStatus': _$ScoringStatusEnumMap[instance.scoringStatus]!,
  'handicapIndex': instance.handicapIndex,
  'tieBreakLabel': instance.tieBreakLabel,
};

_ProcessedEventData _$ProcessedEventDataFromJson(Map<String, dynamic> json) =>
    _ProcessedEventData(
      eventId: json['eventId'] as String,
      individualScores: (json['individualScores'] as List<dynamic>)
          .map((e) => ProcessedPlayerScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaderboard: (json['leaderboard'] as List<dynamic>)
          .map(
            (e) =>
                ProcessedLeaderboardEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      groupRankings: (json['groupRankings'] as List<dynamic>)
          .map((e) => ProcessedGroupResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventStats: json['eventStats'] as Map<String, dynamic>,
      holePars: (json['holePars'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      computeVersion: (json['computeVersion'] as num?)?.toInt() ?? 0,
      lastComputedAt: DateTime.parse(json['lastComputedAt'] as String),
    );

Map<String, dynamic> _$ProcessedEventDataToJson(
  _ProcessedEventData instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'individualScores': instance.individualScores.map((e) => e.toJson()).toList(),
  'leaderboard': instance.leaderboard.map((e) => e.toJson()).toList(),
  'groupRankings': instance.groupRankings.map((e) => e.toJson()).toList(),
  'eventStats': instance.eventStats,
  'holePars': instance.holePars,
  'computeVersion': instance.computeVersion,
  'lastComputedAt': instance.lastComputedAt.toIso8601String(),
};
