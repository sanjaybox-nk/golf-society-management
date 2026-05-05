import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import 'package:golf_society/features/events/logic/scoring/scoring_utils.dart';

/// Helper to build a minimal Scorecard for testing.
Scorecard _card({
  ScorecardStatus status = ScorecardStatus.draft,
  ScoringStatus scoringStatus = ScoringStatus.ok,
  List<int?> holeScores = const [],
  List<int?> playerVerifierScores = const [],
  bool verifiedByPlayer = false,
  bool verifiedByMarker = false,
}) =>
    Scorecard(
      id: 'test',
      competitionId: 'comp',
      roundId: '1',
      entryId: 'p1',
      submittedByUserId: 'system',
      status: status,
      scoringStatus: scoringStatus,
      holeScores: holeScores,
      playerVerifierScores: playerVerifierScores,
      verifiedByPlayer: verifiedByPlayer,
      verifiedByMarker: verifiedByMarker,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

/// Minimal ScoringResult with hole points.
ScoringResult _result(List<int?> holePoints) => ScoringResult(
      score: 0,
      label: 'E',
      holesPlayed: 18,
      adjustedGrossScore: 72,
      holeScores: List.generate(18, (_) => 4),
      holePoints: holePoints,
      holeNetScores: List.generate(18, (_) => 4),
    );

void main() {
  group('ScoringUtils.resolveScoringStatus', () {
    test('returns ok for null card', () {
      expect(ScoringUtils.resolveScoringStatus(null), ScoringStatus.ok);
    });

    test('returns ok for draft card with no scores', () {
      expect(ScoringUtils.resolveScoringStatus(_card()), ScoringStatus.ok);
    });

    test('respects explicit manual override (WD)', () {
      final card = _card(scoringStatus: ScoringStatus.wd);
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.wd);
    });

    test('respects explicit manual override (DQ)', () {
      final card = _card(scoringStatus: ScoringStatus.dq);
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.dq);
    });

    test('auto-detects NR for submitted card with fewer than 18 holes', () {
      final card = _card(
        status: ScorecardStatus.submitted,
        holeScores: List.generate(9, (_) => 4),
      );
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.nr);
    });

    test('auto-detects NR for finalScore card with fewer than 18 holes', () {
      final card = _card(
        status: ScorecardStatus.finalScore,
        holeScores: List.generate(17, (_) => 4),
      );
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.nr);
    });

    test('returns ok for submitted card with all 18 holes', () {
      final card = _card(
        status: ScorecardStatus.submitted,
        holeScores: List.generate(18, (_) => 4),
      );
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.ok);
    });

    test('draft with partial holes is NOT auto-NR (only submitted/final triggers it)', () {
      final card = _card(
        status: ScorecardStatus.draft,
        holeScores: [4, 3, 5],
      );
      expect(ScoringUtils.resolveScoringStatus(card), ScoringStatus.ok);
    });
  });

  group('ScoringUtils.calculateTieBreakLabel', () {
    test('returns null when otherMetrics is null', () {
      expect(ScoringUtils.calculateTieBreakLabel(_result(List.generate(18, (_) => 2)), null), isNull);
    });

    test('returns null when only one player (no comparison possible)', () {
      final metrics = [ScoringUtils.calculateTieBreakMetrics(_result(List.generate(18, (_) => 2)))];
      expect(ScoringUtils.calculateTieBreakLabel(_result(List.generate(18, (_) => 2)), metrics), isNull);
    });

    test('returns B9 label when back-nine differs', () {
      // Player A: back 9 (holes 9-17) all 3 = 27
      // Player B: back 9 all 2 = 18 — differs, so B9 label returned
      final playerA = List<int?>.generate(18, (i) => i >= 9 ? 3 : 2);
      final playerB = List<int?>.generate(18, (_) => 2);
      final metricsB = ScoringUtils.calculateTieBreakMetrics(_result(playerB));
      final label = ScoringUtils.calculateTieBreakLabel(_result(playerA), [metricsB, metricsB]);
      expect(label, startsWith('B9:'));
    });

    test('falls back to B9 when everything is identical', () {
      final points = List<int?>.generate(18, (_) => 2);
      final metrics = [ScoringUtils.calculateTieBreakMetrics(_result(points))];
      // Two entries with identical metrics — returns B9 fallback
      final label = ScoringUtils.calculateTieBreakLabel(
        _result(points),
        [metrics[0], metrics[0]],
      );
      expect(label, startsWith('B9:'));
    });
  });

  group('ScoringUtils.validateAndFinalizeHandshake', () {
    test('returns target unchanged when verifier is null', () {
      final card = _card(status: ScorecardStatus.submitted);
      expect(ScoringUtils.validateAndFinalizeHandshake(targetScorecard: card, verifierScorecard: null), card);
    });

    test('returns target unchanged when scores conflict', () {
      final target = _card(
        status: ScorecardStatus.submitted,
        holeScores: [4, 3, ...List.generate(16, (_) => 4)],
        verifiedByPlayer: true,
        verifiedByMarker: true,
      );
      final verifier = _card(
        playerVerifierScores: [5, 3, ...List.generate(16, (_) => 4)], // mismatch hole 1
      );
      final result = ScoringUtils.validateAndFinalizeHandshake(
        targetScorecard: target, verifierScorecard: verifier,
      );
      expect(result.status, ScorecardStatus.submitted);
    });

    test('transitions to finalScore when scores match and both signed off', () {
      final scores = List<int?>.generate(18, (_) => 4);
      final target = _card(
        status: ScorecardStatus.submitted,
        holeScores: scores,
        verifiedByPlayer: true,
        verifiedByMarker: true,
      );
      final verifier = _card(playerVerifierScores: scores);
      final result = ScoringUtils.validateAndFinalizeHandshake(
        targetScorecard: target, verifierScorecard: verifier,
      );
      expect(result.status, ScorecardStatus.finalScore);
    });

    test('does NOT transition if only player signed off (not marker)', () {
      final scores = List<int?>.generate(18, (_) => 4);
      final target = _card(
        status: ScorecardStatus.submitted,
        holeScores: scores,
        verifiedByPlayer: true,
        verifiedByMarker: false,
      );
      final verifier = _card(playerVerifierScores: scores);
      final result = ScoringUtils.validateAndFinalizeHandshake(
        targetScorecard: target, verifierScorecard: verifier,
      );
      expect(result.status, ScorecardStatus.submitted);
    });
  });
}
