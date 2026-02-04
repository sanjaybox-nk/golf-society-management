import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_standing.freezed.dart';
part 'leaderboard_standing.g.dart';

@freezed
abstract class LeaderboardStanding with _$LeaderboardStanding {
  const LeaderboardStanding._();
  const factory LeaderboardStanding({
    required String leaderboardId,
    required String memberId,
    // Basic Info
    required String memberName,
    String? avatarUrl,
    required double currentHandicap,
    
    // Metrics
    required double points, // Primary sorting metric (OOM points, Stableford total, etc.)
    required int roundsPlayed,
    required int roundsCounted, // For 'Best N'
    
    // Detailed Data (Optional, based on type)
    @Default([]) List<double> history, // Last N scores for "Form"
    @Default({}) Map<String, int> holeScores, // For Eclectic (1-18)
    @Default({}) Map<String, int> stats, // Birdies, Eagles counts for Marker types
  }) = _LeaderboardStanding;

  factory LeaderboardStanding.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardStandingFromJson(json);
}
