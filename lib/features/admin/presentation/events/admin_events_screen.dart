import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../events/presentation/events_provider.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/utils/string_utils.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminEventFilterProvider);
    final upcomingSeasonAsync = ref.watch(adminUpcomingSeasonEventsProvider);
    final pastSeasonAsync = ref.watch(adminPastSeasonEventsProvider);
    final socialAsync = ref.watch(adminSocialEventsProvider);
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Events',
      subtitle: 'Society events and calendar',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: false,
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
          tooltip: 'App Home',
        ),
      ),
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          tooltip: 'Create Event',
          onPressed: () => context.push('/admin/events/new'),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      slivers: [
        // Filter Bar (Harmonized with main EventsScreen)
        SliverToBoxAdapter(
          child: ModernUnderlinedFilterBar<EventFilter>(
            tabs: const [
              ModernFilterTab(label: 'Events', value: EventFilter.season),
              ModernFilterTab(label: 'Social', value: EventFilter.social),
            ],
            selectedValue: filter,
            onTabSelected: (val) => ref.read(adminEventFilterProvider.notifier).update(val),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            isExpanded: true,
          ),
        ),

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
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtSectionTitle(
                title: 'Past Events',
                isPeeking: false,
              ),
            ),
          ),
          _buildEventList(context, ref, pastSeasonAsync, 'Past'),
        ],

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

        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        ),
      ],
    );
  }

  Widget _buildEventList(BuildContext context, WidgetRef ref, AsyncValue<List<GolfEvent>> asyncValue, String type) {
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
              child: BoxyArtEmptyCard(
                title: title,
                message: message,
                icon: icon,
              ),
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
                  child: _AdminEventRow(event: events[index]),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${event.title}"')));
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
        final gameName = comp.rules.gameName;

        return BoxyArtPill.format(
          label: gameName,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GolfEvent event) {
    final status = event.displayStatus;
    Color statusColor;
    String statusText;

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
        BoxyArtPill.status(
          label: statusText,
          color: statusColor,
        ),
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
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: isSelected ? AppTypography.weightExtraBold : AppTypography.weightSemibold,
                    color: isSelected ? Theme.of(context).primaryColor : AppColors.dark600,
                    height: 1.0, // Tighter for UI lists
                  ),
                ),
                trailing: isSelected 
                  ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor, size: 22) 
                  : null,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(eventsRepositoryProvider).updateEvent(
                    event.copyWith(status: s),
                  );
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
      case EventStatus.draft: return Icons.edit_note_rounded;
      case EventStatus.published: return Icons.public_rounded;
      case EventStatus.inPlay: return Icons.play_circle_outline_rounded;
      case EventStatus.suspended: return Icons.pause_circle_outline_rounded;
      case EventStatus.completed: return Icons.check_circle_outline_rounded;
      case EventStatus.cancelled: return Icons.cancel_outlined;
    }
  }
}
