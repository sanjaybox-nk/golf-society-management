import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../events/presentation/events_provider.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import 'package:golf_society/domain/models/competition.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return HeadlessScaffold(
      title: 'Events',
      subtitle: 'Society events and calendar',
      showBack: false,
      leading: Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.home_rounded,
          onPressed: () => context.go('/home'),
          tooltip: 'App Home',
        ),
      ),
      titleSuffix: BoxyArtGlassIconButton(
        icon: Icons.add_rounded,
        tooltip: 'Create Event',
        onPressed: () => context.push('/admin/events/new'),
      ),
      slivers: [
        eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const SliverFillRemaining(
                child: BoxyArtEmptyState(
                  title: 'No Events Found',
                  message: 'Your society hasn\'t created any events yet. Start by creating your first event.',
                  icon: Icons.event_busy_rounded,
                ),
              );
            }

            final now = DateTime.now();
            final upcoming = events.where((e) => e.date.isAfter(now)).toList()
              ..sort((a, b) => a.date.compareTo(b.date));
            final past = events.where((e) => e.date.isBefore(now)).toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            return SliverList(
              delegate: SliverChildListDelegate([
                // Upcoming Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
                  child: BoxyArtSectionTitle(title: 'Upcoming Events', ),
                ),
                if (upcoming.isEmpty)
                  const BoxyArtEmptyState(
                    title: 'No Upcoming Events',
                    message: 'There are no future events scheduled on the calendar.',
                    icon: Icons.calendar_today_rounded,
                    isCompact: true,
                  )
                else
                  ...upcoming.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg, left: AppSpacing.xl, right: AppSpacing.xl),
                    child: _AdminEventRow(event: e),
                  )),

                // Past Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.x3l, AppSpacing.xl, AppSpacing.md),
                  child: BoxyArtSectionTitle(title: 'Past Events', ),
                ),
                if (past.isEmpty)
                  const BoxyArtEmptyState(
                    title: 'No Past Events',
                    message: 'No events have been completed in this season archive.',
                    icon: Icons.history_rounded,
                    isCompact: true,
                  )
                else
                  ...past.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg, left: AppSpacing.xl, right: AppSpacing.xl),
                    child: _AdminEventRow(event: e),
                  )),

                const SizedBox(height: 120),
              ]),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SliverFillRemaining(
            child: BoxyArtEmptyState(
              title: 'Unexpected Error',
              message: err.toString(),
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ),
      ],
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: AppTypography.weightBold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              child: const Text('Delete', style: TextStyle(color: AppColors.coral500, fontWeight: AppTypography.weightBold)),
            ),
          ],
        );
      },
      onDismissed: (direction) {
        ref.read(eventsRepositoryProvider).deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${event.title}"')));
      },
      child: BoxyArtEventCard(
        event: event,
        onTap: () => context.go('/admin/events/manage/${Uri.encodeComponent(event.id)}/event'),
        gameTypePill: _buildGameTypePill(context, ref, event.id),
        statusPill: _buildStatusBadge(context, event),
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

    return BoxyArtPill.status(
      label: statusText,
      color: statusColor,
    );
  }
}
