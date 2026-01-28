import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import 'dart:math';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../../models/member.dart';
import '../../../events/presentation/widgets/registration_card.dart';
import 'package:intl/intl.dart';

class EventRegistrationsAdminScreen extends ConsumerWidget {
  final String eventId;

  const EventRegistrationsAdminScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final allMembersAsync = ref.watch(allMembersProvider);

    return eventAsync.when(
      data: (event) {
        if (event == null) return const Center(child: Text('Event not found'));

        return allMembersAsync.when(
          data: (members) => _buildContent(context, ref, event, members),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading members: $err')),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, GolfEvent event, List<Member> members) {
    // Shared Logic for groups/sorting
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final dinnerOnlyItems = RegistrationLogic.getDinnerOnlyItems(event);
    
    final maxParticipants = event.maxParticipants ?? 999;
    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;
    final buggyQueue = sortedItems.where((i) => i.needsBuggy).toList();

    // Map profile data
    final memberModels = sortedItems.where((i) => !i.isGuest).map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      final status = RegistrationLogic.calculateStatus(
        isGuest: false, 
        registeredAt: item.registeredAt, 
        hasPaid: item.hasPaid, 
        indexInList: sortedItems.indexOf(item), 
        capacity: maxParticipants, 
        deadline: event.registrationDeadline
      );
      final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
      final buggyStatus = RegistrationLogic.calculateBuggyStatus(
        needsBuggy: item.needsBuggy, 
        hasPaid: item.hasPaid, 
        buggyIndexInQueue: buggyIndex, 
        buggyCapacity: buggyCapacity
      );
      return _RegistrationViewModel(item: item, status: status, buggyStatus: buggyStatus, position: sortedItems.indexOf(item) + 1, memberProfile: profile);
    }).toList();

    final guestModels = sortedItems.where((i) => i.isGuest).map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      final status = RegistrationLogic.calculateStatus(
        isGuest: true, 
        registeredAt: item.registeredAt, 
        hasPaid: item.hasPaid, 
        indexInList: sortedItems.indexOf(item), 
        capacity: maxParticipants, 
        deadline: event.registrationDeadline
      );
      final buggyIndex = item.needsBuggy ? buggyQueue.indexOf(item) : -1;
      final buggyStatus = RegistrationLogic.calculateBuggyStatus(
        needsBuggy: item.needsBuggy, 
        hasPaid: item.hasPaid, 
        buggyIndexInQueue: buggyIndex, 
        buggyCapacity: buggyCapacity
      );
      return _RegistrationViewModel(item: item, status: status, buggyStatus: buggyStatus, position: sortedItems.indexOf(item) + 1, memberProfile: profile);
    }).toList();

    final dinnerModels = dinnerOnlyItems.map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      return _RegistrationViewModel(item: item, status: RegistrationStatus.dinner, buggyStatus: RegistrationStatus.none, position: 0, memberProfile: profile);
    }).toList();

    final withdrawnItems = RegistrationLogic.getWithdrawnItems(event);
    final withdrawnModels = withdrawnItems.map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      return _RegistrationViewModel(item: item, status: RegistrationStatus.withdrawn, buggyStatus: RegistrationStatus.none, position: 0, memberProfile: profile);
    }).toList();

    // Stats Logic
    final waitlistCount = sortedItems.where((item) => 
      RegistrationLogic.calculateStatus(
        isGuest: item.isGuest, 
        registeredAt: item.registeredAt, 
        hasPaid: item.hasPaid, 
        indexInList: sortedItems.indexOf(item), 
        capacity: maxParticipants, 
        deadline: event.registrationDeadline
      ) == RegistrationStatus.waitlist
    ).length;
    
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    final closingDateStr = event.registrationDeadline != null 
      ? DateFormat('EEE, d MMM @ HH:mm').format(event.registrationDeadline!)
      : 'No Deadline';

    final buggyQueueLength = sortedItems.where((i) => i.needsBuggy).length;
    final buggiesTaken = buggyQueueLength > buggyCapacity ? buggyCapacity : buggyQueueLength; 
    final buggyMetricStr = '$buggiesTaken/$buggyCapacity';

    final dinnerCount = sortedItems.where((i) {
      if (i.isGuest) return i.registration.guestAttendingDinner;
      return i.registration.attendingDinner;
    }).length + dinnerOnlyItems.length;

    // Confirmed Metrics (Golfers Only - Exclude Dinner Only)
    final confirmedCount = memberModels.where((vm) => vm.status == RegistrationStatus.confirmed).length +
                           guestModels.where((vm) => vm.status == RegistrationStatus.confirmed).length;

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Registrations', 
        showBack: true,
        onBack: () => context.go('/home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: 'Seed Random Registrations',
            onPressed: () => _seedRandomRegistrations(context, ref, event),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                  Table(
                    columnWidths: const {
                      0: FractionColumnWidth(0.33),
                      1: FractionColumnWidth(0.33),
                      2: FractionColumnWidth(0.33),
                    },
                    children: [
                      TableRow(children: [
                        _buildMetricItem(context, 'Total', '${sortedItems.length + dinnerOnlyItems.length}', Icons.group),
                        _buildMetricItem(context, 'Confirmed', '$confirmedCount', Icons.check_circle, iconColor: Colors.green, alignment: CrossAxisAlignment.center),
                        _buildMetricItem(context, 'Capacity', '$maxParticipants', Icons.event_seat, alignment: CrossAxisAlignment.end),
                      ]),
                      const TableRow(children: [SizedBox(height: 12), SizedBox(), SizedBox()]),
                      TableRow(children: [
                        _buildMetricItem(context, 'Guests', '${guestModels.length}', Icons.person_add, iconColor: Colors.orange),
                        _buildMetricItem(context, 'Buggies', buggyMetricStr, Icons.electric_car, suffix: 'spaces', iconColor: Colors.black54, alignment: CrossAxisAlignment.center),
                        _buildMetricItem(context, 'Dinner', '$dinnerCount', Icons.restaurant, alignment: CrossAxisAlignment.end),
                      ]),
                      if (waitlistCount > 0) ...[
                        const TableRow(children: [SizedBox(height: 12), SizedBox(), SizedBox()]),
                        TableRow(children: [
                           _buildMetricItem(context, 'Waitlist', '$waitlistCount', Icons.hourglass_empty, iconColor: Colors.red, isHighlight: true),
                           const SizedBox(),
                           const SizedBox(),
                        ]),
                      ],
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
          _buildSectionHeader('Members (${memberModels.length})'),
          ...memberModels.map((vm) => RegistrationCard(
            name: vm.item.name,
            label: 'Member',
            position: vm.position,
            status: vm.status,
            buggyStatus: vm.buggyStatus,
            attendingDinner: vm.item.registration.attendingDinner,
            hasGuest: vm.item.registration.guestName != null && vm.item.registration.guestName!.isNotEmpty,
            memberProfile: vm.memberProfile,
            onStatusToggle: () => _togglePaid(ref, event, vm.item.registration),
            onBuggyToggle: () => _toggleBuggy(ref, event, vm.item.registration, false),
            onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            onGolfToggle: () => _toggleGolf(ref, event, vm.item.registration),
          )),

          if (guestModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Guests (${guestModels.length})'),
            ...guestModels.map((vm) => RegistrationCard(
              name: vm.item.name,
              label: 'Guest of ${vm.item.registration.memberName}',
              position: vm.position,
              status: vm.status,
              buggyStatus: vm.buggyStatus,
              attendingDinner: vm.item.registration.guestAttendingDinner,
              isGuest: true,
              memberProfile: vm.memberProfile,
              onStatusToggle: () => _togglePaid(ref, event, vm.item.registration),
              onBuggyToggle: () => _toggleBuggy(ref, event, vm.item.registration, true),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, true),
              onGolfToggle: () => _toggleGolf(ref, event, vm.item.registration),
            )),
          ],

          if (dinnerModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Dinner Only (${dinnerModels.length})'),
            ...dinnerModels.map((vm) => RegistrationCard(
              name: vm.item.name,
              label: 'Dinner Only',
              status: vm.status,
              buggyStatus: RegistrationStatus.none,
              attendingDinner: true,
              isDinnerOnly: true,
              memberProfile: vm.memberProfile,
              onStatusToggle: () => _togglePaid(ref, event, vm.item.registration),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
              onGolfToggle: () => _toggleGolf(ref, event, vm.item.registration),
            )),
          ],

          if (withdrawnModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Not Participating (${withdrawnModels.length})'),
            ...withdrawnModels.map((vm) => RegistrationCard(
              name: vm.item.name,
              label: 'Withdrawn',
              status: vm.status,
              buggyStatus: RegistrationStatus.none,
              attendingDinner: false,
              memberProfile: vm.memberProfile,
              onStatusToggle: () => _togglePaid(ref, event, vm.item.registration),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
              onGolfToggle: () => _toggleGolf(ref, event, vm.item.registration),
            )),
          ],
        ],
      ),
    );
  }

  void _togglePaid(WidgetRef ref, GolfEvent event, EventRegistration reg) {
    final updated = reg.copyWith(hasPaid: !reg.hasPaid);
    _updateRegistration(ref, event, updated);
  }

  void _toggleBuggy(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestNeedsBuggy: !reg.guestNeedsBuggy)
      : reg.copyWith(needsBuggy: !reg.needsBuggy);
    _updateRegistration(ref, event, updated);
  }

  void _toggleDinner(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingDinner: !reg.guestAttendingDinner)
      : reg.copyWith(attendingDinner: !reg.attendingDinner);
    _updateRegistration(ref, event, updated);
  }

  void _toggleGolf(WidgetRef ref, GolfEvent event, EventRegistration reg) {
    final updated = reg.copyWith(attendingGolf: !reg.attendingGolf);
    _updateRegistration(ref, event, updated);
  }

  void _updateRegistration(WidgetRef ref, GolfEvent event, EventRegistration updated) {
    final newList = List<EventRegistration>.from(event.registrations);
    final idx = newList.indexWhere((r) => r.memberId == updated.memberId);
    if (idx >= 0) {
      newList[idx] = updated;
      ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(registrations: newList));
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon, {bool isHighlight = false, Color? iconColor, String? suffix, CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    Alignment alignValue = Alignment.centerLeft;
    if (alignment == CrossAxisAlignment.center) alignValue = Alignment.center;
    if (alignment == CrossAxisAlignment.end) alignValue = Alignment.centerRight;

    return Align(
      alignment: alignValue,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor ?? (isHighlight ? Colors.orange : Colors.grey)),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor ?? (isHighlight ? Colors.orange : Theme.of(context).colorScheme.onSurface))),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ],
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
  Future<void> _seedRandomRegistrations(BuildContext context, WidgetRef ref, GolfEvent event) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding random registrations...')));

    try {
      // 1. Get all members
      final members = await ref.read(membersRepositoryProvider).getMembers();
      
      // 2. Shuffle and take 53%
      final random = Random();
      final membersList = List.of(members)..shuffle(random);
      final count = (membersList.length * 0.53).round();
      final selectedMembers = membersList.take(count).toList();
      
      // Select 5 random indices for guests
      final guestIndices = <int>{};
      while (guestIndices.length < 5 && guestIndices.length < selectedMembers.length) {
        guestIndices.add(random.nextInt(selectedMembers.length));
      }

      final mockGuestNames = [
        'John Smith', 'Alice Johnson', 'Bob Williams', 'Charlie Brown', 'David Jones',
        'Emma Davis', 'Frank Miller', 'Grace Wilson', 'Henry Moore', 'Ivy Taylor'
      ];
      
      // 3. Create registrations
      final newRegistrations = <EventRegistration>[];
      
      // We want varied registration times to test FCFS
      DateTime baseTime = DateTime.now().subtract(const Duration(days: 5));
      
      for (int i = 0; i < selectedMembers.length; i++) {
        final m = selectedMembers[i];
        final hasGuest = guestIndices.contains(i);
        
        // Random time within the last 5 days
        final regTime = baseTime.add(Duration(minutes: random.nextInt(7000)));
        
        String? guestName;
        bool guestNeedsBuggy = false;
        bool guestAttendingDinner = false;

        if (hasGuest) {
          guestName = mockGuestNames[random.nextInt(mockGuestNames.length)];
          guestNeedsBuggy = random.nextBool();
          guestAttendingDinner = random.nextBool();
        }

        newRegistrations.add(EventRegistration(
          memberId: m.id,
          memberName: '${m.firstName} ${m.lastName}',
          attendingGolf: true,
          attendingDinner: random.nextBool(),
          needsBuggy: random.nextBool(),
          hasPaid: random.nextBool(), // Random payment status
          cost: 50.0, // Fixed cost for simplicity
          guestName: guestName,
          guestHandicap: hasGuest ? '${random.nextInt(28)}' : null,
          guestAttendingDinner: guestAttendingDinner,
          guestNeedsBuggy: guestNeedsBuggy,
          registeredAt: regTime,
        ));
      }
      
      // 4. Update event
      final repo = ref.read(eventsRepositoryProvider);
      final updatedEvent = event.copyWith(registrations: newRegistrations);
      await repo.updateEvent(updatedEvent);
      
      messenger.showSnackBar(SnackBar(content: Text('Successfully seeded ${newRegistrations.length} registrations (40% of members, ~5 guests)!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error seeding: $e')));
    }
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
