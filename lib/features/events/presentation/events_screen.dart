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
                    final isNextMatch = index == 0;
                    return StaggeredEntrance(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                    return StaggeredEntrance(
                      index: index + 5, // Offset stagger for past events
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent, 
      customShadows: isHighlighted && !isDark ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ] : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isHighlighted)
              Container(
                width: 4,
                color: AppColors.lime500,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
          // Date Badge
          BoxyArtDateBadge(
            date: event.date, 
            endDate: event.endDate,
            highlightColor: event.eventType == EventType.social ? AppColors.coral500 : null,
          ),
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
                    fontWeight: AppTypography.weightExtraBold,
                    fontSize: AppTypography.sizeUI,
                  ),
                ),
                if (event.isInvitational || event.isMultiDay) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (event.isInvitational)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 10, color: AppColors.amber500),
                            const SizedBox(width: 4),
                          Text(
                            'INVITATIONAL EVENT',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.amber500,
                              fontWeight: AppTypography.weightBlack,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          ],
                        ),
                      if (event.isMultiDay)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_repeat_rounded, size: 10, color: textSecondary?.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              'MULTI-DAY',
                              style: AppTypography.caption.copyWith(
                                color: textSecondary?.withValues(alpha: 0.6),
                                fontWeight: AppTypography.weightBlack,
                                fontSize: 10,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                
                // Location Row
                Row(
                  children: [
                    BoxyArtIconBadge(icon: Icons.location_on_rounded, color: primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        event.courseName ?? 'TBA',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: AppTypography.sizeLabelStrong,
                          fontWeight: AppTypography.weightSemibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                
                // Time Row
                Row(
                  children: [
                    BoxyArtIconBadge(icon: Icons.access_time_filled_rounded, color: AppColors.dark600),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Registration: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                      style: TextStyle(
                        color: textSecondary?.withValues(alpha: 0.75),
                        fontSize: AppTypography.sizeLabel,
                        fontWeight: AppTypography.weightBold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                
                // Bottom Pill Row
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (event.eventType == EventType.social)
                      BoxyArtPill(
                        label: 'SOCIAL',
                        color: AppColors.coral500,
                      ),
                    _buildGameTypePill(context, ref, event.id),
                    _buildStatusBadge(context),
                  ],
                ),
              ],
            ),
          ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
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


