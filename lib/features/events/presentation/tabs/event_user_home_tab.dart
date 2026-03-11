import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'dart:convert';
import '../events_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

import '../widgets/event_structural_cards.dart';

class EventUserHomeTab extends ConsumerWidget {
  final String eventId;
  final bool useScaffold;

  const EventUserHomeTab({super.key, required this.eventId, this.useScaffold = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    
    return eventAsync.when(
      data: (event) {
        return EventHomeContent(event: event, useScaffold: useScaffold);
      },
      loading: () => useScaffold 
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const Center(child: CircularProgressIndicator()),
      error: (err, stack) => useScaffold
          ? Scaffold(body: Center(child: Text('Error: $err')))
          : Center(child: Text('Error: $err')),
    );
  }
}

class EventHomeContent extends ConsumerWidget {
  final GolfEvent event;
  final bool useScaffold;

  const EventHomeContent({
    super.key,
    required this.event, 
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = GoRouterState.of(context).uri.path.startsWith('/admin');
    
    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Event Dashboard',
      useScaffold: useScaffold,
      showBack: true,
      actions: isAdmin
          ? [
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                tooltip: 'Edit Layout',
                onPressed: () => context.push('/admin/events/manage/${event.id}/broadcast'),
              ),
            ]
          : null,
      onBack: () {
        try {
          if (isAdmin) {
            context.go('/admin/events');
          } else {
            context.go('/events');
          }
        } catch (_) {
          Navigator.of(context).pop();
        }
      },
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppTheme.cardSpacing),
              _buildActiveShortcuts(context, ref),
              ...() {
                final publishedItems = event.effectiveFeedItems.where((i) => i.isPublished).toList();
                publishedItems.sort((a, b) {
                  if (a.isPinned && !b.isPinned) return -1;
                  if (!a.isPinned && b.isPinned) return 1;
                  return a.sortOrder.compareTo(b.sortOrder);
                });

                return publishedItems.map((item) {
                  switch (item.type) {
                    case FeedItemType.headline:
                      return EventHeadlineCard(event: event);
                    case FeedItemType.podium:
                      return EventPodiumCard(event: event);
                    case FeedItemType.registration:
                      return EventRegistrationCard(event: event, isManagement: isAdmin);
                    case FeedItemType.gallerySnippet:
                      return EventGalleryCard(event: event);
                    case FeedItemType.flash:
                      return _buildFlashItem(context, item);
                    case FeedItemType.newsletter:
                      return _buildNewsletterItem(context, item);
                    case FeedItemType.poll:
                      return _buildPollItem(context, ref, item);
                    default:
                      return const SizedBox.shrink();
                  }
                }).toList();
              }(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashItem(BuildContext context, EventFeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
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

  Widget _buildNewsletterItem(BuildContext context, EventFeedItem item) {
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

    return GestureDetector(
      onTap: () {
        final isAdmin = GoRouterState.of(context).uri.path.startsWith('/admin');
        final prefix = isAdmin ? '/admin/events/manage/${event.id}' : '/events/${event.id}';
        context.push('$prefix/feed/${item.id}', extra: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
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
                padding: const EdgeInsets.all(AppSpacing.xl),
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
      ),
    );
  }

  Widget _buildPollItem(BuildContext context, WidgetRef ref, EventFeedItem item) {
    final options = (item.pollData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final votes = (item.pollData['votes'] as Map?)?.cast<String, String>() ?? {};
    final user = ref.watch(effectiveUserProvider);
    final userVote = votes[user.id];
    final hasVoted = userVote != null;
    
    // Calculate percentages
    final totalVotes = votes.length;
    final Map<String, int> counts = {};
    for (var opt in options) {
      counts[opt] = votes.values.where((v) => v == opt).length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: BoxyArtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.poll_rounded, color: AppColors.lime500, size: AppShapes.iconMd),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'SOCIETY POLL',
                  style: AppTypography.label.copyWith(
                    color: AppColors.lime500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.title ?? 'Quick Question',
              style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
            ),
            const SizedBox(height: AppSpacing.xl),
            ...options.map((option) {
              final count = counts[option] ?? 0;
              final percent = totalVotes == 0 ? 0.0 : count / totalVotes;
              final isSelected = userVote == option;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GestureDetector(
                  onTap: hasVoted ? null : () => _vote(ref, item, option),
                  child: Stack(
                    children: [
                      // Progress Bar Background
                      Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: AppShapes.md,
                          border: Border.all(
                            color: isSelected ? AppColors.lime500 : Colors.transparent,
                            width: AppShapes.borderLight,
                          ),
                        ),
                      ),
                      // Progress Fill
                      if (hasVoted)
                        AnimatedContainer(
                          duration: AppAnimations.slow,
                          height: 48,
                          width: MediaQuery.of(context).size.width * percent,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.lime500.withValues(alpha: AppColors.opacityMedium) : AppColors.lime500.withValues(alpha: AppColors.opacitySubtle),
                            borderRadius: AppShapes.md,
                          ),
                        ),
                      // Content
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightMedium,
                                    fontSize: AppTypography.sizeButton,
                                  ),
                                ),
                              ),
                              if (hasVoted)
                                Text(
                                  '${(percent * 100).round()}%',
                                  style: AppTypography.label.copyWith(
                                    color: isSelected ? AppColors.lime500 : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (hasVoted)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _vote(WidgetRef ref, EventFeedItem item, String option) async {
    final user = ref.read(effectiveUserProvider);
    final votes = Map<String, String>.from(item.pollData['votes'] ?? {});
    votes[user.id] = option;

    final updatedItem = item.copyWith(
      pollData: {
        ...item.pollData,
        'votes': votes,
      },
    );

    final List<EventFeedItem> updatedItems = List.from(event.feedItems);
    final index = updatedItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      updatedItems[index] = updatedItem;
      final updatedEvent = event.copyWith(feedItems: updatedItems);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    }
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: GestureDetector(
        onTap: () => context.go('/events/${event.id}/live'),
        child: BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                      style: AppTypography.label.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: AppTypography.weightBlack,
                        letterSpacing: 1.2,
                        fontSize: AppTypography.sizeCaption,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter Scorecard',
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: AppTypography.sizeLargeBody,
                        height: 1.1,
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
      ),
    );
  }
}
