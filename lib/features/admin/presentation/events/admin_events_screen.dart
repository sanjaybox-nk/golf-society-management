import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../../../events/presentation/tabs/event_user_details_tab.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../models/competition.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return HeadlessScaffold(
      title: 'Events',
      showBack: false,
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          tooltip: 'Create Event',
          onPressed: () => context.push('/admin/events/new'),
        ),
      ],
      slivers: [
        eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text('No events found.')),
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
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: BoxyArtSectionTitle(title: 'Upcoming Events', padding: EdgeInsets.zero),
                ),
                if (upcoming.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No upcoming events scheduled')),
                  )
                else
                  ...upcoming.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    child: _buildEventRow(context, ref, e),
                  )),

                // Past Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 12),
                  child: BoxyArtSectionTitle(title: 'Past Events', padding: EdgeInsets.zero),
                ),
                if (past.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No past events this season')),
                  )
                else
                  ...past.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
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
            child: Center(child: Text('Error: $err')),
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
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Event?',
          message: 'Are you sure you want to delete "${event.title}"?',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
      onDismissed: (direction) {
        ref.read(eventsRepositoryProvider).deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${event.title}"')));
      },
      child: ModernCard(
        onTap: () => _showEventDetailsDialog(context, ref, event),
        padding: const EdgeInsets.all(14),
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
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 6),
                  
                  // Location Row
                  _buildIconLabel(
                    context, 
                    Icons.location_on_rounded, 
                    event.courseName ?? 'TBA',
                    Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 4),
                  
                  // Time Row
                  _buildIconLabel(
                    context, 
                    Icons.access_time_filled_rounded, 
                    'Reg: ${DateFormat('h:mm a').format(event.regTime ?? event.date)}',
                    Colors.grey.shade600,
                    isRegistration: true,
                  ),

                  // Bottom Pill Row
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGameTypePill(context, ref, event.id),
                      if (event.isInvitational) ...[
                        const SizedBox(width: 8),
                        _buildInvitationalBadge(),
                      ],
                      const Spacer(),
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

  void _showEventDetailsDialog(BuildContext context, WidgetRef ref, GolfEvent event) {
    final config = ref.read(themeControllerProvider);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return EventDetailsContent(
          event: event,
          currencySymbol: config.currencySymbol,
          isPreview: true,
          onCancel: () => Navigator.pop(dialogContext),
          onEdit: () {
            Navigator.pop(dialogContext);
            context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/event/edit', extra: event);
          },
          onStatusChanged: (newStatus) {
            ref.read(eventsRepositoryProvider).updateEvent(
              event.copyWith(status: newStatus),
            );
          },
          bottomNavigationBar: ModernSubTabBar(
            selectedIndex: 0,
            borderColor: Color(config.primaryColor),
            onSelected: (index) {
              Navigator.pop(dialogContext);
              if (index == 0) return;
              
              final routes = [
                '/admin/events/manage/${Uri.encodeComponent(event.id)}/event',
                '/admin/events/manage/${Uri.encodeComponent(event.id)}/registrations',
                '/admin/events/manage/${Uri.encodeComponent(event.id)}/grouping',
                '/admin/events/manage/${Uri.encodeComponent(event.id)}/scores',
                '/admin/events/manage/${Uri.encodeComponent(event.id)}/reports',
              ];
              context.push(routes[index], extra: event);
            },
            items: const [
              ModernSubTabItem(icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded, label: 'Info'),
              ModernSubTabItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Registration'),
              ModernSubTabItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_sharp, label: 'Grouping'),
              ModernSubTabItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Scores'),
              ModernSubTabItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
            ],
          ),
        );
      },
    );
  }


  Widget _buildInvitationalBadge() {
    return BoxyArtPill(
      label: toTitleCase('Invitational'),
      color: Colors.purple,
    );
  }

  Widget _buildIconLabel(BuildContext context, IconData icon, String label, Color color, {bool isRegistration = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 13,
              fontWeight: isRegistration ? FontWeight.w900 : FontWeight.w600,
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
        statusColor = Colors.orange;
        break;
      case EventStatus.inPlay:
        statusText = 'LIVE';
        statusColor = Colors.blue;
        break;
      case EventStatus.suspended:
        statusText = 'SUSPENDED';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = Colors.red;
        break;
      case EventStatus.completed:
        statusText = 'COMPLETED';
        statusColor = Colors.grey;
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

