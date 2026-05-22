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
        String fmt(String val) {
          final exp = RegExp(r'(?<=[a-z])[A-Z]');
          final s = val.replaceAllMapped(exp, (m) => ' ${m.group(0)}');
          return s[0].toUpperCase() + s.substring(1).toLowerCase();
        }
        final targets = c.targetTypes.map((t) => fmt(t.name)).join(', ');
        final holeDesc = c.holeFilter == HoleFilter.all
            ? 'all holes'
            : '${fmt(c.holeFilter.name)}s only';
        final count = c.bestN == 0 ? 'all rounds' : 'the best ${c.bestN} rounds';
        if (c.rankingMethod == MarkerRankingMethod.points) {
          return 'Tracks total Stableford points scored on $holeDesc across $count.';
        } else {
          return 'Counts $targets on $holeDesc across $count.';
        }
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
