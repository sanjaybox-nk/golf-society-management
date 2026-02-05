import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../events_provider.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/competitions/presentation/widgets/leaderboard_widget.dart';
import 'package:golf_society/models/competition.dart';
import '../../../members/presentation/members_provider.dart';
import '../widgets/grouping_widgets.dart';
import '../../../competitions/presentation/competitions_provider.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final membersAsync = ref.watch(allMembersProvider);
    final competitionsAsync = ref.watch(competitionsListProvider(null));

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        final bool isPublished = event.isGroupingPublished;
        final groupsData = event.grouping['groups'] as List?;
        final List<TeeGroup> groups = groupsData != null 
            ? groupsData.map((g) => TeeGroup.fromJson(g)).toList()
            : [];

        return Scaffold(
          appBar: BoxyArtAppBar(
            title: 'Grouping',
            subtitle: event.title,
            showBack: true,
          ),
          body: !isPublished
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_clock_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Grouping not yet published', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('The Admin will publish the tee sheet soon.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : groups.every((g) => g.players.isEmpty)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No players confirmed yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'The field is currently being finalized. Check back once registration is closed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final members = membersAsync.value ?? [];
                        final memberMap = {for (var m in members) m.id: m};
                        final history = events.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
                        final comps = competitionsAsync.value ?? [];
                        final comp = comps.where((c) => c.id == event.id).firstOrNull;

                        return GroupingCard(
                          group: group,
                          memberMap: memberMap,
                          history: history,
                          totalGroups: groups.length,
                          rules: comp?.rules,
                          courseConfig: event.courseConfig,
                          isAdmin: false,
                        );
                      },
                    ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

}


class EventScoresUserTab extends ConsumerWidget {
  final String eventId;
  const EventScoresUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        // Mock data for leaderboard
        final mockEntries = [
          LeaderboardEntry(playerName: 'Sanjay Patel', score: 38, handicap: 12),
          LeaderboardEntry(playerName: 'John Doe', score: 36, handicap: 15),
          LeaderboardEntry(playerName: 'Jane Smith', score: 34, handicap: 18),
          LeaderboardEntry(playerName: 'Bob Wilson', score: 31, handicap: 22),
        ];

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: BoxyArtAppBar(
            title: 'LEADERBOARD',
            subtitle: event.title.toUpperCase(),
            showBack: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEntryBanner(context, eventId),
                const SizedBox(height: 24),
                const BoxyArtSectionTitle(title: 'LIVE STANDINGS'),
                const SizedBox(height: 16),
                LeaderboardWidget(entries: mockEntries, format: CompetitionFormat.stableford),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildEntryBanner(BuildContext context, String eventId) {
    return BoxyArtFloatingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'READY TO PLAY?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Submit your scores hole-by-hole to update the live standings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/events/$eventId/scores/entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ENTER SCORECARD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
