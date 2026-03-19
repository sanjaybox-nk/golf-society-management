import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/utils/string_utils.dart';

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
              Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
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
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: AppTypography.sizeButton,
                            fontWeight: AppTypography.weightBold,
                          ),
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
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: AppTypography.sizeButton,
                            fontWeight: AppTypography.weightBold,
                          ),
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
        statusText = 'Draft';
        statusColor = AppColors.amber500;
        break;
      case EventStatus.published:
        statusText = 'Published';
        statusColor = Theme.of(context).colorScheme.secondary;
        break;
      case EventStatus.inPlay:
        statusText = 'Live';
        statusColor = AppColors.teamA;
        break;
      case EventStatus.suspended:
        statusText = 'Suspended';
        statusColor = Colors.deepOrange;
        break;
      case EventStatus.completed:
        statusText = 'Completed';
        statusColor = AppColors.textSecondary;
        break;
      case EventStatus.cancelled:
        statusText = 'Cancelled';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRegistered) ...[
            BoxyArtCard(
              child: Column(
                children: [
                  Text(
                    isFull ? 'Event Full' : 'Secure your spot',
                    style: AppTypography.displayLargeBody.copyWith(
                      fontWeight: AppTypography.weightBlack,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (event.registrationDeadline != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isFull ? 'Register to join the waitlist' : 'CLOSES: ${DateFormat.yMMMd().format(event.registrationDeadline!).toUpperCase()} @ ${DateFormat('h:mm a').format(event.registrationDeadline!).toUpperCase()}',
                      style: AppTypography.labelStrong.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh), 
                        fontWeight: AppTypography.weightBlack,
                        letterSpacing: 1.2,
                        fontSize: AppTypography.sizeCaption,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isFull ? 'Join the waitlist below' : 'Register below to join the event',
                      style: AppTypography.labelStrong.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtButton(
                    title: isFull ? 'Register (Waitlist)' : 'Register Now',
                    onTap: () {
                      try {
                        GoRouter.of(context).push('/events/${event.id}/register-form');
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // MEMBER STATUS SECTION
            BoxyArtSectionTitle(
              title: myRegistration.guestName != null ? 'My Status' : 'Registration Status',
            ),
            BoxyArtCard(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                children: [
                  _buildSelectionGrid(
                    context,
                    isConfirmed: myRegistration.isConfirmed,
                    statusOverride: myRegistration.statusOverride,
                    hasPaid: myRegistration.hasPaid,
                    attendingBreakfast: myRegistration.attendingBreakfast,
                    attendingLunch: myRegistration.attendingLunch,
                    attendingDinner: myRegistration.attendingDinner,
                    needsBuggy: myRegistration.needsBuggy,
                  ),
                  if (myRegistration.dietaryRequirements != null && myRegistration.dietaryRequirements!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.x2l),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: AppShapes.md,
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
                      ),
                      child: _buildDetailSnippet(
                        context, 
                        Icons.set_meal_rounded, 
                        myRegistration.dietaryRequirements!,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x2l),
                  BoxyArtButton(
                    title: isPastDeadline ? 'Registration Closed' : 'Edit Registration',
                    onTap: (isPastDeadline && !isManagement) ? null : () {
                      try {
                        GoRouter.of(context).push('/events/${event.id}/register-form');
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),

            // GUEST STATUS SECTION (If guest exists)
            if (myRegistration.guestName != null) ...[
              const SizedBox(height: AppSpacing.lg), // cardToLabel
              const BoxyArtSectionTitle(title: 'My Guest Status'),
              BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.x2l),
                child: _buildSelectionGrid(
                  context,
                  isConfirmed: myRegistration.guestIsConfirmed,
                  statusOverride: null,
                  hasPaid: myRegistration.hasPaid,
                  attendingBreakfast: myRegistration.guestAttendingBreakfast,
                  attendingLunch: myRegistration.guestAttendingLunch,
                  attendingDinner: myRegistration.guestAttendingDinner,
                  needsBuggy: myRegistration.guestNeedsBuggy,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionGrid(
    BuildContext context, {
    required bool isConfirmed,
    required String? statusOverride,
    required bool hasPaid,
    required bool attendingBreakfast,
    required bool attendingLunch,
    required bool attendingDinner,
    required bool needsBuggy,
  }) {
    final boxes = [
      if (statusOverride == 'waitlist')
        _buildStatusBox(context, Icons.priority_high_rounded, 'Waitlist', 'Status')
      else if (statusOverride == 'withdrawn')
        _buildStatusBox(context, Icons.person_remove_rounded, 'Removed', 'Status')
      else 
        _buildStatusBox(context, isConfirmed ? Icons.check_circle_rounded : Icons.pending_rounded, isConfirmed ? 'Playing' : 'Pending', 'Status'),

      if (hasPaid)
        _buildStatusBox(context, Icons.payments_rounded, 'Paid', 'Payment'),
      if (attendingBreakfast)
        _buildStatusBox(context, Icons.breakfast_dining_rounded, 'Yes', 'Breakfast'),
      if (attendingLunch)
        _buildStatusBox(context, Icons.lunch_dining_rounded, 'Yes', 'Lunch'),
      if (attendingDinner)
        _buildStatusBox(context, Icons.restaurant_rounded, 'Yes', 'Dinner'),
      if (needsBuggy)
        _buildStatusBox(context, Icons.electric_rickshaw_rounded, 'Yes', 'Buggy'),
    ];

    if (boxes.isEmpty) return const SizedBox.shrink();

    final rows = <List<Widget>>[];
    for (var i = 0; i < boxes.length; i += 4) {
      rows.add(boxes.sublist(i, i + 4 > boxes.length ? boxes.length : i + 4));
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row == rows.last ? 0 : AppSpacing.md),
          child: Row(
            children: [
              ...row.map((box) => Expanded(child: Padding(
                padding: EdgeInsets.only(right: box == row.last && row.length == 4 ? 0 : AppSpacing.sm),
                child: box,
              ))),
              if (row.length < 4) 
                ...List.generate(4 - row.length, (index) => const Expanded(child: SizedBox())),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBox(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final neutralColor = isDark ? AppColors.pureWhite : AppColors.dark900;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.actionGreen.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 20, 
            color: neutralColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.displayHeading.copyWith(
              fontSize: AppTypography.sizeBody,
              color: neutralColor,
              letterSpacing: -0.2,
              fontWeight: AppTypography.weightBold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeMicroSmall,
              color: neutralColor.withValues(alpha: AppColors.opacityHigh),
              fontWeight: AppTypography.weightSemibold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
                          width: 160,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 160,
                            height: 120,
                            color: AppColors.dark200,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.dark400),
                          ),
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
                   final memberName = res['memberName'] ?? res['playerName'] ?? 'Player';
                   final score = res['totalPoints'] ?? res['score'] ?? res['points'] ?? '-';
                   
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

class YourGroupCard extends ConsumerWidget {
  final GolfEvent event;
  const YourGroupCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!event.isGroupingPublished) return const SizedBox.shrink();

    final user = ref.watch(effectiveUserProvider);
    TeeGroupParticipant? myParticipant;
    TeeGroup? myGroup;

    final groupsData = event.grouping['groups'] as List?;
    if (groupsData != null) {
      for (var gd in groupsData) {
        try {
          final group = TeeGroup.fromJson(gd as Map<String, dynamic>);
          for (var p in group.players) {
            if (p.registrationMemberId == user.id) {
              myParticipant = p;
              myGroup = group;
              break;
            }
          }
        } catch (_) {}
        if (myParticipant != null) break;
      }
    }

    if (myParticipant == null || myGroup == null) return const SizedBox.shrink();

    final partners = myGroup.players
        .where((p) => p.registrationMemberId != user.id)
        .map((p) => toTitleCase(p.name))
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Your Group'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, Icons.access_time_rounded, 'TEE TIME: ${DateFormat.Hm().format(myGroup.teeTime)}'),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.people_alt_rounded, 'PARTNERS: ${partners.isEmpty ? "Alone" : partners}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityLow),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.sizeCaptionStrong,
              fontWeight: AppTypography.weightExtraBold,
              letterSpacing: 1.2,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
