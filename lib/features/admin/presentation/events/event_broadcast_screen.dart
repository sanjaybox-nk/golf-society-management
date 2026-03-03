import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/data/events_repository.dart';

class EventBroadcastScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventBroadcastScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventBroadcastScreen> createState() => _EventBroadcastScreenState();
}

class _EventBroadcastScreenState extends ConsumerState<EventBroadcastScreen> {
  bool _isSaving = false;

  void _onReorder(GolfEvent event, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Create mutable list
    final List<EventFeedItem> items = List.from(event.feedItems);
    
    // Perform swap
    final EventFeedItem item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update sortOrder for all items based on new index
    final updatedItems = items.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    final updatedEvent = event.copyWith(feedItems: updatedItems);

    setState(() => _isSaving = true);
    await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    return HeadlessScaffold(
      title: 'Event CMS',
      subtitle: 'Manage Updates & Broadcasts',
      useScaffold: true,
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        eventAsync.when(
          data: (event) {
            final items = event.feedItems.sortedBy<num>((e) => e.sortOrder).toList();
            
            return SliverPadding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 20),
              sliver: items.isEmpty ? _buildEmptyState() : _buildReorderableList(event, items),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
        ),
      ],
      floatingActionButton: eventAsync.value != null 
        ? FloatingActionButton.extended(
            onPressed: () => context.push('/admin/events/${widget.eventId}/broadcast/new'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_rounded, size: 48, color: Colors.pink),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Posts Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create newsletters and flash updates to keep members informed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableList(GolfEvent event, List<EventFeedItem> items) {
    return SliverToBoxAdapter(
      child: BoxyArtCard(
        padding: EdgeInsets.zero,
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) => _onReorder(event, oldIndex, newIndex),
          itemBuilder: (context, index) {
            final item = items[index];
            return Material(
              key: ValueKey(item.id),
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    onTap: () => context.push('/admin/events/${event.id}/broadcast/edit/${item.id}', extra: item),
                    leading: _buildTypeIcon(item.type),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? (item.type == FeedItemType.flash ? 'Flash Update' : 'Newsletter'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isPinned) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.push_pin_rounded, size: 16, color: Colors.blue),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (!item.isPublished) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('DRAFT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(DateFormat('MMM d').format(item.createdAt), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const _DragHandle(),
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 64, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeIcon(FeedItemType type) {
    IconData icon;
    Color color;
    switch (type) {
      case FeedItemType.flash:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case FeedItemType.newsletter:
        icon = Icons.article_rounded;
        color = Colors.blue;
        break;
      case FeedItemType.gallery:
        icon = Icons.photo_library_rounded;
        color = Colors.purple;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.drag_indicator_rounded, color: Colors.grey, size: 20),
    );
  }
}
