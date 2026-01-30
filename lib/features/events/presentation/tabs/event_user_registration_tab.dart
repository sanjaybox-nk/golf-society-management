import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';
import '../widgets/event_sliver_app_bar.dart';

import '../../domain/registration_logic.dart';
import '../widgets/registration_card.dart';

// ... (existing imports)

import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../../models/member.dart';

class EventRegistrationUserTab extends ConsumerWidget {
  final String eventId;

  const EventRegistrationUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final allMembersAsync = ref.watch(allMembersProvider); // Fetch members

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhere((e) => e.id == eventId, orElse: () => throw 'Event not found');
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              EventSliverAppBar(
                event: event,
                title: 'Registration',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: allMembersAsync.when(
                    data: (members) => _buildRegistrationContent(context, ref, event, members),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Text('Error loading members'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildRegistrationContent(BuildContext context, WidgetRef ref, GolfEvent event, List<Member> members) {
    if (event.registrations.isEmpty) {
      final String emptyText = event.showRegistrationButton 
          ? 'Registration Open' 
          : 'Registration not open yet';
          
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    // Use Shared Logic for Sorting
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final maxParticipants = event.maxParticipants ?? 999;
    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;
    final buggyQueue = sortedItems.where((i) => i.needsBuggy).toList();
    
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);

    // Pre-calculate confirmed counts to drive waitlist logic
    final confirmedCount = sortedItems.where((item) => item.isConfirmed).length;
    final confirmedBuggyCount = sortedItems.where((item) => 
      item.buggyStatusOverride == 'confirmed' || (item.isConfirmed && item.needsBuggy)).length;

    // Pre-calculate view models to preserve FCFS order/index
    final itemViewModels = List.generate(sortedItems.length, (index) {
        final item = sortedItems[index];
        final status = RegistrationLogic.calculateStatus(
          isGuest: item.isGuest,
          isConfirmed: item.isConfirmed,
          hasPaid: item.hasPaid,
          indexInList: index,
          capacity: maxParticipants,
          confirmedCount: confirmedCount,
          isEventClosed: isClosed,
          statusOverride: item.statusOverride,
        );
        final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
        final buggyStatus = RegistrationLogic.calculateBuggyStatus(
          needsBuggy: item.needsBuggy,
          isConfirmed: item.isConfirmed,
          buggyIndexInQueue: buggyIndex,
          buggyCapacity: buggyCapacity,
          confirmedBuggyCount: confirmedBuggyCount,
          buggyStatusOverride: item.buggyStatusOverride,
        );
        
        // Find Member Profile
        Member? member;
        try {
          if (!item.isGuest) {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
          }
        } catch (_) {}

        return _RegistrationViewModel(
          item: item,
          status: status,
          buggyStatus: buggyStatus,
          position: index + 1,
          memberProfile: member,
        );
    });


    // Dinner Only Items
    final dinnerItems = RegistrationLogic.getDinnerOnlyItems(event);
    final dinnerModels = dinnerItems.map((item) {
        // Find Member Profile
        Member? member;
        try {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
        } catch (_) {}

        return _RegistrationViewModel(
          item: item,
          status: RegistrationStatus.dinner,
          buggyStatus: RegistrationStatus.none,
          position: 0, 
          memberProfile: member,
        );
    }).toList();

    // Withdrawn Items
    final withdrawnItems = RegistrationLogic.getWithdrawnItems(event);
    final withdrawnModels = withdrawnItems.map((item) {
        Member? member;
        try {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
        } catch (_) {}

        return _RegistrationViewModel(
          item: item,
          status: RegistrationStatus.withdrawn,
          buggyStatus: RegistrationStatus.none,
          position: 0, 
          memberProfile: member,
        );
    }).toList();

    // Calculate Metrics
    final waitlistCount = sortedItems.where((item) => 
      RegistrationLogic.calculateStatus(
        isGuest: item.isGuest, 
        isConfirmed: item.isConfirmed,
        hasPaid: item.hasPaid, 
        indexInList: sortedItems.indexOf(item), 
        capacity: maxParticipants, 
        confirmedCount: confirmedCount,
        isEventClosed: isClosed,
        statusOverride: item.statusOverride,
      ) == RegistrationStatus.waitlist
    ).length;
    
    final closingDateStr = event.registrationDeadline != null 
      ? DateFormat('EEE, d MMM @ HH:mm').format(event.registrationDeadline!)
      : 'No Deadline';

    // Buggy Metrics (Confirmed Only)
    final confirmedBuggies = itemViewModels.where((vm) => vm.buggyStatus == RegistrationStatus.confirmed).length;
    final buggyMetricStr = '$confirmedBuggies/$buggyCapacity';

    // Dinner Metrics (Golfers + Guests + Dinner Only - Confirmed Only)
    final dinnerCount = itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && (vm.item.isGuest ? vm.item.registration.guestAttendingDinner : vm.item.registration.attendingDinner)).length + 
                        dinnerModels.where((vm) => vm.status == RegistrationStatus.confirmed).length;

    // Confirmed Metrics (Golfers Only - Exclude Dinner Only)
    final confirmedMembersCount = itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).length;
    final confirmedGuestsCount = itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).length;
    final totalPlaying = confirmedMembersCount + confirmedGuestsCount;
    final playingValue = confirmedGuestsCount > 0 ? '$totalPlaying ($confirmedGuestsCount)' : '$totalPlaying';

    // For metrics display, we use totalPlaying but for logic we use confirmedCount
    final reservedCount = itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved).length;
                           
    final memberViewModels = itemViewModels.where((vm) => !vm.item.isGuest).toList();
    final guestViewModels = itemViewModels.where((vm) => vm.item.isGuest).toList();

