import 'package:golf_society/domain/models/leaderboard_config.dart';

class LeaderboardRuleTranslator {
  static String translate(LeaderboardConfig config) {
    return config.map(
      orderOfMerit: (c) {
        final basis = c.source == OOMSource.position ? 'positional points' : 'Stableford points';
        final count = c.bestN == 0 ? 'all rounds' : 'your best ${c.bestN} rounds';
        return 'An Order of Merit based on $basis, taking $count across the season.';
      },
      bestOfSeries: (c) {
        final metric = c.metric.name;
        return 'A series leaderboard tracking the sum of $metric over your best ${c.bestN} rounds.';
      },
      eclectic: (c) {
        final metric = c.metric == EclecticMetric.strokes ? 'gross strokes' : 'Stableford points';
        final hcp = c.handicapPercentage > 0 ? ' with ${c.handicapPercentage}% handicap allowance' : ' (Scratch)';
        return 'Takes your best score on every hole across all rounds in the series to build a composite scorecard, $metric based$hcp.';
      },
      markerCounter: (c) {
        final targets = c.targetTypes.map((t) => t.name).join(', ');
        final basis = c.rankingMethod == MarkerRankingMethod.points ? 'points' : 'frequency';
        final count = c.bestN == 0 ? 'all rounds' : 'the best ${c.bestN} rounds';
        return 'Tracks the $basis of $targets across $count. Perfect for "Birdie Tree" or "Par Challenge" season standings.';
      },
    );
  }

  static String getBasisLabel(LeaderboardConfig config) {
    return config.map(
      orderOfMerit: (c) => c.source == OOMSource.position ? 'Points' : 'Stableford',
      bestOfSeries: (c) => c.metric.name.toUpperCase(),
      eclectic: (c) => c.metric == EclecticMetric.strokes ? 'Strokes' : 'Stableford',
      markerCounter: (c) => c.rankingMethod == MarkerRankingMethod.count ? 'Count' : 'Points',
    );
  }
}
