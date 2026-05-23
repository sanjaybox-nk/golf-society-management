import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/widgets/event_structural_cards.dart';

class EventBroadcastScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventBroadcastScreen({super.key, required this.eventId});

  static Widget buildAdminFeedItemCardStatic(BuildContext context, EventFeedItem item, GolfEvent event) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
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
                padding: const EdgeInsets.only(right: 140), 
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
                padding: const EdgeInsets.only(right: 140),
                child: Text(
                  item.title!,
                  style: AppTypography.displayHeading.copyWith(
                    fontSize: AppTypography.sizeDisplaySection,
                  ),
                ),
              ),
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.standard),
              const BoxyArtDivider(),
              SizedBox(height: spacing?.labelToCard ?? AppSpacing.standard),
            ],
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: AppShapes.lg,
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Theme.of(context).cardColor,
                    child: const Icon(Icons.image, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.standard),
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

  @override
  ConsumerState<EventBroadcastScreen> createState() => _EventBroadcastScreenState();
}

class _EventBroadcastScreenState extends ConsumerState<EventBroadcastScreen> {
  void _onReorder(GolfEvent event, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Get the visual list that the user is actually reordering (Published items ONLY for Tab 1)
    final items = event.effectiveFeedItems.where((i) => i.isPublished).toList();
    items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    
    if (oldIndex >= items.length || newIndex >= items.length) return;
    
    // Perform swap on visual items
    final EventFeedItem item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Build map of updated sort orders and apply to the sorted visual list
    final updatedFeedItems = items.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    // Preserve the non-published items (drafts) which aren't in this list
    final draftItems = event.feedItems.where((i) => !i.isPublished).toList();
    final finalItems = [...updatedFeedItems, ...draftItems];

    final updatedEvent = event.copyWith(feedItems: finalItems);
    await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: HeadlessScaffold(
        title: 'Event Comms',
        subtitle: 'Post Management',
        topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
        showBack: true,
        onBack: () => context.goNamed(
          'admin-event-manage-tower',
          pathParameters: {'id': widget.eventId},
        ),
        actions: [
          const SizedBox(width: AppSpacing.md),
          BoxyArtGlassIconButton(
            icon: Icons.add_rounded,
            onPressed: () => context.pushNamed(
              'admin-notifications-compose',
              queryParameters: {'eventId': widget.eventId},
            ),
            tooltip: 'Create Notification',
            iconColor: AppColors.dark900,
            iconSize: 24,
          ),
        ],
        slivers: [
          // 1. Tab Bar Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              const ModernUnderlinedTabBar(
                tabLabels: ['Note Studio', 'Layout Management'],
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),

          // 2. Tab Content
          _TabSwitchedContent(
            eventId: widget.eventId,
            onReorder: _onReorder,
          ),
        ],
      ),
    );
  }
}

class _TabSwitchedContent extends StatefulWidget {
  final String eventId;
  final Function(GolfEvent, int, int) onReorder;

  const _TabSwitchedContent({
    required this.eventId,
    required this.onReorder,
  });

  @override
  State<_TabSwitchedContent> createState() => _TabSwitchedContentState();
}

class _TabSwitchedContentState extends State<_TabSwitchedContent> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = DefaultTabController.maybeOf(context);
    if (newController != _controller) {
      _controller?.removeListener(_handleTick);
      _controller = newController;
      _controller?.addListener(_handleTick);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTick);
    super.dispose();
  }

  void _handleTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return _BroadcastContent(
      eventId: widget.eventId,
      tabIndex: _controller!.index,
      onReorder: widget.onReorder,
    );
  }
}

class _BroadcastContent extends ConsumerWidget {
  final String eventId;
  final int tabIndex;
  final Function(GolfEvent, int, int) onReorder;

