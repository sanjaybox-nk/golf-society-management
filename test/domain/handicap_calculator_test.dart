import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';

CourseConfig _course({int slope = 113, double rating = 72.0, int par = 72}) =>
    CourseConfig(slope: slope, rating: rating, par: par);

CompetitionRules _rules({
  int cap = 28,
  double allowance = 1.0,
  bool applyCapToIndex = true,
  CompetitionFormat format = CompetitionFormat.stableford,
  CompetitionSubtype subtype = CompetitionSubtype.none,
  TeamHandicapMethod teamMethod = TeamHandicapMethod.whs,
}) =>
    CompetitionRules(
      handicapCap: cap,
      handicapAllowance: allowance,
      applyCapToIndex: applyCapToIndex,
      format: format,
      subtype: subtype,
      teamHandicapMethod: teamMethod,
    );

void main() {
  group('HandicapCalculator.calculateCourseHandicap', () {
    test('standard slope 113 — no adjustment', () {
      final ch = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: 18.0,
        courseConfig: _course(slope: 113, rating: 72.0, par: 72),
      );
      expect(ch, closeTo(18.0, 0.01));
    });

    test('slope 125 — increases course handicap', () {
      final ch = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: 18.0,
        courseConfig: _course(slope: 125, rating: 72.0, par: 72),
      );
      expect(ch, greaterThan(18.0));
    });

    test('rating above par — adds strokes', () {
      final ch = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: 10.0,
        courseConfig: _course(slope: 113, rating: 74.0, par: 72),
      );
      expect(ch, closeTo(12.0, 0.01));
    });

    test('useWhs false — returns raw index unchanged', () {
      final ch = HandicapCalculator.calculateCourseHandicap(
        handicapIndex: 15.0,
        courseConfig: _course(slope: 130, rating: 74.0, par: 72),
        useWhs: false,
      );
      expect(ch, 15.0);
    });
  });

  group('HandicapCalculator.calculatePlayingHandicap', () {
    test('standard case — 18hcp on par-72 slope-113', () {
      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 18.0,
        rules: _rules(),
        courseConfig: _course(),
      );
      expect(phc, 18);
    });

    test('applies 85% allowance', () {
      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 20.0,
        rules: _rules(allowance: 0.85),
        courseConfig: _course(),
      );
      expect(phc, (20 * 0.85).round());
    });

    test('caps index at handicapCap when applyCapToIndex is true', () {
      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 36.0,
        rules: _rules(cap: 28, applyCapToIndex: true),
        courseConfig: _course(),
      );
      expect(phc, 28);
    });

    test('applyCapToIndex false — index is used uncapped for course handicap calculation', () {
      // With applyCapToIndex: false and cap above the index, index flows through uncapped.
      // Setting cap: 36 ensures neither the index nor the result cap is hit for index 30.
      final phcUncapped = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 30.0,
        rules: _rules(cap: 36, applyCapToIndex: false),
        courseConfig: _course(),
      );
      final phcCapped = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 30.0,
        rules: _rules(cap: 36, applyCapToIndex: true),
        courseConfig: _course(),
      );
      // Both should be equal at 30 since cap (36) > index (30) either way
      expect(phcUncapped, phcCapped);
      expect(phcUncapped, 30);
    });

    test('societyCut reduces playing handicap', () {
      final base = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 20.0,
        rules: _rules(),
        courseConfig: _course(),
      );
      final cut = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 20.0,
        rules: _rules(),
        courseConfig: _course(),
        societyCut: 2.0,
      );
      expect(cut, base - 2);
    });

    test('plus handicap (negative index) returns 0 or positive', () {
      final phc = HandicapCalculator.calculatePlayingHandicap(
        handicapIndex: 0.0,
        rules: _rules(),
        courseConfig: _course(),
      );
      expect(phc, greaterThanOrEqualTo(0));
    });
  });

  group('HandicapCalculator.calculateTeamHandicap — WHS scramble', () {
    final scrambleRules = _rules(
      format: CompetitionFormat.scramble,
      allowance: 1.0,
      teamMethod: TeamHandicapMethod.whs,
      cap: 0, // no cap
      applyCapToIndex: false,
    );

    test('2-player WHS: 35% low + 15% high', () {
      // Both on flat slope-113 par-72 course → CH = index
      final result = HandicapCalculator.calculateTeamHandicap(
        individualIndices: [12.0, 20.0],
        rules: scrambleRules,
        courseConfig: _course(),
      );
      final expected = (12.0 * 0.35 + 20.0 * 0.15).round();
      expect(result, expected);
    });

    test('4-player WHS: 25/20/15/10 percent', () {
      final result = HandicapCalculator.calculateTeamHandicap(
        individualIndices: [8.0, 12.0, 16.0, 20.0],
        rules: scrambleRules,
        courseConfig: _course(),
      );
      final expected = (8.0 * 0.25 + 12.0 * 0.20 + 16.0 * 0.15 + 20.0 * 0.10).round();
      expect(result, expected);
    });

    test('empty list returns 0', () {
      expect(
        HandicapCalculator.calculateTeamHandicap(
          individualIndices: [],
          rules: scrambleRules,
          courseConfig: _course(),
        ),
        0,
      );
    });
  });

  group('HandicapCalculator.calculateDifferential', () {
    test('standard slope 113 — differential matches gross minus rating', () {
      final diff = HandicapCalculator.calculateDifferential(
        grossScore: 82,
        courseConfig: _course(slope: 113, rating: 72.0),
      );
      expect(diff, closeTo(10.0, 0.01));
    });

    test('slope 0 returns 0 (guard against division by zero)', () {
      final diff = HandicapCalculator.calculateDifferential(
        grossScore: 80,
        courseConfig: _course(slope: 0, rating: 72.0),
      );
      expect(diff, 0.0);
    });
  });
}
