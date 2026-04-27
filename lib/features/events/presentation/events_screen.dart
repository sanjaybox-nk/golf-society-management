import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

/// Unified events list screen for both member and admin contexts.
///
/// When [isAdminContext] is `false` (default), shows published/completed events
/// with member-facing registration pills and navigates to `/events/:id`.
///
/// When [isAdminContext] is `true`, shows all statuses including drafts,
/// renders admin status badges with swipe-to-delete, and navigates to the
/// admin event detail route.
class EventsScreen extends ConsumerWidget {
  final bool isAdminContext;

  const EventsScreen({super.key, this.isAdminContext = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Data: pick correct providers based on context ---
    final filter = isAdminContext
        ? ref.watch(adminEventFilterProvider)
        : ref.watch(eventFilterProvider);
    final upcomingSeasonAsync = isAdminContext
        ? ref.watch(adminUpcomingSeasonEventsProvider)
        : ref.watch(upcomingSeasonEventsProvider);
    final pastSeasonAsync = isAdminContext
        ? ref.watch(adminPastSeasonEventsProvider)
        : ref.watch(pastSeasonEventsProvider);
    final socialAsync = isAdminContext
        ? ref.watch(adminSocialEventsProvider)
        : ref.watch(socialEventsProvider);

    // --- Subtitle: dynamic season name for members, static for admin ---
    final String subtitle;
    if (isAdminContext) {
      subtitle = 'Society events and calendar';
    } else {
      final activeSeasonAsync = ref.watch(activeSeasonProvider);
      final seasonName = activeSeasonAsync.when(
        data: (s) => s?.name ?? '',
        loading: () => '',
        error: (_, __) => '',
      );
      subtitle = seasonName.isNotEmpty ? seasonName : 'All Seasons';
    }

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Events',
      subtitle: subtitle,
      topPill: isAdminContext ? BoxyArtPill.committee(label: 'ADMIN') : null,
      showAdminShortcut: false,
      showBack: false,
      leading: isAdminContext
          ? Center(
              child: BoxyArtGlassIconButton(
                icon: Icons.home_rounded,
                onPressed: () => context.go('/home'),
                tooltip: 'App Home',
              ),
            )
          : null,
      actions: isAdminContext
          ? [
              BoxyArtGlassIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Create Event',
                onPressed: () => context.push('/admin/events/new'),
              ),
              const SizedBox(width: AppSpacing.sm),
            ]
          : [],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      slivers: [
        // Filter Bar
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<EventFilter>(
            tabs: const [
              ModernFilterTab(label: 'Events', value: EventFilter.season, icon: Icons.sports_golf_rounded),
              ModernFilterTab(label: 'Social', value: EventFilter.social, icon: Icons.groups_rounded),
            ],
            selectedValue: filter,
            onTabSelected: (val) => isAdminContext
                ? ref.read(adminEventFilterProvider.notifier).update(val)
                : ref.read(eventFilterProvider.notifier).update(val),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            isExpanded: true,
          ),
        ),

        // Spacing below filter bar
        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
        ),

        // Season tab
        if (filter == EventFilter.season) ...[
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Upcoming Events', isPeeking: true),
            ),
          ),
          _buildEventList(
            context, ref, upcomingSeasonAsync, 'Upcoming',
            allowHighlight: !isAdminContext,
          ),

          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Past Events', isPeeking: false),
            ),
          ),
          _buildEventList(context, ref, pastSeasonAsync, 'Past'),
        ],

        // Social tab
        if (filter == EventFilter.social) ...[
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Social Events', isPeeking: true),
            ),
          ),
          _buildEventList(
            context, ref, socialAsync, 'Social',
            allowHighlight: !isAdminContext,
          ),
        ],

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        ),
      ],
    );
  }

  Widget _buildEventList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<GolfEvent>> asyncValue,
    String type, {
    bool allowHighlight = false,
  }) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return asyncValue.when(
      data: (events) {
        if (events.isEmpty) {
          final String title = 'No $type Events';
          final String message = type == 'Upcoming'
              ? 'Your society fairways are quiet. Check back soon for the next fixture.'
              : type == 'Past'
                  ? 'No past events recorded for this season yet.'
                  : 'No social gatherings or clubhouse meets planned.';

          final IconData icon = type == 'Past'
              ? Icons.history_toggle_off_rounded
              : type == 'Social'
                  ? Icons.emoji_events_outlined
                  : Icons.event_note_rounded;

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(title: title, message: message, icon: icon),
            ),
          );
        }

        // Featured event highlight (member view only)
        String? featuredEventId;
        if (allowHighlight && events.isNotEmpty) {
          final liveEvent = events.firstWhereOrNull(
            (e) => e.status == EventStatus.inPlay && e.occursToday,
          );
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
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard),
                  ),
                  child: isAdminContext
                      ? _AdminEventRow(event: event)
                      : _EventRow(event: event, isHighlighted: isHighlighted),
                );
              },
              childCount: events.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
    );
  }
}

