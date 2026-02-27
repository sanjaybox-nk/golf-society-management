import 'package:golf_society/domain/models/competition.dart';

class HandicapCalculator {
  
  /// Calculates the playing handicap for a player based on:
  /// - Their Handicap Index
  /// - The Competition Rules (Format, Allowance, Cap)
  /// - The Course Configuration (Slope, Rating, Par)
  /// - The System Setting (useWhs)
  static int calculatePlayingHandicap({
    required double handicapIndex,
    required CompetitionRules rules,
    required Map<String, dynamic> courseConfig,
    bool useWhs = true,
    String? teeColor,
    double? baseRating,
  }) {
    double baseHandicap = handicapIndex;
    
    // 1. Apply Hard Cap on INDEX if specified
    if (rules.applyCapToIndex && baseHandicap > rules.handicapCap) {
      baseHandicap = rules.handicapCap.toDouble();
    }

    double courseHandicap = baseHandicap;

    if (useWhs) {
       // WHS Formula: Index * (Slope / 113) + (Rating - Par)
       // Strictly data-driven: If course data is empty/null, we cannot calculate accurately.
       // We use 0.0 as the 'ignore' value but avoid hidden hardcoding in the formula.
       final slope = parseValue(courseConfig['slope']);
       final rating = parseValue(courseConfig['rating']);
       final par = parseValue(courseConfig['par']);

       if (slope > 0) {
         courseHandicap = baseHandicap * (slope / 113) + (rating - par);
       }
    }

    // 2. Apply Allowance (e.g. 95%)
    // Safety: If allowance is 0 but competition isn't explicitly GROSS mode,
    // treat it as 1.0 to prevent misconfigured data from zeroing all PHCs.
    final effectiveAllowance = (rules.handicapAllowance == 0 && rules.subtype != CompetitionSubtype.grossStableford)
        ? 1.0
        : rules.handicapAllowance;
    double playingHandicap = courseHandicap * effectiveAllowance;

    // 3. Rounding (Standard .5 rounds up)
    int rounded = playingHandicap.round();

    // 4. Apply Mixed Tee Equity Adjustment (CR - BaseRating) 
    if (useWhs && baseRating != null && rules.useMixedTeeAdjustment && rules.format != CompetitionFormat.stableford) {
      final rating = parseValue(courseConfig['rating']);
      if (rating > 0) {
        final adjustment = (rating - baseRating).round();
        rounded += adjustment;
      }
    }

    // 5. Apply Cap on FINAL result (Safety Gate)
    if (rounded > rules.handicapCap && rules.handicapCap > 0) {
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
      
      // DE-STACKING ALLOWANCE: If using WHS recommended percentages, 
      // the Global Allowance is usually 1.0 (100%). We respect the rules.handicapAllowance 
      // as the "Final Multiplier", but we warn in Admin UI if it's set to something like 0.10.
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
    final slope = parseValue(courseConfig['slope'] ?? 113);
    final rating = parseValue(courseConfig['rating'] ?? 72);
    
    // Differential = (113 / Slope) * (Gross Score - Rating)
    if (slope == 0) return 0.0;
    return (113 / slope) * (grossScore - rating);
  }

  static double parseValue(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  /// Single Source of Truth: Read a player's PHC from the event's grouping data.
  /// Returns 0 if the player is not found in the grouping.
  /// Resilience: Automatically strips '_guest' suffix for lookup.
  static int getStoredPhc(Map<String, dynamic> grouping, String memberId) {
    final groups = (grouping['groups'] as List?) ?? [];
    final lookupId = memberId.replaceFirst('_guest', '');
    for (final g in groups) {
      final players = (g['players'] as List?) ?? [];
      for (final p in players) {
        if (p['registrationMemberId'] == lookupId) {
          return (p['playingHandicap'] as num?)?.round() ?? 0;
        }
      }
    }
    return 0;
  }

  /// Build a full map of memberId → PHC from the event's grouping data.
  /// Used by leaderboard, scorecard modal, etc.
  static Map<String, int> getStoredPhcMap(Map<String, dynamic> grouping) {
    final Map<String, int> result = {};
    final groups = (grouping['groups'] as List?) ?? [];
    for (final g in groups) {
      final players = (g['players'] as List?) ?? [];
      for (final p in players) {
        final id = p['registrationMemberId'] as String?;
        if (id != null) {
          result[id] = (p['playingHandicap'] as num?)?.round() ?? 0;
        }
      }
    }
    return result;
  }
}
