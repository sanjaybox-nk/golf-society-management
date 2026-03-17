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
  final List<int?> holeNetScores;
  final List<int?> holePoints;
  final List<int?> holeScores; // [NEW] authoritative raw scores

  ScoringResult({
    required this.score,
    required this.label,
    required this.holesPlayed,
    required this.adjustedGrossScore,
    required this.holeNetScores,
    required this.holePoints,
    required this.holeScores,
  });

  factory ScoringResult.fromJson(Map<String, dynamic> json) => ScoringResult(
        score: json['score'] as int,
        label: json['label'] as String,
        holesPlayed: json['holesPlayed'] as int,
        adjustedGrossScore: json['adjustedGrossScore'] as int,
        holeNetScores: (json['holeNetScores'] as List).cast<int?>(),
        holePoints: (json['holePoints'] as List).cast<int?>(),
        holeScores: (json['holeScores'] as List?)?.cast<int?>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'label': label,
        'holesPlayed': holesPlayed,
        'adjustedGrossScore': adjustedGrossScore,
        'holeNetScores': holeNetScores,
        'holePoints': holePoints,
        'holeScores': holeScores,
      };
}

class GroupScoringResult {
  final int totalScore;
  final List<int> tieBreakMetrics; // [9, 6, 3, 1]
  final String label;

  GroupScoringResult({
    required this.totalScore,
    required this.tieBreakMetrics,
    required this.label,
  });

  factory GroupScoringResult.fromJson(Map<String, dynamic> json) => GroupScoringResult(
        totalScore: json['totalScore'] as int,
        tieBreakMetrics: (json['tieBreakMetrics'] as List).cast<int>(),
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() => {
        'totalScore': totalScore,
        'tieBreakMetrics': tieBreakMetrics,
        'label': label,
      };
}

class ScoringCalculator {
  /// Calculates strokes for a single hole, handling plus (negative) handicaps correctly.
  static int calculateHoleStrokes({
    required int si,
    required double playingHandicap,
  }) {
    if (playingHandicap >= 0) {
      final int base = playingHandicap ~/ 18;
      final int extra = si <= (playingHandicap % 18).round() ? 1 : 0;
      return base + extra;
    } else {
      // Plus handicap: Take away strokes starting from easiest holes (SI 18 downwards)
      final double absPhc = playingHandicap.abs();
      final int base = absPhc ~/ 18;
      final int extra = (18 - si + 1) <= (absPhc % 18).round() ? 1 : 0;
      return -(base + extra);
    }
  }