// ---------------------------------------------------------------------------
// Member card row — registration status pill, highlight support
// ---------------------------------------------------------------------------

class _EventRow extends ConsumerWidget {
  final GolfEvent event;
  final bool isHighlighted;

  const _EventRow({required this.event, this.isHighlighted = false});

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
        hasHorizontalMargin: false,
        isLegend: true,
      );
    } else if (event.isRegistrationOpen) {
      final isFull = event.maxParticipants != null &&
          event.playingCount >= event.maxParticipants!;
      statusPill = BoxyArtPill.status(
        label: isFull ? 'Register (Waitlist)' : 'Register Now',
        color: isFull ? AppColors.coral500 : primary,
        isAction: true,
        hasHorizontalMargin: false,
      );
    } else {
      final isPast = DateTime.now().isAfter(event.date);
      if (!isPast) {
        statusPill = BoxyArtPill.status(
          label: 'Registration Closed',
          color: AppColors.dark400,
          hasHorizontalMargin: false,
          isLegend: true,
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin card row — status badge + picker, swipe-to-delete, admin navigation
// ---------------------------------------------------------------------------

class _AdminEventRow extends ConsumerWidget {
  final GolfEvent event;

  const _AdminEventRow({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: AppShapes.md,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.x2l),
        child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Event?',
          message: 'Are you sure you want to delete "${event.title}"?',
          confirmText: 'Delete',
          isDangerous: true,
        );
      },
      onDismissed: (direction) {
        ref.read(eventsRepositoryProvider).deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${event.title}"')),
        );
      },
      child: BoxyArtEventCard(
        event: event,
        onTap: () => context.pushNamed(
          'admin-event-details',
          pathParameters: {'id': event.id},
        ),
        gameTypePill: _buildGameTypePill(context, ref, event.id),
        statusPill: GestureDetector(
          onTap: () => _showStatusSelector(context, ref, event),
          child: _buildStatusBadge(context, event),
        ),
      ),
    );
  }

  Widget _buildGameTypePill(BuildContext context, WidgetRef ref, String eventId) {
    final compAsync = ref.watch(competitionDetailProvider(eventId));
    return compAsync.when(
      data: (comp) {
        if (comp == null) return const SizedBox.shrink();
        return BoxyArtPill.format(label: comp.rules.gameName);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GolfEvent event) {
    final status = event.displayStatus;
    final Color statusColor;
    final String statusText;

    switch (status) {
      case EventStatus.draft:
        statusText = 'Draft';
        statusColor = AppColors.amber500;
        break;
      case EventStatus.inPlay:
        statusText = 'Live';
        statusColor = AppColors.teamA;
        break;
      case EventStatus.suspended:
        statusText = 'Suspended';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = AppColors.coral500;
        break;
      case EventStatus.completed:
        statusText = 'Completed';
        statusColor = AppColors.textSecondary;
        break;
      default:
        statusText = 'Published';
        statusColor = AppColors.lime500;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BoxyArtPill.status(label: statusText, color: statusColor),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: statusColor.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  void _showStatusSelector(BuildContext context, WidgetRef ref, GolfEvent event) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Change Event Status',
      isScrollControlled: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: EventStatus.values.map((s) {
          final isSelected = event.status == s;
          String label = toTitleCase(s.name);
          if (s == EventStatus.inPlay) label = 'Live';

          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: BoxyArtIconBadge(
                  icon: _getStatusIcon(s),
                  color: isSelected ? Theme.of(context).primaryColor : AppColors.dark600,
                  showFill: false,
                  showBorder: isSelected,
                  borderColor: isSelected ? Theme.of(context).primaryColor : AppColors.dark300,
                  iconColor: isSelected ? Theme.of(context).primaryColor : AppColors.dark600,
                ),
                title: Text(
                  label.toUpperCase(),
                  style: AppTypography.micro.copyWith(
                    fontWeight: isSelected ? AppTypography.weightExtraBold : AppTypography.weightBold,
                    color: isSelected ? Theme.of(context).primaryColor : AppColors.dark600,
                    letterSpacing: 1.0,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 22)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(status: s));
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getStatusIcon(EventStatus status) {
    switch (status) {
      case EventStatus.draft:      return Icons.edit_note_rounded;
      case EventStatus.published:  return Icons.public_rounded;
      case EventStatus.inPlay:     return Icons.play_circle_outline_rounded;
      case EventStatus.suspended:  return Icons.pause_circle_outline_rounded;
      case EventStatus.completed:  return Icons.check_circle_outline_rounded;
      case EventStatus.cancelled:  return Icons.cancel_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
