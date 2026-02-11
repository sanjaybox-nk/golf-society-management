// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorecard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminEditAudit _$AdminEditAuditFromJson(Map<String, dynamic> json) =>
    _AdminEditAudit(
      overridden: json['overridden'] as bool,
      reason: json['reason'] as String,
      editorId: json['editorId'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$AdminEditAuditToJson(_AdminEditAudit instance) =>
    <String, dynamic>{
      'overridden': instance.overridden,
      'reason': instance.reason,
      'editorId': instance.editorId,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };

_Scorecard _$ScorecardFromJson(Map<String, dynamic> json) => _Scorecard(
  id: json['id'] as String,
  competitionId: json['competitionId'] as String,
  roundId: json['roundId'] as String,
  entryId: json['entryId'] as String,
  submittedByUserId: json['submittedByUserId'] as String,
  status:
      $enumDecodeNullable(_$ScorecardStatusEnumMap, json['status']) ??
      ScorecardStatus.draft,
  scoringStatus:
      $enumDecodeNullable(_$ScoringStatusEnumMap, json['scoringStatus']) ??
      ScoringStatus.ok,
  holeScores:
      (json['holeScores'] as List<dynamic>?)
          ?.map((e) => (e as num?)?.toInt())
          .toList() ??
      const [],
  playerVerifierScores:
      (json['playerVerifierScores'] as List<dynamic>?)
          ?.map((e) => (e as num?)?.toInt())
          .toList() ??
      const [],
  markerId: json['markerId'] as String?,
  grossTotal: (json['grossTotal'] as num?)?.toInt(),
  netTotal: (json['netTotal'] as num?)?.toInt(),
  points: (json['points'] as num?)?.toInt(),
  adminEditAudit: json['adminEditAudit'] == null
      ? null
      : AdminEditAudit.fromJson(json['adminEditAudit'] as Map<String, dynamic>),
  adminOverridePublish: json['adminOverridePublish'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ScorecardToJson(_Scorecard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'competitionId': instance.competitionId,
      'roundId': instance.roundId,
      'entryId': instance.entryId,
      'submittedByUserId': instance.submittedByUserId,
      'status': _$ScorecardStatusEnumMap[instance.status]!,
      'scoringStatus': _$ScoringStatusEnumMap[instance.scoringStatus]!,
      'holeScores': instance.holeScores,
      'playerVerifierScores': instance.playerVerifierScores,
      'markerId': instance.markerId,
      'grossTotal': instance.grossTotal,
      'netTotal': instance.netTotal,
      'points': instance.points,
      'adminEditAudit': instance.adminEditAudit?.toJson(),
      'adminOverridePublish': instance.adminOverridePublish,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$ScorecardStatusEnumMap = {
  ScorecardStatus.draft: 'draft',
  ScorecardStatus.submitted: 'submitted',
  ScorecardStatus.reviewed: 'reviewed',
  ScorecardStatus.finalScore: 'finalScore',
};

const _$ScoringStatusEnumMap = {
  ScoringStatus.ok: 'ok',
  ScoringStatus.incomplete: 'incomplete',
  ScoringStatus.nr: 'nr',
  ScoringStatus.wd: 'wd',
  ScoringStatus.dq: 'dq',
};
