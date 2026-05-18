import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scorecard_constants.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/features/events/presentation/widgets/scorecard_resolver.dart';

/// Minimal GolfEvent with only required fields.
GolfEvent _event({
  String id = 'event1',
  List<Map<String, dynamic>> results = const [],
}) =>
    GolfEvent(
      id: id,
      title: 'Test Event',
      seasonId: 'season1',
      date: DateTime(2025, 6, 1),
      results: results,
    );

/// Minimal LeaderboardEntry.
LeaderboardEntry _entry({
  String entryId = 'p1',
  List<int?>? holeScores,
  List<String>? teamMemberIds,
  int? teamIndex,
}) =>
    LeaderboardEntry(
      entryId: entryId,
      playerName: 'Test Player',
      score: 0,
      handicap: 10,
      position: 1,
      mode: CompetitionMode.singles,
      scoringStatus: ScoringStatus.ok,
      holeScores: holeScores,
      teamMemberIds: teamMemberIds,
      teamIndex: teamIndex,
    );

/// Minimal Scorecard.
Scorecard _scorecard({
  required String entryId,
  List<int?> holeScores = const [],
}) =>
    Scorecard(
      id: 'sc_$entryId',
      competitionId: 'event1',
      roundId: '1',
      entryId: entryId,
      submittedByUserId: 'user1',
      holeScores: holeScores,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

void main() {
  group('ScorecardResolver.resolve', () {
    test('direct bridge — entry has holeScores → returns directBridge scorecard', () {
      final holeScores = List<int?>.generate(18, (_) => 4);
      final result = ScorecardResolver.resolve(
        entry: _entry(holeScores: holeScores),
        scorecards: [],
        event: _event(),
      );
      expect(result.id, startsWith(ScorecardConstants.directIdPrefix));
      expect(result.status, ScorecardStatus.finalScore);
      expect(result.holeScores, holeScores);
    });

    test('direct bridge takes priority over live scorecard', () {
      final holeScores = List<int?>.generate(18, (_) => 4);
      final liveCard = _scorecard(entryId: 'p1', holeScores: List.generate(18, (_) => 5));
      final result = ScorecardResolver.resolve(
        entry: _entry(holeScores: holeScores),
        scorecards: [liveCard],
        event: _event(),
      );
      expect(result.id, startsWith(ScorecardConstants.directIdPrefix));
    });

    test('live scorecard — matching entryId with scores → returns live scorecard', () {
      final liveCard = _scorecard(entryId: 'p1', holeScores: List.generate(18, (_) => 4));
      final result = ScorecardResolver.resolve(
        entry: _entry(),
        scorecards: [liveCard],
        event: _event(),
      );
      expect(result.id, 'sc_p1');
    });

    test('live scorecard empty (all nulls) → falls through to seeded lookup', () {
      final emptyLive = _scorecard(entryId: 'p1', holeScores: List.generate(18, (_) => null));
      final seededScores = List.generate(18, (_) => 4);
      final result = ScorecardResolver.resolve(
        entry: _entry(),
        scorecards: [emptyLive],
        event: _event(results: [
          {'memberId': 'p1', 'holeScores': seededScores},
        ]),
      );
      expect(result.id, startsWith(ScorecardConstants.tempIdPrefix));
    });

    test('seeded result with memberId → returns temp scorecard', () {
      final seededScores = List.generate(18, (_) => 4);
      final result = ScorecardResolver.resolve(
        entry: _entry(),
        scorecards: [],
        event: _event(results: [
          {'memberId': 'p1', 'holeScores': seededScores},
        ]),
      );
      expect(result.id, startsWith(ScorecardConstants.tempIdPrefix));
      expect(result.status, ScorecardStatus.finalScore);
    });

    test('seeded result with userId fallback → resolves correctly', () {
      final seededScores = List.generate(18, (_) => 4);
      final result = ScorecardResolver.resolve(
        entry: _entry(),
        scorecards: [],
        event: _event(results: [
          {'userId': 'p1', 'holeScores': seededScores},
        ]),
      );
      expect(result.id, startsWith(ScorecardConstants.tempIdPrefix));
    });

    test('no scorecard and no seeded result → returns empty placeholder', () {
      final result = ScorecardResolver.resolve(
        entry: _entry(),
        scorecards: [],
        event: _event(),
      );
      expect(result.id, startsWith(ScorecardConstants.emptyIdPrefix));
      expect(result.status, ScorecardStatus.draft);
      expect(result.holeScores.length, 18);
      expect(result.holeScores.every((s) => s == null), isTrue);
    });

    test('team member fallback — resolves via teamMemberIds', () {
      final memberCard = _scorecard(entryId: 'member1', holeScores: List.generate(18, (_) => 4));
      final result = ScorecardResolver.resolve(
        entry: _entry(entryId: 'team_1', teamMemberIds: ['member1', 'member2']),
        scorecards: [memberCard],
        event: _event(),
      );
      expect(result.entryId, 'member1');
    });
  });
}
