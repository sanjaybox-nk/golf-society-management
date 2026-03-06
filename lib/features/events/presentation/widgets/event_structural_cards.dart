import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

class EventHeadlineCard extends StatelessWidget {
  final GolfEvent event;
  const EventHeadlineCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 16),
                  _buildStatusBadge(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = event.displayStatus;
    
    String statusText;
    Color statusColor;
    
    switch (status) {
      case EventStatus.draft:
        statusText = 'DRAFT';
        statusColor = Colors.orange;
        break;
      case EventStatus.published:
        statusText = 'PUBLISHED';
        statusColor = const Color(0xFF27AE60);
        break;
      case EventStatus.inPlay:
        statusText = 'LIVE';
        statusColor = Colors.blue;
        break;
      case EventStatus.suspended:
        statusText = 'SUSPENDED';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.completed:
        statusText = 'COMPLETED';
        statusColor = Colors.grey;
        break;
      case EventStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = Colors.red;
        break;
    }
    
    return BoxyArtPill.status(
      label: statusText,
      color: statusColor,
    );
  }
}

class EventRegistrationCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isManagement;
  const EventRegistrationCard({super.key, required this.event, this.isManagement = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isManagement) {
      if (!event.showRegistrationButton || 
          event.displayStatus == EventStatus.draft || 
          event.displayStatus == EventStatus.cancelled ||
          event.displayStatus == EventStatus.completed ||
          event.displayStatus == EventStatus.inPlay) {
        return const SizedBox.shrink();
      }
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
            if (isRegistered) ...[
              const SizedBox(height: 24),
              // Compact Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCompactStatusIcon(
                    context, 
                    Icons.payments_rounded, 
                    myRegistration.hasPaid, 
                    'Paid',
                    AppColors.lime500,
                  ),
                  _buildStatusSeparator(),
                  _buildCompactStatusIcon(
                    context, 
                    Icons.breakfast_dining_rounded, 
                    myRegistration.attendingBreakfast, 
                    'Breakfast',
                    AppColors.amber500,
                  ),
                  _buildStatusSeparator(),
                  _buildCompactStatusIcon(
                    context, 
                    Icons.lunch_dining_rounded, 
                    myRegistration.attendingLunch, 
                    'Lunch',
                    AppColors.amber500,
                  ),
                  _buildStatusSeparator(),
                  _buildCompactStatusIcon(
                    context, 
                    Icons.restaurant_rounded, 
                    myRegistration.attendingDinner, 
                    'Dinner',
                    AppColors.coral500,
                  ),
                  if (myRegistration.needsBuggy) ...[
                    _buildStatusSeparator(),
                    _buildCompactStatusIcon(
                      context, 
                      Icons.electric_rickshaw_rounded, 
                      true, 
                      'Buggy',
                      AppColors.coral500,
                    ),
                  ],
                ],
              ),
              
              // Detail Snippets
              if (myRegistration.guestName != null || 
                  (myRegistration.dietaryRequirements != null && myRegistration.dietaryRequirements!.isNotEmpty)) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (myRegistration.guestName != null)
                        _buildDetailSnippet(
                          context, 
                          Icons.person_add_rounded, 
                          'Guest: ${myRegistration.guestName}',
                        ),
                      if (myRegistration.dietaryRequirements != null && myRegistration.dietaryRequirements!.isNotEmpty) ...[
                        if (myRegistration.guestName != null) const SizedBox(height: 8),
                        _buildDetailSnippet(
                          context, 
                          Icons.set_meal_rounded, 
                          myRegistration.dietaryRequirements!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
            
            BoxyArtButton(
              title: isPastDeadline 
                  ? 'Registration Closed' 
                  : (isRegistered ? 'Edit Registration' : (isFull ? 'Register (Waitlist)' : 'Register Now')),
              onTap: (isPastDeadline || isManagement) ? null : () {
                try {
                  GoRouter.of(context).push('/events/${event.id}/register-form');
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatusIcon(BuildContext context, IconData icon, bool active, String label, Color activeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active ? activeColor : (isDark ? AppColors.dark400 : AppColors.dark200);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 20,
        width: 1,
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildDetailSnippet(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class EventGalleryCard extends StatelessWidget {
  final GolfEvent event;
  final bool isManagement;
  const EventGalleryCard({super.key, required this.event, this.isManagement = false});

  @override
  Widget build(BuildContext context) {
    if (!isManagement && event.galleryUrls.isEmpty) return const SizedBox.shrink();

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
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                  onTap: isManagement ? null : () {
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
}

class EventPodiumCard extends StatelessWidget {
  final GolfEvent event;
  final bool isManagement;
  const EventPodiumCard({super.key, required this.event, this.isManagement = false});

  @override
  Widget build(BuildContext context) {
    if (!isManagement) {
      if (event.displayStatus != EventStatus.completed || event.results.isEmpty) {
        return const SizedBox.shrink();
      }
    }

    final topResults = event.results.take(3).toList();
    
    // In management mode, if no results yet, show a dummy/placeholder to represent the block
    if (isManagement && topResults.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoxyArtSectionTitle(title: 'Event Recap & Results'),
            BoxyArtCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Podium Results Block\n(Visible when event completed)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                  onTap: isManagement ? null : () {
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
