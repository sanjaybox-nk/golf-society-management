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
      appBar: BoxyArtAppBar(
        title: 'Manage Events',
        isLarge: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/admin/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/events/new'),
        child: const Icon(Icons.add),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          // Sort by date descending (newest first) for admin
          final sortedEvents = [...events]
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            itemCount: sortedEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
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
                    message:
                        'Are you sure you want to delete "${event.title}"?',
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
                child: BoxyArtFloatingCard(
                  onTap: () => context.push(
                    '/admin/events/manage/${event.id}/event',
                    extra: event,
                  ),
                  child: Row(
                    children: [
                      BoxyArtDateBadge(date: event.date),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                               onTap: () => _toggleEventStatus(context, ref, event),
                               child: _StatusChip(status: event.status),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('MMM d').format(event.date)} @ ${event.courseName ?? 'TBA'}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status and Publish Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
// Status chip moved to main column
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.people_outline, color: Colors.blue, size: 20),
                                tooltip: 'Registrations',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                  onPressed: () => context.push(
                                    '/admin/events/manage/${event.id}/registrations',
                                    extra: event,
                                  ),
                              ),
// Publish button removed (moved to Status Chip)
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }



  void _toggleEventStatus(BuildContext context, WidgetRef ref, GolfEvent event) async {
    final isDraft = event.status == EventStatus.draft;
    final action = isDraft ? 'Publish' : 'Unpublish';
    final message = isDraft
        ? 'This will make "${event.title}" visible to all members. Continue?'
        : 'This will hide "${event.title}" from members. Continue?';
        
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: '$action Event?',
      message: message,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          child: Text(
            action, 
            style: TextStyle(
              color: isDraft ? Colors.green : Colors.orange, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    if (confirm == true) {
      try {
        final newStatus = isDraft ? EventStatus.published : EventStatus.draft;
        await ref.read(eventsRepositoryProvider).updateEvent(
          event.copyWith(status: newStatus),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event ${newStatus.name} 🚀')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: $e')),
          );
        }
      }
    }
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

