import '../../models/competition.dart';

class HandicapCalculator {
  
  /// Calculates the playing handicap for a player based on:
  /// - Their Handicap Index
  /// - The Competition Rules (Format, Allowance, Cap)
  /// - The Course Configuration (Slope, Rating, Par)
  /// - The System Setting (useWhs)
  static int calculatePlayingHandicap({
    required double handicapIndex,
    required CompetitionRules rules,
    required Map<String, dynamic> courseConfig, // Should contain 'slope', 'rating', 'par' or tees
    bool useWhs = true,
    String? teeColor, // Optional, if courseConfig has tees
    double? baseRating, // [NEW] For mixed tee equity adjustments
  }) {
    // 1. Cap the Index first? Usually calculated plays off full then capped? 
    // WHS says: Use full index to calc Course Handicap, then apply allowance, then cap?
    // User request implies simple system. Let's follow standard WHS flow but allow non-WHS shortcut.
    
    double baseHandicap = handicapIndex;
    
    // 1. Apply Hard Cap on INDEX if specified
    if (rules.applyCapToIndex && baseHandicap > rules.handicapCap) {
      baseHandicap = rules.handicapCap.toDouble();
    }

    double courseHandicap = baseHandicap;

    if (useWhs) {
       // WHS Formula: Index * (Slope / 113) + (Rating - Par)
       final slope = _parseValue(courseConfig['slope'] ?? 113);
       final rating = _parseValue(courseConfig['rating'] ?? 72);
       final par = _parseValue(courseConfig['par'] ?? 72);

       courseHandicap = baseHandicap * (slope / 113) + (rating - par);
    }

    // 2. Apply Allowance (e.g. 95%)
    double playingHandicap = courseHandicap * rules.handicapAllowance;

    // 3. Rounding (Standard .5 rounds up)
    int rounded = playingHandicap.round();

    // 4. Apply Mixed Tee Equity Adjustment (CR - BaseRating) 
    // This is primarily for Medal play to normalize everyone to a single rating/par benchmark.
    // [UPDATED] Now gated by rule setting (default OFF).
    if (useWhs && baseRating != null && rules.useMixedTeeAdjustment && rules.format != CompetitionFormat.stableford) {
      final rating = _parseValue(courseConfig['rating'] ?? 72);
      final adjustment = (rating - baseRating).round();
      rounded += adjustment;
    }

    // 5. Apply Cap on FINAL result (Safety Gate)
    if (rounded > rules.handicapCap) {
      rounded = rules.handicapCap;
    }

    return rounded;
  }

  /// Calculates a combined team handicap (mostly for Scramble)
  static int calculateTeamHandicap({
    required List<double> individualIndices,
    required CompetitionRules rules,
    required Map<String, dynamic> courseConfig,
  }) {
    if (individualIndices.isEmpty) return 0;

    // 1. Calculate individual Course Handicaps (100% CH)
    final individualCHs = individualIndices.map((idx) => 
      calculatePlayingHandicap(
        handicapIndex: idx, 
        rules: rules.copyWith(handicapAllowance: 1.0, applyCapToIndex: false), // Full CH
        courseConfig: courseConfig,
      ).toDouble()
    ).toList()..sort(); // Sort Low to High

    // 2. Apply Scramble Allowances
    if (rules.format == CompetitionFormat.scramble) {
      int baseTeamHandicap;
      
      switch (rules.teamHandicapMethod) {
        case TeamHandicapMethod.average:
          // Simple arithmetic mean
          final sum = individualCHs.fold<double>(0, (a, b) => a + b);
          baseTeamHandicap = (sum / individualCHs.length).round();
          break;
          
        case TeamHandicapMethod.sum:
          // Simple sum
          baseTeamHandicap = individualCHs.fold<double>(0, (a, b) => a + b).round();
          break;
          
        case TeamHandicapMethod.whs:
          // WHS Recommendations
          if (individualCHs.length == 4) {
            // 25% / 20% / 15% / 10%
            baseTeamHandicap = (individualCHs[0] * 0.25 + 
                          individualCHs[1] * 0.20 + 
                          individualCHs[2] * 0.15 + 
                          individualCHs[3] * 0.10).round();
          } else if (individualCHs.length == 2) {
            // 35% / 15%
            baseTeamHandicap = (individualCHs[0] * 0.35 + individualCHs[1] * 0.15).round();
          } else if (individualCHs.length == 3) {
            // 30% / 20% / 10%
            baseTeamHandicap = (individualCHs[0] * 0.30 + individualCHs[1] * 0.20 + individualCHs[2] * 0.10).round();
          } else {
            // Fallback for non-standard team sizes
            baseTeamHandicap = individualCHs.fold<double>(0, (a, b) => a + b).round();
          }
          break;
      }

      // Apply society allowance as a final multiplier (100% = no change)
      int result = (baseTeamHandicap * rules.handicapAllowance).round();

      // Apply Team Cap if specified
      if (rules.teamHandicapCap != null && result > rules.teamHandicapCap!) {
        result = rules.teamHandicapCap!;
      }
      return result;
    }

    // [FIX] Fourball (Better Ball) does NOT use a Team Handicap.
    // Patients play off their individual allowances (e.g. 85%).
    // We return 0 here to signal that no aggregate handicap should be applied.
    if (rules.subtype == CompetitionSubtype.fourball) {
      return 0;
    }

    // [NEW] Foursomes (Alternate Shot)
    // Formula: (Partner A CH + Partner B CH) * Team Allowance (Default 50%)
    if (rules.subtype == CompetitionSubtype.foursomes) {
      final sum = individualCHs.fold<double>(0, (a, b) => a + b);
      return (sum * rules.handicapAllowance).round();
    }

    // Default fallback: Average or Sum with global allowance
    final sum = individualCHs.fold<double>(0, (a, b) => a + b);
    return (sum * rules.handicapAllowance).round();
  }

  static double calculateDifferential({
    required int grossScore,
    required Map<String, dynamic> courseConfig,
  }) {
    final slope = _parseValue(courseConfig['slope'] ?? 113);
    final rating = _parseValue(courseConfig['rating'] ?? 72);
    
    // Differential = (113 / Slope) * (Gross Score - Rating)
    if (slope == 0) return 0.0;
    return (113 / slope) * (grossScore - rating);
  }

  static double _parseValue(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
