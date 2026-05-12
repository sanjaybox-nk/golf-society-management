// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorecard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HoleAuditEntry _$HoleAuditEntryFromJson(Map<String, dynamic> json) =>
    _HoleAuditEntry(
      hole: (json['hole'] as num).toInt(),
      playerScore: (json['playerScore'] as num).toInt(),
      markerScore: (json['markerScore'] as num).toInt(),
      resolvedTo: (json['resolvedTo'] as num).toInt(),
      reason: json['reason'] as String,
      editorId: json['editorId'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$HoleAuditEntryToJson(_HoleAuditEntry instance) =>
    <String, dynamic>{
      'hole': instance.hole,
      'playerScore': instance.playerScore,
      'markerScore': instance.markerScore,
      'resolvedTo': instance.resolvedTo,
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
  shotAttributions:
      (json['shotAttributions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), e as String?),
      ) ??
      const {},
  grossTotal: (json['grossTotal'] as num?)?.toInt(),
  netTotal: (json['netTotal'] as num?)?.toInt(),
  points: (json['points'] as num?)?.toInt(),
  handicapIndex: (json['handicapIndex'] as num?)?.toDouble(),
  playingHandicap: (json['playingHandicap'] as num?)?.toInt(),
  assignedTeeName: json['assignedTeeName'] as String?,
  holeAuditLog:
      (json['holeAuditLog'] as List<dynamic>?)
          ?.map((e) => HoleAuditEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  approvedBy: json['approvedBy'] as String?,
  approvedAt: const OptionalTimestampConverter().fromJson(json['approvedAt']),
  adminOverridePublish: json['adminOverridePublish'] as bool? ?? false,
  verifiedByPlayer: json['verifiedByPlayer'] as bool? ?? false,
  verifiedByMarker: json['verifiedByMarker'] as bool? ?? false,
  markerReassignmentOpen: json['markerReassignmentOpen'] as bool? ?? false,
  playerVerifiedAt: const OptionalTimestampConverter().fromJson(
    json['playerVerifiedAt'],
  ),
  markerVerifiedAt: const OptionalTimestampConverter().fromJson(
    json['markerVerifiedAt'],
  ),
  holeTags:
      (json['holeTags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          int.parse(k),
          (e as List<dynamic>).map((e) => e as String).toList(),
        ),
      ) ??
      const {},
  submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ScorecardToJson(
  _Scorecard instance,
) => <String, dynamic>{
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
  'shotAttributions': instance.shotAttributions.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'grossTotal': instance.grossTotal,
  'netTotal': instance.netTotal,
  'points': instance.points,
  'handicapIndex': instance.handicapIndex,
  'playingHandicap': instance.playingHandicap,
  'assignedTeeName': instance.assignedTeeName,
  'holeAuditLog': instance.holeAuditLog.map((e) => e.toJson()).toList(),
  'approvedBy': instance.approvedBy,
  'approvedAt': const OptionalTimestampConverter().toJson(instance.approvedAt),
  'adminOverridePublish': instance.adminOverridePublish,
  'verifiedByPlayer': instance.verifiedByPlayer,
  'verifiedByMarker': instance.verifiedByMarker,
  'markerReassignmentOpen': instance.markerReassignmentOpen,
  'playerVerifiedAt': const OptionalTimestampConverter().toJson(
    instance.playerVerifiedAt,
  ),
  'markerVerifiedAt': const OptionalTimestampConverter().toJson(
    instance.markerVerifiedAt,
  ),
  'holeTags': instance.holeTags.map((k, e) => MapEntry(k.toString(), e)),
  'submittedAt': _$JsonConverterToJson<Object?, DateTime>(
    instance.submittedAt,
    const TimestampConverter().toJson,
  ),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$ScorecardStatusEnumMap = {
  ScorecardStatus.draft: 'draft',
  ScorecardStatus.submitted: 'submitted',
  ScorecardStatus.reviewed: 'reviewed',
  ScorecardStatus.finalScore: 'finalScore',
  ScorecardStatus.approved: 'approved',
};

const _$ScoringStatusEnumMap = {
  ScoringStatus.ok: 'ok',
  ScoringStatus.incomplete: 'incomplete',
  ScoringStatus.nr: 'nr',
  ScoringStatus.wd: 'wd',
  ScoringStatus.dq: 'dq',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
