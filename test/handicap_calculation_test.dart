import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/features/competitions/services/competition_scoring_service.dart';

void main() {
  group('CompetitionScoringService - Expanded Handicap Tests', () {
    
    group('Texas Scramble Edge Cases', () {
      test('Single player team (should return their own handicap)', () {
        final haps = [15.0];
        final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
        expect(teamHc, 15.0);
      });

      test('Empty team (should return 0)', () {
        final haps = <double>[];
        final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
        expect(teamHc, 0.0);
      });

      test('Uneven handicaps (weighting check)', () {
        // 4 players: Pro (0), Mid (10), Mid (20), High (30)
        // (0 * 0.25) + (10 * 0.20) + (20 * 0.15) + (30 * 0.10)
        // 0 + 2.0 + 3.0 + 3.0 = 8.0
        final haps = [0.0, 10.0, 20.0, 30.0];
        final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
        expect(teamHc, 8.0);
      });

      test('All scratch players', () {
        final haps = [0.0, 0.0, 0.0, 0.0];
        final teamHc = CompetitionScoringService.calculateTexasScrambleHandicap(haps);
        expect(teamHc, 0.0);
      });
    });

    group('Stableford Edge Cases', () {
      test('Extreme high gross score (should remain 0 points, no negative)', () {
        // Par 4, Gross 10, 0 strokes -> Net 10 -> 4 - 10 + 2 = -4 -> 0 points
        expect(CompetitionScoringService.calculateStablefordPoints(10, 4, 0), 0);
      });

      test('Negative net score (Hole in one on Par 4 with stroke received)', () {
        // Gross 1, Par 4, 1 stroke -> Net 0 -> 4 - 0 + 2 = 6 points
        expect(CompetitionScoringService.calculateStablefordPoints(1, 4, 1), 6);
      });

      test('Zero gross score (Invalid but should handle gracefully)', () {
        // Gross 0, Par 4, 0 strokes -> Net 0 -> 4-0+2 = 6 points
        expect(CompetitionScoringService.calculateStablefordPoints(0, 4, 0), 6);
      });
    });

    group('4BBB Edge Cases', () {
      test('One player fails to record score (null)', () {
        final p1Gross = [4, null, 5];
        final p2Gross = [null, 4, 4];
        final p1Allowances = [0, 0, 0];
        final p2Allowances = [0, 0, 0];
        
        final bestNet = CompetitionScoringService.calculateFourBallBestNetScores(
          player1Scores: p1Gross,
          player2Scores: p2Gross,
          player1StrokeAllowances: p1Allowances,
          player2StrokeAllowances: p2Allowances,
        );
        
        expect(bestNet, [4, 4, 4]);
      });

      test('Both players fail to record score (should return penalty 99)', () {
        final p1Gross = [null];
        final p2Gross = [null];
        final p1Allowances = [0];
        final p2Allowances = [0];
        
        final bestNet = CompetitionScoringService.calculateFourBallBestNetScores(
          player1Scores: p1Gross,
          player2Scores: p2Gross,
          player1StrokeAllowances: p1Allowances,
          player2StrokeAllowances: p2Allowances,
        );
        
        expect(bestNet, [99]);
      });
    });
  });
}
