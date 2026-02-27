import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/competition.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsProvider);
    final pastAsync = ref.watch(pastEventsProvider);
    final activeSeasonAsync = ref.watch(activeSeasonProvider);
    
    final seasonName = activeSeasonAsync.when(
      data: (s) => s?.name ?? '',
      loading: () => '',
      error: (err, stack) => '',
    );

    final subtitle = seasonName.isNotEmpty 
        ? 'Society calendar - $seasonName' 
        : 'Society calendar';

    return HeadlessScaffold(
      title: 'Events',
      subtitle: subtitle,
      slivers: [
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
                    return StaggeredEntrance(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EventCard(event: events[index], isHighlighted: isNextMatch),
                      ),
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
                    return StaggeredEntrance(
                      index: index + 5, // Offset stagger for past events
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EventCard(event: events[index], isHighlighted: false),
                      ),
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
      ],
    );
  }
}

class _EventCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isHighlighted;

  const _EventCard({required this.event, this.isHighlighted = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return BoxyArtCard(
      onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
      padding: const EdgeInsets.all(14),
      backgroundColor: isHighlighted 
          ? (isDark ? primary.withValues(alpha: 0.15) : primary.withValues(alpha: 0.03))
          : null,
      child: Row(
        children: [
          // Date Badge
          BoxyArtDateBadge(date: event.date, endDate: event.endDate),
          const SizedBox(width: 14),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Row
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Location Row
                Row(
                  children: [
                    BoxyArtIconBadge(icon: Icons.location_on_rounded, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.courseName ?? 'TBA',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Time Row
                Row(
                  children: [
                    BoxyArtIconBadge(icon: Icons.access_time_filled_rounded, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Registration: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                      style: TextStyle(
                        color: textSecondary?.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                
                // Bottom Pill Row
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildGameTypePill(context, ref, event.id),
                    if (event.isInvitational)
                      BoxyArtPill.type(
                        label: 'Invitational',
                      ),
                    if (event.isMultiDay == true)
                      BoxyArtPill.type(
                        label: 'Multi-day',
                      ),
                    _buildStatusBadge(context),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = event.displayStatus;
    
    String statusText;
    Color statusColor;
    
    if (status == EventStatus.draft) {
      statusText = 'Draft';
      statusColor = Colors.orange;
    } else if (status == EventStatus.inPlay) {
      statusText = 'Live';
      statusColor = Colors.blue;
    } else if (status == EventStatus.suspended) {
      statusText = 'Suspended';
      statusColor = Colors.deepOrange;
    } else if (status == EventStatus.cancelled) {
      statusText = 'Cancelled';
      statusColor = Colors.red;
    } else if (status == EventStatus.completed) {
      statusText = 'Completed';
      statusColor = Colors.grey;
    } else {
      // Published = Open for members
      statusText = 'Published';
      statusColor = const Color(0xFF27AE60);
    }

    return BoxyArtPill.status(
      label: statusText,
      color: statusColor,
    );
  }

  Widget _buildGameTypePill(BuildContext context, WidgetRef ref, String eventId) {
    final compAsync = ref.watch(competitionDetailProvider(eventId));

    return compAsync.when(
      data: (comp) {
        if (comp == null) return const SizedBox.shrink();
        final gameName = comp.rules.gameName;
        
        return BoxyArtPill.format(
          label: gameName,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}


