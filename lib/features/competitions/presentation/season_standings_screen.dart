import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'standings/leaderboard_table_view.dart';

class SeasonStandingsScreen extends ConsumerWidget {
  final String? seasonId;

  const SeasonStandingsScreen({super.key, this.seasonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSeasonAsync = ref.watch(activeSeasonProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;
    final primary = Theme.of(context).primaryColor;
    const currentUserId = ''; 

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

        return DefaultTabController(
          length: season.leaderboards.length,
          child: Scaffold(
            backgroundColor: beigeBackground,
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 80),
                    _buildHeader(context, season),
                    const SizedBox(height: 12),
                    TabBar(
                      isScrollable: true,
                      indicatorColor: primary,
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey.shade400,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      tabs: season.leaderboards.map((l) => Tab(text: l.name.toUpperCase())).toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: season.leaderboards.map((config) {
                           return _LeaderboardTab(seasonId: season.id, leaderboardId: config.id, currentUserId: currentUserId);
                        }).toList(),
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

  const _LeaderboardTab({required this.seasonId, required this.leaderboardId, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the standings for this specific leaderboard
    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: seasonId, leaderboardId: leaderboardId)));

    return standingsAsync.when(
      data: (standings) => LeaderboardTableView(standings: standings, currentUserId: currentUserId),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading standings: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}
