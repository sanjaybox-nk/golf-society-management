import 'dart:math';

class TieBreakerLogic {
  /// Resolves a tie between two players using countback (Back 9, Back 6, Back 3, Back 1).
  /// Returns 1 if player A wins, -1 if player B wins, 0 if still tied.
  ///
  /// [higherIsBetter] should be true for Stableford (more points wins) and
  /// false for stroke play (fewer strokes wins). Prefer passing
  /// `ScoringStrategyRegistry.forRules(rules).higherIsBetter`.
  static int resolveTie({
    required List<int> holeScoresA,
    required List<int> holeScoresB,
    required List<int> pars,
    required List<int> sis,
    required double handicapA,
    required double handicapB,
    bool higherIsBetter = true,
  }) {
    int cmp;

    cmp = _compare(
      _scoreForRange(holeScoresA, pars, sis, handicapA, 9, 17, higherIsBetter),
      _scoreForRange(holeScoresB, pars, sis, handicapB, 9, 17, higherIsBetter),
      higherIsBetter,
    );
    if (cmp != 0) return cmp;

    cmp = _compare(
      _scoreForRange(holeScoresA, pars, sis, handicapA, 12, 17, higherIsBetter),
      _scoreForRange(holeScoresB, pars, sis, handicapB, 12, 17, higherIsBetter),
      higherIsBetter,
    );
    if (cmp != 0) return cmp;

    cmp = _compare(
      _scoreForRange(holeScoresA, pars, sis, handicapA, 15, 17, higherIsBetter),
      _scoreForRange(holeScoresB, pars, sis, handicapB, 15, 17, higherIsBetter),
      higherIsBetter,
    );
    if (cmp != 0) return cmp;

    return _compare(
      _scoreForRange(holeScoresA, pars, sis, handicapA, 17, 17, higherIsBetter),
      _scoreForRange(holeScoresB, pars, sis, handicapB, 17, 17, higherIsBetter),
      higherIsBetter,
    );
  }

  static int _compare(int scoreA, int scoreB, bool higherIsBetter) {
    if (higherIsBetter) {
      if (scoreA > scoreB) return 1;
      if (scoreB > scoreA) return -1;
    } else {
      if (scoreA < scoreB) return 1;
      if (scoreB < scoreA) return -1;
    }
    return 0;
  }

  static int _scoreForRange(
    List<int> scores,
    List<int> pars,
    List<int> sis,
    double handicap,
    int startHole,
    int endHole,
    bool higherIsBetter,
  ) {
    int total = 0;
    final phc = handicap.round();
    for (int i = startHole; i <= endHole; i++) {
      final score = scores[i];
      if (higherIsBetter) {
        int shots = phc ~/ 18;
        if (phc % 18 >= sis[i]) shots++;
        total += max(0, pars[i] - (score - shots) + 2);
      } else {
        total += score;
      }
    }
    return total;
  }
}
