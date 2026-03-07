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
                borderRadius: AppShapes.xl,
                child: Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, d MMM yyyy').format(event.date),
                          style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          event.courseName ?? 'Location TBA',
                          style: AppTypography.bodySmall.copyWith(fontWeight: AppTypography.weightBold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
        statusColor = AppColors.amber500;
        break;
      case EventStatus.published:
        statusText = 'PUBLISHED';
        statusColor = const Color(0xFF27AE60);
        break;
      case EventStatus.inPlay:
        statusText = 'LIVE';
        statusColor = AppColors.teamA;
        break;
      case EventStatus.suspended:
        statusText = 'SUSPENDED';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.completed:
        statusText = 'COMPLETED';
        statusColor = AppColors.textSecondary;
        break;
      case EventStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = AppColors.coral500;
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
                    style: AppTypography.displayLargeBody.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (event.registrationDeadline != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isFull ? 'Register to join the waitlist' : 'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                      style: AppTypography.labelStrong.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh), 
                        fontWeight: AppTypography.weightExtraBold,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isFull ? 'Join the waitlist below' : 'Register below to join the event',
                      style: AppTypography.labelStrong.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: AppSpacing.md,
                    height: AppSpacing.md,
                    decoration: BoxDecoration(
                      color: myRegistration.hasPaid ? const Color(0xFF27AE60) : const Color(0xFFF39C12),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.softScale,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    myRegistration.hasPaid ? 'Confirmed (Paid)' : 'Registered (Pending)',
                    style: AppTypography.displayLargeBody.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
            ],
            if (isRegistered) ...[
              const SizedBox(height: AppSpacing.x2l),
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
                      Theme.of(context).primaryColor,
                    ),
                  ],
                ],
              ),
              
              // Detail Snippets
              if (myRegistration.guestName != null || 
                  (myRegistration.dietaryRequirements != null && myRegistration.dietaryRequirements!.isNotEmpty)) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: AppShapes.md,
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
                        if (myRegistration.guestName != null) const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.x2l),
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
        Icon(icon, color: color, size: AppShapes.iconMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            fontWeight: active ? AppTypography.weightBold : AppTypography.weightRegular,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: AppSpacing.xl,
        width: AppShapes.borderThin,
        color: AppColors.textSecondary.withValues(alpha: AppColors.opacityMedium),
      ),
    );
  }

  Widget _buildDetailSnippet(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.labelStrong.copyWith(fontWeight: AppTypography.weightMedium),
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
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: AppShapes.md,
                        child: Image.network(
                          event.galleryUrls[index],
                          width: AppShapes.borderThin,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'Podium Results Block\n(Visible when event completed)',
                    textAlign: TextAlign.center,
                      style: AppTypography.labelStrong.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
                     leading: BoxyArtNumberBadge(number: rank, size: 36, color: rank == 1 ? Theme.of(context).primaryColor : null),
                     title: Text(memberName, style: AppTypography.body.copyWith(fontWeight: AppTypography.weightBold)),
                     trailing: Text('$score pts', style: AppTypography.displayLargeBody.copyWith(fontWeight: AppTypography.weightBlack, color: Theme.of(context).primaryColor)),
                   );
                }),
                const SizedBox(height: AppSpacing.md),
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
