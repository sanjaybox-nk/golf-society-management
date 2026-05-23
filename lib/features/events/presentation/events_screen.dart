import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/competitions/presentation/season_standings_screen.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/utils/date_utils.dart' as utils;
import 'package:golf_society/features/competitions/presentation/standings/season_leaderboard_configs_provider.dart';

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
    final upcomingAsync = isAdminContext
        ? ref.watch(adminUpcomingEventsProvider)
        : ref.watch(upcomingEventsProvider);
    final pastAsync = isAdminContext
        ? ref.watch(adminPastEventsProvider)
        : ref.watch(pastEventsProvider);

    // --- Subtitle: dynamic season name for members, static for admin ---
    final String subtitle;
    if (isAdminContext) {
      subtitle = 'Society events and calendar';
    } else {
      final activeSeasonAsync = ref.watch(activeSeasonProvider);
      final seasonName = activeSeasonAsync.when(
        data: (s) => s?.name ?? '',
        loading: () => '',
        error: (e, s) => '',
      );
      subtitle = seasonName.isNotEmpty ? seasonName : 'All Seasons';
    }

    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Golf Events',
      subtitle: subtitle,
      topPill: isAdminContext ? BoxyArtIndicator.committee(label: 'ADMIN') : null,
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
          child: BoxyArtTabBar<EventFilter>(
            tabs: const [
              ModernFilterTab(label: 'Golf Events', value: EventFilter.season),
              ModernFilterTab(label: 'Leaderboards', value: EventFilter.leaderboard),
            ],
            selectedValue: filter,
            onTabSelected: (val) => isAdminContext
                ? ref.read(adminEventFilterProvider.notifier).update(val)
                : ref.read(eventFilterProvider.notifier).update(val),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
        ),

        // Golf Events tab
        if (filter == EventFilter.season) ...[
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(title: 'Upcoming Events', isPeeking: true),
            ),
          ),
          _buildEventList(
            context, ref, upcomingAsync, 'Upcoming',
            allowHighlight: !isAdminContext,
          ),
          if (pastAsync.value?.isNotEmpty == true) ...[
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: BoxyArtSectionTitle(title: 'Past Events', followsCard: true),
              ),
            ),
            _buildEventList(context, ref, pastAsync, 'Past'),
          ],
        ],

        // Leaderboard tab
        if (filter == EventFilter.leaderboard)
          _buildLeaderboardTab(context, ref),

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(effectiveUserProvider);
    final seasonAsync = ref.watch(activeSeasonProvider);

    return seasonAsync.when(
      data: (season) {
        if (season == null) {
          return const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'No Leaderboards Assigned',
                message: 'No leaderboards have been assigned to the current season.',
                icon: Icons.leaderboard_rounded,
              ),
            ),
          );
        }
        final leaderboardsAsync = ref.watch(seasonLeaderboardConfigsProvider(season.id));
        final leaderboards = leaderboardsAsync.value ?? [];

        if (leaderboardsAsync.isLoading) {
          return const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
            sliver: SliverToBoxAdapter(child: BoxyArtLoadingCard(useCard: true)),
          );
        }

        if (leaderboards.isEmpty) {
          return const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'No Leaderboards',
                message: 'No leaderboards have been assigned to this season yet.',
                icon: Icons.leaderboard_rounded,
              ),
            ),
          );
        }
        final groups = groupLeaderboards(leaderboards);
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),
              for (final group in groups) ...[
                BoxyArtSectionTitle(title: group.label, isPeeking: true),
                for (final config in group.configs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.cardToCard),
                    child: LeaderboardHubCard(
                      seasonId: season.id,
                      config: config,
                      currentUserId: currentUser.id,
                    ),
                  ),
              ],
            ]),
          ),
        );
      },
      loading: () => const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
        sliver: SliverToBoxAdapter(child: BoxyArtLoadingCard(useCard: true)),
      ),
      error: (e, s) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverToBoxAdapter(
          child: BoxyArtEmptyCard(
            title: 'Leaderboard Error',
            message: e.toString(),
            icon: Icons.error_outline_rounded,
          ),
        ),
      ),
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
      statusPill = BoxyArtIndicator.status(
        label: 'Confirmed',
        color: AppColors.lime600,
        hasHorizontalMargin: false,
        isLegend: true,
      );
    } else if (event.isRegistrationOpen) {
      final isFull = event.maxParticipants != null &&
          event.playingCount >= event.maxParticipants!;
      statusPill = BoxyArtIndicator.status(
        label: isFull ? 'Register (Waitlist)' : 'Register Now',
        color: isFull ? AppColors.coral500 : primary,
        isAction: true,
        hasHorizontalMargin: false,
      );
    } else {
      final isPast = utils.DateUtils.isPastEvent(event);
      if (!isPast) {
        statusPill = BoxyArtIndicator.status(
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
      gameTypePill: _gameTypePill(context, ref, event.id),
      statusPill: statusPill,
      isHighlighted: isHighlighted,
      showSponsorStrip: true,
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
        gameTypePill: _gameTypePill(context, ref, event.id),
        statusPill: _buildStatusBadge(context, ref, event),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, WidgetRef ref, GolfEvent event) {
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

    final isCompleted = status == EventStatus.completed;
    return BoxyArtIndicator(
      label: statusText,
      dotColor: statusColor,
      showBackground: true,
      hasHorizontalMargin: false,
      actionIcon: isCompleted ? Icons.lock_open_rounded : Icons.keyboard_arrow_down_rounded,
      onTap: isCompleted
          ? () => _confirmReopen(context, ref, event)
          : () => _showStatusSelector(context, ref, event),
    );
  }

  Future<void> _confirmReopen(BuildContext context, WidgetRef ref, GolfEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => BoxyArtDialog(
        title: 'Reopen Event?',
        message: 'This will unlock scoring and set the event back to Live. Use this to correct errors after close.',
        confirmText: 'Reopen',
        cancelText: 'Cancel',
        isDangerous: true,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
    if (confirmed == true) {
      await ref.read(eventsRepositoryProvider).updateEvent(
        event.copyWith(status: EventStatus.inPlay, isScoringLocked: false),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event reopened')),
        );
      }
    }
  }

  void _showStatusSelector(BuildContext context, WidgetRef ref, GolfEvent event) {
    BoxyArtBottomSheet.show(
      context: context,
      title: 'Change Event Status',
      child: Builder(
        builder: (context) {
          final spacing = Theme.of(context).extension<AppSpacingTokens>();
          final cardGap = spacing?.cardToCard ?? AppSpacing.atomic;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: EventStatus.values.where((s) => s != EventStatus.completed).map((s) {
              final isSelected = event.status == s;
              final label = s == EventStatus.inPlay ? 'Live' : toTitleCase(s.name);
              return BoxyArtSelectCard(
                icon: _getStatusIcon(s),
                label: label,
                isSelected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(status: s));
                },
                cardGap: cardGap,
              );
            }).toList(),
          );
        },
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

Widget _gameTypePill(BuildContext context, WidgetRef ref, String eventId) {
  final compAsync = ref.watch(competitionDetailProvider(eventId));
  return compAsync.when(
    data: (comp) {
      if (comp == null) return const SizedBox.shrink();
      return Text(
        toTitleCase(comp.rules.gameName),
        style: AppTypography.label.copyWith(
          fontSize: 11.0,
          color: AppColors.dark500,
          fontWeight: AppTypography.weightRegular,
          letterSpacing: -0.2,
        ),
      );
    },
    loading: () => const SizedBox.shrink(),
    error: (e, s) => const SizedBox.shrink(),
  );
}
