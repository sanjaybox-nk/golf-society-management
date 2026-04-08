import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:collection/collection.dart';

class EventHeadlineCard extends ConsumerWidget {
  final GolfEvent event;
  const EventHeadlineCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasImage = event.imageUrl != null && event.imageUrl!.isNotEmpty;
    
    return BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              BoxyArtImage(
                url: event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorWidget: Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.dark200,
                  child: const Icon(Icons.image_not_supported_rounded, color: AppColors.dark400, size: AppShapes.iconLg),
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
                          style: AppTypography.body.copyWith(
                            fontWeight: AppTypography.weightStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.atomic),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: AppShapes.iconSm, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.atomic),
                      Expanded(
                        child: Text(
                          event.courseName ?? 'Location TBA',
                          style: AppTypography.body.copyWith(
                            fontWeight: AppTypography.weightStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusBadge(context, ref),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, WidgetRef ref) {
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
        statusColor = Color(ref.watch(themeControllerProvider).statusPublishedColor);
        break;
      case EventStatus.inPlay:
        statusText = 'Live';
        statusColor = Color(ref.watch(themeControllerProvider).statusPublishedColor); // Match lifecycle color
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
  final bool isPeeking;
  const EventRegistrationCard({super.key, required this.event, this.isManagement = false, this.isPeeking = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final config = ref.watch(themeControllerProvider);
    final myRegistration = event.registrations.where((r) => r.memberId == user.id).firstOrNull;
    final isRegistered = myRegistration != null;

    if (!isManagement) {
      if (isRegistered) {
        // [FIX] Consistently hide the status card if the event is cancelled or draft
        if (event.displayStatus == EventStatus.draft || 
            event.displayStatus == EventStatus.cancelled) {
          return const SizedBox.shrink();
        }
      }
    }
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);

    final stats = RegistrationLogic.getRegistrationStats(event);
    final isFull = event.maxParticipants != null && stats.confirmedGolfers >= event.maxParticipants!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isRegistered) ...[
          SizedBox(height: isPeeking ? 0 : (Theme.of(context).extension<AppSpacingTokens>()?.cardToLabel ?? AppSpacing.cardToLabel)),
          BoxyArtCard(
            gradient: AppGradients.brandPrimary(context),
            isHero: true,
            child: Column(
              children: [
                Text(
                  event.displayStatus == EventStatus.completed 
                      ? 'Event Completed' 
                      : (!event.isRegistrationOpen ? 'Registration Closed' : (isFull ? 'Event Full' : 'Secure your spot')),
                  style: AppTypography.headline.copyWith(
                    fontWeight: AppTypography.weightHeavy,
                    color: AppColors.pureWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (event.registrationDeadline != null || !event.isRegistrationOpen) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    event.displayStatus == EventStatus.completed
                        ? 'This event has finished and closed'
                        : (!event.isRegistrationOpen 
                            ? 'This event is no longer accepting new entries.'
                            : (isFull ? 'Register to join the waitlist' : 'CLOSES: ${DateFormat.yMMMd().format(event.registrationDeadline!).toUpperCase()} @ ${DateFormat('h:mm a').format(event.registrationDeadline!).toUpperCase()}')),
                    style: AppTypography.micro.copyWith(
                      color: AppColors.pureWhite.withValues(alpha: 0.8),
                      fontWeight: AppTypography.weightHeavy,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isFull ? 'Join the waitlist below' : 'Register below to join the event',
                    style: AppTypography.label.copyWith(
                      color: AppColors.pureWhite.withValues(alpha: 0.8),
                      fontWeight: AppTypography.weightHeavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.x2l),
                BoxyArtButton(
                  title: event.displayStatus == EventStatus.completed
                      ? 'Event Completed'
                      : (!event.isRegistrationOpen 
                          ? 'Registration Closed' 
                          : (isFull ? 'Register (Waitlist)' : 'Register Now')),
                  fullWidth: true,
                  backgroundColor: !event.isRegistrationOpen 
                      ? AppColors.pureWhite.withValues(alpha: 0.2) 
                      : AppColors.pureWhite,
                  textColor: !event.isRegistrationOpen 
                      ? AppColors.pureWhite 
                      : Color(config.primaryColor),
                  onTap: !event.isRegistrationOpen ? null : () {
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
            isPeeking: isPeeking,
          ),
          BoxyArtCard(
            child: Column(
              children: [
                _buildSelectionGrid(
                  context,
                  ref,
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
                  fullWidth: true,
                  backgroundColor: Color(config.primaryColor),
                  textColor: ContrastHelper.getContrastingText(Color(config.primaryColor)),
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
            SizedBox(height: Theme.of(context).extension<AppSpacingTokens>()?.cardToLabel ?? AppSpacing.cardToLabel),
            const BoxyArtSectionTitle(title: 'My Guest Status'),
            BoxyArtCard(
              child: _buildSelectionGrid(
                context,
                ref,
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
    );
  }

  Widget _buildSelectionGrid(
    BuildContext context,
    WidgetRef ref, {
    required bool isConfirmed,
    String? statusOverride,
    required bool hasPaid,
    required bool attendingBreakfast,
    required bool attendingLunch,
    required bool attendingDinner,
    required bool needsBuggy,
  }) {
    final boxes = [
      if (statusOverride == 'playing' || (statusOverride == null && isConfirmed))
        const ModernMetricStat(icon: Icons.check_circle_rounded, value: 'Playing', label: 'Status')
      else if (statusOverride == 'reserve')
        const ModernMetricStat(icon: Icons.hourglass_empty_rounded, value: 'Reserve', label: 'Status')
      else if (statusOverride == 'waitlist')
        const ModernMetricStat(icon: Icons.list_alt_rounded, value: 'Waitlist', label: 'Status')
      else if (statusOverride == null && !isConfirmed)
        const ModernMetricStat(icon: Icons.history_edu_rounded, value: 'Pending', label: 'Status', color: AppColors.amber500),
      if (attendingBreakfast)
        const ModernMetricStat(icon: Icons.breakfast_dining_rounded, value: 'Yes', label: 'Breakfast'),
      if (attendingLunch)
        const ModernMetricStat(icon: Icons.lunch_dining_rounded, value: 'Yes', label: 'Lunch'),
      if (attendingDinner)
        const ModernMetricStat(icon: Icons.restaurant_rounded, value: 'Yes', label: 'Dinner'),
      if (needsBuggy)
        const ModernMetricStat(icon: Icons.electric_rickshaw_rounded, value: 'Yes', label: 'Buggy'),
      ModernMetricStat(
        icon: hasPaid ? Icons.payments_rounded : Icons.info_outline_rounded, 
        value: hasPaid ? 'Paid' : 'Due', 
        label: 'Payment',
        color: hasPaid ? null : AppColors.amber500,
      ),
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
                padding: EdgeInsets.only(right: box == row.last && row.length == 4 ? 0 : AppSpacing.md),
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

  Widget _buildDetailSnippet(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.label.copyWith(fontWeight: AppTypography.weightStrong),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class EventGalleryCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isManagement;
  final bool isPeeking;
  const EventGalleryCard({super.key, required this.event, this.isManagement = false, this.isPeeking = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isManagement && event.galleryUrls.isEmpty) return const SizedBox.shrink();
    final config = ref.watch(themeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(title: 'Event Gallery', isPeeking: isPeeking),
        BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (event.galleryUrls.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: event.galleryUrls.length > 5 ? 5 : event.galleryUrls.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: AppShapes.md,
                        child: BoxyArtImage(
                          url: event.galleryUrls[index],
                          width: 160,
                          height: 120,
                          fit: BoxFit.cover,
                          errorWidget: Container(
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
              ],
              BoxyArtButton(
                title: event.galleryUrls.length > 5 ? 'View All ${event.galleryUrls.length} Photos' : 'View Gallery',
                fullWidth: true,
                backgroundColor: Color(config.primaryColor),
                textColor: ContrastHelper.getContrastingText(Color(config.primaryColor)),
                onTap: isManagement ? null : () {
                  context.push('/events/${event.id}/photos');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventPodiumCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isManagement;
  final bool isPeeking;
  const EventPodiumCard({super.key, required this.event, this.isManagement = false, this.isPeeking = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isManagement) {
      final status = event.displayStatus;
      if ((status != EventStatus.completed && status != EventStatus.inPlay) || event.results.isEmpty) {
        return const SizedBox.shrink();
      }
    }

    final topResults = event.results.take(3).toList();
    final membersAsync = ref.watch(allMembersProvider);
    final members = membersAsync.value ?? [];
    
    // In management mode, if no results yet, show a dummy/placeholder to represent the block
    if (isManagement && topResults.isEmpty) {
      return Column(
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
                  style: AppTypography.label.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (topResults.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(
          title: event.displayStatus == EventStatus.inPlay ? 'Live Leaderboard' : 'Event Recap & Results', 
          isPeeking: isPeeking,
        ),
          BoxyArtCard(
            child: Column(
              children: [
                ...topResults.asMap().entries.map((entry) {
                   final rank = entry.key + 1;
                   final res = entry.value;
                   final memberId = res['memberId'];
                   final member = members.firstWhereOrNull((m) => m.id == memberId);
                   final memberName = member != null ? '${member.firstName} ${member.lastName}' : (res['memberName'] ?? res['playerName'] ?? 'Player');
                   final photoUrl = member?.avatarUrl ?? res['avatarUrl'] ?? res['photoUrl'];
                   final score = res['totalPoints'] ?? res['score'] ?? res['points'] ?? '-';

                   return ListTile(
                     contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 42,
                        height: 42,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            BoxyArtAvatar(
                              url: photoUrl,
                              initials: memberName.isNotEmpty ? memberName[0] : 'P',
                              radius: 18,
                              isCircle: true,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: BoxyArtNumberBadge(
                                number: rank,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(memberName, style: AppTypography.body.copyWith(fontWeight: AppTypography.weightHeavy)),
                      trailing: Text('$score pts', style: AppTypography.headline.copyWith(fontSize: 18.0, fontWeight: AppTypography.weightHeavy, color: null)),
                    );
                }),
              ],
            ),
          ),
        ],
      );
  }
}

class YourGroupCard extends ConsumerWidget {
  final GolfEvent event;
  final bool isPeeking;
  const YourGroupCard({super.key, required this.event, this.isPeeking = false});

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
            // Logic: Identify 'ME' in the group. 
            // If there's a Member + Guest, we prefer the Member identity for the 'ME' marker.
            if (p.registrationMemberId == user.id && !p.isGuest) {
              myParticipant = p;
              myGroup = group;
              break;
            }
          }
          
          // Fallback: If no pure member match (maybe they are registered as a guest only?), 
          // take any match with their ID.
          if (myParticipant == null) {
            for (var p in group.players) {
              if (p.registrationMemberId == user.id) {
                myParticipant = p;
                myGroup = group;
                break;
              }
            }
          }
        } catch (_) {}
        if (myParticipant != null) break;
      }
    }

    if (myParticipant == null || myGroup == null) return const SizedBox.shrink();

    // Fix: Exclude only the specific participant object 'me', not everyone with my registration ID
    // (This ensures my guest is correctly shown as a partner)
    final partnersList = myGroup.players
        .where((p) => p != myParticipant) 
        .map((p) => toTitleCase(p.name))
        .toList();
        
    final partners = partnersList.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(
          title: 'Your Group',
          isPeeking: isPeeking,
        ),
        BoxyArtCard(
          gradient: AppGradients.brandPrimary(context),
          isHero: true,
          customShadows: Theme.of(context).extension<AppShadows>()?.softScale,
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModernInfoRow(
                icon: Icons.access_time_rounded,
                label: 'Tee Time',
                value: DateFormat.Hm().format(myGroup.teeTime),
                labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                valueColor: AppColors.pureWhite,
                iconColor: AppColors.pureWhite,
                fontSize: AppTypography.sizeHeadline,
              ),
              const SizedBox(height: AppSpacing.xl),
              ModernInfoRow(
                icon: Icons.people_alt_rounded,
                label: 'Partners',
                value: partners.isEmpty ? "Alone" : partners,
                labelColor: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh),
                valueColor: AppColors.pureWhite,
                iconColor: AppColors.pureWhite,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
