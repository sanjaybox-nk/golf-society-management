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
import '../../../../models/member.dart';
import '../../../members/presentation/members_provider.dart';

class EventRegistrationUserTab extends ConsumerWidget {
  final String eventId;

  const EventRegistrationUserTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
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
                subtitle: event.title,
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

    // 1. Calculate confirmed items for participation display
    int rollingConfirmedCount = 0;
    final itemStatuses = <RegistrationItem, RegistrationStatus>{};
    final buggyStatuses = <RegistrationItem, RegistrationStatus>{};

    for (int i = 0; i < sortedItems.length; i++) {
        final item = sortedItems[i];
        final status = RegistrationLogic.calculateStatus(
          isGuest: item.isGuest,
          isConfirmed: item.isConfirmed,
          hasPaid: item.hasPaid,
          capacity: maxParticipants,
          confirmedCount: rollingConfirmedCount,
          isEventClosed: isClosed,
          statusOverride: item.statusOverride,
        );
        itemStatuses[item] = status;
        if (status == RegistrationStatus.confirmed) {
          rollingConfirmedCount++;
        }

        // Buggy Status
        final confirmedBuggyCount = sortedItems.take(i).where((prev) => 
          itemStatuses[prev] == RegistrationStatus.confirmed && prev.needsBuggy).length;
        
        final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
        buggyStatuses[item] = RegistrationLogic.calculateBuggyStatus(
          needsBuggy: item.needsBuggy,
          isConfirmed: status == RegistrationStatus.confirmed,
          buggyIndexInQueue: buggyIndex,
          buggyCapacity: buggyCapacity,
          confirmedBuggyCount: confirmedBuggyCount,
          buggyStatusOverride: item.isGuest ? item.registration.guestBuggyStatusOverride : item.registration.buggyStatusOverride,
        );
    }

    final itemViewModels = sortedItems.map((item) {
        Member? member;
        try {
          if (!item.isGuest) {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
          }
        } catch (_) {}

        return _RegistrationViewModel(
          item: item,
          status: itemStatuses[item]!,
          buggyStatus: buggyStatuses[item]!,
          position: sortedItems.indexOf(item) + 1,
          memberProfile: member,
        );
    }).toList();


    // 2. Prepare other sections
    final dinnerItems = RegistrationLogic.getDinnerOnlyItems(event);
    final dinnerModels = dinnerItems.map((item) {
        Member? member;
        try {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
        } catch (_) {}
        return _RegistrationViewModel(item: item, status: RegistrationStatus.dinner, buggyStatus: RegistrationStatus.none, position: 0, memberProfile: member);
    }).toList();

    final withdrawnItems = RegistrationLogic.getWithdrawnItems(event);
    final withdrawnModels = withdrawnItems.map((item) {
        Member? member;
        try {
            member = members.firstWhere((m) => m.id == item.registration.memberId);
        } catch (_) {}
        return _RegistrationViewModel(item: item, status: RegistrationStatus.withdrawn, buggyStatus: RegistrationStatus.none, position: 0, memberProfile: member);
    }).toList();

    // 3. Stats Logic (Standardized)
    final stats = RegistrationLogic.getRegistrationStats(event);
    
    final playingValue = stats.confirmedGuests > 0 
        ? '${stats.confirmedGolfers} (${stats.confirmedGuests})' 
        : '${stats.confirmedGolfers}';

    final reserveValue = stats.reserveGuests > 0 
        ? '${stats.reserveGolfers} (${stats.reserveGuests})' 
        : '${stats.reserveGolfers}';

    final int capacity = event.maxParticipants ?? 0;
    final String availableSlotsStr = capacity > 0 
        ? '${stats.confirmedGolfers}/$capacity spaces'
        : 'Unlimited';

    final closingDateStr = event.registrationDeadline != null 
      ? DateFormat('EEE, d MMM @ HH:mm').format(event.registrationDeadline!)
      : 'No Deadline';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // METRICS CARD
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(context, 'Total', '${stats.totalGolfers}', Icons.group, iconColor: const Color(0xFF2C3E50)),
                    _buildMetricItem(context, 'Playing', playingValue, Icons.check_circle, iconColor: const Color(0xFF27AE60)),
                    _buildMetricItem(context, 'Reserve', reserveValue, Icons.hourglass_top, iconColor: const Color(0xFFF39C12)),
                    _buildMetricItem(context, 'Guests', '${stats.totalGuests}', Icons.person_add, iconColor: Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(context, 'Buggies', '${stats.buggyCount}/$buggyCapacity', Icons.electric_rickshaw, iconColor: const Color(0xFF2C3E50), suffix: 'spaces'),
                    _buildMetricItem(context, 'Dinner', '${stats.dinnerCount}', Icons.restaurant, iconColor: Colors.purple),
                    if (stats.waitlistGolfers > 0)
                      _buildMetricItem(context, 'Waitlist', '${stats.waitlistGolfers}', Icons.priority_high, iconColor: const Color(0xFFC0392B)),
                  ],
                ),
                
                const Divider(height: 24),
                
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
                    Icon(isClosed ? Icons.lock : Icons.timer, size: 14, color: isClosed ? Colors.red : Colors.grey),
                    const SizedBox(width: 6),
                    Text(isClosed ? 'Registration Closed' : 'Closes: $closingDateStr',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isClosed ? Colors.red : Colors.grey[800])),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // PLAYING MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest)) ...[
          BoxyArtSectionTitle(title: 'Playing Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.attendingBreakfast,
            attendingLunch: vm.item.registration.attendingLunch,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: false,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // PLAYING GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Playing Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Guest of ${vm.item.registration.memberName}',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
            attendingLunch: vm.item.registration.guestAttendingLunch,
            attendingDinner: vm.item.registration.guestAttendingDinner,
            hasGuest: false,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: true,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // WAITLIST MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Waitlist Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.attendingBreakfast,
            attendingLunch: vm.item.registration.attendingLunch,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: false,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // WAITLIST GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Waitlist Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Guest of ${vm.item.registration.memberName}',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
            attendingLunch: vm.item.registration.guestAttendingLunch,
            attendingDinner: vm.item.registration.guestAttendingDinner,
            hasGuest: false,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: true,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // RESERVED MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Reserved Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.attendingBreakfast,
            attendingLunch: vm.item.registration.attendingLunch,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: false,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // RESERVED GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Reserved Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Guest of ${vm.item.registration.memberName}',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
            attendingLunch: vm.item.registration.guestAttendingLunch,
            attendingDinner: vm.item.registration.guestAttendingDinner,
            hasGuest: false,
            hasPaid: vm.item.registration.hasPaid,
            isGuest: true,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // DINNER ONLY
        if (dinnerModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Dinner Only (${dinnerModels.length})'),
          ...dinnerModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Dinner Only',
            status: vm.status,
            buggyStatus: RegistrationStatus.none,
            attendingBreakfast: false,
            attendingLunch: false,
            attendingDinner: true,
            hasPaid: vm.item.registration.hasPaid,
            isDinnerOnly: true,
            isAdmin: false,
            memberProfile: vm.memberProfile,
          )),
        ],

        // WITHDRAWN
        if (withdrawnModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Withdrawn (${withdrawnModels.length})'),
          ...withdrawnModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Withdrawn',
            status: vm.status,
            buggyStatus: RegistrationStatus.none,
            attendingBreakfast: false,
            attendingLunch: false,
            attendingDinner: false,
            hasPaid: vm.item.registration.hasPaid,
            isAdmin: false,
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
                Text(
                  suffix,
                  style: const TextStyle(fontSize: 8, color: Colors.white70),
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
