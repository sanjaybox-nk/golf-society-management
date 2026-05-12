import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scoring_calculator.dart';
import '../../domain/models/processed_event_data.dart';

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

    // Standard countback: B9, B6, B3, B1
    final metrics = calculateTieBreakMetrics(result);
    final mNames = ['B9', 'B6', 'B3', 'B1'];

    // Find first metric that differs from ANY other player with the same score
    for (int i = 0; i < metrics.length; i++) {
      final val = metrics[i];
      final anyDiff = otherMetrics.any((other) => i < other.length && other[i] != val);
      if (anyDiff) {
        return '${mNames[i]}: $val';
      }
    }
    
    // If absolutely everything is tied, show B9 as fallback
    return 'B9: ${metrics[0]}';
  }

  static List<int> calculateTieBreakMetrics(ScoringResult result) {
    // Standard countback: B9, B6, B3, B1
    return [
      _getSegmentTotal(result, 9, 18),
      _getSegmentTotal(result, 12, 18),
      _getSegmentTotal(result, 15, 18),
      _getSegmentTotal(result, 17, 18),
    ];
  }

  static int _getSegmentTotal(ScoringResult result, int start, int end) {
    if (result.holePoints.length < end) return 0;
    return result.holePoints.sublist(start, end).whereType<int>().fold<int>(0, (sum, p) => sum + p);
  }

  /// [NEW] Final system-level submission trigger.
  /// Transitions a scorecard to [ScorecardStatus.finalScore] if both parties have verified
  /// and there are no score discrepancies between the player's recorded scores 
  /// and the marker's recorded scores for that player.
  static Scorecard validateAndFinalizeHandshake({
    required Scorecard targetScorecard,
    required Scorecard? verifierScorecard,
  }) {
    if (verifierScorecard == null) return targetScorecard;

    // 1. Conflict detection: only flag holes where BOTH sides entered AND disagree.
    // An empty holeScores (player didn't self-enter) is not a conflict.
    bool isConflictFree = true;
    for (int i = 0; i < 18; i++) {
      final p = targetScorecard.holeScores.elementAtOrNull(i);
      final m = verifierScorecard.playerVerifierScores.elementAtOrNull(i);
      if (p != null && m != null && p != m) {
        isConflictFree = false;
        break;
      }
    }

    if (!isConflictFree) return targetScorecard;

    // 2. Transition to submitted when both parties have signed off — awaits admin lock
    if (targetScorecard.verifiedByPlayer && targetScorecard.verifiedByMarker) {
      return targetScorecard.copyWith(
        status: ScorecardStatus.submitted,
        updatedAt: DateTime.now(),
      );
    }
    
    return targetScorecard;
  }
}
