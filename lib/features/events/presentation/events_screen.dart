import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/golf_event.dart';
import 'events_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final pastEvents = ref.watch(pastEventsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past Results'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EventsList(events: upcomingEvents, isUpcoming: true),
            _EventsList(events: pastEvents, isUpcoming: false),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<GolfEvent> events;
  final bool isUpcoming;

  const _EventsList({
    required this.events,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_busy : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming events' : 'No past events found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _EventCard(event: events[index], isUpcoming: isUpcoming);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final GolfEvent event;
  final bool isUpcoming;

  const _EventCard({
    required this.event,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to event details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Badge
              _DateBadge(date: event.date),
              const SizedBox(width: 16),
              
              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tee-off: ${DateFormat('h:mm a').format(event.teeOffTime ?? event.date)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),

              // Action / Arrow
              Column(
                children: [
                  if (isUpcoming)
                    Chip(
                      label: const Text('Register'),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MST').format(date).toUpperCase(), // Month (e.g. MAY)
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
          ),
          Text(
            DateFormat('d').format(date), // Day (e.g. 15)
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
