class ScorecardConstants {
  ScorecardConstants._();

  /// Default round identifier used throughout the app. Placeholder for future multi-round support.
  static const String defaultRoundId = '1';

  /// Sentinel user ID for scorecards created by automated processes (seeding, system generation).
  static const String systemUserId = 'system';

  /// Prefix for empty/placeholder scorecard IDs created before a real scorecard exists.
  static const String emptyIdPrefix = 'empty_';

  /// Prefix for directly-bridged scorecard IDs (seeded from result data).
  static const String directIdPrefix = 'direct_';

  /// Prefix for temporary scorecard IDs during in-progress scoring sessions.
  static const String tempIdPrefix = 'temp_';
}
