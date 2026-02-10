import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_definition.freezed.dart';
part 'match_definition.g.dart';

enum MatchType { singles, fourball, foursomes, scramble }

enum MatchRoundType { group, roundOf32, roundOf16, quarterFinal, semiFinal, finalRound }

@freezed
abstract class MatchDefinition with _$MatchDefinition {
  const factory MatchDefinition({
    required String id,
    required MatchType type,
    required List<String> team1Ids, // Player IDs for Side A
    required List<String> team2Ids, // Player IDs for Side B
    @Default({}) Map<String, int> strokesReceived, // Map<PlayerID, Strokes> relative to scratch/lowest
    String? groupId, // Optional link to TeeGroup
    
    // Bracket / Season Data
    @Default(MatchRoundType.group) MatchRoundType round,
    String? bracketId, // ID of the tournament/bracket
    String? nextMatchId, // ID of the match winner advances to
    int? bracketOrder, // Visual ordering index
    
    // Override Labels (optional)
    String? team1Name, // e.g., "Team Europe" or "Names calculated"
    String? team2Name,
  }) = _MatchDefinition;

  factory MatchDefinition.fromJson(Map<String, dynamic> json) =>
      _$MatchDefinitionFromJson(json);
}

@freezed
abstract class MatchResult with _$MatchResult {
  const factory MatchResult({
    required String matchId,
    required int winningTeamIndex, // 0 = Team 1, 1 = Team 2, -1 = Halve/Draw
    required String status, // Display string: "3&2", "1UP", "A/S"
    required int score, // Positive = Team 1 UP, Negative = Team 2 UP
    required List<int> holeResults, // 1 = T1 Win, -1 = T2 Win, 0 = Halve, null = Not Played
    required int holesPlayed,
    @Default(false) bool isFinal,
  }) = _MatchResult;

  factory MatchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchResultFromJson(json);
}
