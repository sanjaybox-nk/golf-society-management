import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';
import '../../../../models/event_registration.dart';
import '../widgets/event_sliver_app_bar.dart';

import '../../domain/registration_logic.dart';
import '../widgets/registration_card.dart';

// ... (existing imports)

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
                    data: (members) => _buildRegistrationContent(context, event, members),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading members'),
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

  Widget _buildRegistrationContent(BuildContext context, GolfEvent event, List<Member> members) {
    if (event.registrations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No members registered yet.\nBe the first safely!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
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

    // Pre-calculate view models to preserve FCFS order/index
    final itemViewModels = List.generate(sortedItems.length, (index) {
        final item = sortedItems[index];
        final status = RegistrationLogic.calculateStatus(
          isGuest: item.isGuest, 
          registeredAt: item.registeredAt, 
          hasPaid: item.hasPaid, 
          indexInList: index, 
          capacity: maxParticipants, 
          deadline: event.registrationDeadline
        );
        
        int buggyIndex = -1;
        if (item.needsBuggy) {
          buggyIndex = buggyQueue.indexOf(item);
        }
        final buggyStatus = RegistrationLogic.calculateBuggyStatus(
          needsBuggy: item.needsBuggy, 
          hasPaid: item.hasPaid, 
          buggyIndexInQueue: buggyIndex, 
          buggyCapacity: buggyCapacity
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

    final memberModels = itemViewModels.where((m) => !m.item.isGuest).toList();
    final guestModels = itemViewModels.where((m) => m.item.isGuest).toList();

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

    // Calculate Metrics
    final totalRegistered = sortedItems.length;
    final waitlistCount = sortedItems.where((i) => 
      RegistrationLogic.calculateStatus(
        isGuest: i.isGuest, 
        registeredAt: i.registeredAt, 
        hasPaid: i.hasPaid, 
        indexInList: sortedItems.indexOf(i), 
        capacity: maxParticipants, 
        deadline: event.registrationDeadline
      ) == RegistrationStatus.waitlist
    ).length;
    
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    final closingDateStr = event.registrationDeadline != null 
      ? DateFormat('EEE, d MMM @ HH:mm').format(event.registrationDeadline!)
      : 'No Deadline';

    // Buggy Metrics
    final buggyQueueLength = sortedItems.where((i) => i.needsBuggy).length;
    final buggiesTaken = buggyQueueLength > buggyCapacity ? buggyCapacity : buggyQueueLength; 
    final buggyMetricStr = '$buggiesTaken/$buggyCapacity';

    // Dinner Metrics (Golfers + Guests + Dinner Only)
    final dinnerCount = sortedItems.where((i) {
      if (i.isGuest) return i.registration.guestAttendingDinner;
      return i.registration.attendingDinner;
    }).length + dinnerItems.length;

    // Confirmed Metrics (Golfers Only - Exclude Dinner Only)
    final confirmedCount = itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed).length;
                           
    final guestCount = guestModels.length;

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
                // Metrics Table
                Table(
                  // Force exact 1/3 width for each column to be perfectly even
                  columnWidths: const {
                    0: FractionColumnWidth(0.33),
                    1: FractionColumnWidth(0.33),
                    2: FractionColumnWidth(0.33),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Total', '${totalRegistered + dinnerItems.length}', Icons.group),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Confirmed', '$confirmedCount', Icons.check_circle, iconColor: Colors.green),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Capacity', '$maxParticipants', Icons.event_seat),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Guests', '$guestCount', Icons.person_add, iconColor: Colors.orange),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Buggies', buggyMetricStr, Icons.electric_car, suffix: 'spaces', iconColor: Colors.black54),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMetricItem(context, 'Dinner', '$dinnerCount', Icons.restaurant),
                        ),
                      ],
                    ),
                    if (waitlistCount > 0)
                      TableRow(
                        children: [
                           _buildMetricItem(context, 'Waitlist', '$waitlistCount', Icons.hourglass_empty, iconColor: Colors.red, isHighlight: true),
                           const SizedBox(),
                           const SizedBox(),
                        ],
                      ),
                  ],
                ),
                
                const Divider(height: 16), // Compact divider
                
                // Closing Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

        _buildSectionHeader('Members (${memberModels.length})'),
        const SizedBox(height: 8),
        ...memberModels.map((vm) => RegistrationCard(
          name: vm.item.name,
          label: 'Member',
          position: vm.position,
          status: vm.status,
          buggyStatus: vm.buggyStatus,
          attendingDinner: vm.item.registration.attendingDinner,
          hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
          memberProfile: vm.memberProfile,
        )),
        
        if (guestModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Guests (${guestModels.length})'),
          const SizedBox(height: 8),
          ...guestModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Guest of ${vm.item.registration.memberName}',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingDinner: vm.item.registration.guestAttendingDinner,
            isGuest: true,
            memberProfile: vm.memberProfile,
          )),
        ],

        if (dinnerModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Dinner Only (${dinnerModels.length})'),
          const SizedBox(height: 8),
          ...dinnerModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Dinner Only',
            status: vm.status,
            buggyStatus: RegistrationStatus.none,
            attendingDinner: true,
            isDinnerOnly: true,
            memberProfile: vm.memberProfile,
          )),
        ],
      ],
    );
  }
  
  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon, {bool isHighlight = false, Color? iconColor, String? suffix}) {
    // Determine the flex alignment for the Align widget
    Alignment alignValue = Alignment.centerLeft;

    return Align(
      alignment: alignValue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor ?? (isHighlight ? Colors.orange : Colors.grey)),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: iconColor ?? (isHighlight ? Colors.orange : Theme.of(context).colorScheme.onSurface),
              )),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix, style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                )),
              ],
            ],
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
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
