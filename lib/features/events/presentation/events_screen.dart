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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final upcomingSeasonAsync = ref.watch(upcomingSeasonEventsProvider);
    final pastSeasonAsync = ref.watch(pastSeasonEventsProvider);
    final socialAsync = ref.watch(socialEventsProvider);
    final filter = ref.watch(eventFilterProvider);
    
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
      showAdminShortcut: false, // Explicitly removed as per user preference
      slivers: [
        // Filter Bar (Simplified to 2 Tabs - Harmonized with MembersScreen style)
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -16.0),
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
        ),

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
          _buildEventList(context, ref, upcomingSeasonAsync, 'Upcoming'),

          // Past Section
          SliverPadding(
            padding: EdgeInsets.only(top: spacing?.cardToLabel ?? AppSpacing.xl, left: AppSpacing.xl, right: AppSpacing.xl),
            sliver: const SliverToBoxAdapter(
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
          _buildEventList(context, ref, socialAsync, 'Social'),
        ],
      ],
    );
  }

  Widget _buildEventList(BuildContext context, WidgetRef ref, AsyncValue<List<GolfEvent>> asyncValue, String type) {
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
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isLast = index == events.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                  child: _EventRow(event: events[index]),
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

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BoxyArtEventCard(
      event: event,
      onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
      gameTypePill: _buildGameTypePill(context, ref, event.id),
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


