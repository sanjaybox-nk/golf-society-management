import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:io';
import 'package:go_router/go_router.dart';
import '../../domain/registration_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/competition.dart';
import '../../../competitions/presentation/widgets/competition_shared_widgets.dart';

class EventUserDetailsTab extends ConsumerWidget {
  final String eventId;
  final bool useScaffold;

  const EventUserDetailsTab({super.key, required this.eventId, this.useScaffold = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    
    return eventAsync.when(
      data: (event) {
        final config = ref.watch(themeControllerProvider);
        final user = ref.watch(effectiveUserProvider);
        final isAdmin = user.role != MemberRole.member;

        // Check for preview mode
        bool isPreview = false;
        try {
          isPreview = GoRouterState.of(context).uri.queryParameters['preview'] == 'true';
        } catch (_) {
          isPreview = false;
        }

        return EventDetailsContent(
          event: event, 
          currencySymbol: config.currencySymbol,
          isPreview: isPreview,
          useScaffold: useScaffold,
          onStatusChanged: isAdmin ? (newStatus) {
            ref.read(eventsRepositoryProvider).updateEvent(
              event.copyWith(status: newStatus),
            );
          } : null,
        );
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

class EventDetailsContent extends ConsumerWidget {
  final GolfEvent event;
  final String currencySymbol;
  final bool isPreview;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final ValueChanged<EventStatus>? onStatusChanged;
  final Widget? bottomNavigationBar;
  final bool useScaffold;
  final Competition? competition; // Optional direct competition object for previewing

  const EventDetailsContent({
    super.key,
    required this.event, 
    required this.currencySymbol,
    this.isPreview = false,
    this.onCancel,
    this.onEdit,
    this.onStatusChanged,
    this.bottomNavigationBar,
    this.useScaffold = true,
    this.competition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final isAdmin = user.role != MemberRole.member;

    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Info Hub',
      useScaffold: useScaffold,
      leading: isPreview ? Center(
        child: BoxyArtGlassIconButton(
          icon: Icons.close_rounded,
          iconSize: 24,
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ) : null,
      showBack: !isPreview,
      onBack: () {
        if (isPreview && onCancel != null) {
          onCancel!();
          return;
        }
        try {
          context.go('/events');
        } catch (_) {
          Navigator.of(context).pop();
        }
      },
      actions: [
        if (!isPreview) ...[
          if (onEdit != null)
            BoxyArtGlassIconButton(
              icon: Icons.edit_rounded,
              iconSize: 24,
              onPressed: onEdit,
              tooltip: 'Edit Event Settings',
            )
          else if (isAdmin) ...[
            BoxyArtGlassIconButton(
              icon: Icons.edit_rounded,
              iconSize: 24,
              onPressed: () {
                final id = event.id;
                context.push('/admin/events/manage/${Uri.encodeComponent(id)}/event/edit', extra: event);
              },
              tooltip: 'Edit Event Settings',
            ),
            if (event.eventType == EventType.golf)
              BoxyArtGlassIconButton(
                icon: Icons.tune_rounded,
                iconSize: 24,
                onPressed: () {
                  context.push('/admin/events/manage/${Uri.encodeComponent(event.id)}/manual-cuts');
                },
                tooltip: 'Manual Handicap Cuts',
              ),
          ],
        ],
      ],
      bottomNavigationBar: bottomNavigationBar,
      slivers: [
        // Status Badge (Integrated into content)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
            child: _buildStatusBadge(context),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
                SizedBox(height: AppTheme.cardSpacing),
                _buildRegistrationCard(context),
                SizedBox(height: AppTheme.cardSpacing),
                _buildHeroSection(context),
                SizedBox(height: AppTheme.cardSpacing),
              _buildDateTimeSection(context),
              SizedBox(height: AppTheme.cardSpacing),
              if (event.eventType == EventType.golf) ...[
                _buildCourseSelectionSection(context),
                _buildCourseDataHardeningSection(context),
                SizedBox(height: AppTheme.cardSpacing),
              ],
              if (event.eventType == EventType.golf) ...[
                CompetitionRulesCard(
                  eventId: event.id,
                  title: 'Competition Rules',
                  competition: competition,
                ),
              ],
              if (event.eventType == EventType.golf && event.secondaryTemplateId != null) ...[
                SizedBox(height: AppTheme.cardSpacing),
                _buildSecondaryRulesSection(context),
              ],
              SizedBox(height: AppTheme.cardSpacing),
              _buildPlayingCostsSection(context),
              SizedBox(height: AppTheme.cardSpacing),
              _buildMealCostsSection(context),
              SizedBox(height: AppTheme.cardSpacing),
              _buildDinnerLocationSection(context),
              SizedBox(height: AppTheme.cardSpacing),
              _buildFacilitiesSection(context),
              SizedBox(height: AppTheme.cardSpacing),
              _buildAwardsSection(context, ref),
              SizedBox(height: AppTheme.cardSpacing),
              _buildNotesSection(context),
            ]),
          ),
        ),
      ],
    );
  }


  Widget _buildStatusBadge(BuildContext context) {
    final displayStatus = event.displayStatus;
    
    // Member view uses user-friendly labels
    // Admin view shows technical statuses (draft/published/inplay/completed)
    String statusText;
    Color statusColor;
    
    if (displayStatus == EventStatus.draft) {
      statusText = 'DRAFT';
      statusColor = AppColors.amber500;
    } else if (displayStatus == EventStatus.completed) {
      statusText = 'COMPLETED';
      statusColor = AppColors.textSecondary;
    } else if (displayStatus == EventStatus.inPlay) {
      statusText = 'LIVE';
      statusColor = AppColors.teamA;
    } else if (displayStatus == EventStatus.suspended) {
      statusText = 'SUSPENDED';
      statusColor = Colors.deepOrange;
    } else if (displayStatus == EventStatus.cancelled) {
      statusText = 'CANCELLED';
      statusColor = AppColors.coral500;
    } else {
      statusText = 'PUBLISHED';
      statusColor = const Color(0xFF27AE60);
    }

    final badge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BoxyArtPill.status(
          label: statusText,
          color: statusColor,
        ),
        if (onStatusChanged != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.keyboard_arrow_down_rounded, size: AppShapes.iconXs, color: statusColor),
        ],
      ],
    );

