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
                  const SizedBox(height: 12),
                  ModernUnderlinedFilterBar<String>(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${season.year} Standings',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          Text(
            season.name.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: _buildFormatSpecificHeader(config),
                ),
              ),

            if (standings.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_outlined, 
                        size: 64, 
                        color: Theme.of(context).brightness == Brightness.dark 
                           ? AppColors.dark150.withValues(alpha: 0.2) 
                           : AppColors.dark400.withValues(alpha: 0.2)
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NO STANDINGS YET', 
                        style: AppTypography.label.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark300,
                          letterSpacing: 1.2,
                        )
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Standings will appear here once events in this season are published and calculated.', 
                        textAlign: TextAlign.center, 
                        style: AppTypography.bodySmall.copyWith(color: Colors.grey)
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
      error: (e, s) => Center(child: Text('Error loading standings: $e', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildFormatSpecificHeader(LeaderboardConfig config) {
    // Return unique UI helpers based on format
    return BoxyArtCard(
      padding: const EdgeInsets.all(16),
      child: config.map(
        orderOfMerit: (oom) => Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Top ${oom.positionPointsMap.length} players per event earn points.',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        bestOfSeries: (bos) => Row(
          children: [
            const Icon(Icons.stars_rounded, size: 16, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Counting best ${bos.bestN} rounds for the season.',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        eclectic: (_) => Row(
          children: [
            const Icon(Icons.grid_on_rounded, size: 16, color: Colors.teal),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Your ultimate scorecard combining your best score on each hole across the season.',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        markerCounter: (_) => Row(
          children: [
            const Icon(Icons.park_rounded, size: 16, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Total birdie/eagle count for the season.',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    final Color rankColor = rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey : Colors.brown.shade400);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: isWinner ? 80 : 64,
                height: isWinner ? 80 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMe ? primary : rankColor, 
                    width: isWinner ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isMe ? primary : rankColor).withValues(alpha: 0.2), 
                      blurRadius: 15, 
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: isWinner ? 32 : 24, 
                      fontWeight: FontWeight.bold, 
                      color: isMe ? primary : rankColor,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rankColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          standing.memberName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isMe ? FontWeight.w900 : (isWinner ? FontWeight.w900 : FontWeight.bold), 
            fontSize: isWinner ? 14 : 12,
            color: isMe ? primary : null,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${standing.points.toStringAsFixed(0)} $unit',
          style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: isWinner ? 60 : 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: isMe ? Border.fromBorderSide(const BorderSide(color: AppColors.amber500, width: 2)) : null,
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isMe ? AppColors.amber500 : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 14,
            backgroundColor: isMe ? AppColors.amber500.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
            child: Text(
              standing.memberName.isNotEmpty ? standing.memberName[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isMe ? AppColors.amber500 : Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              standing.memberName,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: isMe ? FontWeight.w900 : FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            standing.points.toStringAsFixed(0),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isMe ? AppColors.amber500 : null),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(standing.memberName[0].toUpperCase()),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    standing.memberName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${standing.roundsPlayed} Rounds Played',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    standing.points.toStringAsFixed(0),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                  ),
                  const Text('TOTAL PTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'PERFORMANCE BREAKDOWN',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _buildFormatSpecificDetails(context),
          const SizedBox(height: 40),
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
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text('No further breakdown available for this format.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEST OF SERIES ($countingRounds ROUNDS)',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: points.map((p) {
              final isCounting = p >= threshold && p > 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCounting ? Colors.amber.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isCounting ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent),
                ),
                child: Text(
                  p.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: isCounting ? FontWeight.w900 : FontWeight.normal,
                    color: isCounting ? Colors.amber.shade900 : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          if (points.isEmpty) 
            const Text('No scores recorded yet.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('BEST HOLE-BY-HOLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 16),
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
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$hole', style: const TextStyle(fontSize: 8, color: Colors.teal)),
                      Text(
                        score != null ? '$score' : '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBirdieStat('🐦', 'BIRDIES', counts['birdies'] ?? 0, Colors.blue),
          _buildBirdieStat('🦅', 'EAGLES', counts['eagles'] ?? 0, Colors.orange),
          _buildBirdieStat('🔥', 'ALBATROSS', counts['albatross'] ?? 0, Colors.red),
        ],
      ),
    );
  }

  Widget _buildBirdieStat(String emoji, String label, int count, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
