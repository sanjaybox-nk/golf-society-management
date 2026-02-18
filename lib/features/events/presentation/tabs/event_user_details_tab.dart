import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../../core/shared_ui/shared_ui.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:io';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../domain/registration_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/competition.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../../features/competitions/utils/competition_rule_translator.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../../models/member.dart';

class EventUserDetailsTab extends ConsumerWidget {
  final String eventId;

  const EventUserDetailsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        
        if (event == null) {
          return const Scaffold(
            body: Center(
              child: Text('Event data no longer available'),
            ),
          );
        }
        
        final config = ref.watch(themeControllerProvider);
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
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
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

  const EventDetailsContent({
    super.key,
    required this.event, 
    required this.currencySymbol,
    this.isPreview = false,
    this.onCancel,
    this.onEdit,
    this.onStatusChanged,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final isAdmin = user.role != MemberRole.member;

    return HeadlessScaffold(
      title: event.title,
      subtitle: 'Info Hub',
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
        if (onEdit != null)
          BoxyArtGlassIconButton(
            icon: Icons.edit_outlined,
            iconSize: 24,
            onPressed: onEdit,
            tooltip: 'Edit Event Settings',
          )
        else if (isAdmin)
          BoxyArtGlassIconButton(
            icon: Icons.app_registration_rounded,
            iconSize: 24,
            onPressed: () {
               final id = event.id;
               context.push('/admin/events/manage/$id/event/edit', extra: event);
            },
            tooltip: 'Edit Event Settings',
          ),
      ],
      bottomNavigationBar: bottomNavigationBar,
      slivers: [
        // Status Badge (Integrated into content)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatusBadge(context),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              _buildRegistrationCard(context),
              const SizedBox(height: 24),
              _buildHeroSection(context),
              const SizedBox(height: 32),
              _buildDateTimeSection(context),
              const SizedBox(height: 24),
              _buildCourseSelectionSection(context),
              const SizedBox(height: 24),
              _buildCompetitionRulesSection(context),
              if (event.secondaryTemplateId != null) ...[
                const SizedBox(height: 24),
                _buildSecondaryRulesSection(context),
              ],
              const SizedBox(height: 24),
              _buildPlayingCostsSection(context),
              const SizedBox(height: 24),
              _buildMealCostsSection(context),
              const SizedBox(height: 24),
              _buildDinnerLocationSection(context),
              const SizedBox(height: 24),
              _buildFacilitiesSection(context),
              const SizedBox(height: 24),
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
      statusColor = Colors.orange;
    } else if (displayStatus == EventStatus.completed) {
      statusText = 'COMPLETED';
      statusColor = Colors.grey;
    } else if (displayStatus == EventStatus.inPlay) {
      statusText = 'LIVE';
      statusColor = Colors.blue;
    } else if (displayStatus == EventStatus.suspended) {
      statusText = 'SUSPENDED';
      statusColor = Colors.deepOrange;
    } else if (displayStatus == EventStatus.cancelled) {
      statusText = 'CANCELLED';
      statusColor = Colors.red;
    } else {
      statusText = 'PUBLISHED';
      statusColor = const Color(0xFF27AE60);
    }

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          if (onStatusChanged != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: statusColor),
          ],
        ],
      ),
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
      builder: (context) => BoxyArtFloatingCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Change Event Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: EventStatus.values.map((s) {
                    String label = s.name.toUpperCase();
                    if (s == EventStatus.inPlay) label = 'LIVE';
                    
                    return ListTile(
                      leading: Icon(
                        _getStatusIcon(s),
                        color: _getStatusColor(s),
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight: event.status == s ? FontWeight.bold : FontWeight.normal,
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
            const SizedBox(height: 16),
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
      case EventStatus.draft: return Colors.orange;
      case EventStatus.published: return const Color(0xFF27AE60);
      case EventStatus.inPlay: return Colors.blue;
      case EventStatus.suspended: return Colors.deepOrange;
      case EventStatus.completed: return Colors.grey;
      case EventStatus.cancelled: return Colors.red;
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return ModernCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  event.description!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (event.description != null && event.description!.isNotEmpty) {
      return ModernCard(
        child: Text(
          event.description!,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
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
        const SizedBox(height: 12),
        ModernCard(
          child: Column(
            children: [
              ModernInfoRow(
                label: event.isMultiDay ? 'Start Date' : 'Event Date',
                value: DateFormat('EEEE, d MMM yyyy').format(event.date),
                icon: Icons.calendar_today_rounded,
              ),
              if (event.isMultiDay && event.endDate != null) ...[
                const SizedBox(height: 16),
                ModernInfoRow(
                  label: 'End Date',
                  value: DateFormat('EEEE, d MMM yyyy').format(event.endDate!),
                  icon: Icons.calendar_today_rounded,
                ),
              ],
              const SizedBox(height: 16),
              ModernInfoRow(
                label: 'Tee-off',
                value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 16),
              ModernInfoRow(
                label: 'Registration',
                value: event.regTime != null 
                    ? DateFormat('h:mm a').format(event.regTime!)
                    : 'TBA',
                icon: Icons.app_registration_rounded,
              ),
              if (event.registrationDeadline != null) ...[
                const SizedBox(height: 16),
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
        const SizedBox(height: 12),
        ModernCard(
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
                        size: 20,
                      ),
                      onPressed: () => _launchMap(event.courseName!, event.courseDetails),
                    ),
                ],
              ),
              if (event.courseDetails != null && event.courseDetails!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    event.courseDetails!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              if (event.selectedTeeName != null) ...[
                const SizedBox(height: 16),
                ModernInfoRow(
                  label: 'Tee Position',
                  value: event.selectedTeeName!,
                  icon: Icons.flag_rounded,
                ),
              ],
              if (event.maxParticipants != null) ...[
                const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              ModernInfoRow(
                label: 'Dress Code',
                value: event.dressCode ?? 'Standard Golf Attire',
                icon: Icons.checkroom_rounded,
              ),
              if (event.availableBuggies != null) ...[
                const SizedBox(height: 16),
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

  Widget _buildRegistrationCard(BuildContext context) {
    // Hide only if registration button is disabled or event is draft/cancelled
    if (!event.showRegistrationButton || 
        event.displayStatus == EventStatus.draft || 
        event.displayStatus == EventStatus.cancelled) {
      return const SizedBox.shrink();
    }

    // For now, we'll assume the user is a mock member
    const currentMemberId = 'current-user-id';
    
    final myRegistration = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
    final isRegistered = myRegistration != null;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);

    // Show "Registration Closed" card if past deadline
    if (isPastDeadline) {
      return ModernCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'REGISTRATION CLOSED',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Registration deadline has passed',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final stats = RegistrationLogic.getRegistrationStats(event);
    final isFull = event.maxParticipants != null && stats.confirmedGolfers >= event.maxParticipants!;

    return ModernCard(
      child: Column(
        children: [
          if (!isRegistered) ...[
            Column(
              children: [
                Text(
                  isFull ? 'Event Full' : 'Secure your spot',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (event.registrationDeadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isFull ? 'Register to join the waitlist' : 'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          BoxyArtButton(
            title: isRegistered ? 'Edit Registration' : (isFull ? 'Register (Waitlist)' : 'Register Now'),
            onTap: isPreview ? null : () {
              try {
                GoRouter.of(context).push('/events/${event.id}/register-form');
              } catch (_) {
                // Silently fail or handled by isPreview being disabled
              }
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
    );
  }


  Widget _buildCompetitionRulesSection(BuildContext context) {
    return _CompetitionRulesCard(
      eventId: event.id,
      title: 'Competition Rules',
      icon: Icons.golf_course,
      iconColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSecondaryRulesSection(BuildContext context) {
    return _CompetitionRulesCard(
      eventId: '${event.id}_secondary',
      title: 'Secondary Game (Overlay)',
      icon: Icons.compare_arrows,
      iconColor: Colors.orange,
    );
  }


  Widget _buildPlayingCostsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Playing Costs'),
        const SizedBox(height: 12),
        ModernCard(
          child: Column(
            children: [
              _buildModernCostRow(context, 'Member Cost', event.memberCost),
              if (event.guestCost != null) ...[
                const SizedBox(height: 12),
                _buildModernCostRow(context, 'Guest Cost', event.guestCost),
              ],
              if (event.buggyCost != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildModernCostRow(context, 'Buggy Cost', event.buggyCost, subtitle: 'Payable to Pro Shop'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernCostRow(BuildContext context, String label, double? cost, {String? subtitle}) {
    if (cost == null) return const SizedBox.shrink();
    
    final String costText = cost == 0 
        ? 'FREE' 
        : '$currencySymbol${cost.toStringAsFixed(2)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11),
              ),
          ],
        ),
        Text(
          costText, 
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          )
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
        const SizedBox(height: 12),
        ModernCard(
          child: Column(
            children: [
              if (hasBreakfast) ...[
                _buildModernCostRow(context, 'Breakfast', event.breakfastCost),
                if (hasLunch || hasDinner) const SizedBox(height: 12),
              ],
              if (hasLunch) ...[
                _buildModernCostRow(context, 'Lunch', event.lunchCost),
                if (hasDinner) const SizedBox(height: 12),
              ],
              if (hasDinner) _buildModernCostRow(context, 'Dinner', event.dinnerCost),
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
        const SizedBox(height: 12),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: event.facilities.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF27AE60)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
        const SizedBox(height: 12),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty) ...[
              Text(
                note.title!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 16),
            ],
            if (note.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  note.imageUrl!,
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
              const SizedBox(height: 16),
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
        const SizedBox(height: 12),
        ModernCard(
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
                    size: 20,
                  ),
                  onPressed: () => _launchMap(event.dinnerLocation!, null),
                ),
            ],
          ),
        ),
      ],
    );
  }


}

class _CompetitionRulesCard extends ConsumerWidget {
  final String eventId;
  final String title;
  final IconData icon;
  final Color iconColor;

  const _CompetitionRulesCard({
    required this.eventId,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compsAsync = ref.watch(competitionDetailProvider(eventId));
    
    return compsAsync.when(
      data: (comp) {
        if (comp == null) return const SizedBox.shrink();
        
        final description = CompetitionRuleTranslator.translate(comp.rules);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxyArtSectionTitle(title: title),
            const SizedBox(height: 12),
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (comp.name != null && comp.name!.isNotEmpty)
                                  ? comp.name!.toUpperCase()
                                  : comp.rules.gameName.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (comp.name != null && comp.name!.isNotEmpty)
                              Text(
                                comp.rules.gameName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      BoxyArtStatusPill(
                        text: comp.rules.scoringType.toUpperCase(),
                        baseColor: comp.rules.scoringType == 'GROSS' ? const Color(0xFFE74C3C) : (eventId.contains('_secondary') ? const Color(0xFFF39C12) : const Color(0xFF16A085)),
                      ),
                      BoxyArtStatusPill(
                        text: comp.rules.defaultAllowanceLabel,
                        baseColor: iconColor,
                      ),
                      BoxyArtStatusPill(
                        text: comp.rules.modeLabel,
                        baseColor: const Color(0xFF34495E),
                      ),
                      if (comp.rules.applyCapToIndex && 
                          comp.rules.handicapCap < 54 && 
                          comp.rules.format != CompetitionFormat.scramble && 
                          comp.rules.subtype != CompetitionSubtype.foursomes && 
                          comp.rules.subtype != CompetitionSubtype.fourball)
                        BoxyArtStatusPill(
                          text: 'CAPPED @ ${comp.rules.handicapCap.toInt()} HCP',
                          baseColor: const Color(0xFFD35400),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
