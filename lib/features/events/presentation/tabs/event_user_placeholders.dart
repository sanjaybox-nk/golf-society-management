import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../events_provider.dart';
import '../widgets/event_sliver_app_bar.dart';
import '../../../../core/utils/grouping_service.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

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
                        return _buildGroupCard(context, group);
                      },
                    ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildGroupCard(BuildContext context, TeeGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BoxyArtFloatingCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group ${group.index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat.Hm().format(group.teeTime),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...group.players.map((p) => _buildPlayerRow(p)),
        ],
      ),
    ),
  );
}

  Widget _buildPlayerRow(TeeGroupParticipant p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            p.isGuest ? Icons.person_outline : Icons.person,
            size: 20,
            color: p.isCaptain ? Colors.orange : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: p.isCaptain ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (p.isGuest) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'G', 
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.orange, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (p.isCaptain)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.shield, color: Colors.orange, size: 16),
            ),
          if (p.needsBuggy)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.electric_rickshaw, size: 16, color: Colors.blue),
            ),
        ],
      ),
    );
  }
}

class EventScoresUserTab extends ConsumerWidget {
  final String eventId;
  const EventScoresUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return Scaffold(
          appBar: BoxyArtAppBar(
            title: 'Leaderboard',
            subtitle: event.title,
            showBack: true,
          ),
          body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                       SizedBox(height: 16),
                       Text('No scores yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
