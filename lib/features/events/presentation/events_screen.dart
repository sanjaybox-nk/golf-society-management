import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        ? seasonName 
        : 'All Seasons';

    return HeadlessScaffold(
      title: 'Events',
      subtitle: subtitle,
      slivers: [
        // Upcoming Section
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'Upcoming Events'),
          ),
        ),
        upcomingAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const SliverToBoxAdapter(
                child: BoxyArtEmptyState(
                  title: 'No Upcoming Events',
                  message: 'There are no upcoming events scheduled for this season yet.',
                  icon: Icons.calendar_today_rounded,
                  isCompact: true,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _EventRow(event: events[index]),
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
          padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.x3l, AppSpacing.xl, AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'Past Events'),
          ),
        ),
        pastAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const SliverToBoxAdapter(
                child: BoxyArtEmptyState(
                  title: 'No Past Events',
                  message: 'You haven\'t participated in any events this season yet.',
                  icon: Icons.history_rounded,
                  isCompact: true,
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _EventRow(event: events[index]),
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

class _EventRow extends ConsumerWidget {
  final GolfEvent event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BoxyArtEventCard(
      event: event,
      onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
      gameTypePill: _buildGameTypePill(context, ref, event.id),
      statusPill: _buildStatusBadge(context, event),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GolfEvent event) {
    final status = event.displayStatus;
    
    String statusText;
    Color statusColor;
    
    if (status == EventStatus.draft) {
      statusText = 'Draft';
      statusColor = AppColors.amber500;
    } else if (status == EventStatus.inPlay) {
      statusText = 'Live';
      statusColor = AppColors.teamA;
    } else if (status == EventStatus.suspended) {
      statusText = 'Suspended';
      statusColor = Colors.deepOrange;
    } else if (status == EventStatus.cancelled) {
      statusText = 'Cancelled';
      statusColor = AppColors.coral500;
    } else if (status == EventStatus.completed) {
      statusText = 'Completed';
      statusColor = AppColors.textSecondary;
    } else {
      // Published = Open for members
      statusText = 'Published';
      statusColor = AppColors.lime500;
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


