import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'dart:convert';
import '../events_provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/event_structural_cards.dart';
import '../../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/member.dart';

class EventUserHomeTab extends ConsumerWidget {
  final String eventId;

  const EventUserHomeTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    
    return eventAsync.when(
      data: (event) {
        return EventHomeContent(event: event);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class EventHomeContent extends ConsumerWidget {
  final GolfEvent event;

  const EventHomeContent({
    super.key,
    required this.event, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final isStaff = user.role != MemberRole.member;
    final isAdminMode = GoRouterState.of(context).uri.path.startsWith('/admin');
    
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Event Dashboard',
      showAdminShortcut: false, // Explicitly removed as requested
      showBack: true,
      actions: isStaff
          ? [
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                tooltip: 'Edit Layout',
                onPressed: () => context.push('/admin/events/manage/${event.id}/broadcast'),
              ),
            ]
          : null,
      onBack: () {
        if (isStaff && isAdminMode) {
          context.go('/admin/events');
        } else {
          context.go('/events');
        }
      },
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Tab-to-Content Spacing (Standardized 32px overall visual: 24px header + 8px spacer)
              const SizedBox(height: AppSpacing.xs),
              _buildActiveShortcuts(context, ref),
              ...() {
                final publishedItems = event.effectiveFeedItems.where((i) => i.isPublished).toList();
                publishedItems.sort((a, b) {
                  if (a.isPinned && !b.isPinned) return -1;
                  if (!a.isPinned && b.isPinned) return 1;
                  return a.sortOrder.compareTo(b.sortOrder);
                });

                if (publishedItems.isEmpty) return <Widget>[];

                return [
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: publishedItems.length,
                    separatorBuilder: (context, index) {
                      final nextItem = publishedItems[index + 1];
                      // Logic: title handles top padding. 
                      // If next item includes its own SectionTitle, separator is 0.
                      if (nextItem.type == FeedItemType.gallerySnippet || 
                          nextItem.type == FeedItemType.podium || 
                          nextItem.type == FeedItemType.registration) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard);
                    },
                    itemBuilder: (context, index) {
                      final item = publishedItems[index];
                      // Absolute first item in whole scroll view needs peeking if it has a title
                      final isScoringActive = event.displayStatus != EventStatus.completed && 
                                            ((event.displayStatus == EventStatus.inPlay) || 
                                             (DateTime.now().isAfter(event.date) && !(event.isScoringLocked == true)));
                      final isAbsoluteFirst = index == 0 && (event.eventType != EventType.golf || !isScoringActive);

                      switch (item.type) {
                        case FeedItemType.headline:
                          return EventHeadlineCard(event: event);
                        case FeedItemType.podium:
                          return EventPodiumCard(event: event, isPeeking: isAbsoluteFirst);
                        case FeedItemType.registration:
                          return EventRegistrationCard(event: event, isManagement: isStaff, isPeeking: isAbsoluteFirst);
                        case FeedItemType.gallerySnippet:
                          return EventGalleryCard(event: event, isPeeking: isAbsoluteFirst);
                        case FeedItemType.flash:
                          return _buildFlashItem(context, item);
                        case FeedItemType.newsletter:
                          return _buildNewsletterItem(context, item, ref);
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ];
              }(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashItem(BuildContext context, EventFeedItem item) {
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
        ],
      ),
    );
  }

  Widget _buildNewsletterItem(BuildContext context, EventFeedItem item, WidgetRef ref) {
    String snippet = '';
    try {
      final decoded = jsonDecode(item.content);
      if (decoded is List && decoded.isNotEmpty) {
        // Multi-section: use first section
        final firstNote = EventNote.fromJson(decoded.first as Map<String, dynamic>);
        snippet = _getPlainTextSnippet(firstNote.content);
      } else {
        // Legacy or single:
        snippet = _getPlainTextSnippet(item.content);
      }
    } catch (_) {}

    final user = ref.watch(effectiveUserProvider);
    final config = ref.watch(themeControllerProvider);
    final isStaff = user.role != MemberRole.member;
    final isAdminMode = GoRouterState.of(context).uri.path.startsWith('/admin');

    return GestureDetector(
      onTap: () {
        final prefix = isStaff && isAdminMode ? '/admin/events/manage/${event.id}' : '/events/${event.id}';
        context.push('$prefix/feed/${item.id}', extra: item);
      },
      child: BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
                  child: Image.network(
                    item.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: config.cardVerticalPadding,
                  horizontal: config.cardHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.title != null && item.title!.isNotEmpty) ...[
                      Text(
                        item.title!,
                        style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (snippet.isNotEmpty)
                      Text(
                        snippet,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sizeBodySmall,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Text(
                          'READ FULL STORY',
                          style: TextStyle(
                            fontSize: AppTypography.sizeCaptionStrong,
                            fontWeight: AppTypography.weightBlack,
                            letterSpacing: 1.2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.arrow_forward_rounded, size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
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


  String _getPlainTextSnippet(String quillJson) {
    try {
      final delta = jsonDecode(quillJson);
      if (delta is List) {
        final buffer = StringBuffer();
        for (var op in delta) {
          if (op is Map && op.containsKey('insert') && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {}
    return quillJson.length > 150 ? '${quillJson.substring(0, 147)}...' : quillJson;
  }

  Widget _buildActiveShortcuts(BuildContext context, WidgetRef ref) {
    if (event.eventType != EventType.golf) return const SizedBox.shrink();

    final status = event.displayStatus;
    final bool isLocked = event.isScoringLocked == true;
    final bool isCompleted = status == EventStatus.completed;
    
    final now = DateTime.now();
    final isSameDayOrPast = now.year == event.date.year && 
                             now.month == event.date.month && 
                             now.day == event.date.day || 
                             now.isAfter(event.date);

    final bool isScoringActive = !isCompleted && ((status == EventStatus.inPlay) || (isSameDayOrPast && !isLocked));

    if (!isScoringActive) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.go('/events/${event.id}/live'),
      child: BoxyArtCard(
          // Using default tokenized padding
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityMedium),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READY TO SCORE?',
                      style: AppTypography.micro.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: AppTypography.weightHeavy,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.atomic),
                    Text(
                      'Enter Scorecard',
                      style: AppTypography.headline.copyWith(
                        fontWeight: AppTypography.weightHeavy,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, 
                size: 16, 
                color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHigh),
              ),
            ],
          ),
        ),
      );
  }
}
