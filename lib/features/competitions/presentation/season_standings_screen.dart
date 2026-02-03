import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import '../../../../models/season.dart';

class SeasonStandingsScreen extends ConsumerWidget {
  final String? seasonId;

  const SeasonStandingsScreen({super.key, this.seasonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSeasonAsync = ref.watch(activeSeasonProvider);

    return activeSeasonAsync.when(
      data: (season) {
        if (season == null) {
          return const Scaffold(body: Center(child: Text('No active season found')));
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: BoxyArtAppBar(
            title: '${season.year} STANDINGS',
            subtitle: season.name.toUpperCase(),
            centerTitle: true,
            isLarge: true,
          ),
          body: Column(
            children: [
              _buildRulesSummary(season),
              Expanded(
                child: _buildStandingsList(season),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildRulesSummary(Season season) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRuleItem('MODE', season.pointsMode.name.toUpperCase()),
          _buildRuleItem('BEST N', '${season.bestN} Rounds'),
          _buildRuleItem('TIES', season.tiePolicy.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStandingsList(Season season) {
    // Mock standings data
    final mockStandings = [
      _StandingEntry(name: 'Sanjay Patel', points: 420.5, played: 12, counting: 8),
      _StandingEntry(name: 'John Doe', points: 398.0, played: 10, counting: 8),
      _StandingEntry(name: 'Jane Smith', points: 385.5, played: 8, counting: 8),
      _StandingEntry(name: 'Bob Wilson', points: 350.0, played: 14, counting: 8),
      _StandingEntry(name: 'Alice Brown', points: 342.0, played: 9, counting: 8),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: mockStandings.length,
      itemBuilder: (context, index) {
        final entry = mockStandings[index];
        final isTop3 = index < 3;
        final color = isTop3 ? Theme.of(context).primaryColor : Colors.white;

        return BoxyArtFloatingCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Played: ${entry.played} (Counting: ${entry.counting})',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      entry.points.toString(),
                      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const Text('POINTS', style: TextStyle(color: Colors.grey, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StandingEntry {
  final String name;
  final double points;
  final int played;
  final int counting;

  _StandingEntry({required this.name, required this.points, required this.played, required this.counting});
}
