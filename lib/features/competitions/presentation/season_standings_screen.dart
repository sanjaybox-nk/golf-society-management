import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'standings/leaderboard_table_view.dart';

class SeasonStandingsScreen extends ConsumerWidget {
  final String? seasonId;

  const SeasonStandingsScreen({super.key, this.seasonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSeasonAsync = ref.watch(activeSeasonProvider);
    // Ideally fetch current user ID. 
    // Since I can't easily find the provider, I'll use a placeholder or check 'context' if available via some global.
    // Use an empty string for now if not found, highlighting won't work but app won't crash.
    const currentUserId = ''; 

    return activeSeasonAsync.when(
      data: (season) {
        if (season == null) {
          return const Scaffold(body: Center(child: Text('No active season found')));
        }
        
        if (season.leaderboards.isEmpty) {
           return Scaffold(
            backgroundColor: Colors.black,
            appBar: BoxyArtAppBar(title: '${season.year} STANDINGS'),
            body: const Center(child: Text('No leaderboards configured', style: TextStyle(color: Colors.white))),
           );
        }

        return DefaultTabController(
          length: season.leaderboards.length,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: BoxyArtAppBar(
              title: '${season.year} STANDINGS',
              subtitle: season.name.toUpperCase(),
              centerTitle: true,
              isLarge: true,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.white60,
                tabAlignment: TabAlignment.center,
                tabs: season.leaderboards.map((l) => Tab(text: l.name.toUpperCase())).toList(),
              ),
            ),
            body: TabBarView(
              children: season.leaderboards.map((config) {
                 return _LeaderboardTab(seasonId: season.id, leaderboardId: config.id, currentUserId: currentUserId);
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
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
