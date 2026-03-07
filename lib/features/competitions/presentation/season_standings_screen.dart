import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collection/collection.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import '../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';

class SeasonStandingsScreen extends ConsumerStatefulWidget {
  final String? seasonId;

  const SeasonStandingsScreen({super.key, this.seasonId});

  @override
  ConsumerState<SeasonStandingsScreen> createState() => _SeasonStandingsScreenState();
}

class _SeasonStandingsScreenState extends ConsumerState<SeasonStandingsScreen> {
  String? _selectedLeaderboardId;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(effectiveUserProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;
    final currentUserId = currentUser.id;
    final activeSeasonAsync = ref.watch(activeSeasonProvider);

    return activeSeasonAsync.when(
      data: (season) {
        if (season == null) {
          return const Scaffold(body: Center(child: Text('No active season found')));
        }
        
        if (season.leaderboards.isEmpty) {
           return Scaffold(
            backgroundColor: beigeBackground,
            body: Stack(
              children: [
                _buildHeader(context, season),
                const Center(child: Text('No leaderboards configured')),
              ],
            ),
           );
        }

        if (_selectedLeaderboardId == null || !season.leaderboards.any((l) => l.id == _selectedLeaderboardId)) {
          // Initialize in next frame to avoid build phase setState equivalent if needed, but it's fine to just fall back
           _selectedLeaderboardId = season.leaderboards.first.id;
        }

        final currentId = _selectedLeaderboardId ?? season.leaderboards.first.id;

        return Scaffold(
          backgroundColor: beigeBackground,
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 80),
                  _buildHeader(context, season),
                  const SizedBox(height: AppSpacing.md),
                  ModernUnderlinedFilterBar<String>(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    tabs: season.leaderboards.map((l) => ModernFilterTab(
                      label: l.name.toUpperCase(), 
                      value: l.id,
                    )).toList(),
                    selectedValue: currentId,
                    onTabSelected: (val) {
                      setState(() {
                        _selectedLeaderboardId = val;
                      });
                    },
                  ),
                  Expanded(
                    child: _LeaderboardTab(
                      key: ValueKey(currentId),
                      seasonId: season.id, 
                      leaderboardId: currentId, 
                      currentUserId: currentUserId,
                    ),
                  ),
                ],
              ),
                
                // Back Button sticky
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: AppSpacing.x4l,
                            height: AppSpacing.x4l,
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.softScale,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_rounded, size: AppShapes.iconMd, color: Colors.black.withValues(alpha: 0.87)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
      },
      loading: () => Scaffold(backgroundColor: beigeBackground, body: const Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(backgroundColor: beigeBackground, body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic season) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${season.year} Standings',
            style: const TextStyle(
              fontSize: AppTypography.sizeDisplayMedium,
              fontWeight: AppTypography.weightBold,
              letterSpacing: -1,
            ),
          ),
          Text(
            season.name.toUpperCase(),
            style: TextStyle(
              fontSize: AppTypography.sizeLabel,
              color: AppColors.dark500,
              fontWeight: AppTypography.weightBold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final String seasonId;
  final String leaderboardId;
  final String currentUserId;

  const _LeaderboardTab({super.key, required this.seasonId, required this.leaderboardId, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: seasonId, leaderboardId: leaderboardId)));
    final activeSeasonAsync = ref.watch(activeSeasonProvider);

    return standingsAsync.when(
      data: (standings) {
        final config = activeSeasonAsync.value?.leaderboards.firstWhereOrNull((l) => l.id == leaderboardId);
        
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: _buildFormatSpecificHeader(config),
                ),
              ),

            if (standings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_outlined, 
                        size: AppShapes.iconMassive, 
                        color: Theme.of(context).brightness == Brightness.dark 
                           ? AppColors.dark150.withValues(alpha: AppColors.opacityMedium) 
                           : AppColors.dark400.withValues(alpha: AppColors.opacityMedium)
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'NO STANDINGS YET', 
                        style: AppTypography.label.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                          letterSpacing: 1.2,
                        )
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Standings will appear here once events in this season are published and calculated.', 
                        textAlign: TextAlign.center, 
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)
                      ),
                      const SizedBox(height: 100), // Account for bottom padding
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final standing = standings[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 6),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading standings: $e', style: const TextStyle(color: AppColors.coral500))),
    );
  }

  Widget _buildFormatSpecificHeader(LeaderboardConfig config) {
    // Return unique UI helpers based on format
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: config.map(
        orderOfMerit: (oom) => Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: AppShapes.iconSm, color: AppColors.teamA),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Top ${oom.positionPointsMap.length} players per event earn points.',
                style: const TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightMedium),
              ),
            ),
          ],
        ),
        bestOfSeries: (bos) => Row(
          children: [
            const Icon(Icons.stars_rounded, size: AppShapes.iconSm, color: AppColors.amber500),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Counting best ${bos.bestN} rounds for the season.',
                style: const TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightMedium),
              ),
            ),
          ],
        ),
        eclectic: (_) => Row(
          children: [
            const Icon(Icons.grid_on_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Your ultimate scorecard combining your best score on each hole across the season.',
                style: TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightMedium),
              ),
            ),
          ],
        ),
        markerCounter: (_) => Row(
          children: [
            const Icon(Icons.park_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Total birdie/eagle count for the season.',
                style: TextStyle(fontSize: AppTypography.sizeCaptionStrong, fontWeight: AppTypography.weightMedium),
              ),
            ),
          ],
        ),
      ),
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
    // Resolve Unit
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
          // 2nd Place
          Expanded(child: _PodiumSpot(standing: standings[1], rank: 2, unit: unit, isMe: standings[1].memberId == currentUserId)),
          // 1st Place
          Expanded(child: _PodiumSpot(standing: standings[0], rank: 1, isWinner: true, unit: unit, isMe: standings[0].memberId == currentUserId)),
          // 3rd Place
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
    required this.standing, 
    required this.rank, 
    this.isWinner = false,
    required this.unit,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final Color rankColor = rank == 1 ? AppColors.amber500 : (rank == 2 ? AppColors.textSecondary : Colors.brown);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: isWinner ? 80 : 64,
                height: isWinner ? 80 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMe ? primary : rankColor, 
                    width: isWinner ? 3 : 2,
                  ),
                  boxShadow: AppShadows.softScale,
                ),
                child: Center(
                  child: Text(
                    standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: isWinner ? 32 : 24, 
                      fontWeight: AppTypography.weightBold, 
                      color: isMe ? primary : rankColor,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: rankColor,
                borderRadius: AppShapes.md,
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(color: AppColors.pureWhite, fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          standing.memberName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isMe ? AppTypography.weightBlack : (isWinner ? AppTypography.weightBlack : AppTypography.weightBold), 
            fontSize: isWinner ? 14 : 12,
            color: isMe ? primary : null,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${standing.points.toStringAsFixed(0)} $unit',
          style: TextStyle(fontSize: AppTypography.sizeCaption, color: primary, fontWeight: AppTypography.weightBold),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          height: isWinner ? 60 : 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rMd)),
          ),
        ),
      ],
    );
  }
}

