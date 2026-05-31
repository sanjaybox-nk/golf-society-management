import 'dart:math';

class TieBreakerLogic {
  /// Resolves a tie using countback: B9→B6→B3→B1→F9→F6→F3→F1.
  /// Returns 1 if player A wins, -1 if player B wins, 0 if genuinely tied.
  ///
  /// [higherIsBetter] should be true for Stableford (more points wins) and
  /// false for stroke play (fewer strokes wins).
  static int resolveTie({
    required List<int> holeScoresA,
    required List<int> holeScoresB,
    required List<int> pars,
    required List<int> sis,
    required double handicapA,
    required double handicapB,
    bool higherIsBetter = true,
  }) {
    // Back 9 chain
    final backSteps = [(9, 17), (12, 17), (15, 17), (17, 17)];
    for (final (start, end) in backSteps) {
      final cmp = _compare(
        _scoreForRange(holeScoresA, pars, sis, handicapA, start, end, higherIsBetter),
        _scoreForRange(holeScoresB, pars, sis, handicapB, start, end, higherIsBetter),
        higherIsBetter,
      );
      if (cmp != 0) return cmp;
    }

    // Front 9 chain (narrows from hole 9 inward)
    final frontSteps = [(0, 8), (3, 8), (6, 8), (8, 8)];
    for (final (start, end) in frontSteps) {
      final cmp = _compare(
        _scoreForRange(holeScoresA, pars, sis, handicapA, start, end, higherIsBetter),
        _scoreForRange(holeScoresB, pars, sis, handicapB, start, end, higherIsBetter),
        higherIsBetter,
      );
      if (cmp != 0) return cmp;
    }

    return 0;
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