  /// Calculates Stableford points for a single hole.
  static int calculateHolePoints({
    required int grossScore,
    required int par,
    required int si,
    required double playingHandicap,
  }) {
    final int freeShots = calculateHoleStrokes(si: si, playingHandicap: playingHandicap);
    final int netScore = grossScore - freeShots;
    return (par - netScore + 2).clamp(0, 8); 
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
  }) {
    final effectivePhc = playingHandicap;
    final int holesPlayed = holeScores.where((s) => s != null).length;
    
    if (holesPlayed == 0) {
      return ScoringResult(
        score: 0,
        label: format == CompetitionFormat.stableford ? '0' : 'E',
        holesPlayed: 0,
        adjustedGrossScore: 0,
        holeNetScores: [],
        holePoints: [],
        holeScores: holeScores,
      );
    }

    int totalPoints = 0;
    int totalGross = 0;
    int parOfHolesPlayed = 0;
    int adjustedGrossTotal = 0;
    final List<int?> holeNetScores = List.filled(holeScores.length, null);
    final List<int?> holePoints = List.filled(holeScores.length, null);
    final List<int?> finalHoleScores = List.from(holeScores);

    for (int i = 0; i < holeScores.length; i++) {
      final scoreCounted = holeScores[i];
      if (scoreCounted != null && i < holes.length) {
        final hole = holes[i];
        final int par = hole.par;
        final int si = hole.si;

        // Calculate strokes for this hole
        final int freeShots = calculateHoleStrokes(si: si, playingHandicap: effectivePhc);
        
        // Hole-level tracking
        final int netScore = scoreCounted - freeShots;
        holeNetScores[i] = netScore;

        // 1. Adjusted Gross (WHS Net Double Bogey Cap)
        final ndbCap = par + 2 + freeShots;
        final whsScore = scoreCounted > ndbCap ? ndbCap : scoreCounted;
        adjustedGrossTotal += whsScore;

        // 2. Format Specifics
        if (format == CompetitionFormat.stableford) {
          final pts = calculateHolePoints(
            grossScore: scoreCounted,
            par: par,
            si: si,
            playingHandicap: effectivePhc,
          );
          totalPoints += pts;
          holePoints[i] = pts;
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
          
          // For non-stableford, points can represent relation to par per hole if needed
          holePoints[i] = netScore - par;
        }
      }
    }

    if (format == CompetitionFormat.stableford) {
      return ScoringResult(
        score: totalPoints,
        label: totalPoints.toString(),
        holesPlayed: holesPlayed,
        adjustedGrossScore: adjustedGrossTotal,
        holeNetScores: holeNetScores,
        holePoints: holePoints,
        holeScores: finalHoleScores,
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
        holeNetScores: holeNetScores,
        holePoints: holePoints,
        holeScores: finalHoleScores,
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

    final int freeShots = calculateHoleStrokes(si: si, playingHandicap: playingHandicap);

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

  /// Aggregates multiple individual results into a "Best Ball" team result.
  static ScoringResult calculateBestBall({
    required List<ScoringResult> individualResults,
    required List<CourseHole> holes,
    required CompetitionFormat format,
  }) {
    if (individualResults.isEmpty) {
      return ScoringResult(score: 0, label: '-', holesPlayed: 0, adjustedGrossScore: 0, holeNetScores: [], holePoints: [], holeScores: []);
    }

    final int numHoles = holes.length;
    final holeNetScores = List<int?>.from(individualResults.first.holeNetScores);
    final holePoints = List<int?>.from(individualResults.first.holePoints);
    final combinedHoleScores = List<int?>.from(individualResults.first.holeScores);
    int maxHolesPlayed = individualResults.first.holesPlayed;

    for (int i = 1; i < individualResults.length; i++) {
      final res = individualResults[i];
      if (res.holesPlayed > maxHolesPlayed) maxHolesPlayed = res.holesPlayed;
      
      for (int h = 0; h < numHoles; h++) {
        final p = res.holePoints[h];
        final n = res.holeNetScores[h];
        
        if (p != null) {
          if (format == CompetitionFormat.stableford) {
            if (holePoints[h] == null || p > holePoints[h]!) holePoints[h] = p;
          } else {
             // For stroke play, "best ball" usually means the lowest net score
             if (holeNetScores[h] == null || (n != null && n < holeNetScores[h]!)) {
               holeNetScores[h] = n;
               holePoints[h] = p; // Re-sync relative to par
             }
          }
        }
      }
    }

    int totalScore = 0;
    if (format == CompetitionFormat.stableford) {
      totalScore = holePoints.whereType<int>().fold<int>(0, (a, b) => a + b);
    } else {
      // Stroke Play: Summer of best nets - Sum of pars
      final int totalNet = holeNetScores.whereType<int>().fold<int>(0, (a, b) => a + b);
      final int totalPar = holes.take(maxHolesPlayed).fold<int>(0, (acc, h) => acc + h.par);
      totalScore = totalNet - totalPar;
    }

    return ScoringResult(
      score: totalScore,
      label: format == CompetitionFormat.stableford 
          ? totalScore.toString() 
          : (totalScore == 0 ? 'E' : (totalScore > 0 ? '+$totalScore' : '$totalScore')),
      holesPlayed: maxHolesPlayed,
      adjustedGrossScore: 0, // Not typically used for team aggregate
      holeNetScores: holeNetScores,
      holePoints: holePoints,
      holeScores: combinedHoleScores,
    );
  }

  /// Calculates a centralized group result for rankings and podiums.
  /// Result matches the "Best X individual round totals" logic requested by USER.
  static GroupScoringResult calculateGroupResult({
    required List<ScoringResult> individualResults,
    required CompetitionRules rules,
    required int bestX,
  }) {
    if (individualResults.isEmpty) {
      return GroupScoringResult(totalScore: 0, tieBreakMetrics: [0, 0, 0, 0], label: '-');
    }

    final isStableford = rules.format == CompetitionFormat.stableford;
    
    // 1. Calculate Aggregate Round Total (Sum of Best X individual totals)
    final List<int> individualScores = individualResults.map((r) => r.score).toList();
    individualScores.sort();
    if (isStableford) individualScores.sort((a, b) => b.compareTo(a));
    
    final int finalTotal = individualScores.take(bestX).fold<int>(0, (sum, s) => sum + s);

    // 2. Calculate Hole-by-Hole Best X for Tie-Breaker Metrics (Countback)
    // Segments: 9 holes, 6 holes, 3 holes, 1 hole
    final int b9 = _calculateGroupSegment(individualResults, 9, 18, bestX, isStableford);
    final int b6 = _calculateGroupSegment(individualResults, 12, 18, bestX, isStableford);
    final int b3 = _calculateGroupSegment(individualResults, 15, 18, bestX, isStableford);
    final int b1 = _calculateGroupSegment(individualResults, 17, 18, bestX, isStableford);

    return GroupScoringResult(
      totalScore: finalTotal,
      tieBreakMetrics: [b9, b6, b3, b1],
      label: !isStableford && finalTotal == 0 
          ? 'E' 
          : (!isStableford && finalTotal > 0 ? '+$finalTotal' : finalTotal.toString()),
    );
  }

  static int _calculateGroupSegment(
    List<ScoringResult> individuals, 
    int startHole, 
    int endHole, 
    int bestX, 
    bool isStableford
  ) {
    int segmentSum = 0;
    for (int i = startHole; i < endHole; i++) {
      final holeScores = individuals.map((r) {
        final val = (i < r.holePoints.length) ? r.holePoints[i] : null;
        return val ?? (isStableford ? 0 : 99);
      }).toList();
      
      holeScores.sort();
      if (isStableford) holeScores.sort((a, b) => b.compareTo(a));
      
      segmentSum += holeScores.take(bestX).fold<int>(0, (sum, s) => sum + s);
    }
    return segmentSum;
  }
}
