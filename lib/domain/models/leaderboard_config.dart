import 'package:freezed_annotation/freezed_annotation.dart';
import 'division_config.dart';

part 'leaderboard_config.freezed.dart';
part 'leaderboard_config.g.dart';

enum OOMSource { position, stableford, gross }
enum BestOfMetric { gross, net, stableford, position }
enum EclecticMetric { strokes, stableford }
enum TiePolicy { countback, shared, playoff }
enum MarkerType { birdie, eagle, albatross, holeInOne, two, par }
enum MarkerRankingMethod { count, points }
enum HoleFilter { all, par3, par4, par5 }
enum LeaderboardType { orderOfMerit, bestOfSeries, eclectic, markerCounter }
enum OOMRankingBasis { stableford, gross }

enum ScoringType { accumulative, position }

enum LeaderboardScope { seasonOnly, invitationalsOnly, global }

@freezed
abstract class LeaderboardConfig with _$LeaderboardConfig {
  const LeaderboardConfig._();

  const factory LeaderboardConfig.orderOfMerit({
    required String id,
    required String name,
    @Default(LeaderboardScope.seasonOnly) LeaderboardScope scope,
    @Default(OOMSource.position) OOMSource source,
    @Default(OOMRankingBasis.stableford) OOMRankingBasis rankingBasis,
    @Default({}) Map<int, int> positionPointsMap,
    @Default(0) int appearancePoints,
    @Default(0) int bestN,
    Division? divisionFilter,
  }) = OrderOfMeritConfig;

  const factory LeaderboardConfig.bestOfSeries({
    required String id,
    required String name,
    @Default(LeaderboardScope.seasonOnly) LeaderboardScope scope,
    @Default(8) int bestN,
    @Default(BestOfMetric.stableford) BestOfMetric metric,
    @Default(ScoringType.accumulative) ScoringType scoringType,
    @Default(TiePolicy.countback) TiePolicy tiePolicy,
    @Default({}) Map<int, int> positionPointsMap,
    @Default(0) int appearancePoints,
    Division? divisionFilter,
  }) = BestOfSeriesConfig;

  const factory LeaderboardConfig.eclectic({
    required String id,
    required String name,
    @Default(LeaderboardScope.seasonOnly) LeaderboardScope scope,
    @Default(EclecticMetric.strokes) EclecticMetric metric,
    @Default(0) int handicapPercentage,
    Division? divisionFilter,
  }) = EclecticConfig;

  const factory LeaderboardConfig.markerCounter({
    required String id,
    required String name,
    @Default(LeaderboardScope.seasonOnly) LeaderboardScope scope,
    required Set<MarkerType> targetTypes,
    @Default(HoleFilter.all) HoleFilter holeFilter,
    @Default(MarkerRankingMethod.count) MarkerRankingMethod rankingMethod,
    @Default(0) int bestN,
    Division? divisionFilter,
  }) = MarkerCounterConfig;

  factory LeaderboardConfig.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardConfigFromJson(json);
}
