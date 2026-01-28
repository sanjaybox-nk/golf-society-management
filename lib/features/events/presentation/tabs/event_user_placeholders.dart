import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../events_provider.dart';
import '../widgets/event_sliver_app_bar.dart';

class EventGroupingUserTab extends ConsumerWidget {
  final String eventId;
  const EventGroupingUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              EventSliverAppBar(
                event: event,
                title: 'Grouping',
              ),
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey),
                       SizedBox(height: 16),
                       Text('Grouping not published', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
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
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              EventSliverAppBar(
                event: event,
                title: 'Leaderboard',
              ),
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                       SizedBox(height: 16),
                       Text('No scores yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
