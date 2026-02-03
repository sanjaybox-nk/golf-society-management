
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

    // Apply Hard Cap on Index if specified? 
    // Usually cap applies to Playing HC. But let's check rules.
    // rules.handicapCap is int. Let's apply it at the end usually.

    double courseHandicap = baseHandicap;

    if (useWhs) {
       // WHS Formula: Index * (Slope / 113) + (Rating - Par)
       // We need slope/rating from courseConfig.
       // Structure of courseConfig is flexible map currently. Let's assume standard keys or simple fallback.
       final slope = _parseValue(courseConfig['slope'] ?? 113);
       final rating = _parseValue(courseConfig['rating'] ?? 72);
       final par = _parseValue(courseConfig['par'] ?? 72);

       courseHandicap = baseHandicap * (slope / 113) + (rating - par);
    }

    // 2. Apply Allowance (e.g. 95%)
    double playingHandicap = courseHandicap * rules.handicapAllowance;

    // 3. Rounding (Standard .5 rounds up)
    int rounded = playingHandicap.round();

    // 4. Apply Cap (Max Playing Handicap)
    // If cap is 28, and calc is 30, use 28.
    if (rounded > rules.handicapCap) {
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
