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
    String? guestInputAssigneeId,
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
    @Default([]) List<int> conflictedHoles,
    @Default(0) int committeeAdjustment,
    String? committeeNote,
    @TimestampConverter() DateTime? submittedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Scorecard;

  factory Scorecard.fromJson(Map<String, dynamic> json) =>
      _$ScorecardFromJson(json);

  /// Computes which hole numbers (1-indexed) have a score disagreement between
  /// the player's entry and the marker's entry. Call this before any write that
  /// changes holeScores or playerVerifierScores, and persist the result.
  static List<int> computeConflicts(
      List<int?> holeScores, List<int?> verifierScores) {
    final result = <int>[];
    for (int i = 0; i < holeScores.length && i < verifierScores.length; i++) {
      final player = holeScores[i];
      final marker = verifierScores[i];
      if (player != null && marker != null && player != marker) {
        result.add(i + 1);
      }
    }
    return result;
  }
}
