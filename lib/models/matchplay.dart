import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'matchplay.freezed.dart';
part 'matchplay.g.dart';

enum MatchplayStatus { scheduled, live, completed, walkover, cancelled }

@freezed
abstract class MatchplayResult with _$MatchplayResult {
  const factory MatchplayResult({
    required String winnerId,
    required String scoreDisplay, // e.g., "3 & 2", "1 Up", "2 Up"
    @Default([]) List<int> holeWins, // 1 for Player A win, -1 for Player B win, 0 for halved
    @Default(false) bool isWalkover,
  }) = _MatchplayResult;

  factory MatchplayResult.fromJson(Map<String, dynamic> json) =>
      _$MatchplayResultFromJson(json);
}

@freezed
abstract class MatchplayMatch with _$MatchplayMatch {
  const factory MatchplayMatch({
    required String id,
    required String playerAId,
    required String playerBId,
    String? playerAName,
    String? playerBName,
    required double playerAHandicap,
    required double playerBHandicap,
    required int strokesReceived, // Result of (A-B) * allowance
    @Default(MatchplayStatus.scheduled) MatchplayStatus status,
    MatchplayResult? result,
    String? eventId, // Link to a specific society event if played during one
    @OptionalTimestampConverter() DateTime? playedDate,
  }) = _MatchplayMatch;

  factory MatchplayMatch.fromJson(Map<String, dynamic> json) =>
      _$MatchplayMatchFromJson(json);
}

@freezed
abstract class MatchplayRound with _$MatchplayRound {
  const factory MatchplayRound({
    required String id,
    required String name, // e.g., "Quarter Finals"
    @Default([]) List<MatchplayMatch> matches,
    @TimestampConverter() required DateTime deadline,
  }) = _MatchplayRound;

  factory MatchplayRound.fromJson(Map<String, dynamic> json) =>
      _$MatchplayRoundFromJson(json);
}

@freezed
abstract class MatchplayComp with _$MatchplayComp {
  const factory MatchplayComp({
    required String id,
    required String title,
    @Default(true) bool isActive,
    @Default([]) List<MatchplayRound> rounds,
    @Default(1.0) double handicapAllowance, // Usually full difference or 90%
    @TimestampConverter() required DateTime createdAt,
  }) = _MatchplayComp;

  factory MatchplayComp.fromJson(Map<String, dynamic> json) =>
      _$MatchplayCompFromJson(json);
}
