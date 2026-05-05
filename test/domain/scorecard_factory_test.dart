import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scorecard_constants.dart';
import 'package:golf_society/domain/scoring/scorecard_factory.dart';

void main() {
  group('ScorecardFactory.createEmpty', () {
    test('id uses empty prefix + entryId', () {
      final card = ScorecardFactory.createEmpty(entryId: 'abc', competitionId: 'comp1');
      expect(card.id, '${ScorecardConstants.emptyIdPrefix}abc');
    });

    test('sets correct competitionId and entryId', () {
      final card = ScorecardFactory.createEmpty(entryId: 'p1', competitionId: 'c1');
      expect(card.competitionId, 'c1');
      expect(card.entryId, 'p1');
    });

    test('uses default roundId sentinel', () {
      final card = ScorecardFactory.createEmpty(entryId: 'p1', competitionId: 'c1');
      expect(card.roundId, ScorecardConstants.defaultRoundId);
    });

    test('submittedByUserId is system sentinel', () {
      final card = ScorecardFactory.createEmpty(entryId: 'p1', competitionId: 'c1');
      expect(card.submittedByUserId, ScorecardConstants.systemUserId);
    });

    test('status is draft', () {
      final card = ScorecardFactory.createEmpty(entryId: 'p1', competitionId: 'c1');
      expect(card.status, ScorecardStatus.draft);
    });

    test('generates exactly 18 null hole scores', () {
      final card = ScorecardFactory.createEmpty(entryId: 'p1', competitionId: 'c1');
      expect(card.holeScores.length, 18);
      expect(card.holeScores.every((s) => s == null), isTrue);
    });
  });

  group('ScorecardFactory.fromSeededResult', () {
    test('id uses temp prefix + entryId', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': List.generate(18, (_) => 4)},
      );
      expect(card.id, '${ScorecardConstants.tempIdPrefix}p1');
    });

    test('status is finalScore', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': List.generate(18, (_) => 4)},
      );
      expect(card.status, ScorecardStatus.finalScore);
    });

    test('safely casts int hole scores', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': [3, 4, 5, null, 4, 3, 4, 5, 3, 4, 4, 3, 5, 4, 3, 4, 4, 3]},
      );
      expect(card.holeScores[0], 3);
      expect(card.holeScores[3], isNull);
    });

    test('safely casts double hole scores from Firestore without throwing', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': [3.0, 4.0, null, 5.0] + List.generate(14, (_) => 4.0)},
      );
      expect(card.holeScores[0], 3);
      expect(card.holeScores[1], 4);
      expect(card.holeScores[2], isNull);
    });

    test('parses integer points', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': List.generate(18, (_) => 4), 'points': 36},
      );
      expect(card.points, 36);
    });

    test('parses double points from Firestore without throwing', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': List.generate(18, (_) => 4), 'points': 36.0},
      );
      expect(card.points, 36);
    });

    test('null points when field absent', () {
      final card = ScorecardFactory.fromSeededResult(
        entryId: 'p1', competitionId: 'c1',
        result: {'holeScores': List.generate(18, (_) => 4)},
      );
      expect(card.points, isNull);
    });
  });

  group('ScorecardFactory.fromDirectBridge', () {
    test('id uses direct prefix + entryId', () {
      final card = ScorecardFactory.fromDirectBridge(
        entryId: 'p1', competitionId: 'c1',
        holeScores: List.generate(18, (_) => 4),
      );
      expect(card.id, '${ScorecardConstants.directIdPrefix}p1');
    });

    test('status is finalScore', () {
      final card = ScorecardFactory.fromDirectBridge(
        entryId: 'p1', competitionId: 'c1',
        holeScores: List.generate(18, (_) => 4),
      );
      expect(card.status, ScorecardStatus.finalScore);
    });

    test('preserves hole scores including nulls', () {
      final scores = [3, null, 4, ...List.generate(15, (_) => 4)];
      final card = ScorecardFactory.fromDirectBridge(
        entryId: 'p1', competitionId: 'c1', holeScores: scores,
      );
      expect(card.holeScores[0], 3);
      expect(card.holeScores[1], isNull);
      expect(card.holeScores[2], 4);
    });
  });
}