  const _BroadcastContent({
    required this.eventId,
    required this.tabIndex,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return eventAsync.when(
      data: (event) {
        List<EventFeedItem> items;
        if (tabIndex == 1) {
          // Tab 2: History & Management (Published items ONLY)
          items = event.effectiveFeedItems.where((i) => i.isPublished).toList();
          items.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return a.sortOrder.compareTo(b.sortOrder);
          });
        } else {
          // Tab 1: Newsletter Studio (Newsletters ONLY - Drafts & Published)
          items = event.feedItems.where((i) => i.type == FeedItemType.newsletter).toList();
          // Sort by creation date descending
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        // Design 4.x: Gap between persistent header (Tab Bar) and the first card uses cardToLabel token
        final topPadding = spacing?.cardToLabel ?? AppSpacing.section;

        return SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.hero,
            top: topPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (tabIndex == 0) {
                  // In Studio Tab, index 0 is the creation card
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudioCreationCard(context, eventId),
                        const BoxyArtSectionTitle(title: 'Note Library'),
                      ],
                    );
                  }
                  final itemIndex = index - 1;
                  if (itemIndex >= items.length) return null;
                  return _NewsletterLibraryTile(
                    event: event, 
                    item: items[itemIndex],
                    spacing: spacing,
                  );
                } else {
                  // In History Tab
                  if (index == 0) {
                    if (items.isEmpty) return _buildEmptyState(context, tabIndex);
                    return ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      onReorder: (oldIndex, newIndex) => onReorder(event, oldIndex, newIndex),
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.45),
                          child: child,
                        );
                      },
                      itemBuilder: (context, idx) => _buildItemWrapper(context, event, items[idx], spacing, idx, true),
                    );
                  }
                  return null;
                }
              },
              childCount: tabIndex == 0 ? items.length + 1 : 1,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildStudioCreationCard(BuildContext context, String eventId) {
    return BoxyArtCard(
      // Design 4.x: Action-only cards use tighter vertical padding (lg) with standard horizontal (xl)
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xl,
      ),
      child: BoxyArtButton(
        title: 'Create Note',
        icon: Icons.add_rounded,
        onTap: () => context.pushNamed(
          'admin-notifications-compose',
          queryParameters: {'eventId': eventId, 'type': 'newsletter'},
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int tabIndex) {
    return Center(
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
              child: Icon(
                tabIndex == 0 ? Icons.campaign_rounded : Icons.mark_as_unread_rounded, 
                size: AppShapes.iconHero, 
                color: AppColors.coral400
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              tabIndex == 0 ? 'No Published Posts' : 'No Notes Yet',
              style: const TextStyle(fontSize: AppTypography.sizeDisplaySection, fontWeight: AppTypography.weightBold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tabIndex == 0 
                ? 'All published updates and newsletters will appear here in chronological order.' 
                : 'Start by creating a new draft note.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWrapper(BuildContext context, GolfEvent event, EventFeedItem item, AppSpacingTokens? spacing, int index, bool allowReorder) {
    return Container(
      key: ValueKey(item.id),
      margin: EdgeInsets.only(bottom: spacing?.cardToLabel ?? AppSpacing.standard),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (item.type == FeedItemType.flash || item.type == FeedItemType.newsletter) {
                context.push('/admin/events/manage/${event.id}/broadcast/edit/${item.id}', extra: item);
              }
            },
            child: AbsorbPointer(
              child: EventBroadcastScreen.buildAdminFeedItemCardStatic(context, item, event),
            ),
          ),
          
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
                if (allowReorder)
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
  }
}

class _NewsletterLibraryTile extends ConsumerWidget {
  final GolfEvent event;
  final EventFeedItem item;
  final AppSpacingTokens? spacing;

  const _NewsletterLibraryTile({
    required this.event,
    required this.item,
    this.spacing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('d MMM yyyy').format(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: ValueKey('newsletter_${item.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showBoxyArtDialog<bool>(
            context: context,
            title: 'Delete Note?',
            message: 'Are you sure you want to permanently delete "${item.title ?? 'this note'}"? This action cannot be undone.',
            confirmText: 'Delete',
            isDangerous: true,
          );
        },
        onDismissed: (direction) async {
          // 1. Filter out the item
          final updatedItems = event.feedItems.where((fi) => fi.id != item.id).toList();
          final updatedEvent = event.copyWith(feedItems: updatedItems);
          
          // 2. Persist to Firestore
          await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Note deleted')),
            );
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.coral500.withValues(alpha: AppColors.opacityLow),
            borderRadius: AppShapes.lg,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.coral500, size: 28),
        ),
        child: BoxyArtCard(
          onTap: () {
            context.push('/admin/events/manage/${event.id}/broadcast/edit/${item.id}', extra: item);
          },
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isPublished ? Icons.mark_email_read_rounded : Icons.mark_as_unread_rounded, 
                  size: 20, 
                  color: Theme.of(context).primaryColor
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? 'Untitled Note',
                      style: AppTypography.memberName.copyWith(
                        fontSize: 16,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Created on $dateStr',
                      style: AppTypography.micro.copyWith(
                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Dedicated Status Column (Matching Renewal Hub)
              BoxyArtStatusPill(
                isPaid: item.isPublished,
                paidLabel: 'Published',
                dueLabel: 'Draft',
                onToggle: () async {
                  final newStatus = !item.isPublished;
                  
                  // 1. Update local list
                  final updatedItems = event.feedItems.map((fi) {
                    if (fi.id == item.id) {
                      return fi.copyWith(isPublished: newStatus);
                    }
                    return fi;
                  }).toList();
                  
                  final updatedEvent = event.copyWith(feedItems: updatedItems);
                  
                  // 2. Persist to Firestore
                  await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.child, {required this.backgroundColor});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.backgroundColor != backgroundColor;
  }
}
