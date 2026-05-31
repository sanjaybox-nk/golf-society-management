import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';

/// Pure utility functions for scoring calculations.
/// Extracted from EventScoringProcessor for readability.
class ScoringUtils {
  ScoringUtils._();

  static ScoringStatus resolveScoringStatus(Scorecard? card) {
    if (card == null) return ScoringStatus.ok;
    
    // Explicit manual overrides (WD, DQ, NR set by admin)
    if (card.scoringStatus != ScoringStatus.ok) return card.scoringStatus;

    // Automatic NR detection: If submitted/final but incomplete
    final isSubmitted = card.status == ScorecardStatus.submitted || card.status == ScorecardStatus.finalScore;
    final holesPlayed = card.holeScores.where((s) => s != null).length;
    
    if (isSubmitted && holesPlayed < 18) {
      return ScoringStatus.nr;
    }

    return ScoringStatus.ok;
  }

  static String? calculateTieBreakLabel(ScoringResult result, List<List<int>>? otherMetrics) {
    if (otherMetrics == null || otherMetrics.length <= 1) return null;

    final metrics = calculateTieBreakMetrics(result);
    const mNames = ['B9', 'B6', 'B3', 'B1', 'F9', 'F6', 'F3', 'F1'];

    for (int i = 0; i < metrics.length; i++) {
      final val = metrics[i];
      final anyDiff = otherMetrics.any((other) => i < other.length && other[i] != val);
      if (anyDiff) {
        return '${mNames[i]}: $val';
      }
    }

    return 'B9: ${metrics[0]}';
  }

  static List<int> calculateTieBreakMetrics(ScoringResult result) {
    // Back 9 countback then front 9 countback — each segment narrows from its last hole.
    // B9=10-18, B6=13-18, B3=16-18, B1=18, F9=1-9, F6=4-9, F3=7-9, F1=9
    return [
      _getSegmentTotal(result, 9, 18),
      _getSegmentTotal(result, 12, 18),
      _getSegmentTotal(result, 15, 18),
      _getSegmentTotal(result, 17, 18),
      _getSegmentTotal(result, 0, 9),
      _getSegmentTotal(result, 3, 9),
      _getSegmentTotal(result, 6, 9),
      _getSegmentTotal(result, 8, 9),
    ];
  }

  // Stroke countback uses net strokes (lower = better) rather than points.
  static List<int> calculateStrokeCountbackMetrics(ScoringResult result) {
    return [
      _getNetSegmentTotal(result, 9, 18),
      _getNetSegmentTotal(result, 12, 18),
      _getNetSegmentTotal(result, 15, 18),
      _getNetSegmentTotal(result, 17, 18),
      _getNetSegmentTotal(result, 0, 9),
      _getNetSegmentTotal(result, 3, 9),
      _getNetSegmentTotal(result, 6, 9),
      _getNetSegmentTotal(result, 8, 9),
    ];
  }

  static String? calculateStrokeTieBreakLabel(ScoringResult result, List<List<int>>? otherMetrics) {
    if (otherMetrics == null || otherMetrics.length <= 1) return null;
    final metrics = calculateStrokeCountbackMetrics(result);
    const mNames = ['B9', 'B6', 'B3', 'B1', 'F9', 'F6', 'F3', 'F1'];
    for (int i = 0; i < metrics.length; i++) {
      final val = metrics[i];
      final anyDiff = otherMetrics.any((other) => i < other.length && other[i] != val);
      if (anyDiff) return '${mNames[i]}: $val';
    }
    return 'B9: ${metrics[0]}';
  }

  static int _getSegmentTotal(ScoringResult result, int start, int end) {
    if (result.holePoints.length < end) return 0;
    return result.holePoints.sublist(start, end).whereType<int>().fold<int>(0, (sum, p) => sum + p);
  }

  static int _getNetSegmentTotal(ScoringResult result, int start, int end) {
    if (result.holeNetScores.length < end) return 0;
    return result.holeNetScores.sublist(start, end).whereType<int>().fold<int>(0, (sum, p) => sum + p);
  }

  /// [NEW] Final system-level submission trigger.
  /// Transitions a scorecard to [ScorecardStatus.finalScore] when sign-off
  /// conditions are met and there are no score discrepancies.
  ///
  /// Guests have no app account so cannot provide a player signature.
  /// For guest entries (entryId ending in '_guest') only marker confirmation
  /// is required — the host member is the responsible party.
  static Scorecard validateAndFinalizeHandshake({
    required Scorecard targetScorecard,
    required Scorecard? verifierScorecard,
  }) {
    if (verifierScorecard == null) return targetScorecard;

    // Read the stored conflict state — computed at write time, not here.
    if (targetScorecard.conflictedHoles.isNotEmpty) return targetScorecard;

    final isGuestEntry = targetScorecard.entryId.endsWith('_guest');
    final readyToFinalize = isGuestEntry
        ? targetScorecard.verifiedByMarker
        : targetScorecard.verifiedByPlayer && targetScorecard.verifiedByMarker;

    if (readyToFinalize) {
      return targetScorecard.copyWith(
        status: ScorecardStatus.finalScore,
        updatedAt: DateTime.now(),
      );
    }

    return targetScorecard;
  }
}
