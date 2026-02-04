import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/features/competitions/services/competition_scoring_service.dart';

void main() {
  group('CompetitionScoringService - Texas Scramble', () {
    test('4-man team handicap calculation (WHS)', () {
      final haps = [10.0, 15.0, 20.0, 25.0];
      final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
      
      // (10 * 0.25) + (15 * 0.20) + (20 * 0.15) + (25 * 0.10)
      // 2.5 + 3.0 + 3.0 + 2.5 = 11.0
      expect(teamHc, 11.0);
    });

    test('3-man team handicap calculation (WHS)', () {
      final haps = [10.0, 20.0, 30.0];
      final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
      
      // (10 * 0.30) + (20 * 0.20) + (30 * 0.10)
      // 3.0 + 4.0 + 3.0 = 10.0
      expect(teamHc, 10.0);
    });

    test('2-man team handicap calculation (WHS)', () {
      final haps = [10.0, 20.0];
      final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
      
      // (10 * 0.35) + (20 * 0.15)
      // 3.5 + 3.0 = 6.5
      expect(teamHc, 6.5);
    });
  });

  group('CompetitionScoringService - 4BBB', () {
    test('Better ball selection (Net)', () {
      final p1Gross = [4, 5, 4];
      final p2Gross = [5, 4, 3];
      final p1Allowances = [1, 0, 1];
      final p2Allowances = [0, 1, 0];
      
      // Hole 1: P1 net 3, P2 net 5 -> Best 3
      // Hole 2: P1 net 5, P2 net 3 -> Best 3
      // Hole 3: P1 net 3, P2 net 3 -> Best 3
      
      final bestNet = CompetitionScoringService.calculateFourBallBestNetScores(
        player1Scores: p1Gross,
        player2Scores: p2Gross,
        player1StrokeAllowances: p1Allowances,
        player2StrokeAllowances: p2Allowances,
      );
      
      expect(bestNet.sublist(0, 3), [3, 3, 3]);
    });
  });

  group('CompetitionScoringService - Stableford', () {
    test('Stableford points calculation', () {
      // Net Par (4-0=4) -> 2 points
      expect(CompetitionScoringService.calculateStablefordPoints(4, 4, 0), 2);
      // Net Birdie (3-0=3) -> 3 points
      expect(CompetitionScoringService.calculateStablefordPoints(3, 4, 0), 3);
      // Net Bogey (5-0=5) -> 1 point
      expect(CompetitionScoringService.calculateStablefordPoints(5, 4, 0), 1);
      // Net Double Bogey (6-0=6) -> 0 points
      expect(CompetitionScoringService.calculateStablefordPoints(6, 4, 0), 0);
      // Net Eagle (2-0=2) -> 4 points
      expect(CompetitionScoringService.calculateStablefordPoints(2, 4, 0), 4);
      
      // With strokes: Gross 5, Par 4, 1 stroke -> Net 4 (Par) -> 2 points
      expect(CompetitionScoringService.calculateStablefordPoints(5, 4, 1), 2);
    });
  });
}
