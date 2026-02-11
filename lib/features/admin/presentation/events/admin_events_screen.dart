import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../events/presentation/events_provider.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';


class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final now = DateTime.now();
          final upcoming = events.where((e) => e.date.isAfter(now)).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          final past = events.where((e) => e.date.isBefore(now)).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  'Manage Events',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.home_rounded, size: 24),
                  onPressed: () => context.go('/home'),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    onPressed: () => context.push('/admin/settings'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              
              // Upcoming Section
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtSectionTitle(title: 'Upcoming Events'),
                ),
              ),
              if (upcoming.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No upcoming events scheduled')),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildEventRow(context, ref, upcoming[index]),
                      ),
                      childCount: upcoming.length,
                    ),
                  ),
                ),

              // Past Section
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtSectionTitle(title: 'Past Events'),
                ),
              ),
              if (past.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No past events this season')),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildEventRow(context, ref, past[index]),
                      ),
                      childCount: past.length,
                    ),
                  ),
                ),

              // Bottom padding for FAB
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black, // Assuming primary is bright/gold
      ),
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
          onTap: () => context.push('/events/${event.id}?preview=true'),
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
                        _StatusChip(status: event.status),
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
    final isDraft = status == EventStatus.draft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDraft ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDraft ? Colors.orange : Colors.green,
          width: 0.5,
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: isDraft ? Colors.orange : Colors.green,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

