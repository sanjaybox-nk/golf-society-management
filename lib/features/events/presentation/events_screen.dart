import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/golf_event.dart';
import 'events_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsProvider);
    final pastAsync = ref.watch(pastEventsProvider);

    return Scaffold(
      appBar: const BoxyArtAppBar(
        title: 'Events', 
        subtitle: 'Society calendar',
        isLarge: true,
        showLeading: false, // Remove menu icon
      ),
      body: CustomScrollView(
        slivers: [
          // Upcoming Section
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Upcoming Events'),
            ),
          ),
          upcomingAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No upcoming events scheduled')),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Highlight the first event (Next Match)
                    final isNextMatch = index == 0;
                    return _EventCard(event: events[index], isHighlighted: isNextMatch);
                  },
                  childCount: events.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),

          // Past Section
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 8), // Extra top spacing
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Past Events'),
            ),
          ),
          pastAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No past events this season')),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _EventCard(event: events[index], isHighlighted: false);
                  },
                  childCount: events.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),
          
          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final GolfEvent event;
  final bool isHighlighted;

  const _EventCard({required this.event, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: BoxyArtFloatingCard(
        onTap: () => context.push('/events/${event.id}'),
        border: isHighlighted 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Badge
            BoxyArtDateBadge(date: event.date),
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
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.courseName ?? 'TBA',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registration: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action / Arrow
            Column(
              children: [
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

