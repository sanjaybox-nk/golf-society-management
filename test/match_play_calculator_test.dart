
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/features/matchplay/domain/match_play_calculator.dart';
import 'package:golf_society/models/scorecard.dart';

void main() {
  group('MatchPlayCalculator Tests', () {
    final courseConfig = {
      'holes': List.generate(18, (i) => {'par': 4, 'si': i + 1})
    };

    test('All Square Match - 18 Holes Halved', () {
      final match = MatchDefinition(
        id: 'm1',
        type: MatchType.singles,
        team1Ids: ['p1'],
        team2Ids: ['p2'],
      );

      final s1 = Scorecard(
        id: 's1',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p1',
        submittedByUserId: 'u1',
        status: ScorecardStatus.finalScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: List.filled(18, 4),
      );

      final s2 = Scorecard(
        id: 's2',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p2',
        submittedByUserId: 'u2',
        status: ScorecardStatus.finalScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: List.filled(18, 4),
      );

      final result = MatchPlayCalculator.calculate(
        match: match,
        scorecards: [s1, s2],
        courseConfig: courseConfig,
        holesToPlay: 18,
      );

      expect(result.status, equals('A/S'));
      expect(result.winningTeamIndex, equals(-1));
      expect(result.holesPlayed, equals(18));
      expect(result.isFinal, isTrue);
    });

    test('Early Exit - 5 & 4 Victory', () {
       // T1 wins first 5 holes, halves next 9. T1 lead is 5. Holes left: 4. Match should end.
       final match = MatchDefinition(
        id: 'm2',
        type: MatchType.singles,
        team1Ids: ['p1'],
        team2Ids: ['p2'],
      );

      final s1 = Scorecard(
        id: 's1',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p1',
        submittedByUserId: 'u1',
        status: ScorecardStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: [...List.filled(5, 3), ...List.filled(9, 4)], // 5 birdies, 9 pars
      );

      final s2 = Scorecard(
        id: 's2',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p2',
        submittedByUserId: 'u2',
        status: ScorecardStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: List.filled(14, 4), // 14 pars
      );

      final result = MatchPlayCalculator.calculate(
        match: match,
        scorecards: [s1, s2],
        courseConfig: courseConfig,
        holesToPlay: 18,
      );

      expect(result.status, equals('5 & 4'));
      expect(result.winningTeamIndex, equals(0));
      expect(result.holesPlayed, equals(14));
      expect(result.isFinal, isTrue);
    });

    test('Net Matchplay - Strokes Received', () {
       // P2 gets 1 stroke on SI 1.
       // Hole 1 (SI 1): P1 scores 4, P2 scores 5. Net P2 is 4 (Halve).
       final match = MatchDefinition(
        id: 'm3',
        type: MatchType.singles,
        team1Ids: ['p1'],
        team2Ids: ['p2'],
        strokesReceived: {'p2': 1},
      );

      final s1 = Scorecard(
        id: 's1',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p1',
        submittedByUserId: 'u1',
        status: ScorecardStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: [4],
      );

      final s2 = Scorecard(
        id: 's2',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p2',
        submittedByUserId: 'u2',
        status: ScorecardStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: [5],
      );

      final result = MatchPlayCalculator.calculate(
        match: match,
        scorecards: [s1, s2],
        courseConfig: courseConfig,
        holesToPlay: 18,
      );

      expect(result.status, equals('A/S')); // 4 vs (5-1)
      expect(result.holesPlayed, equals(1));
    });

    test('1 UP Result - 18th Hole Decider', () {
       final match = MatchDefinition(
        id: 'm4',
        type: MatchType.singles,
        team1Ids: ['p1'],
        team2Ids: ['p2'],
      );

      final s1 = Scorecard(
        id: 's1',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p1',
        submittedByUserId: 'u1',
        status: ScorecardStatus.finalScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: [...List.filled(17, 4), 3], // Birdie on 18
      );

      final s2 = Scorecard(
        id: 's2',
        competitionId: 'e1',
        roundId: '1',
        entryId: 'p2',
        submittedByUserId: 'u2',
        status: ScorecardStatus.finalScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        holeScores: List.filled(18, 4),
      );

      final result = MatchPlayCalculator.calculate(
        match: match,
        scorecards: [s1, s2],
        courseConfig: courseConfig,
        holesToPlay: 18,
      );

      expect(result.status, equals('1 UP'));
      expect(result.winningTeamIndex, equals(0));
      expect(result.isFinal, isTrue);
    });
  });
}