    if (onStatusChanged == null) return badge;

    return GestureDetector(
      onTap: () => _showStatusSelector(context),
      child: badge,
    );
  }

  void _showStatusSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BoxyArtCard(
        margin: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Change Event Status',
                style: TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLargeBody),
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: EventStatus.values.map((s) {
                    String label = s.name;
                    if (s == EventStatus.inPlay) label = 'Live';
                    
                    return ListTile(
                      leading: Icon(
                        _getStatusIcon(s),
                        color: _getStatusColor(s),
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight: event.status == s ? AppTypography.weightBold : AppTypography.weightRegular,
                          color: event.status == s ? _getStatusColor(s) : null,
                        ),
                      ),
                      trailing: event.status == s ? Icon(Icons.check_rounded, color: _getStatusColor(s)) : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (onStatusChanged != null) {
                          onStatusChanged!(s);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.cardSpacing),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(EventStatus status) {
    switch (status) {
      case EventStatus.draft: return Icons.edit_note_rounded;
      case EventStatus.published: return Icons.public_rounded;
      case EventStatus.inPlay: return Icons.play_circle_outline_rounded;
      case EventStatus.suspended: return Icons.pause_circle_outline_rounded;
      case EventStatus.completed: return Icons.check_circle_outline_rounded;
      case EventStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft: return AppColors.amber500;
      case EventStatus.published: return const Color(0xFF27AE60);
      case EventStatus.inPlay: return AppColors.teamA;
      case EventStatus.suspended: return Colors.deepOrange;
      case EventStatus.completed: return AppColors.textSecondary;
      case EventStatus.cancelled: return AppColors.coral500;
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return BoxyArtCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppShapes.xl,
              child: Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  event.description!,
                  style: TextStyle(
                    fontSize: AppTypography.sizeButton,
                    fontWeight: AppTypography.weightSemibold,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (event.description != null && event.description!.isNotEmpty) {
      return BoxyArtCard(
        child: Text(
          event.description!,
          style: TextStyle(
            fontSize: AppTypography.sizeButton,
            fontWeight: AppTypography.weightSemibold,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
            height: 1.5,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }


  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Date & Time'),
        BoxyArtCard(
          child: Column(
            children: [
              ModernInfoRow(
                label: event.isMultiDay ? 'Start Date' : 'Event Date',
                value: DateFormat('EEEE, d MMM yyyy').format(event.date),
                icon: Icons.calendar_today_rounded,
              ),
              if (event.isMultiDay && event.endDate != null) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                ModernInfoRow(
                  label: 'End Date',
                  value: DateFormat('EEEE, d MMM yyyy').format(event.endDate!),
                  icon: Icons.calendar_today_rounded,
                ),
              ],
              const SizedBox(height: AppTheme.cardSpacing),
              if (event.eventType == EventType.golf) ...[
                ModernInfoRow(
                  label: 'Tee-off',
                  value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: AppTheme.cardSpacing),
              ],
              ModernInfoRow(
                label: 'Registration',
                value: event.regTime != null 
                    ? DateFormat('h:mm a').format(event.regTime!)
                    : 'TBA',
                icon: Icons.app_registration_rounded,
              ),
              if (event.registrationDeadline != null) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                ModernInfoRow(
                  label: 'Deadline',
                  value: '${DateFormat('d MMM').format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                  icon: Icons.timer_outlined,
                  iconColor: Colors.redAccent,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Course'),
        BoxyArtCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ModernInfoRow(
                      label: 'Location',
                      value: event.courseName ?? 'TBA',
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                  if (event.courseName != null)
                    IconButton(
                      icon: Icon(
                        Icons.map_outlined, 
                        color: Theme.of(context).primaryColor,
                        size: AppShapes.iconMd,
                      ),
                      onPressed: () => _launchMap(event.courseName!, event.courseDetails),
                    ),
                ],
              ),
              if (event.courseDetails != null && event.courseDetails!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    event.courseDetails!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: AppTypography.sizeLabelStrong,
                    ),
                  ),
                ),
              ],
              if (event.eventType == EventType.golf && (event.selectedTeeName != null || event.selectedFemaleTeeName != null)) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                Builder(
                  builder: (context) {
                    final maleTee = event.selectedTeeName;
                    final femaleTee = event.selectedFemaleTeeName;
                    String value;
                    if (maleTee != null && femaleTee != null) {
                      if (maleTee == femaleTee) {
                        value = maleTee;
                      } else {
                        value = '$maleTee / $femaleTee';
                      }
                    } else {
                      value = maleTee ?? femaleTee ?? 'TBA';
                    }
                    return ModernInfoRow(
                      label: 'Tee Position',
                      value: value,
                      icon: Icons.flag_rounded,
                    );
                  }
                ),
              ],
              if (event.maxParticipants != null) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                Builder(
                  builder: (context) {
                    final stats = RegistrationLogic.getRegistrationStats(event);
                    final available = (event.maxParticipants! - stats.confirmedGolfers).clamp(0, event.maxParticipants!);
                    return ModernInfoRow(
                      label: 'Field Capacity',
                      value: '$available / ${event.maxParticipants} slots available',
                      icon: Icons.groups_rounded,
                      iconColor: available == 0 ? Colors.redAccent : null,
                    );
                  }
                ),
              ],
              const SizedBox(height: AppTheme.cardSpacing),
              ModernInfoRow(
                label: 'Dress Code',
                value: event.dressCode ?? 'Standard Golf Attire',
                icon: Icons.checkroom_rounded,
              ),
              if (event.eventType == EventType.golf && event.availableBuggies != null) ...[
                const SizedBox(height: AppTheme.cardSpacing),
                ModernInfoRow(
                  label: 'Buggies',
                  value: '${event.availableBuggies} available',
                  icon: Icons.electric_rickshaw_rounded,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchMap(String courseName, String? details) async {
    final query = details != null && details.isNotEmpty 
        ? '$courseName, $details' 
        : courseName;
    final encodedQuery = Uri.encodeComponent(query);
    
    // Use platform specific URL schemes if possible, fallback to universal
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$encodedQuery';

    final Uri url = Uri.parse(Platform.isIOS ? appleMapsUrl : googleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to generic browser search if map apps can't be launched
        final searchUrl = Uri.parse('https://www.google.com/search?q=$encodedQuery');
        await launchUrl(searchUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Silently fail or show error
    }
  }

  Widget _buildCourseDataHardeningSection(BuildContext context) {
    // Only show for Admins (based on presence of onStatusChanged callback)
    if (onStatusChanged == null || event.eventType == EventType.social) return const SizedBox.shrink();

    final config = event.courseConfig;
    final slope = config.slope;
    final rating = config.rating;
    final par = config.par;

    final bool isMissing = (slope ?? 0) <= 0 || (rating ?? 0) <= 0 || (par ?? 0) <= 0;
    if (!isMissing) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.cardSpacing),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.coral500.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.xl,
                border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityMedium)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       const Icon(Icons.warning_amber_rounded, color: AppColors.coral500, size: AppShapes.iconLg),
                       const SizedBox(width: AppSpacing.md),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text(
                               'Missing Course Data',
                               style: TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeBody, color: AppColors.coral500),
                             ),
                             Text(
                               'Handicaps cannot be accurately calculated.',
                               style: TextStyle(fontSize: AppTypography.sizeLabelStrong, color: AppColors.coral500.withValues(alpha: AppColors.opacityHigh)),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: AppSpacing.xl),
                   _buildManualDataFixer(context, ref),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildManualDataFixer(BuildContext context, WidgetRef ref) {
    final config = event.courseConfig;
    final slopeController = TextEditingController(text: config.slope.toString());
    final ratingController = TextEditingController(text: config.rating.toString());
    final parController = TextEditingController(text: config.par.toString());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniInput(context, 'Slope', slopeController),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMiniInput(context, 'Rating', ratingController),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMiniInput(context, 'Par', parController),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.cardSpacing),
        BoxyArtButton(
          title: 'Apply Course Updates',
          isPrimary: true,
          onTap: () async {
             final updatedConfig = event.courseConfig.copyWith(
               slope: (double.tryParse(slopeController.text) ?? 113).toInt(),
               rating: double.tryParse(ratingController.text) ?? 72.0,
               par: (double.tryParse(parController.text) ?? 72).toInt(),
             );

             final updatedEvent = event.copyWith(courseConfig: updatedConfig);
             await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
             
             if (context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Course data updated! Scroll to Grouping to Recalculate HCPs.'))
               );
             }
          },
        ),
      ],
    );
  }

  Widget _buildMiniInput(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, letterSpacing: 1.0),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBody),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard(BuildContext context) {
    if (!event.showRegistrationButton || 
        (!isPreview && (
          event.displayStatus == EventStatus.draft || 
          event.displayStatus == EventStatus.cancelled ||
          event.displayStatus == EventStatus.completed ||
          event.displayStatus == EventStatus.inPlay
        ))) {
      return const SizedBox.shrink();
    }

    // For now, we'll assume the user is a mock member
    const currentMemberId = 'current-user-id';
    
    final myRegistration = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
    final isRegistered = myRegistration != null;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);

    // If past deadline and not registered, hide entire section
    if (isPastDeadline && !isRegistered) {
      return const SizedBox.shrink();
    }

    final stats = RegistrationLogic.getRegistrationStats(event);
    final isFull = event.maxParticipants != null && stats.confirmedGolfers >= event.maxParticipants!;

    return BoxyArtCard(
      child: Column(
        children: [
          if (!isRegistered) ...[
            Column(
              children: [
                Text(
                  isFull ? 'Event Full' : 'Secure your spot',
                  style: const TextStyle(
                    fontWeight: AppTypography.weightBlack,
                    fontSize: AppTypography.sizeLargeBody,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (event.registrationDeadline != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isFull ? 'Register to join the waitlist' : 'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh), 
                      fontSize: AppTypography.sizeLabelStrong,
                      fontWeight: AppTypography.weightExtraBold,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isFull ? 'Join the waitlist below' : 'Register below to join the event',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: AppTypography.sizeLabelStrong),
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
                  style: const TextStyle(
                    fontWeight: AppTypography.weightBlack,
                    fontSize: AppTypography.sizeLargeBody,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2l),
          ],
          BoxyArtButton(
            title: isRegistered ? 'Edit Registration' : (isFull ? 'Register (Waitlist)' : 'Register Now'),
            onTap: (isPreview || isPastDeadline) ? null : () {
              try {
                GoRouter.of(context).push('/events/${event.id}/register-form');
              } catch (_) {
                // Silently fail or handled by isPreview being disabled
              }
            },
          ),
          
          if (isRegistered) ...[
            const SizedBox(height: AppSpacing.x3l),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ModernMetricStat(
                      value: myRegistration.hasPaid ? 'YES' : 'NO',
                      label: 'Paid',
                      icon: Icons.payments_rounded,
                      color: myRegistration.hasPaid ? const Color(0xFF27AE60) : AppColors.dark400,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: myRegistration.attendingBreakfast ? 'YES' : 'NO',
                      label: 'Breakfast',
                      icon: Icons.breakfast_dining_rounded,
                      color: myRegistration.attendingBreakfast ? const Color(0xFF795548) : AppColors.dark400,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: myRegistration.attendingLunch ? 'YES' : 'NO',
                      label: 'Lunch',
                      icon: Icons.lunch_dining_rounded,
                      color: myRegistration.attendingLunch ? const Color(0xFFD35400) : AppColors.dark400,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: myRegistration.attendingDinner ? 'YES' : 'NO',
                      label: 'Dinner',
                      icon: Icons.dinner_dining_rounded,
                      color: myRegistration.attendingDinner ? const Color(0xFF2980B9) : AppColors.dark400,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }




  Widget _buildSecondaryRulesSection(BuildContext context) {
    return CompetitionRulesCard(
      eventId: '${event.id}_secondary',
      title: 'Secondary Game (Overlay)',
      isSecondary: true,
    );
  }


  Widget _buildPlayingCostsSection(BuildContext context) {
    if (event.eventType == EventType.social) {
      if (event.eventCost == null || event.eventCost == 0) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BoxyArtSectionTitle(title: 'Event Cost'),
          BoxyArtCard(
            child: ModernCostRow(
              label: 'Per Person', 
              amount: '$currencySymbol${event.eventCost!.toStringAsFixed(2)}',
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Playing Costs'),
        BoxyArtCard(
          child: Column(
            children: [
              ModernCostRow(
                label: 'Member Golf', 
                amount: '$currencySymbol${event.memberCost?.toStringAsFixed(2) ?? 'TBA'}',
              ),
              if (event.guestCost != null) ...[
                const SizedBox(height: 10),
                ModernCostRow(
                  label: 'Guest Golf', 
                  amount: '$currencySymbol${event.guestCost?.toStringAsFixed(2)}',
                ),
              ],
              if (event.buggyCost != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1),
                ),
                ModernCostRow(
                  label: 'Buggy Hire', 
                  amount: '$currencySymbol${event.buggyCost?.toStringAsFixed(2)}',
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payable to Pro Shop',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf), 
                      fontSize: AppTypography.sizeLabelStrong,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMealCostsSection(BuildContext context) {
    final bool hasBreakfast = event.hasBreakfast && event.breakfastCost != null;
    final bool hasLunch = event.hasLunch && event.lunchCost != null;
    final bool hasDinner = event.hasDinner && event.dinnerCost != null;

    if (!hasBreakfast && !hasLunch && !hasDinner) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Meals'),
        BoxyArtCard(
          child: Column(
            children: [
              if (hasBreakfast) ...[
                ModernCostRow(label: 'Breakfast', amount: '$currencySymbol${event.breakfastCost?.toStringAsFixed(2)}'),
                if (hasLunch || hasDinner) const SizedBox(height: 10),
              ],
              if (hasLunch) ...[
                ModernCostRow(label: 'Lunch', amount: '$currencySymbol${event.lunchCost?.toStringAsFixed(2)}'),
                if (hasDinner) const SizedBox(height: 10),
              ],
              if (hasDinner) ModernCostRow(label: 'Dinner', amount: '$currencySymbol${event.dinnerCost?.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(BuildContext context) {
    if (event.facilities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Facilities'),
        BoxyArtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: event.facilities.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFF27AE60).withValues(alpha: AppColors.opacityLow),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: AppShapes.iconSm, color: Color(0xFF27AE60)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontWeight: AppTypography.weightSemibold, 
                        fontSize: AppTypography.sizeBody,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: AppColors.opacityStrong),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    if (event.notes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Notes & Content'),
        ...event.notes.map((note) => _buildNoteCard(context, note)),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, EventNote note) {
    QuillController? quillController;
    try {
      if (note.content.isNotEmpty) {
        quillController = QuillController(
          document: Document.fromJson(jsonDecode(note.content)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty) ...[
              Text(
                note.title!,
                style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLargeBody),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppTheme.cardSpacing),
            ],
            if (note.imageUrl != null) ...[
              ClipRRect(
                borderRadius: AppShapes.lg,
                child: Image.network(
                  note.imageUrl!,
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
                config: QuillEditorConfig(
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

  Widget _buildDinnerLocationSection(BuildContext context) {
    if (event.dinnerLocation == null || event.dinnerLocation!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Dinner Info'),
        BoxyArtCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ModernInfoRow(
                  label: 'Location',
                  value: event.dinnerLocation!,
                  icon: Icons.restaurant_rounded,
                ),
              ),
              if (isPreview == false)
                IconButton(
                  icon: Icon(
                    Icons.map_outlined,
                    color: Theme.of(context).primaryColor,
                    size: AppShapes.iconMd,
                  ),
                  onPressed: () => _launchMap(event.dinnerLocation!, null),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAwardsSection(BuildContext context, WidgetRef ref) {
    if (event.eventType == EventType.social || !event.showAwards || event.awards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Event Prizes'),
        BoxyArtCard(
          child: Column(
            children: event.awards.map((award) {
              final isLast = award == event.awards.last;
              IconData icon;
              Color iconColor;
              
              switch (award.type.toLowerCase()) {
                case 'cup':
                  icon = Icons.emoji_events_rounded;
                  iconColor = const Color(0xFFFFD700); // Gold
                  break;
                case 'voucher':
                  icon = Icons.confirmation_number_rounded;
                  iconColor = const Color(0xFF27AE60);
                  break;
                default:
                  icon = Icons.payments_rounded;
                  iconColor = const Color(0xFF2D9CDB);
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: AppColors.opacityLow),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: AppShapes.iconMd, color: iconColor),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                award.label,
                                style: const TextStyle(
                                  fontSize: AppTypography.sizeBody,
                                  fontWeight: AppTypography.weightBold,
                                ),
                              ),
                              if (award.type.toLowerCase() != 'cup' && award.value > 0)
                                Text(
                                  'Value: ${ref.watch(themeControllerProvider).currencySymbol}${award.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeLabelStrong,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                                  ),
                                )
                              else
                                Text(
                                  toTitleCase(award.type),
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeLabel,
                                    fontWeight: AppTypography.weightExtraBold,
                                    letterSpacing: 0.5,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHalf),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


}


String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
