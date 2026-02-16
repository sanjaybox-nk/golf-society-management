import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../../../events/presentation/tabs/event_user_details_tab.dart';
import '../../../../core/theme/theme_controller.dart';


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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
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
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Event?',
          message: 'Are you sure you want to delete "${event.title}"?',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
      onDismissed: (direction) {
        ref.read(eventsRepositoryProvider).deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${event.title}"')),
        );
      },
      child: ModernCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
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
                    context.push('/admin/events/manage/${event.id}/event/edit', extra: event);
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
                      if (index == 0) return; // Already on Info
                      
                      final routes = [
                        '/admin/events/manage/${event.id}/event',
                        '/admin/events/manage/${event.id}/registrations',
                        '/admin/events/manage/${event.id}/grouping',
                        '/admin/events/manage/${event.id}/scores',
                        '/admin/events/manage/${event.id}/reports',
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
          },
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              _buildModernDateBadge(context, event.date),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusChip(status: event.displayStatus),
                        const SizedBox(width: 8),
                        if (event.registrations.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 10, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.registrations.length}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.courseName ?? 'TBA',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildActionIcon(
                context,
                Icons.people_outline_rounded,
                () => context.push(
                  '/admin/events/manage/${event.id}/registrations',
                  extra: event,
                ),
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).dividerColor),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildModernDateBadge(BuildContext context, DateTime date) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: 56,
      height: 64,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            DateFormat('d').format(date),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? Theme.of(context).primaryColor),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status.name.toUpperCase();

    switch (status) {
      case EventStatus.draft:
        color = Colors.orange;
        break;
      case EventStatus.published:
        color = const Color(0xFF27AE60);
        label = 'PUBLISHED';
        break;
      case EventStatus.inPlay:
        color = Colors.blue;
        label = 'LIVE';
        break;
      case EventStatus.suspended:
        color = Colors.deepOrange;
        break;
      case EventStatus.completed:
        color = Colors.grey;
        break;
      case EventStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

