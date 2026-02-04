import 'dart:math';

class CompetitionScoringService {
  /// Calculates the team handicap for Texas Scramble based on WHS weighting.
  /// teamHandicaps: List of playing handicaps of team members.
  /// teamHandicaps must be sorted from lowest to highest for correct weighting.
  static double calculateTexasScrambleHandicap(List<double> playingHandicaps) {
    if (playingHandicaps.isEmpty) return 0.0;

    // Sort to ensure correct weighting application
    final sortedHcs = List<double>.from(playingHandicaps)..sort();

    if (sortedHcs.length == 4) {
      // 25% lowest + 20% + 15% + 10% highest
      return (sortedHcs[0] * 0.25) +
          (sortedHcs[1] * 0.20) +
          (sortedHcs[2] * 0.15) +
          (sortedHcs[3] * 0.10);
    } else if (sortedHcs.length == 3) {
      // 30% lowest + 20% + 10% highest
      return (sortedHcs[0] * 0.30) + (sortedHcs[1] * 0.20) + (sortedHcs[2] * 0.10);
    } else if (sortedHcs.length == 2) {
      // 35% lowest + 15% highest
      return (sortedHcs[0] * 0.35) + (sortedHcs[1] * 0.15);
    }

    // Default or single player (not really a scramble)
    return sortedHcs.first;
  }

  /// Calculates 4-Ball Better Ball (4BBB) scores.
  /// Returns a list of the best net scores per hole.
  static List<int> calculateFourBallBestNetScores({
    required List<int?> player1Scores,
    required List<int?> player2Scores,
    required List<int> player1StrokeAllowances, // Extra strokes per hole
    required List<int> player2StrokeAllowances,
  }) {
    final bestNetScores = <int>[];

    for (int i = 0; i < player1Scores.length; i++) {
      final p1Gross = player1Scores[i] ?? 99; // Penalty score if null
      final p2Gross = player2Scores[i] ?? 99;

      final p1Net = p1Gross - player1StrokeAllowances[i];
      final p2Net = p2Gross - player2StrokeAllowances[i];

      bestNetScores.add(min(p1Net, p2Net));
    }

    return bestNetScores;
  }

  /// Calculates Stableford points for a hole.
  static int calculateStablefordPoints(int grossScore, int holePar, int strokesReceived) {
    final netScore = grossScore - strokesReceived;
    final points = holePar - netScore + 2;
    return max(0, points);
  }
}
