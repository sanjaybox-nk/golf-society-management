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
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Society calendar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ),
          ),

          // Upcoming Section
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final isNextMatch = index == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: events[index], isHighlighted: isNextMatch),
                      );
                    },
                    childCount: events.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),

          // Past Section
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
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
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: events[index], isHighlighted: false),
                      );
                    },
                    childCount: events.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
          ),
          
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
    final primary = Theme.of(context).primaryColor;
    
    return ModernCard(
      onTap: () => context.push('/events/${event.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.courseName ?? 'TBA',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Registration: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

