import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:golf_society/domain/models/competition.dart'; // ignore: unused_import
import 'package:golf_society/domain/models/scorecard.dart'; // ignore: unused_import
import 'package:golf_society/domain/scoring/scoring_calculator.dart';

part 'processed_event_data.freezed.dart';
part 'processed_event_data.g.dart';

@freezed
abstract class ProcessedPlayerScore with _$ProcessedPlayerScore {
  const factory ProcessedPlayerScore({
    required String playerId,
    required String playerName,
    required bool isGuest,
    required double handicapIndex,
    @Default(0.0) double courseHandicap,
    required int playingHandicap,
    @Default(0.0) double appliedSocietyCut,
    required String teeName,
    required List<int?> holeScores,
    required ScoringResult result,
    String? tieBreakLabel,
    String? thruLabel,
    @Default(ScoringStatus.ok) ScoringStatus scoringStatus,
  }) = _ProcessedPlayerScore;

  factory ProcessedPlayerScore.fromJson(Map<String, dynamic> json) =>
      _$ProcessedPlayerScoreFromJson(json);
}

@freezed
abstract class ProcessedGroupResult with _$ProcessedGroupResult {
  const factory ProcessedGroupResult({
    required int groupIndex,
    required String label,
    required int totalScore,
    required List<int> tieBreakMetrics,
  }) = _ProcessedGroupResult;

  factory ProcessedGroupResult.fromJson(Map<String, dynamic> json) => _$ProcessedGroupResultFromJson(json);
}

@freezed
abstract class ProcessedLeaderboardEntry with _$ProcessedLeaderboardEntry {
  const factory ProcessedLeaderboardEntry({
    required String entryId,
    required String playerName,
    required int score,
    required String scoreLabel,
    required int holesPlayed,
    required bool isGuest,
    required List<String> teamMemberIds,
    @Default([]) List<String> teamMemberNames,
    required List<int> individualPlayingHandicaps,
    required List<int?> holeNetScores,
    List<List<int?>>? individualHoleScores,
    List<List<int?>>? individualHoleNetScores,
    List<List<int?>>? individualHolePoints,
    List<int?>? holeScores,
    List<int?>? holePoints,
    @Default(false) bool hasSocietyCut,
    required int position,
    @Default([]) List<int> tieBreakMetrics,
    @Default(ScoringStatus.ok) ScoringStatus scoringStatus,
    double? handicapIndex,
    String? tieBreakLabel,
  }) = _ProcessedLeaderboardEntry;

  factory ProcessedLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$ProcessedLeaderboardEntryFromJson(json);
}

@freezed
abstract class ProcessedEventData with _$ProcessedEventData {
  const factory ProcessedEventData({
    required String eventId,
    required List<ProcessedPlayerScore> individualScores,
    required List<ProcessedLeaderboardEntry> leaderboard,
    required List<ProcessedGroupResult> groupRankings,
    required Map<String, dynamic> eventStats,
    required List<int> holePars,
    @Default(0) int computeVersion,
    required DateTime lastComputedAt,
  }) = _ProcessedEventData;

  factory ProcessedEventData.fromJson(Map<String, dynamic> json) =>
      _$ProcessedEventDataFromJson(json);
}
