import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'standings/season_leaderboard_configs_provider.dart';
import '../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/season.dart' show SeasonStatus;
import 'package:golf_society/design_system/design_system.dart';
import '../../admin/utils/leaderboard_rule_translator.dart';

class SeasonStandingsScreen extends ConsumerWidget {
  final String? seasonId;

  const SeasonStandingsScreen({super.key, this.seasonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = seasonId != null 
        ? ref.watch(seasonByIdProvider(seasonId!))
        : ref.watch(activeSeasonProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final currentUserId = currentUser.id;

    return seasonAsync.when(
      data: (season) {
        if (season == null) {
          return const HeadlessScaffold(
            title: 'Standings',
            showBack: true,
            slivers: [
              SliverFillRemaining(
                child: BoxyArtEmptyCard(
                  title: 'No Season Found',
                  message: 'No active season is currently configured.',
                  icon: Icons.leaderboard_rounded,
                ),
              ),
            ],
          );
        }

        final actualSeasonId = seasonId ?? season.id;
        final leaderboardsAsync = ref.watch(seasonLeaderboardConfigsProvider(actualSeasonId));
        final leaderboards = leaderboardsAsync.value ?? [];

        final isClosed = season.status == SeasonStatus.closed;
        final title = '${season.year} Standings';
        final subtitle = isClosed ? 'Season closed · standings are final' : '${leaderboards.length} Leaderboard${leaderboards.length == 1 ? '' : 's'} active';

        if (leaderboardsAsync.isLoading) {
          return const HeadlessScaffold(
            title: 'Season Standings',
            showBack: true,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtLoadingCard(useCard: true),
                ),
              ),
            ],
          );
        }

        if (leaderboards.isEmpty) {
           return HeadlessScaffold(
            title: title,
            subtitle: subtitle,
            showBack: true,
            slivers: const [
              SliverFillRemaining(
                child: BoxyArtEmptyCard(
                  title: 'No Active Standings',
                  message: 'No leaderboards have been assigned to this season yet.',
                  icon: Icons.leaderboard_rounded,
                ),
              ),
            ],
           );
        }

        final groups = groupLeaderboards(leaderboards);

        return HeadlessScaffold(
          title: title,
          subtitle: subtitle,
          showBack: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.lg),
                  if (isClosed) ...[
                    BoxyArtCard(
                      backgroundColor: AppColors.amber500.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.amber500.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.standard,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.amber500),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Season closed — standings are final and will not change.',
                              style: AppTypography.micro.copyWith(color: AppColors.dark400),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.standard),
                  ],
                  for (final group in groups) ...[
                    BoxyArtSectionTitle(title: group.label, isPeeking: true),
                    for (final config in group.configs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.cardToCard),
                        child: LeaderboardHubCard(
                          seasonId: season.id,
                          config: config,
                          currentUserId: currentUserId,
                        ),
                      ),
                  ],
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(
        title: 'Season Standings',
        showBack: true,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: true),
            ),
          ),
        ],
      ),
      error: (e, s) => HeadlessScaffold(
        title: 'Season Standings',
        showBack: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'Leaderboard Error',
                message: e.toString(),
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardGroup {
  final String label;
  final List<LeaderboardConfig> configs;
  LeaderboardGroup(this.label, this.configs);
}

List<LeaderboardGroup> groupLeaderboards(List<LeaderboardConfig> leaderboards) {
  final oom = leaderboards.where((l) => l is OrderOfMeritConfig).toList();
  final bos = leaderboards.where((l) => l is BestOfSeriesConfig).toList();
  final eclectic = leaderboards.where((l) => l is EclecticConfig).toList();
  final marker = leaderboards.where((l) => l is MarkerCounterConfig).toList();
  return [
    if (oom.isNotEmpty) LeaderboardGroup('Order of Merit', oom),
    if (bos.isNotEmpty) LeaderboardGroup('Best of Series', bos),
    if (eclectic.isNotEmpty) LeaderboardGroup('Eclectic', eclectic),
    if (marker.isNotEmpty) LeaderboardGroup('Marker Counters', marker),
  ];
}

class LeaderboardHubCard extends ConsumerWidget {
  final String seasonId;
  final LeaderboardConfig config;
  final String currentUserId;

  const LeaderboardHubCard({
    super.key,
    required this.seasonId,
    required this.config,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: seasonId, leaderboardId: config.id)));
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon = config.map(
      orderOfMerit: (_) => Icons.emoji_events_rounded,
      bestOfSeries: (_) => Icons.stars_rounded,
      eclectic: (_) => Icons.grid_on_rounded,
      markerCounter: (_) => Icons.park_rounded,
    );

    final Color brandColor = config.map(
      orderOfMerit: (_) => AppColors.teamA,
      bestOfSeries: (_) => AppColors.amber500,
      eclectic: (_) => AppColors.lime500,
      markerCounter: (_) => AppColors.lime500,
    );

    final String description = LeaderboardRuleTranslator.translate(config);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.large),
      onTap: () => context.push('/locker/standings/${config.id}?seasonId=$seasonId'),
      child: Row(
        children: [
          BoxyArtIconBadge(
            icon: icon,
            color: brandColor,
            isTinted: true,
            size: AppShapes.iconHero,
            iconSize: AppShapes.iconLg,
          ),
          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name.toUpperCase(),
                  style: AppTypography.labelStrong,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                standingsAsync.when(
                  data: (standings) {
                    if (standings.isEmpty) {
                      return Text(
                        'NO DATA AVAILABLE',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.dark400,
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      );
                    }

                    final leader = standings.first;
                    final isMemberLeader = leader.memberId == currentUserId;
                    final Color indicatorColor = isMemberLeader ? primary : brandColor;

                    final unit = config.map(
                      orderOfMerit: (_) => 'PTS',
                      bestOfSeries: (bos) => bos.metric == BestOfMetric.stableford ? 'PTS' : 'STR',
                      eclectic: (e) => e.metric == EclecticMetric.stableford ? 'PTS' : 'STR',
                      markerCounter: (c) => c.rankingMethod == MarkerRankingMethod.points ? 'PTS' : 'MARKERS',
                    );

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMemberLeader ? Icons.person_rounded : Icons.trending_up_rounded,
                          size: AppShapes.iconXs,
                          color: indicatorColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            '1st: ${isMemberLeader ? 'YOU' : leader.memberName} • ${leader.points.toStringAsFixed(0)} $unit',
                            style: AppTypography.micro.copyWith(
                              color: indicatorColor,
                              fontWeight: AppTypography.weightBold,
                              letterSpacing: AppTypography.lsStandard,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: AppShapes.iconXs,
                    width: AppShapes.iconXs,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.dark400,
            size: AppShapes.iconSm,
          ),
        ],
      ),
    );
  }
}
