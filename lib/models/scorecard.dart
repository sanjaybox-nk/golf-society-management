import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'scorecard.freezed.dart';
part 'scorecard.g.dart';

enum ScorecardStatus { draft, submitted, reviewed, finalScore }

enum ScoringStatus { ok, incomplete, nr, wd, dq }

@freezed
abstract class AdminEditAudit with _$AdminEditAudit {
  const factory AdminEditAudit({
    required bool overridden,
    required String reason,
    required String editorId,
    @TimestampConverter() required DateTime timestamp,
  }) = _AdminEditAudit;

  factory AdminEditAudit.fromJson(Map<String, dynamic> json) =>
      _$AdminEditAuditFromJson(json);
}

@freezed
abstract class Scorecard with _$Scorecard {
  const Scorecard._();

  const factory Scorecard({
    required String id,
    required String competitionId,
    required String roundId,
    required String entryId, // memberId or teamId
    required String submittedByUserId,
    @Default(ScorecardStatus.draft) ScorecardStatus status,
    @Default(ScoringStatus.ok) ScoringStatus scoringStatus,
    @Default([]) List<int?> holeScores,
    @Default([]) List<int?> playerVerifierScores,
    String? markerId,
    int? grossTotal,
    int? netTotal,
    int? points,
    AdminEditAudit? adminEditAudit,
    @Default(false) bool adminOverridePublish,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Scorecard;

  factory Scorecard.fromJson(Map<String, dynamic> json) =>
      _$ScorecardFromJson(json);
}
