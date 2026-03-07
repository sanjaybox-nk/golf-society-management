import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
      subtitle: 'Manage society events and calendar',
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
                    child: _buildEventRow(context, ref, e),
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
                    child: _buildEventRow(context, ref, e),
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

  Widget _buildEventRow(BuildContext context, WidgetRef ref, GolfEvent event) {
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
      child: BoxyArtCard(
        onTap: () => context.go('/admin/events/manage/${Uri.encodeComponent(event.id)}/home'),
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
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeUI, letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 6),
                  
                  // Location Row
                  _buildIconLabel(
                    context, 
                    Icons.location_on_rounded, 
                    event.courseName ?? 'TBA',
                    Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Time Row
                  _buildIconLabel(
                    context, 
                    Icons.access_time_filled_rounded, 
                    'Reg: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                    AppColors.dark600,
                    isRegistration: true,
                  ),

                  // Bottom Pill Row
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (event.eventType == EventType.social) 
                              BoxyArtPill(label: 'SOCIAL', color: AppColors.coral500),
                            _buildGameTypePill(context, ref, event.id),
                            if (event.isInvitational) _buildInvitationalBadge(),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatusBadge(event),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInvitationalBadge() {
    return BoxyArtPill(
      label: toTitleCase('Invitational'),
      color: AppColors.teamB,
    );
  }

  Widget _buildIconLabel(BuildContext context, IconData icon, String label, Color color, {bool isRegistration = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppColors.opacityLow),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: AppShapes.iconXs, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: AppTypography.sizeLabelStrong,
              fontWeight: isRegistration ? AppTypography.weightBlack : AppTypography.weightSemibold,
              letterSpacing: isRegistration ? 0.8 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGameTypePill(BuildContext context, WidgetRef ref, String eventId) {
    final compAsync = ref.watch(competitionDetailProvider(eventId));

    return compAsync.when(
      data: (comp) {
        if (comp == null) return const SizedBox.shrink();
        final gameName = comp.rules.gameName;
        final color = Theme.of(context).colorScheme.primary;

        return BoxyArtPill(
          label: toTitleCase(gameName),
          color: color,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusBadge(GolfEvent event) {
    final status = event.displayStatus;
    Color statusColor;
    String statusText;

    switch (status) {
      case EventStatus.draft:
        statusText = 'DRAFT';
        statusColor = AppColors.amber500;
        break;
      case EventStatus.inPlay:
        statusText = 'LIVE';
        statusColor = AppColors.teamA;
        break;
      case EventStatus.suspended:
        statusText = 'SUSPENDED';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = AppColors.coral500;
        break;
      case EventStatus.completed:
        statusText = 'COMPLETED';
        statusColor = AppColors.textSecondary;
        break;
      default:
        statusText = 'PUBLISHED';
        statusColor = const Color(0xFF27AE60);
    }

    return BoxyArtPill(
      label: toTitleCase(statusText),
      color: statusColor,
    );
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

