import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/widgets/event_structural_cards.dart';

class EventBroadcastScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventBroadcastScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventBroadcastScreen> createState() => _EventBroadcastScreenState();
}

class _EventBroadcastScreenState extends ConsumerState<EventBroadcastScreen> {
  void _onReorder(GolfEvent event, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Get the visual list that the user is actually reordering
    final items = event.effectiveFeedItems;
    items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    
    // Perform swap on visual items
    final EventFeedItem item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Build map of updated sort orders and apply to the sorted visual list
    // By saving `items` instead of just updating `event.feedItems`, 
    // we ensure synthesized system blocks (like Headline, Registration) 
    // are permanently saved to the DB with their user-defined layout positions.
    final updatedFeedItems = items.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    final updatedEvent = event.copyWith(feedItems: updatedFeedItems);
    await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    return HeadlessScaffold(
      title: 'Event CMS',
      subtitle: 'Updates & Broadcasts',
      useScaffold: true,
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        eventAsync.when(
          data: (event) {
            final items = event.effectiveFeedItems;
            items.sort((a, b) {
              if (a.isPinned && !b.isPinned) return -1;
              if (!a.isPinned && b.isPinned) return 1;
              return a.sortOrder.compareTo(b.sortOrder);
            });
            
            return SliverPadding(
              padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100, top: AppSpacing.xl),
              sliver: items.isEmpty ? _buildEmptyState() : _buildReorderableList(event, items),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.x2l),
                decoration: BoxDecoration(
                  color: AppColors.coral400.withValues(alpha: AppColors.opacityLow),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_rounded, size: AppShapes.iconHero, color: AppColors.coral400),
              ),
              const SizedBox(height: AppSpacing.x2l),
              const Text(
                'No Posts Yet',
                style: TextStyle(fontSize: AppTypography.sizeDisplaySection, fontWeight: AppTypography.weightBold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'To create a new post, visit the Admin Home and use the "Broadcast" trigger.',
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
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        onReorder: (oldIndex, newIndex) => _onReorder(event, oldIndex, newIndex),
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.45),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            key: ValueKey(item.id),
            margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (item.type == FeedItemType.flash || item.type == FeedItemType.newsletter) {
                      context.push('/admin/events/manage/${event.id}/broadcast/edit/${item.id}', extra: item);
                    }
                  },
                  // Render the actual WYSIWYG card
                  child: AbsorbPointer( // Prevent clicks on internal elements from swallowing the tap
                    child: _buildAdminFeedItemCard(context, item, event),
                  ),
                ),
                
                // Top Right Action Buttons Overlaid
                Positioned(
                  top: item.type == FeedItemType.flash ? 12 : 20,
                  right: item.type == FeedItemType.flash ? 12 : 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!item.isPublished) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.amber500.withValues(alpha: AppColors.opacityMedium),
                            borderRadius: AppShapes.xs,
                          ),
                          child: const Text('DRAFT', style: TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.amber500)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (item.isPinned) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.teamA.withValues(alpha: AppColors.opacityLow),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.push_pin_rounded, size: AppShapes.iconSm, color: AppColors.teamA),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      ReorderableDragStartListener(
                        index: index,
                        child: const _DragHandle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminFeedItemCard(BuildContext context, EventFeedItem item, GolfEvent event) {
    if (item.type == FeedItemType.headline) {
      return EventHeadlineCard(event: event);
    } else if (item.type == FeedItemType.podium) {
      return EventPodiumCard(event: event, isManagement: true);
    } else if (item.type == FeedItemType.registration) {
      return EventRegistrationCard(event: event, isManagement: true);
    } else if (item.type == FeedItemType.gallerySnippet) {
      return EventGalleryCard(event: event, isManagement: true);
    } else if (item.type == FeedItemType.flash) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
          borderRadius: AppShapes.lg,
          border: Border.all(color: AppColors.amber500.withValues(alpha: AppColors.opacityMuted)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.campaign_rounded, color: AppColors.amber500),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 140), // Room for draft + pin + drag handle
                child: Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: AppTypography.sizeButton,
                    fontWeight: AppTypography.weightExtraBold,
                    color: AppColors.amber500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item.type == FeedItemType.newsletter) {
      QuillController? quillController;
      try {
        if (item.content.isNotEmpty) {
          quillController = QuillController(
            document: Document.fromJson(jsonDecode(item.content)),
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          );
        }
      } catch (_) {}

      return BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.title != null && item.title!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(right: 140), // Room for draft + pin + drag handle
                child: Text(
                  item.title!,
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: AppTypography.sizeDisplaySection,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppTheme.cardSpacing),
            ],
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: AppShapes.lg,
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Theme.of(context).cardColor,
                    child: const Icon(Icons.image, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.cardSpacing),
            ],
            if (quillController != null)
              QuillEditor.basic(
                controller: quillController,
                config: const QuillEditorConfig(
                  padding: EdgeInsets.zero,
                  autoFocus: false,
                  expands: false,
                ),
              ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppShapes.sm,
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: const Icon(Icons.drag_indicator_rounded, color: AppColors.textSecondary, size: AppShapes.iconMd),
    );
  }
}
