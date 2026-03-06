import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:collection/collection.dart';

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
  /// Calculates Stableford points for a single hole.
  static int calculateHolePoints({
    required int grossScore,
    required int par,
    required int si,
    required double playingHandicap,
  }) {
    final int freeShots = (playingHandicap ~/ 18) + (si <= (playingHandicap % 18) ? 1 : 0);
    final int netScore = grossScore - freeShots;
    return (par - netScore + 2).clamp(0, 8); // Standard Stableford: Net Par=2, Bogey=1, Double=0
  }

  /// Resolves the correct course configuration (pars, SIs, rating, slope) for a specific player
  /// based on their gender and the event's tee settings.
  static CourseConfig resolvePlayerCourseConfig({
    required String memberId,
    required GolfEvent event,
    required List<Member> membersList,
    String? manualTeeName,
  }) {
    final tees = event.courseConfig.tees;
    
    if (tees.isEmpty) {
      return event.courseConfig;
    }

    final member = membersList.firstWhereOrNull((m) => m.id == memberId.replaceFirst('_guest', ''));
    final gender = member?.gender?.toLowerCase() ?? 'male';
    
    TeeConfig? selectedTee;
    
    // 1. Manual Override logic
    if (manualTeeName != null) {
      selectedTee = tees.firstWhereOrNull((t) => 
        t.name.toLowerCase().trim() == manualTeeName.toLowerCase().trim()
      );
    }

    if (selectedTee == null) {
      if (gender == 'female') {
         if (event.selectedFemaleTeeName != null) {
           selectedTee = tees.firstWhereOrNull((t) => 
             t.name.toLowerCase().trim() == event.selectedFemaleTeeName!.toLowerCase().trim()
           );
         }
         selectedTee ??= tees.firstWhereOrNull((t) => 
           t.name.toLowerCase().contains('red') || 
           t.name.toLowerCase().contains('lady') ||
           t.name.toLowerCase().contains('female')
         );
      }
      
      selectedTee ??= tees.firstWhereOrNull((t) => 
         t.name.toLowerCase().trim() == (event.selectedTeeName ?? 'white').toLowerCase().trim()
      );
  
      selectedTee ??= tees.first;
    }
    final TeeConfig nonNullTee = selectedTee;
    final pars = nonNullTee.holePars;
    final sis = nonNullTee.holeSIs;
    
    final reconstructedHoles = List.generate(pars.length, (i) => CourseHole(
      hole: i + 1,
      par: pars[i],
      si: sis[i],
      yardage: nonNullTee.yardages.length > i ? nonNullTee.yardages[i] : null,
    ));

    return event.courseConfig.copyWith(
       rating: nonNullTee.rating,
       slope: nonNullTee.slope,
       par: pars.isEmpty ? (event.courseConfig.par ?? 72) : pars.fold<int>(0, (a, b) => a + b),
       holes: reconstructedHoles.isNotEmpty ? reconstructedHoles : event.courseConfig.holes,
       selectedTeeName: nonNullTee.name,
    );
  }

  /// Calculates "Score to Par" (Net) or Stableford Points.
  /// Handles partial rounds by scaling par and handicap correctly.
  static ScoringResult calculate({
    required List<int?> holeScores,
    required List<CourseHole> holes,
    required double playingHandicap,
    required CompetitionFormat format,
    MaxScoreConfig? maxScoreConfig,
    double societyCut = 0.0,
  }) {
    final effectivePhc = playingHandicap - societyCut;
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
        final int par = hole.par;
        final int si = hole.si;

        // Calculate strokes for this hole
        final double strokes = effectivePhc;
        final int freeShots = (strokes ~/ 18) + (si <= (strokes % 18) ? 1 : 0);
        
        // 1. Adjusted Gross (WHS Net Double Bogey Cap)
        final ndbCap = par + 2 + freeShots;
        final whsScore = scoreCounted > ndbCap ? ndbCap : scoreCounted;
        adjustedGrossTotal += whsScore;

        // 2. Format Specifics
        if (format == CompetitionFormat.stableford) {
          totalPoints += calculateHolePoints(
            grossScore: scoreCounted,
            par: par,
            si: si,
            playingHandicap: effectivePhc,
          );
        } else {
          int compScore = applyMaxScoreCap(
            grossScore: scoreCounted,
            par: par,
            si: si,
            playingHandicap: effectivePhc,
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
      final double scaledPhc = (effectivePhc * (holesPlayed / 18));
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
