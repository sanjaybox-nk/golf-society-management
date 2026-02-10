import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:io';
import 'package:go_router/go_router.dart';
import '../widgets/event_sliver_app_bar.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../domain/registration_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/competition.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../debug/presentation/state/debug_providers.dart';
import '../../../../features/competitions/utils/competition_rule_translator.dart';

class EventUserDetailsTab extends ConsumerWidget {
  final String eventId;

  const EventUserDetailsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final statusOverride = ref.watch(eventStatusOverrideProvider);
    
    return eventsAsync.when(
      data: (events) {
        var event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        
        // [LAB MODE] Apply Status Override if set
        if (statusOverride != null) {
           event = event.copyWith(status: statusOverride);
        }

        final config = ref.watch(themeControllerProvider);
        return EventDetailsContent(event: event, currencySymbol: config.currencySymbol);
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

  const EventDetailsContent({
    super.key,
    required this.event, 
    required this.currencySymbol,
    this.isPreview = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: Registration and Gallery sections removed as they have their own tabs now
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRegistrationCard(context),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(context, ref),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return EventSliverAppBar(
      event: event,
      title: event.title,
      subtitle: '${event.courseName ?? 'TBA'} • ${DateFormat('d MMM yyyy').format(event.date)}',
      isPreview: isPreview,
      onCancel: onCancel,
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'Basic Info'),
        const SizedBox(height: 12),
        BoxyArtFloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null && event.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow(
                'Title',
                _buildDetailValue(event.title),
              ),
              _buildDetailRow(
                'Status',
                Row(
                  children: [
                  _buildDetailValue(event.status.name.toUpperCase()),
                ],
              ),
              ),
              if (event.description != null && event.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  event.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'DateTime & Registration'),
        const SizedBox(height: 12),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              if ((event.isMultiDay ?? false) && event.endDate != null) ...[
                _buildDetailRow(
                  'Start Date',
                  _buildDetailValue(DateFormat('EEEE, d MMM yyyy').format(event.date)),
                ),
                _buildDetailRow(
                  'End Date',
                  _buildDetailValue(DateFormat('EEEE, d MMM yyyy').format(event.endDate!)),
                ),
              ] else
                _buildDetailRow(
                  'Event Date',
                  _buildDetailValue(DateFormat('EEEE, d MMM yyyy').format(event.date)),
                ),
              _buildDetailRow(
                'Tee-off',
                _buildDetailValue(DateFormat('h:mm a').format(event.teeOffTime ?? event.date)),
              ),
              _buildDetailRow(
                'Registration',
                _buildDetailValue(event.regTime != null 
                  ? DateFormat('h:mm a').format(event.regTime!)
                  : 'TBA'),
              ),
              if (event.registrationDeadline != null)
                _buildDetailRow(
                  'Deadline',
                  _buildDetailValue('${DateFormat('d MMM').format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}'),
                ),
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
        const BoxyArtSectionTitle(title: 'Course Selection'),
        const SizedBox(height: 12),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              _buildDetailRow(
                'Course',
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailValue(event.courseName ?? 'TBA'),
                          if (event.courseDetails != null && event.courseDetails!.isNotEmpty)
                            Text(
                              event.courseDetails!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (event.courseName != null)
                      IconButton(
                        icon: Icon(
                          Icons.location_on_outlined, 
                          color: Theme.of(context).primaryColor,
                          size: 23,
                        ),
                        onPressed: () => _launchMap(event.courseName!, event.courseDetails),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
              if (event.selectedTeeName != null)
                _buildDetailRow(
                  'Tee Position',
                  _buildDetailValue(event.selectedTeeName!),
                ),
              _buildDetailRow(
                'Dress Code',
                _buildDetailValue(event.dressCode ?? 'Standard Golf Attire'),
              ),
              if (event.availableBuggies != null)
                _buildDetailRow(
                  'Buggies',
                  _buildDetailValue('${event.availableBuggies} available'),
                ),
              _buildDetailRow(
                'Availability',
                _buildDetailValue(() {
                  final stats = RegistrationLogic.getRegistrationStats(event);
                  if (event.maxParticipants == null) return 'Unlimited';
                  final remaining = event.maxParticipants! - stats.confirmedGolfers;
                  if (remaining <= 0) return 'Event is full';
                  return '${event.maxParticipants} spots, $remaining remaining';
                }()),
              ),
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
    if (isPreview || !event.showRegistrationButton || event.status == EventStatus.completed) return const SizedBox.shrink();

    // For now, we'll assume the user is a mock member
    const currentMemberId = 'current-user-id';
    
    final myRegistration = event.registrations.where((r) => r.memberId == currentMemberId).firstOrNull;
    final isRegistered = myRegistration != null;
    
    final isPastDeadline = event.registrationDeadline != null && 
                          DateTime.now().isAfter(event.registrationDeadline!);

    final stats = RegistrationLogic.getRegistrationStats(event);
    final isFull = event.maxParticipants != null && stats.confirmedGolfers >= event.maxParticipants!;

    // Disabled if:
    // 1. Deadline passed (always)
    // 2. Button hidden by config (always)
    final isRegistrationDisabled = 
        isPastDeadline || 
        !event.showRegistrationButton;

    return BoxyArtFloatingCard(
      child: Column(
        children: [
          if (!isRegistered) ...[
            Column(
              children: [
                Text(
                  isPastDeadline 
                    ? 'Registration Closed'
                    : (isFull ? 'Event Full' : 'Secure your spot'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isPastDeadline && event.registrationDeadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isFull ? 'Register to join the waitlist' : 'Closes: ${DateFormat.yMMMd().format(event.registrationDeadline!)} @ ${DateFormat('h:mm a').format(event.registrationDeadline!)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ] else if (!isPastDeadline) ...[
                  const SizedBox(height: 4),
                  Text(
                    isFull ? 'Join the waitlist below' : 'Register below to join the event',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: myRegistration.hasPaid ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  myRegistration.hasPaid ? 'Confirmed (Paid)' : 'Registered (Pending)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
          BoxyArtButton(
            title: isPastDeadline 
                ? 'Registration closed' 
                : (isRegistered ? 'Edit My Registration' : (isFull ? 'Register Now (Waitlist)' : 'Register Now')),
            onTap: isRegistrationDisabled 
                ? null 
                : () {
                    GoRouter.of(context).push('/events/${event.id}/register-form');
                  },
          ),
          
          if (isRegistered) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryIcon(Icons.attach_money, 'Paid', myRegistration.hasPaid),
                _buildSummaryIcon(Icons.breakfast_dining, 'Breakfast', myRegistration.attendingBreakfast),
                _buildSummaryIcon(Icons.lunch_dining, 'Lunch', myRegistration.attendingLunch),
                _buildSummaryIcon(Icons.dinner_dining, 'Dinner', myRegistration.attendingDinner),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryIcon(IconData icon, String label, bool active) {
    return Column(
      children: [
        Icon(
          icon, 
          size: 20, 
          color: active ? Colors.green : Colors.grey.shade300,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? Colors.black87 : Colors.grey.shade400,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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
        BoxyArtFloatingCard(
          child: Column(
            children: [
              _buildCostRow('Member Cost', event.memberCost),
              _buildCostRow('Guest Cost', event.guestCost),
              if (event.buggyCost != null) ...[
                const Divider(height: 24),
                _buildCostRow('Buggy Cost', event.buggyCost),
                const SizedBox(height: 4),
                const Text(
                  'Payable to Pro Shop',
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
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
        const BoxyArtSectionTitle(title: 'Meal Options & Costs'),
        const SizedBox(height: 12),
        BoxyArtFloatingCard(
          child: Column(
            children: [
              if (hasBreakfast) _buildCostRow('Breakfast', event.breakfastCost),
              if (hasLunch) _buildCostRow('Lunch', event.lunchCost),
              if (hasDinner) _buildCostRow('Dinner', event.dinnerCost),
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
        BoxyArtFloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: event.facilities.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDetailValue(f)),
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
      child: BoxyArtFloatingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty) ...[
              Text(
                note.title!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
            if (note.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  note.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade100,
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
        BoxyArtFloatingCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.restaurant, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.dinnerLocation!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              if (isPreview == false)
                IconButton(
                  icon: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 23,
                  ),
                  onPressed: () => _launchMap(event.dinnerLocation!, null),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildDetailRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for consistent alignment across cards
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildDetailValue(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        ),
      ),
    );
  }
  Widget _buildCostRow(String label, double? cost, {bool isTotal = false}) {
    if (cost == null) return const SizedBox.shrink();
    
    final String costText = cost == 0 
        ? '(incl)' 
        : '$currencySymbol${cost.toStringAsFixed(2)}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 8.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            )
          ),
          Text(
            costText, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: isTotal ? 16 : 14,
            )
          ),
        ],
      ),
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
            BoxyArtFloatingCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.1),
                        child: Icon(icon, color: iconColor),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (comp.name != null && comp.name!.isNotEmpty)
                              Text(
                                comp.rules.gameName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      BoxyArtStatusPill(
                        text: comp.rules.scoringType.toUpperCase(),
                        baseColor: comp.rules.scoringType == 'GROSS' ? Colors.redAccent : (eventId.contains('_secondary') ? Colors.orangeAccent : Colors.teal),
                      ),
                      BoxyArtStatusPill(
                        text: comp.rules.defaultAllowanceLabel,
                        baseColor: iconColor,
                      ),
                      BoxyArtStatusPill(
                        text: comp.rules.mode.name.toUpperCase(),
                        baseColor: Colors.blueGrey,
                      ),
                      if (comp.rules.handicapCap < 54)
                        BoxyArtStatusPill(
                          text: 'CAPPED @ ${comp.rules.handicapCap.toInt()} HCP',
                          baseColor: Colors.orange.shade700,
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
