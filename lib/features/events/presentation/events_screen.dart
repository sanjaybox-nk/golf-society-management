import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingSeasonAsync = ref.watch(upcomingSeasonEventsProvider);
    final pastSeasonAsync = ref.watch(pastSeasonEventsProvider);
    final socialAsync = ref.watch(socialEventsProvider);
    final activeSeasonAsync = ref.watch(activeSeasonProvider);
    final filter = ref.watch(eventFilterProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
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
      showAdminShortcut: false, 
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      slivers: [
        // Filter Bar (Simplified to 2 Tabs - Harmonized with MembersScreen style)
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<EventFilter>(
            tabs: const [
              ModernFilterTab(label: 'Events', value: EventFilter.season),
              ModernFilterTab(label: 'Social', value: EventFilter.social),
            ],
            selectedValue: filter,
            onTabSelected: (val) => ref.read(eventFilterProvider.notifier).update(val),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            isExpanded: true,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel)),

        // 1. Season Events Tab
        if (filter == EventFilter.season) ...[
          // Upcoming Section
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(
                title: 'Upcoming Events',
                isPeeking: true,
              ),
            ),
          ),
          _buildEventList(context, ref, upcomingSeasonAsync, 'Upcoming', allowHighlight: true),

          // Past Section
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(
                title: 'Past Events',
              ),
            ),
          ),
          _buildEventList(context, ref, pastSeasonAsync, 'Past'),
        ],

        // 2. Social Events Tab
        if (filter == EventFilter.social) ...[
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(
                title: 'Social Events',
                isPeeking: true,
              ),
            ),
          ),
          _buildEventList(context, ref, socialAsync, 'Social', allowHighlight: true),
        ],
      ],
    );
  }

  Widget _buildEventList(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<List<GolfEvent>> asyncValue, 
    String type, 
    {bool allowHighlight = false}
  ) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    
    return asyncValue.when(
      data: (events) {
        if (events.isEmpty) {
          return SliverToBoxAdapter(
            child: BoxyArtEmptyState(
              title: 'No $type Events',
              message: 'There are no $type events scheduled yet.',
              icon: type == 'Past' ? Icons.history_rounded : Icons.calendar_today_rounded,
              isCompact: true,
            ),
          );
        }

        // Determine the "Featured" event to highlight in this list
        String? featuredEventId;
        if (allowHighlight && events.isNotEmpty) {
          final liveEvent = events.firstWhereOrNull((e) => e.status == EventStatus.inPlay && e.occursToday);
          featuredEventId = liveEvent?.id ?? events.first.id;
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isLast = index == events.length - 1;
                final event = events[index];
                final isHighlighted = event.id == featuredEventId;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                  child: _EventRow(
                    event: event, 
                    isHighlighted: isHighlighted,
                  ),
                );
              },
              childCount: events.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      ))),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
    );
  }
}

class _EventRow extends ConsumerWidget {
  final GolfEvent event;
  final bool isHighlighted;

  const _EventRow({
    required this.event,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final isRegistered = event.registrations.any((r) => r.memberId == user.id);
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    Widget? statusPill;
    if (isRegistered) {
      statusPill = BoxyArtPill.status(
        label: 'Confirmed',
        color: AppColors.lime600,
      );
    } else if (event.isRegistrationOpen) {
      final isFull = event.maxParticipants != null && 
                    event.playingCount >= event.maxParticipants!;
      statusPill = BoxyArtPill.status(
        label: isFull ? 'Register (Waitlist)' : 'Register Now',
        color: isFull ? AppColors.coral500 : primary,
        isAction: true,
      );
    } else {
      final isPast = DateTime.now().isAfter(event.date);
      if (!isPast) {
        statusPill = BoxyArtPill.status(
          label: 'Registration Closed',
          color: AppColors.dark400,
        );
      }
    }
    return BoxyArtEventCard(
      event: event,
      onTap: () => context.go('/events/${Uri.encodeComponent(event.id)}'),
      gameTypePill: _buildGameTypePill(context, ref, event.id, isHighlighted),
      statusPill: statusPill,
      isHighlighted: isHighlighted,
    );
  }

  Widget _buildGameTypePill(BuildContext context, WidgetRef ref, String eventId, bool isHighlighted) {
    final compAsync = ref.watch(competitionDetailProvider(eventId));

    return compAsync.when(
      data: (comp) {
        if (comp == null) return const SizedBox.shrink();
        final gameName = comp.rules.gameName;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        final color = isHighlighted 
            ? AppColors.pureWhite
            : (isDark ? AppColors.pureWhite : AppColors.dark400);

        return Text(
          toTitleCase(gameName),
          style: AppTypography.label.copyWith(
            fontSize: 11.0,
            color: color,
            fontWeight: AppTypography.weightStrong,
            letterSpacing: -0.2,
          ),
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


