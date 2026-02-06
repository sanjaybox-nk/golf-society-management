import 'dart:math';

class MatchplayHandicapCalculator {
  /// Calculates the number of strokes received by the higher handicap player.
  /// Standard matchplay logic: (Handicap A - Handicap B) * allowance.
  /// The lowest player effectively plays off scratch (0).
  static int calculateStrokesReceived({
    required double handicapA,
    required double handicapB,
    double allowance = 1.0, // Default to 100%
  }) {
    final diff = (handicapA - handicapB).abs();
    return (diff * allowance).round();
  }

  /// Determines which holes strokes are received on based on the course SI.
  /// Returns a list of hole indices (0-indexed) where a stroke is given.
  static List<int> getStrokeIndices({
    required int totalStrokes,
    required List<int> holeSIs,
  }) {
    final receivingIndices = <int>[];
    
    // Strokes are given on holes with SI <= totalStrokes
    // If strokes > 18, everyone gets at least one, and we start again from SI 1
    for (int i = 0; i < holeSIs.length; i++) {
        int strokesOnThisHole = (totalStrokes / 18).floor();
        if (totalStrokes % 18 >= holeSIs[i]) {
            strokesOnThisHole++;
        }
        
        if (strokesOnThisHole > 0) {
            receivingIndices.add(i);
        }
    }
    
    return receivingIndices;
  }

  /// Calculates the match status (e.g., "2 Up") based on hole-by-hole scores.
  /// scoresA and scoresB are raw stroke counts.
  /// strokesReceivedIndices are the 0-indexed holes where Player B (the higher HCP) gets a shot.
  static String calculateMatchStatus({
    required List<int?> scoresA,
    required List<int?> scoresB,
    required List<int> strokesReceivedIndices,
    bool playerBIsHigher = true,
  }) {
    int upCount = 0;
    int holesPlayed = 0;

    for (int i = 0; i < min(scoresA.length, scoresB.length); i++) {
      final sA = scoresA[i];
      final sB = scoresB[i];
      
      if (sA == null || sB == null) continue;
      holesPlayed++;

      // Adjust sB if playerB is receiving a stroke on this hole
      int effectiveSA = sA;
      int effectiveSB = sB;
      
      if (strokesReceivedIndices.contains(i)) {
        if (playerBIsHigher) effectiveSB--;
        else effectiveSA--;
      }

      if (effectiveSA < effectiveSB) {
        upCount++;
      } else if (effectiveSB < effectiveSA) {
        upCount--;
      }
    }

    if (upCount == 0) return "All Square";
    
    final leader = upCount > 0 ? "Player A" : "Player B";
    final absUp = upCount.abs();
    
    // Check if the match is finished (Dormie)
    final holesRemaining = 18 - holesPlayed;
    if (absUp > holesRemaining) {
        // Match finished: e.g., "3 & 2"
        return "$absUp & $holesRemaining";
    }

    return "$absUp Up";
  }
}
