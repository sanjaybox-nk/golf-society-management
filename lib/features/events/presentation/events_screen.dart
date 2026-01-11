import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/golf_event.dart';
import 'events_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(eventFilterProvider);

    return Scaffold(
      appBar: const BoxyArtAppBar(title: 'Events'),
      body: Stack(
        children: [
          _EventsList(
            provider: currentFilter == EventFilter.upcoming 
              ? upcomingEventsProvider 
              : pastEventsProvider, 
            isUpcoming: currentFilter == EventFilter.upcoming,
          ),
          
          // Floating Filter Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingFilterBar<EventFilter>(
              selectedValue: currentFilter,
              options: [
                FloatingFilterOption(label: 'Upcoming', value: EventFilter.upcoming),
                FloatingFilterOption(label: 'Past Results', value: EventFilter.past),
              ],
              onChanged: (filter) {
                ref.read(eventFilterProvider.notifier).update(filter);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  final Provider<AsyncValue<List<GolfEvent>>> provider;
  final bool isUpcoming;

  const _EventsList({
    required this.provider,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(provider);

    return eventsAsync.when(
      data: (events) {
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
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _EventCard(event: events[index], isUpcoming: isUpcoming);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: BoxyArtFloatingCard(
        onTap: () {
          // TODO: Navigate to event details
        },
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
                  Theme(
                    data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                    child: const Chip(
                      label: Text('Register'),
                      labelStyle: TextStyle(fontSize: 12, color: Colors.white),
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                else
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
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
            DateFormat('MMM').format(date).toUpperCase(), // Month (e.g. MAY)
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
