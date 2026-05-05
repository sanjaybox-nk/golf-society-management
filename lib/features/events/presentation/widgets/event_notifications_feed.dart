import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/presentation/widgets/event_info_sections.dart';
import 'package:golf_society/features/events/presentation/widgets/event_structural_cards.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

/// Renders the "News updates" tab: registration card, group info, sponsor
/// cards, flash/newsletter messages, podium recap, and gallery.
class EventNotificationsFeed extends ConsumerWidget {
  const EventNotificationsFeed({super.key, required this.event});
  final GolfEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final user = ref.watch(effectiveUserProvider);
    final isStaff = user.role != MemberRole.member;

    final publishedItems = event.effectiveFeedItems.where((i) => i.isPublished).toList();
    final regItem    = publishedItems.firstWhereOrNull((i) => i.type == FeedItemType.registration);
    final podiumItem = publishedItems.firstWhereOrNull((i) => i.type == FeedItemType.podium);
    final galleryItem = publishedItems.firstWhereOrNull((i) => i.type == FeedItemType.gallerySnippet);

    final newsItems = publishedItems
        .where((i) => i.type == FeedItemType.flash || i.type == FeedItemType.newsletter)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    bool userIsInGroup = false;
    final groupsData = event.grouping['groups'] as List?;
    if (groupsData != null) {
      for (final gd in groupsData) {
        final players = (gd as Map<String, dynamic>)['players'] as List?;
        if (players != null &&
            players.any((p) => (p as Map<String, dynamic>)['registrationMemberId'] == user.id)) {
          userIsInGroup = true;
          break;
        }
      }
    }

    final showYourGroup = event.isGroupingPublished && userIsInGroup;
    final hasContent = regItem != null || showYourGroup || newsItems.isNotEmpty || podiumItem != null || galleryItem != null;

    if (!hasContent) {
      return Column(
        children: [
          SizedBox(height: spacing?.cardToLabel ?? AppSpacing.x4l),
          const BoxyArtEmptyCard(
            icon: Icons.notifications_off_rounded,
            title: 'No Notifications',
            message: 'Check back later for event updates and society newsletters.',
          ),
        ],
      );
    }

    return Column(
      children: [
        if (regItem != null) ...[
          EventRegistrationCard(event: event, isManagement: isStaff, isPeeking: true),
          ..._buildSponsors(context, ref),
        ],
        if (showYourGroup)
          YourGroupCard(event: event, isPeeking: regItem == null),
        if (newsItems.isNotEmpty) ...[
          BoxyArtSectionTitle(
            title: 'Messages',
            isPeeking: regItem == null && !showYourGroup,
          ),
          ...newsItems.mapIndexed((index, item) => Padding(
                padding: EdgeInsets.only(
                  bottom: (index == newsItems.length - 1 && podiumItem == null && galleryItem == null)
                      ? 0
                      : (spacing?.cardToCard ?? AppSpacing.standard),
                ),
                child: item.type == FeedItemType.newsletter
                    ? _NewsletterCard(event: event, item: item)
                    : _FlashCard(item: item),
              )),
        ],
        if (podiumItem != null)
          EventPodiumCard(
            event: event,
            isManagement: isStaff,
            isPeeking: regItem == null && !showYourGroup && newsItems.isEmpty,
          ),
        if (galleryItem != null)
          EventGalleryCard(
            event: event,
            isManagement: isStaff,
            isPeeking: regItem == null && !showYourGroup && newsItems.isEmpty && podiumItem == null,
          ),
      ],
    );
  }

  List<Widget> _buildSponsors(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final sponsors = societyConfig.ledgerEntries
        .where((e) => e.type == 'Sponsorship' && e.scope == 'event' && e.eventId == event.id && e.isPaid)
        .toList();

    if (sponsors.isEmpty) return [];

    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    return [
      const BoxyArtSectionTitle(title: 'OFFICIAL EVENT SPONSOR'),
      ...sponsors.mapIndexed((index, s) => Padding(
            padding: EdgeInsets.only(
              bottom: index < sponsors.length - 1 ? (spacing?.cardToCard ?? AppSpacing.standard) : 0,
            ),
            child: BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (s.logoUrl != null && s.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        s.logoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, _x) => const BoxyArtIconBadge(icon: Icons.handshake_rounded, size: 48),
                      ),
                    )
                  else
                    const BoxyArtIconBadge(icon: Icons.handshake_rounded, size: 48),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.source.toUpperCase(), style: AppTypography.label),
                        if (s.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: buildRichDescription(context, s.description!),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    ];
  }
}

// ── Flash alert card ──────────────────────────────────────────────────────────

class _FlashCard extends StatelessWidget {
  const _FlashCard({required this.item});
  final EventFeedItem item;

  @override
  Widget build(BuildContext context) {
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
}

// ── Newsletter card ───────────────────────────────────────────────────────────

class _NewsletterCard extends StatelessWidget {
  const _NewsletterCard({required this.event, required this.item});
  final GolfEvent event;
  final EventFeedItem item;

  @override
  Widget build(BuildContext context) {
    final snippet = _plainTextSnippet(item.content);
    return GestureDetector(
      onTap: () {
        final isAdmin = GoRouterState.of(context).uri.path.startsWith('/admin');
        final prefix = isAdmin ? '/admin/events/manage/${event.id}' : '/events/${event.id}';
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
                  errorBuilder: (_, __, _x) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title != null && item.title!.isNotEmpty) ...[
                    Text(item.title!, style: AppTypography.label),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (snippet.isNotEmpty)
                    Text(
                      snippet,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: AppColors.opacityHigh),
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text('READ FULL STORY',
                          style: AppTypography.micro.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward_rounded,
                          size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
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

  String _plainTextSnippet(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List && decoded.isNotEmpty) {
        final firstNote = EventNote.fromJson(decoded.first as Map<String, dynamic>);
        return _extractPlainText(firstNote.content);
      }
      return _extractPlainText(content);
    } catch (_) {}
    return content.length > 150 ? '${content.substring(0, 147)}...' : content;
  }

  String _extractPlainText(String quillJson) {
    try {
      final delta = jsonDecode(quillJson);
      if (delta is List) {
        final buf = StringBuffer();
        for (final op in delta) {
          if (op is Map && op.containsKey('insert') && op['insert'] is String) {
            buf.write(op['insert']);
          }
        }
        return buf.toString().trim();
      }
    } catch (_) {}
    return quillJson.length > 150 ? '${quillJson.substring(0, 147)}...' : quillJson;
  }
}
