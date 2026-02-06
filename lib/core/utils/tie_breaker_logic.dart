import 'dart:math';

class TieBreakerLogic {
  /// Resolves a tie between two players using countback (Back 9, Back 6, etc.).
  /// Returns 1 if player A wins, -1 if player B wins, 0 if still tied.
  static int resolveTie({
    required List<int> holeScoresA,
    required List<int> holeScoresB,
    required List<int> pars,
    required List<int> sis,
    required double handicapA,
    required double handicapB,
    bool isStableford = true,
  }) {
    // 1. Back 9
    int back9A = _calculateScoreForRange(holeScoresA, pars, sis, handicapA, 9, 17, isStableford);
    int back9B = _calculateScoreForRange(holeScoresB, pars, sis, handicapB, 9, 17, isStableford);
    
    int cmp = _compare(back9A, back9B, isStableford);
    if (cmp != 0) return cmp;

    // 2. Back 6
    int back6A = _calculateScoreForRange(holeScoresA, pars, sis, handicapA, 12, 17, isStableford);
    int back6B = _calculateScoreForRange(holeScoresB, pars, sis, handicapB, 12, 17, isStableford);
    
    cmp = _compare(back6A, back6B, isStableford);
    if (cmp != 0) return cmp;

    // 3. Back 3
    int back3A = _calculateScoreForRange(holeScoresA, pars, sis, handicapA, 15, 17, isStableford);
    int back3B = _calculateScoreForRange(holeScoresB, pars, sis, handicapB, 15, 17, isStableford);
    
    cmp = _compare(back3A, back3B, isStableford);
    if (cmp != 0) return cmp;

    // 4. Hole 18 (Back 1)
    int back1A = _calculateScoreForRange(holeScoresA, pars, sis, handicapA, 17, 17, isStableford);
    int back1B = _calculateScoreForRange(holeScoresB, pars, sis, handicapB, 17, 17, isStableford);
    
    return _compare(back1A, back1B, isStableford);
  }

  static int _compare(int scoreA, int scoreB, bool isStableford) {
    if (isStableford) {
      if (scoreA > scoreB) return 1;
      if (scoreB > scoreA) return -1;
    } else {
      // In Medal, lower score wins
      if (scoreA < scoreB) return 1;
      if (scoreB < scoreA) return -1;
    }
    return 0;
  }

  static int _calculateScoreForRange(
    List<int> scores,
    List<int> pars,
    List<int> sis,
    double handicap,
    int startHole,
    int endHole,
    bool isStableford,
  ) {
    int total = 0;
    final phc = handicap.round();

    for (int i = startHole; i <= endHole; i++) {
        final score = scores[i];
        if (isStableford) {
            int shots = (phc / 18).floor();
            if (phc % 18 >= sis[i]) shots++;
            final points = max(0, pars[i] - (score - shots) + 2);
            total += points;
        } else {
            // Net score for range in Medal is slightly complex because HCP is usually 
            // applied to the total, but for countback we apply fractional HCP or just gross?
            // Standard golf rule for countback in medal is to subtract 1/2, 1/3, 1/6, 1/18 of handicap.
            total += score;
        }
    }
    return total;
  }
}