class _StandingRow extends StatelessWidget {
  final LeaderboardStanding standing;
  final int rank;
  final bool isMe;

  const _StandingRow({required this.standing, required this.rank, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: isMe ? Border.fromBorderSide(const BorderSide(color: AppColors.amber500, width: AppShapes.borderMedium)) : null,
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.x2l,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: AppTypography.weightBlack,
                color: isMe ? AppColors.amber500 : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CircleAvatar(
            radius: 14,
            backgroundColor: isMe ? AppColors.amber500.withValues(alpha: AppColors.opacityMedium) : AppColors.textSecondary.withValues(alpha: AppColors.opacityLow),
            child: Text(
              standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
              style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: isMe ? AppColors.amber500 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              standing.memberName,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: isMe ? AppTypography.weightBlack : AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            standing.points.toStringAsFixed(0),
            style: TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody, color: isMe ? AppColors.amber500 : null),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    // Show format-specific breakdown dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StandingDetailSheet(standing: standing),
    );
  }
}

class _StandingDetailSheet extends StatelessWidget {
  final LeaderboardStanding standing;
  const _StandingDetailSheet({required this.standing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rPill)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l, vertical: AppSpacing.x3l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: AppSpacing.x4l,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMedium),
                borderRadius: AppShapes.grabber,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(standing.memberName[0].toUpperCase()),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    standing.memberName,
                    style: const TextStyle(fontSize: AppTypography.sizeDisplaySection, fontWeight: AppTypography.weightBold),
                  ),
                  Text(
                    '${standing.roundsPlayed} Rounds Played',
                    style: TextStyle(color: AppColors.dark500, fontSize: AppTypography.sizeLabelStrong),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    standing.points.toStringAsFixed(0),
                    style: TextStyle(fontSize: AppTypography.sizeDisplayLocker, fontWeight: AppTypography.weightBlack, color: Theme.of(context).primaryColor),
                  ),
                  const Text('TOTAL PTS', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3l),
          const Text(
            'PERFORMANCE BREAKDOWN',
            style: TextStyle(fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBlack, letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFormatSpecificDetails(context),
          const SizedBox(height: AppSpacing.x4l),
          BoxyArtButton(
            title: 'Close',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSpecificDetails(BuildContext context) {
    // Check for Eclectic or Birdie Tree data
    if (standing.holeScores.isNotEmpty) {
      return MasterScorecardWidget(scores: standing.holeScores);
    } else if (standing.stats.isNotEmpty) {
      return BirdieGalleryWidget(counts: standing.stats);
    } else if (standing.history.isNotEmpty) {
      return PointsBreakdownWidget(
        points: standing.history,
        countingRounds: standing.roundsCounted,
      );
    }
    
    return const BoxyArtCard(
      padding: EdgeInsets.all(AppSpacing.x2l),
      child: Center(
        child: Text('No further breakdown available for this format.', style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
      ),
    );
  }
}

class PointsBreakdownWidget extends StatelessWidget {
  final List<double> points;
  final int countingRounds;

  const PointsBreakdownWidget({super.key, required this.points, required this.countingRounds});

  @override
  Widget build(BuildContext context) {
    // Sort points descending to show winners
    final sortedPoints = [...points]..sort((a, b) => b.compareTo(a));
    final threshold = countingRounds > 0 && sortedPoints.length >= countingRounds 
        ? sortedPoints[countingRounds - 1] 
        : -1.0;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEST OF SERIES ($countingRounds ROUNDS)',
            style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.amber500),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: points.map((p) {
              final isCounting = p >= threshold && p > 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isCounting ? AppColors.amber500.withValues(alpha: AppColors.opacityLow) : AppColors.textSecondary.withValues(alpha: AppColors.opacitySubtle),
                  borderRadius: AppShapes.sm,
                  border: Border.all(color: isCounting ? AppColors.amber500.withValues(alpha: AppColors.opacityMuted) : Colors.transparent),
                ),
                child: Text(
                  p.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: isCounting ? AppTypography.weightBlack : AppTypography.weightRegular,
                    color: isCounting ? AppColors.amber500 : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          if (points.isEmpty) 
            const Text('No scores recorded yet.', style: TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class MasterScorecardWidget extends StatelessWidget {
  final Map<String, int> scores;
  const MasterScorecardWidget({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Text('BEST HOLE-BY-HOLE', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.lime500)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(18, (index) {
              final hole = index + 1;
              final score = scores['$hole'];
              return Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                  borderRadius: AppShapes.sm,
                  border: Border.all(color: AppColors.lime500.withValues(alpha: AppColors.opacityMedium)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$hole', style: const TextStyle(fontSize: AppTypography.sizeNano, color: AppColors.lime500)),
                      Text(
                        score != null ? '$score' : '-',
                        style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBodySmall),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class BirdieGalleryWidget extends StatelessWidget {
  final Map<String, int> counts;
  const BirdieGalleryWidget({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBirdieStat('🐦', 'BIRDIES', counts['birdies'] ?? 0, AppColors.teamA),
          _buildBirdieStat('🦅', 'EAGLES', counts['eagles'] ?? 0, AppColors.amber500),
          _buildBirdieStat('🔥', 'ALBATROSS', counts['albatross'] ?? 0, AppColors.coral500),
        ],
      ),
    );
  }

  Widget _buildBirdieStat(String emoji, String label, int count, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: AppTypography.sizeDisplayLocker)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$count',
          style: TextStyle(fontSize: AppTypography.sizeDisplaySection, fontWeight: AppTypography.weightBlack, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: AppTypography.sizeMicroSmall, fontWeight: AppTypography.weightBold, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
