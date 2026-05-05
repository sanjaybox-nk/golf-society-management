import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/scoring/tie_breaker_logic.dart';

// 18 flat pars (all 4) and SIs 1–18 in order.
final _pars = List.generate(18, (_) => 4);
final _sis  = List.generate(18, (i) => i + 1);

// Scores where every hole = par (gross 4).
final _parScores = List.generate(18, (_) => 4);

void main() {
  group('TieBreakerLogic.resolveTie — Stableford (higherIsBetter: true)', () {
    test('returns 0 when both players are identical', () {
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: _parScores,
          holeScoresB: _parScores,
          pars: _pars,
          sis: _sis,
          handicapA: 18,
          handicapB: 18,
          higherIsBetter: true,
        ),
        0,
      );
    });

    test('player A wins when back 9 is better', () {
      // A scores birdie on hole 10 (index 9); B scores par.
      final scoresA = List<int>.from(_parScores)..[9] = 3;
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: scoresA,
          holeScoresB: _parScores,
          pars: _pars,
          sis: _sis,
          handicapA: 18,
          handicapB: 18,
          higherIsBetter: true,
        ),
        1,
      );
    });

    test('player B wins when back 9 is better', () {
      final scoresB = List<int>.from(_parScores)..[9] = 3;
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: _parScores,
          holeScoresB: scoresB,
          pars: _pars,
          sis: _sis,
          handicapA: 18,
          handicapB: 18,
          higherIsBetter: true,
        ),
        -1,
      );
    });

    test('falls through to back 3 when back 9 and back 6 tie', () {
      // Both equal on holes 9–14; A better on holes 15–17.
      final scoresA = List<int>.from(_parScores)
        ..[15] = 3
        ..[16] = 3
        ..[17] = 3;
      final scoresB = List<int>.from(_parScores);
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: scoresA,
          holeScoresB: scoresB,
          pars: _pars,
          sis: _sis,
          handicapA: 18,
          handicapB: 18,
          higherIsBetter: true,
        ),
        1,
      );
    });
  });

  group('TieBreakerLogic.resolveTie — Stroke (higherIsBetter: false)', () {
    test('player A wins when back 9 gross is lower', () {
      // A scores bogey on back 9 (all 5s); B scores double (all 6s).
      // Lower gross wins in stroke play.
      final scoresA = List<int>.from(_parScores).map((s) => s).toList();
      final scoresB = List<int>.from(_parScores).toList();
      for (int i = 9; i < 18; i++) {
        scoresA[i] = 5;
        scoresB[i] = 6;
      }
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: scoresA,
          holeScoresB: scoresB,
          pars: _pars,
          sis: _sis,
          handicapA: 0,
          handicapB: 0,
          higherIsBetter: false,
        ),
        1,
      );
    });

    test('player B wins when back 9 gross is lower', () {
      final scoresA = List<int>.from(_parScores).toList();
      final scoresB = List<int>.from(_parScores).toList();
      for (int i = 9; i < 18; i++) {
        scoresA[i] = 6;
        scoresB[i] = 5;
      }
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: scoresA,
          holeScoresB: scoresB,
          pars: _pars,
          sis: _sis,
          handicapA: 0,
          handicapB: 0,
          higherIsBetter: false,
        ),
        -1,
      );
    });

    test('returns 0 when all gross scores are identical', () {
      expect(
        TieBreakerLogic.resolveTie(
          holeScoresA: _parScores,
          holeScoresB: _parScores,
          pars: _pars,
          sis: _sis,
          handicapA: 0,
          handicapB: 0,
          higherIsBetter: false,
        ),
        0,
      );
    });
  });

  group('TieBreakerLogic — default parameter is higherIsBetter = true', () {
    test('omitting higherIsBetter uses Stableford direction', () {
      final scoresA = List<int>.from(_parScores)..[9] = 3;
      final result = TieBreakerLogic.resolveTie(
        holeScoresA: scoresA,
        holeScoresB: _parScores,
        pars: _pars,
        sis: _sis,
        handicapA: 18,
        handicapB: 18,
      );
      expect(result, 1); // A wins with Stableford direction
    });
  });
}
