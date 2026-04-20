import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import '../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';

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
        
        final title = '${season.year} Standings';
        final leaderboards = season.leaderboards;
        final subtitle = '${leaderboards.length} Leaderboards Active';

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

        return HeadlessScaffold(
          title: title,
          subtitle: subtitle,
          showBack: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final config = leaderboards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _LeaderboardHubCard(
                        seasonId: season.id,
                        config: config,
                        currentUserId: currentUserId,
                      ),
                    );
                  },
                  childCount: leaderboards.length,
                ),
              ),
            ),
            // Safety bottom padding for the floating navigation
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

class _LeaderboardHubCard extends ConsumerWidget {
  final String seasonId;
  final LeaderboardConfig config;
  final String currentUserId;

  const _LeaderboardHubCard({
    required this.seasonId,
    required this.config,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: seasonId, leaderboardId: config.id)));
    final primary = Theme.of(context).primaryColor;

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

    final String description = config.map(
      orderOfMerit: (_) => 'Accumulate points from all rounds.',
      bestOfSeries: (bos) => 'Count top ${bos.bestN} scores.',
      eclectic: (_) => 'Best score per hole across season.',
      markerCounter: (_) => 'Track Birdies, Eagles, or Pars.',
    );

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => context.push('/locker/standings/${config.id}?seasonId=$seasonId'),
      child: Row(
        children: [
          // Standardized Design 4.x Icon Badge
          BoxyArtIconBadge(
            icon: icon,
            color: brandColor,
            isTinted: true,
            size: 48,
            iconSize: 24,
          ),
          const SizedBox(width: AppSpacing.lg),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name.toUpperCase(),
                  style: AppTypography.labelStrong.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Live Leader Info with Premium Branded Labels
                standingsAsync.when(
                  data: (standings) {
                    if (standings.isEmpty) {
                      return Text(
                        'NO DATA AVAILABLE',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontWeight: AppTypography.weightBlack,
                          letterSpacing: 1.0,
                        ),
                      );
                    }
                    
                    final leader = standings.first;
                    final isMemberLeader = leader.memberId == currentUserId;
                    final Color indicatorColor = isMemberLeader ? primary : brandColor;

                    final unit = config.map(
                      orderOfMerit: (_) => 'PTS', 
                      bestOfSeries: (bos) => bos.metric == BestOfMetric.stableford ? 'PTS' : 'STR', 
                      eclectic: (_) => 'STR', 
                      markerCounter: (_) => 'BIRDIES',
                    );
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMemberLeader ? Icons.person_rounded : Icons.trending_up_rounded,
                          size: 14,
                          color: indicatorColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '1st: ${isMemberLeader ? 'YOU' : leader.memberName} • ${leader.points.toStringAsFixed(0)} $unit',
                            style: AppTypography.micro.copyWith(
                              color: indicatorColor,
                              fontWeight: AppTypography.weightBlack,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          
          // Trailing Chevron for Hub Navigation
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
