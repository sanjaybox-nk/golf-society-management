import 'package:golf_society/domain/models/competition.dart';

class ScoringResult {
  final int score;
  final String label;
  final int holesPlayed;
  final int adjustedGrossScore;

  ScoringResult({
    required this.score,
    required this.label,
    required this.holesPlayed,
    required this.adjustedGrossScore,
  });
}

class ScoringCalculator {
  /// Calculates "Score to Par" (Net) or Stableford Points.
  /// Handles partial rounds by scaling par and handicap correctly.
  static ScoringResult calculate({
    required List<int?> holeScores,
    required List<Map<String, dynamic>> holes,
    required double playingHandicap,
    required CompetitionFormat format,
    MaxScoreConfig? maxScoreConfig,
  }) {
    final int holesPlayed = holeScores.where((s) => s != null).length;
    
    if (holesPlayed == 0) {
      return ScoringResult(
        score: 0,
        label: '-',
        holesPlayed: 0,
        adjustedGrossScore: 0,
      );
    }

    int totalPoints = 0;
    int totalGross = 0;
    int parOfHolesPlayed = 0;
    int adjustedGrossTotal = 0;

    for (int i = 0; i < holeScores.length; i++) {
      final scoreCounted = holeScores[i];
      if (scoreCounted != null && i < holes.length) {
        final hole = holes[i];
        final int par = hole['par'] as int? ?? 4;
        final int si = hole['si'] as int? ?? 18;

        // Calculate strokes for this hole
        final double strokes = playingHandicap;
        final int freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
        
        // 1. Adjusted Gross (WHS Net Double Bogey Cap)
        final ndbCap = par + 2 + freeShots;
        final whsScore = scoreCounted > ndbCap ? ndbCap : scoreCounted;
        adjustedGrossTotal += whsScore;

        // 2. Format Specifics
        if (format == CompetitionFormat.stableford) {
          final netScore = scoreCounted - freeShots;
          final points = (par - netScore + 2).clamp(0, 10);
          totalPoints += points;
        } else {
          int compScore = applyMaxScoreCap(
            grossScore: scoreCounted,
            par: par,
            si: si,
            playingHandicap: playingHandicap,
            format: format,
            maxScoreConfig: maxScoreConfig,
          );
          totalGross += compScore;
          parOfHolesPlayed += par;
        }
      }
    }

    if (format == CompetitionFormat.stableford) {
      return ScoringResult(
        score: totalPoints,
        label: totalPoints.toString(),
        holesPlayed: holesPlayed,
        adjustedGrossScore: adjustedGrossTotal,
      );
    } else {
      // Stroke / Max Score / Scramble logic: Relative to Par
      // IMPORTANT: Scaling PHC to holes played to avoid -83 jump
      final double scaledPhc = (playingHandicap * (holesPlayed / 18));
      final double netScoreToPar = (totalGross - scaledPhc) - parOfHolesPlayed;
      final int roundedScore = netScoreToPar.round();
      
      return ScoringResult(
        score: roundedScore,
        label: roundedScore == 0 ? 'E' : (roundedScore > 0 ? '+$roundedScore' : '$roundedScore'),
        holesPlayed: holesPlayed,
        adjustedGrossScore: adjustedGrossTotal,
      );
    }
  }

  /// Authoritative capping logic for competition formats like Max Score.
  static int applyMaxScoreCap({
    required int grossScore,
    required int par,
    required int si,
    required double playingHandicap,
    required CompetitionFormat format,
    MaxScoreConfig? maxScoreConfig,
  }) {
    final cap = getMaxScoreCap(
      par: par,
      si: si,
      playingHandicap: playingHandicap,
      format: format,
      maxScoreConfig: maxScoreConfig,
    );
    
    if (cap == null) return grossScore;
    return grossScore > cap ? cap : grossScore;
  }

  /// Returns the maximum allowed score for a hole based on competition rules.
  static int? getMaxScoreCap({
    required int par,
    required int si,
    required double playingHandicap,
    required CompetitionFormat format,
    MaxScoreConfig? maxScoreConfig,
  }) {
    if (format != CompetitionFormat.maxScore || maxScoreConfig == null) return null;

    final int freeShots = (playingHandicap ~/ 18) + (si <= (playingHandicap % 18) ? 1 : 0);

    int compCap;
    if (maxScoreConfig.type == MaxScoreType.fixed) {
      compCap = maxScoreConfig.value;
    } else if (maxScoreConfig.type == MaxScoreType.parPlusX) {
      compCap = par + maxScoreConfig.value;
    } else {
      // WHS Net Double Bogey
      compCap = par + 2 + freeShots;
    }

    return compCap;
  }
}
