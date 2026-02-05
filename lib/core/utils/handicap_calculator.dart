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

    // 4. Apply Cap on FINAL PLAYING HC if not already capped at index level
    if (!rules.applyCapToIndex && rounded > rules.handicapCap) {
      rounded = rules.handicapCap;
    }

    return rounded;
  }

  static double _parseValue(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
