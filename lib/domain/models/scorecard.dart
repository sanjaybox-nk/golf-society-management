import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/utils/json_converters.dart';

part 'scorecard.freezed.dart';
part 'scorecard.g.dart';

enum ScorecardStatus { draft, submitted, reviewed, finalScore, approved }

enum ScoringStatus { ok, incomplete, nr, wd, dq }

@freezed
abstract class HoleAuditEntry with _$HoleAuditEntry {
  const factory HoleAuditEntry({
    required int hole,
    required int playerScore,
    required int markerScore,
    required int resolvedTo,
    required String reason,
    required String editorId,
    @TimestampConverter() required DateTime timestamp,
  }) = _HoleAuditEntry;

  factory HoleAuditEntry.fromJson(Map<String, dynamic> json) =>
      _$HoleAuditEntryFromJson(json);
}

@freezed
abstract class Scorecard with _$Scorecard {
  const Scorecard._();

  const factory Scorecard({
    required String id,
    required String competitionId,
    required String roundId,
    required String entryId,
    required String submittedByUserId,
    @Default(ScorecardStatus.draft) ScorecardStatus status,
    @Default(ScoringStatus.ok) ScoringStatus scoringStatus,
    @Default([]) List<int?> holeScores,
    @Default([]) List<int?> playerVerifierScores,
    String? markerId,
    @Default({}) Map<int, String?> shotAttributions,
    int? grossTotal,
    int? netTotal,
    int? points,
    double? handicapIndex,
    int? playingHandicap,
    String? assignedTeeName,
    @Default([]) List<HoleAuditEntry> holeAuditLog,
    String? approvedBy,
    @OptionalTimestampConverter() DateTime? approvedAt,
    @Default(false) bool adminOverridePublish,
    @Default(false) bool verifiedByPlayer,
    @Default(false) bool verifiedByMarker,
    @Default(false) bool markerReassignmentOpen,
    @OptionalTimestampConverter() DateTime? playerVerifiedAt,
    @OptionalTimestampConverter() DateTime? markerVerifiedAt,
    @Default({}) Map<int, List<String>> holeTags,
    @TimestampConverter() DateTime? submittedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Scorecard;

  factory Scorecard.fromJson(Map<String, dynamic> json) =>
      _$ScorecardFromJson(json);
}
