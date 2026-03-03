import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../domain/registration_logic.dart';
import '../../../members/presentation/profile_provider.dart';

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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
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
    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Event Dashboard',
      useScaffold: true,
      showBack: true,
      onBack: () {
        try {
          context.go('/events');
        } catch (_) {
          Navigator.of(context).pop();
        }
      },
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppTheme.cardSpacing),
              _buildHeadlineCard(context),
              _buildPodiumSummaryCard(context),
              _buildRegistrationCard(context, ref),
              _buildGallerySnippetCard(context),
              _buildFeedItems(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadlineCard(BuildContext context) {
    final bool hasImage = event.imageUrl != null && event.imageUrl!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, d MMM yyyy').format(event.date),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.courseName ?? 'Location TBA',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildFeedItems(BuildContext context) {
    if (event.feedItems.isEmpty) return const SizedBox.shrink();

    final publishedItems = event.feedItems.where((i) => i.isPublished).toList();
    publishedItems.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });

    if (publishedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: publishedItems.map((item) {
        if (item.type == FeedItemType.flash) {
          return _buildFlashItem(context, item);
        } else if (item.type == FeedItemType.newsletter) {
          return _buildNewsletterItem(context, item);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildFlashItem(BuildContext context, EventFeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context, WidgetRef ref) {
    if (!event.showRegistrationButton || 
        event.displayStatus == EventStatus.draft || 
        event.displayStatus == EventStatus.cancelled ||
        event.displayStatus == EventStatus.completed ||
        event.displayStatus == EventStatus.inPlay) {
      return const SizedBox.shrink();
    }

    final user = ref.watch(effectiveUserProvider);
    final myRegistration = event.registrations.where((r) => r.memberId == user.id).firstOrNull;
    final isRegistered = myRegistration != null;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);

    if (isPastDeadline && !isRegistered) {
      return const SizedBox.shrink();
    }

    final stats = RegistrationLogic.getRegistrationStats(event);
    final isFull = event.maxParticipants != null && stats.confirmedGolfers >= event.maxParticipants!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: BoxyArtCard(
        child: Column(
          children: [
            if (!isRegistered) ...[
              Column(
                children: [
                  Text(
                    isFull ? 'Event Full' : 'Secure your spot',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (event.registrationDeadline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      isFull ? 'Register to join the waitlist' : 'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8), 
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      isFull ? 'Join the waitlist below' : 'Register below to join the event',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: myRegistration.hasPaid ? const Color(0xFF27AE60) : const Color(0xFFF39C12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (myRegistration.hasPaid ? const Color(0xFF27AE60) : const Color(0xFFF39C12)).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    myRegistration.hasPaid ? 'Confirmed (Paid)' : 'Registered (Pending)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            BoxyArtButton(
              title: isRegistered ? 'Edit Registration' : (isFull ? 'Register (Waitlist)' : 'Register Now'),
              onTap: isPastDeadline ? null : () {
                try {
                  GoRouter.of(context).push('/events/${event.id}/register-form');
                } catch (_) {}
              },
            ),
            if (isRegistered) ...[
              const SizedBox(height: 32),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ModernMetricStat(
                        value: myRegistration.hasPaid ? 'YES' : 'NO',
                        label: 'Paid',
                        icon: Icons.payments_rounded,
                        color: myRegistration.hasPaid ? const Color(0xFF27AE60) : Colors.grey.shade400,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernMetricStat(
                        value: myRegistration.attendingBreakfast ? 'YES' : 'NO',
                        label: 'Breakfast',
                        icon: Icons.breakfast_dining_rounded,
                        color: myRegistration.attendingBreakfast ? const Color(0xFF795548) : Colors.grey.shade400,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernMetricStat(
                        value: myRegistration.attendingLunch ? 'YES' : 'NO',
                        label: 'Lunch',
                        icon: Icons.lunch_dining_rounded,
                        color: myRegistration.attendingLunch ? const Color(0xFFD35400) : Colors.grey.shade400,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernMetricStat(
                        value: myRegistration.attendingDinner ? 'YES' : 'NO',
                        label: 'Dinner',
                        icon: Icons.dinner_dining_rounded,
                        color: myRegistration.attendingDinner ? const Color(0xFF2980B9) : Colors.grey.shade400,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewsletterItem(BuildContext context, EventFeedItem item) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.title != null && item.title!.isNotEmpty) ...[
              Text(
                item.title!,
                style: AppTypography.displayHeading.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: AppTheme.cardSpacing),
            ],
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Theme.of(context).cardColor,
                    child: const Icon(Icons.image, color: Colors.grey),
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
      ),
    );
  }

  Widget _buildGallerySnippetCard(BuildContext context) {
    if (event.galleryUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event Gallery'),
          BoxyArtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: event.galleryUrls.length > 5 ? 5 : event.galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event.galleryUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                BoxyArtButton(
                  title: event.galleryUrls.length > 5 ? 'View All ${event.galleryUrls.length} Photos' : 'View Gallery',
                  onTap: () {
                    context.push('/events/${event.id}/photos');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSummaryCard(BuildContext context) {
    if (event.displayStatus != EventStatus.completed || event.results.isEmpty) {
      return const SizedBox.shrink();
    }

    final topResults = event.results.take(3).toList();
    if (topResults.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event Recap & Results'),
          BoxyArtCard(
            child: Column(
              children: [
                ...topResults.asMap().entries.map((entry) {
                   final rank = entry.key + 1;
                   final res = entry.value;
                   final memberName = res['memberName'] ?? 'Player';
                   final score = res['totalPoints'] ?? res['score'] ?? '-';
                   
                   return ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: BoxyArtNumberBadge(number: rank, size: 36, color: rank == 1 ? AppColors.lime500 : null),
                     title: Text(memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     trailing: Text('$score pts', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.lime500)),
                   );
                }),
                const SizedBox(height: 12),
                BoxyArtButton(
                  title: 'View Full Results',
                  isPrimary: false,
                  onTap: () {
                    context.push('/events/${event.id}/stats');
                  },
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}

