import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import '../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';

class SeasonLeaderboardDetailScreen extends ConsumerWidget {
  final String leaderboardId;
  final String? seasonId;

  const SeasonLeaderboardDetailScreen({
    super.key, 
    required this.leaderboardId, 
    this.seasonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = seasonId != null 
        ? ref.watch(seasonByIdProvider(seasonId!))
        : ref.watch(activeSeasonProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final currentUserId = currentUser.id;

    // Use provided seasonId or fall back to active season ID
    final actualSeasonId = seasonId ?? seasonAsync.value?.id;

    if (actualSeasonId == null) {
      return const HeadlessScaffold(
        title: 'Standings',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtLoadingCard(useCard: false),
          ),
        ],
      );
    }

    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: actualSeasonId, leaderboardId: leaderboardId)));

    return seasonAsync.when(
      data: (season) {
        final config = season?.leaderboards.firstWhereOrNull((l) => l.id == leaderboardId);
        final title = config?.name ?? 'Standings';
        final subtitle = season?.name.toUpperCase() ?? 'SEASON STANDINGS';

        return HeadlessScaffold(
          title: title,
          subtitle: subtitle,
          showBack: true,
          slivers: [
            standingsAsync.when(
              data: (standings) {
                return SliverMainAxisGroup(
                  slivers: [
                    if (standings.length >= 3)
                      SliverToBoxAdapter(
                        child: _PodiumHeader(
                          standings: standings.take(3).toList(),
                          config: config,
                          currentUserId: currentUserId,
                        ),
                      ),
                    
                    if (config != null)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                        sliver: SliverToBoxAdapter(
                          child: _buildFormatSpecificHeader(context, config),
                        ),
                      ),

                    if (standings.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: BoxyArtEmptyCard(
                          title: 'NO DATA AVAILABLE',
                          message: 'Standings will appear here once events in this season are published and calculated.',
                          icon: Icons.leaderboard_outlined,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final standing = standings[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                                child: _StandingRow(standing: standing, rank: index + 1, isMe: standing.memberId == currentUserId),
                              );
                            },
                            childCount: standings.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtLoadingCard(useCard: false),
                ),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: BoxyArtEmptyState(
                  title: 'Standings Error',
                  message: e.toString(),
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Standings', showBack: true, slivers: [SliverToBoxAdapter(child: BoxyArtLoadingCard())]),
      error: (e, s) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverToBoxAdapter(child: Text(e.toString()))]),
    );
  }

  Widget _buildFormatSpecificHeader(BuildContext context, LeaderboardConfig config) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(theme.extension<AppShapeTokens>()?.cardRadius ?? AppSpacing.lg),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
          width: 1,
        ),
      ),
      child: config.map(
        orderOfMerit: (oom) => _buildInfoRow(context, Icons.info_outline_rounded,
          'Top ${oom.positionPointsMap.length} players per event earn points.', AppColors.teamA),
        bestOfSeries: (bos) => _buildInfoRow(context, Icons.stars_rounded,
          'Season series counting your best ${bos.bestN} round scores.', AppColors.amber500),
        eclectic: (_) => _buildInfoRow(context, Icons.grid_on_rounded,
          'Your ultimate scorecard combining your best score on each hole across the season.', AppColors.lime500),
        markerCounter: (_) => _buildInfoRow(context, Icons.park_rounded,
          'Total birdie/eagle count tracked across the entire season.', AppColors.lime500),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String message, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppShapes.iconSm, color: iconColor),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            message,
            style: AppTypography.label.copyWith(fontWeight: AppTypography.weightMedium, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _PodiumHeader extends StatelessWidget {
  final List<LeaderboardStanding> standings;
  final LeaderboardConfig? config;
  final String currentUserId;

  const _PodiumHeader({required this.standings, this.config, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final String unit = config?.map(
      orderOfMerit: (_) => 'PTS',
      bestOfSeries: (bos) => bos.metric == BestOfMetric.stableford ? 'PTS' : 'STR',
      eclectic: (_) => 'STR',
      markerCounter: (_) => 'BIRDIES',
    ) ?? 'PTS';

    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumSpot(standing: standings[1], rank: 2, unit: unit, isMe: standings[1].memberId == currentUserId)),
          Expanded(child: _PodiumSpot(standing: standings[0], rank: 1, isWinner: true, unit: unit, isMe: standings[0].memberId == currentUserId)),
          Expanded(child: _PodiumSpot(standing: standings[2], rank: 3, unit: unit, isMe: standings[2].memberId == currentUserId)),
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final LeaderboardStanding standing;
  final int rank;
  final bool isWinner;
  final String unit;
  final bool isMe;

  const _PodiumSpot({
    super.key,
    required this.standing,
    required this.rank,
    this.isWinner = false,
    required this.unit,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    
    final Color rankColor = rank == 1 
        ? AppColors.amber500 
        : (rank == 2 
            ? (isDark ? AppColors.dark150 : AppColors.dark400) 
            : (isDark ? AppColors.dark300 : AppColors.dark600));

    final double avatarSize = isWinner ? 92.0 : 76.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter, 
          clipBehavior: Clip.none, 
          children: [
            // High-Fidelity Avatar with Rank Branding
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: avatarSize, 
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: isDark ? AppColors.dark600 : AppColors.pureWhite,
                  border: Border.all(
                    color: isMe ? primary : rankColor.withValues(alpha: isWinner ? 1 : 0.4), 
                    width: isWinner ? 4.0 : 2.5,
                  ),
                  boxShadow: isWinner 
                      ? [BoxShadow(color: rankColor.withValues(alpha: 0.25), blurRadius: 24, spreadRadius: 4)] 
                      : theme.extension<AppShadows>()?.softScale ?? [],
                ),
                child: Center(
                  child: Text(
                    standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: isWinner ? 38 : 30, 
                      fontWeight: AppTypography.weightBlack, 
                      color: isMe ? primary : rankColor,
                    ),
                  ),
                ),
              ),
            ),
            
            // Standardized Rank Badge
            Positioned(
              bottom: 2, 
              child: BoxyArtNumberBadge(
                number: rank, 
                size: 28, 
                isRanking: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Name & Points with High-Contrast Typography
        Text(
          standing.memberName, 
          textAlign: TextAlign.center, 
          style: AppTypography.labelStrong.copyWith(
            fontSize: isWinner ? 13 : 11, 
            color: isMe ? primary : null, 
            letterSpacing: -0.1,
          ), 
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${standing.points.toStringAsFixed(0)} $unit', 
          style: AppTypography.micro.copyWith(
            color: primary, 
            fontWeight: AppTypography.weightBlack, 
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Branded Podium Section
        Container(
          width: double.infinity, 
          height: isWinner ? 68 : 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark800 : AppColors.pureWhite, 
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(theme.extension<AppShapeTokens>()?.cardRadius ?? AppSpacing.lg),
            ), 
            boxShadow: theme.extension<AppShadows>()?.softScale ?? [],
            border: Border.all(
              color: isDark ? AppColors.dark600.withValues(alpha: 0.3) : AppColors.dark100,
              width: 1,
            ),
          ),
          child: isWinner ? Center(
            child: Icon(
              Icons.star_rounded, 
              color: AppColors.amber500.withValues(alpha: 0.6), 
              size: 18,
            ),
          ) : null,
        ),
      ],
    );
  }
}

class _StandingRow extends StatelessWidget {
  final LeaderboardStanding standing;
  final int rank;
  final bool isMe;

  const _StandingRow({
    super.key,
    required this.standing,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: isMe ? Border.all(color: AppColors.amber500, width: 1.5) : null,
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          // Standardized Rank Badge
          BoxyArtNumberBadge(
            number: rank, 
            size: 32, 
            isRanking: true,
          ),
          const SizedBox(width: AppSpacing.lg),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.memberName, 
                  style: AppTypography.labelStrong.copyWith(
                    color: isMe ? primary : null,
                  ), 
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMe) 
                  Text(
                    'PERSONAL BEST', 
                    style: AppTypography.micro.copyWith(
                      color: AppColors.amber500, 
                      fontWeight: AppTypography.weightBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),
          
          // Points Display
          Text(
            standing.points.toStringAsFixed(0), 
            style: AppTypography.body.copyWith(
              fontWeight: AppTypography.weightBlack, 
              color: isMe ? primary : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'PTS', 
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold, 
              color: AppColors.dark400,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      useRootNavigator: false, 
      backgroundColor: Colors.transparent,
      builder: (context) => _StandingDetailSheet(standing: standing),
    );
  }
}

class _StandingDetailSheet extends StatelessWidget {
  final LeaderboardStanding standing;
  
  const _StandingDetailSheet({
    super.key,
    required this.standing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rPill)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Grabber
          Center(
            child: Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: AppColors.dark300.withValues(alpha: 0.5), 
                borderRadius: AppShapes.grabber,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Member Header
          Row(
            children: [
              BoxyArtIconBadge(
                icon: Icons.person_rounded,
                color: primary,
                isTinted: true,
                size: 64,
                iconSize: 32,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(standing.memberName, style: AppTypography.displaySmall),
                    Text(
                      'TOTAL SEASON POINTS', 
                      style: AppTypography.micro.copyWith(
                        letterSpacing: 1.5, 
                        color: AppColors.textSecondary,
                        fontWeight: AppTypography.weightBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                standing.points.toStringAsFixed(0), 
                style: AppTypography.displaySmall.copyWith(color: primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          
          Text(
            'SEASON SUMMARY', 
            style: AppTypography.labelStrong.copyWith(
              letterSpacing: 1.5,
              color: isDark ? AppColors.dark200 : AppColors.dark400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Summary Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.8,
            children: [
              _buildStatCard(context, 'ROUNDS PLAYED', standing.roundsPlayed.toString()),
              _buildStatCard(context, 'ROUNDS COUNTED', standing.roundsCounted.toString()),
              _buildStatCard(context, 'BEST ROUND', (standing.history.isNotEmpty ? standing.history.reduce((a, b) => a > b ? a : b).toStringAsFixed(0) : '0')),
              _buildStatCard(context, 'HANDICAP', standing.currentHandicap.toStringAsFixed(1)),
            ],
          ),
          
          const SizedBox(height: AppSpacing.x3l),
          
          BoxyArtButton(
            title: 'CLOSE',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: AppTypography.micro.copyWith(
              color: AppColors.textSecondary, 
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: AppTypography.weightBlack,
            ),
          ),
          Text(
            value, 
            style: AppTypography.labelStrong.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