    final guestCount = guestViewModels.length;

    final int capacity = event.maxParticipants ?? 0;
    final int availableSlots = capacity - confirmedCount;
    final String availableSlotsStr = capacity > 0 
        ? '${availableSlots > 0 ? availableSlots : 0} spaces'
        : 'Unlimited';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // METRICS CARD
        Card(
          elevation: 1, // Standard elevation
          color: Theme.of(context).cardColor, // Standard card color (usually white/surface)
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0), // Reduced vertical padding
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(context, 'Total', '${event.registrations.length}', Icons.group, iconColor: const Color(0xFF2C3E50)),
                    _buildMetricItem(context, 'Playing', playingValue, Icons.check_circle, iconColor: const Color(0xFF27AE60)),
                    _buildMetricItem(context, 'Reserve', '$reservedCount', Icons.hourglass_top, iconColor: const Color(0xFFF39C12)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(context, 'Guests', '$guestCount', Icons.person_add, iconColor: const Color(0xFFE67E22)),
                    _buildMetricItem(context, 'Buggies', buggyMetricStr, Icons.electric_rickshaw, suffix: 'spaces', iconColor: const Color(0xFF34495E)),
                    _buildMetricItem(context, 'Dinner', '$dinnerCount', Icons.restaurant, iconColor: const Color(0xFF8E44AD)),
                  ],
                ),
                if (waitlistCount > 0) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: _buildMetricItem(context, 'Waitlist', '$waitlistCount', Icons.hourglass_empty, iconColor: const Color(0xFFC0392B), isHighlight: true),
                  ),
                ],
                
                const Divider(height: 16), // Compact divider
                
                // Closing Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (capacity > 0) ...[
                      Text(
                        availableSlotsStr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[800]),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('|', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    ],
                    Icon(
                      isClosed ? Icons.lock : Icons.timer, 
                      size: 14, 
                      color: isClosed ? Colors.red : Colors.grey[700]
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isClosed ? 'Registration Closed' : 'Closes: $closingDateStr',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isClosed ? Colors.red : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        BoxyArtSectionTitle(title: 'Playing (${memberViewModels.where((vm) => vm.status == RegistrationStatus.confirmed).length})'),
        const SizedBox(height: 8),
        ...memberViewModels.where((vm) => vm.status == RegistrationStatus.confirmed).map((vm) => RegistrationCard(
          name: vm.item.name,
          label: 'Member',
          position: vm.position,
          status: vm.status,
          buggyStatus: vm.buggyStatus,
          attendingBreakfast: vm.item.registration.attendingBreakfast,
          attendingLunch: vm.item.registration.attendingLunch,
          attendingDinner: vm.item.registration.attendingDinner,
          hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
          isGuest: false,
          memberProfile: vm.memberProfile,
        )),

        if (memberViewModels.any((vm) => vm.status == RegistrationStatus.reserved)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Reserved (${memberViewModels.where((vm) => vm.status == RegistrationStatus.reserved).length})'),
          const SizedBox(height: 8),
          ...memberViewModels.where((vm) => vm.status == RegistrationStatus.reserved).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.attendingBreakfast,
            attendingLunch: vm.item.registration.attendingLunch,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            isGuest: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        if (memberViewModels.any((vm) => vm.status == RegistrationStatus.waitlist)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Waitlist (${memberViewModels.where((vm) => vm.status == RegistrationStatus.waitlist).length})'),
          const SizedBox(height: 8),
          ...memberViewModels.where((vm) => vm.status == RegistrationStatus.waitlist).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.attendingBreakfast,
            attendingLunch: vm.item.registration.attendingLunch,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            isGuest: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        if (guestViewModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Guests (${guestViewModels.length})'),
          const SizedBox(height: 8),
          ...guestViewModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Guest of ${vm.item.registration.memberName}',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
            attendingLunch: vm.item.registration.guestAttendingLunch,
            attendingDinner: vm.item.registration.guestAttendingDinner,
            isGuest: true,
            memberProfile: null,
          )),
        ],

        if (dinnerModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Dinner Only (${dinnerModels.length})'),
          const SizedBox(height: 8),
          ...dinnerModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Dinner Only',
            status: vm.status,
            buggyStatus: RegistrationStatus.none,
            attendingBreakfast: false,
            attendingLunch: false,
            attendingDinner: true,
            isDinnerOnly: true,
            memberProfile: vm.memberProfile,
          )),
        ],

        if (withdrawnModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Withdrawn (${withdrawnModels.length})'),
          const SizedBox(height: 8),
          ...withdrawnModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Withdrawn',
            status: vm.status,
            buggyStatus: RegistrationStatus.none,
            attendingBreakfast: false,
            attendingLunch: false,
            attendingDinner: false,
            memberProfile: vm.memberProfile,
          )),
        ],
      ],
    );
  }
  
  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon, {bool isHighlight = false, Color? iconColor, String? suffix}) {
    final theme = Theme.of(context);
    final color = iconColor ?? (isHighlight ? Colors.orange : theme.primaryColor);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (value.contains('(')) 
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value.split(' ')[0],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: value.split(' ')[1],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: value.length > 4 ? 14 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (suffix != null)
                const Text(
                  'spaces',
                  style: TextStyle(fontSize: 8, color: Colors.white70),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }



}

class _RegistrationViewModel {
  final RegistrationItem item;
  final RegistrationStatus status;
  final RegistrationStatus buggyStatus;
  final int position;
  final Member? memberProfile;

  _RegistrationViewModel({
    required this.item,
    required this.status,
    required this.buggyStatus,
    required this.position,
    this.memberProfile,
  });
}
