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
import '../../../../core/utils/csv_export_service.dart';
import '../../../../core/theme/theme_controller.dart';

class EventRegistrationsAdminScreen extends ConsumerWidget {
  final String eventId;

  const EventRegistrationsAdminScreen({super.key, required this.eventId}); // No changes here, just for context match if needed, but the chunk is above.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final allMembersAsync = ref.watch(allMembersProvider);

    return eventAsync.when(
      data: (event) {
        return Scaffold(
          appBar: BoxyArtAppBar(
            title: 'Registrations',
            subtitle: event.title,
            centerTitle: true,
            isLarge: true,
            leadingWidth: 70, 
            leading: Center(
              child: TextButton(
                onPressed: () => context.canPop() ? context.pop() : context.go('/admin/events'),
                child: const Text('Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.casino, color: Colors.white),
                tooltip: 'Seed Random Registrations',
                onPressed: () => _seedRandomRegistrations(context, ref, event),
              ),
              Builder(
                builder: (buttonContext) => IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  tooltip: 'Export CSV',
                  onPressed: () {
                    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;
                    final shareOrigin = box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null;

                    CsvExportService.exportRegistrations(
                      event: event,
                      participants: RegistrationLogic.getSortedItems(event),
                      dinnerOnly: RegistrationLogic.getDinnerOnlyItems(event),
                      sharePositionOrigin: shareOrigin,
                    );
                  },
                ),
              ),
            ],
          ),
          body: allMembersAsync.when(
            data: (members) => _buildContent(context, ref, event, members),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading members: $err')),
          ),
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
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    final closingDateStr = event.registrationDeadline != null
      ? DateFormat('EEE, d MMM @ HH:mm').format(event.registrationDeadline!)
      : 'No Deadline';

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

    final memberModels = sortedItems.where((i) => !i.isGuest).map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      return _RegistrationViewModel(
        item: item, 
        status: itemStatuses[item]!, 
        buggyStatus: buggyStatuses[item]!, 
        position: sortedItems.indexOf(item) + 1, 
        memberProfile: profile
      );
    }).toList();

    final guestModels = sortedItems.where((i) => i.isGuest).map((item) {
      final profile = members.where((m) => m.id == item.registration.memberId).firstOrNull;
      return _RegistrationViewModel(
        item: item, 
        status: itemStatuses[item]!, 
        buggyStatus: buggyStatuses[item]!, 
        position: sortedItems.indexOf(item) + 1, 
        memberProfile: profile
      );
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

    // Stats Logic (Standardized)
    final stats = RegistrationLogic.getRegistrationStats(event);

    final playingValue = stats.confirmedGuests > 0 ? '${stats.confirmedGolfers} (${stats.confirmedGuests})' : '${stats.confirmedGolfers}';
    final reserveValue = stats.reserveGuests > 0 ? '${stats.reserveGolfers} (${stats.reserveGuests})' : '${stats.reserveGolfers}';

    final config = ref.watch(themeControllerProvider);
    final currency = config.currencySymbol;

    final int capacity = event.maxParticipants ?? 0;
    final String availableSlotsStr = capacity > 0
        ? '${stats.confirmedGolfers}/$capacity spaces'
        : 'Unlimited';

    // Financial Metrics (Golf Fees Only)
    final double memberDinnerCost = event.dinnerCost ?? 0.0;

    
    final double totalPaidFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) {
          double golfCost = 0.0;
          
          // Member golf cost
          if (r.isConfirmed && r.attendingGolf) {
            golfCost += event.memberCost ?? 0.0;
          }
          
          // Guest golf cost
          if (r.guestIsConfirmed && r.guestName != null && r.guestName!.isNotEmpty) {
            golfCost += event.guestCost ?? 0.0;
          }
          
          return sum + golfCost;
        });

    final double totalDinnerFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingDinner && r.isConfirmed ? memberDinnerCost : 0.0) +
            (r.guestAttendingDinner && r.guestIsConfirmed ? memberDinnerCost : 0.0));

    final double totalBreakfastFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingBreakfast && r.isConfirmed ? (event.breakfastCost ?? 0.0) : 0.0) +
            (r.guestAttendingBreakfast && r.guestIsConfirmed ? (event.breakfastCost ?? 0.0) : 0.0));

    final double totalLunchFees = event.registrations
        .where((r) => r.hasPaid)
        .fold(0.0, (sum, r) => sum +
            (r.attendingLunch && r.isConfirmed ? (event.lunchCost ?? 0.0) : 0.0) +
            (r.guestAttendingLunch && r.guestIsConfirmed ? (event.lunchCost ?? 0.0) : 0.0));

    final playingMembers = memberModels.where((vm) => vm.status == RegistrationStatus.confirmed).toList();
    final playingGuests = guestModels.where((vm) => vm.status == RegistrationStatus.confirmed).toList();
    final reservedMembers = memberModels.where((vm) => vm.status == RegistrationStatus.reserved).toList();
    final reservedGuests = guestModels.where((vm) => vm.status == RegistrationStatus.reserved).toList();
    final waitlistMembers = memberModels.where((vm) => vm.status == RegistrationStatus.waitlist).toList();
    final waitlistGuests = guestModels.where((vm) => vm.status == RegistrationStatus.waitlist).toList();

    return ListView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(context, 'Total', '${event.registrations.length}', Icons.group, iconColor: const Color(0xFF2C3E50)),
                      _buildMetricItem(context, 'Playing', playingValue, Icons.check_circle, iconColor: const Color(0xFF27AE60)),
                      _buildMetricItem(context, 'Reserve', reserveValue, Icons.hourglass_top, iconColor: const Color(0xFFF39C12)),
                      _buildMetricItem(context, 'Guests', '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}', Icons.person_add, iconColor: Colors.purple),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(context, 'Paid', '$currency${totalPaidFees.toStringAsFixed(0)}', Icons.attach_money, iconColor: const Color(0xFF16A085)),
                      _buildMetricItem(context, 'Breakfast', '$currency${totalBreakfastFees.toStringAsFixed(0)}', Icons.breakfast_dining, iconColor: const Color(0xFF795548)),
                      _buildMetricItem(context, 'Lunch', '$currency${totalLunchFees.toStringAsFixed(0)}', Icons.lunch_dining, iconColor: const Color(0xFFD35400)),
                      _buildMetricItem(context, 'Dinner', '$currency${totalDinnerFees.toStringAsFixed(0)}', Icons.restaurant_menu, iconColor: const Color(0xFF2980B9)),
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
          // MEMBERS - PLAYING
          if (playingMembers.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Playing (${playingMembers.length})'),
            ...playingMembers.map((vm) => RegistrationCard(
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
              isAdmin: true,
              memberProfile: vm.memberProfile,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            )),
          ],

          // MEMBERS - WAITLIST
          if (waitlistMembers.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Waitlist (${waitlistMembers.length})'),
            ...waitlistMembers.map((vm) => RegistrationCard(
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
              isAdmin: true,
              memberProfile: vm.memberProfile,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            )),
          ],

          // MEMBERS - RESERVED
          if (reservedMembers.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Reserved (${reservedMembers.length})'),
            ...reservedMembers.map((vm) => RegistrationCard(
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
              isAdmin: true,
              memberProfile: vm.memberProfile,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            )),
          ],

          // GUESTS - PLAYING
          if (playingGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Playing Guests (${playingGuests.length})'),
            ...playingGuests.map((vm) => RegistrationCard(
              name: vm.item.name, 
              label: 'Guest of ${vm.item.registration.memberName}',
              position: vm.position,
              status: vm.status,
              buggyStatus: vm.buggyStatus,
              attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
              attendingLunch: vm.item.registration.guestAttendingLunch,
              attendingDinner: vm.item.registration.guestAttendingDinner,
              hasPaid: vm.item.registration.hasPaid,
              isAdmin: true,
              memberProfile: null, 
              isGuest: true,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, true),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, true),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, true),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, true),
            )),
          ],

          // WAITLIST GUESTS
          if (waitlistGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Waitlist Guests (${waitlistGuests.length})'),
            ...waitlistGuests.map((vm) => RegistrationCard(
              name: vm.item.name, 
              label: 'Guest of ${vm.item.registration.memberName}',
              position: vm.position,
              status: vm.status,
              buggyStatus: vm.buggyStatus,
              attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
              attendingLunch: vm.item.registration.guestAttendingLunch,
              attendingDinner: vm.item.registration.guestAttendingDinner,
              hasPaid: vm.item.registration.hasPaid,
              isAdmin: true,
              memberProfile: null, 
              isGuest: true,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, true),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, true),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, true),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, true),
            )),
          ],

          // RESERVED GUESTS
          if (reservedGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Reserved Guests (${reservedGuests.length})'),
            ...reservedGuests.map((vm) => RegistrationCard(
              name: vm.item.name, 
              label: 'Guest of ${vm.item.registration.memberName}',
              position: vm.position,
              status: vm.status,
              buggyStatus: vm.buggyStatus,
              attendingBreakfast: vm.item.registration.guestAttendingBreakfast,
              attendingLunch: vm.item.registration.guestAttendingLunch,
              attendingDinner: vm.item.registration.guestAttendingDinner,
              hasPaid: vm.item.registration.hasPaid,
              isAdmin: true,
              memberProfile: null, 
              isGuest: true,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, true),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, true),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, true),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, true),
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
              attendingBreakfast: vm.item.registration.attendingBreakfast,
              attendingLunch: vm.item.registration.attendingLunch,
              attendingDinner: true,
              hasPaid: vm.item.registration.hasPaid,
              isDinnerOnly: true,
              isAdmin: true,
              memberProfile: vm.memberProfile,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: null,
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            )),
          ],

          // NOT PARTICIPATING
          if (withdrawnModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Not Participating (${withdrawnModels.length})'),
            ...withdrawnModels.map((vm) => RegistrationCard(
              name: vm.item.name,
              label: 'Withdrawn',
              status: vm.status,
              buggyStatus: RegistrationStatus.none,
              attendingBreakfast: vm.item.registration.attendingBreakfast,
              attendingLunch: vm.item.registration.attendingLunch,
              attendingDinner: false,
              hasPaid: vm.item.registration.hasPaid,
              isAdmin: true,
              memberProfile: vm.memberProfile,
              onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
              onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
              onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
              onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
              onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
            )),
          ],
        ],
    );
  }

  

  void _updateStatus(WidgetRef ref, GolfEvent event, EventRegistration reg, RegistrationStatus newStatus) {
    String? nextOverride;
    // Map enum to override string
    switch (newStatus) {
      case RegistrationStatus.confirmed:
        nextOverride = 'confirmed';
        break;
      case RegistrationStatus.reserved:
        nextOverride = 'reserved';
        break;
      case RegistrationStatus.waitlist:
        nextOverride = 'waitlist';
        break;
      case RegistrationStatus.withdrawn:
        nextOverride = 'withdrawn';
        break;
      default:
        nextOverride = null;
    }

    // Sync raw flags
    bool nextHasPaid = reg.hasPaid;
    bool nextIsConfirmed = reg.isConfirmed;

    if (nextOverride == 'confirmed') {
      nextHasPaid = true;
      nextIsConfirmed = true;
    } else if (nextOverride == 'reserved' || nextOverride == 'waitlist') {
      nextHasPaid = true;
      nextIsConfirmed = false;
    } else if (nextOverride == 'withdrawn') {
      // We keep isConfirmed and hasPaid to track that they WERE confirmed/paid 
      // before withdrawing, which drives the bracketed simulation metrics.
    }

    final historyItem = RegistrationHistoryItem(
      timestamp: DateTime.now(),
      action: 'Status Update',
      description: 'Changed status to ${nextOverride ?? 'None'}',
      actor: 'Admin',
    );

    final updated = reg.copyWith(
      statusOverride: nextOverride,
      hasPaid: nextHasPaid,
      isConfirmed: nextIsConfirmed,
      history: [...(reg.history ?? []), historyItem],
    );
    _updateRegistration(ref, event, updated);
  }

  void _toggleBuggyStatus(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    bool nextNeedsBuggy = isGuest ? reg.guestNeedsBuggy : reg.needsBuggy;
    String? currentOverride = isGuest ? reg.guestBuggyStatusOverride : reg.buggyStatusOverride;
    String? nextOverride;

    if (!nextNeedsBuggy) {
      // 1. Enable buggy (Auto/Reserved state initially)
      nextNeedsBuggy = true;
      nextOverride = null;
    } else if (currentOverride == null) {
      // 2. Currently Auto. Next is Confirmed.
      nextOverride = 'confirmed';
    } else if (currentOverride == 'confirmed') {
      // 3. Next is Reserved.
      nextOverride = 'reserved';
    } else if (currentOverride == 'reserved') {
      // 4. Next is Waitlist.
      nextOverride = 'waitlist';
    } else {
      // 5. Back to Disabled.
      nextNeedsBuggy = false;
      nextOverride = null;
    }

    final updated = isGuest 
      ? reg.copyWith(guestNeedsBuggy: nextNeedsBuggy, guestBuggyStatusOverride: nextOverride)
      : reg.copyWith(needsBuggy: nextNeedsBuggy, buggyStatusOverride: nextOverride);
    _updateRegistration(ref, event, updated);
  }

  void _toggleBreakfast(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingBreakfast: !reg.guestAttendingBreakfast)
      : reg.copyWith(attendingBreakfast: !reg.attendingBreakfast);
    _updateRegistration(ref, event, updated);
  }

  void _toggleLunch(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingLunch: !reg.guestAttendingLunch)
      : reg.copyWith(attendingLunch: !reg.attendingLunch);
    _updateRegistration(ref, event, updated);
  }


  void _toggleDinner(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingDinner: !reg.guestAttendingDinner)
      : reg.copyWith(attendingDinner: !reg.attendingDinner);
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
        
        final attendingBreakfast = random.nextBool();
        final attendingLunch = random.nextBool();
        final attendingDinner = random.nextBool();

        String? guestName;
        bool guestNeedsBuggy = false;
        bool guestAttendingBreakfast = false;
        bool guestAttendingLunch = false;
        bool guestAttendingDinner = false;

        if (hasGuest) {
          guestName = mockGuestNames[random.nextInt(mockGuestNames.length)];
          guestNeedsBuggy = random.nextBool();
          guestAttendingBreakfast = random.nextBool();
          guestAttendingLunch = random.nextBool();
          guestAttendingDinner = random.nextBool();
        }

        // Calculate a more realistic cost based on event settings
        double regCost = (event.memberCost ?? 0.0) +
            (attendingBreakfast ? (event.breakfastCost ?? 0.0) : 0.0) +
            (attendingLunch ? (event.lunchCost ?? 0.0) : 0.0) +
            (attendingDinner ? (event.dinnerCost ?? 0.0) : 0.0);
            
        if (hasGuest) {
          regCost += (event.guestCost ?? 0.0) +
              (guestAttendingBreakfast ? (event.breakfastCost ?? 0.0) : 0.0) +
              (guestAttendingLunch ? (event.lunchCost ?? 0.0) : 0.0) +
              (guestAttendingDinner ? (event.dinnerCost ?? 0.0) : 0.0);
        }

        final isConfirmed = random.nextDouble() > 0.4; // 60% chance of being confirmed

        newRegistrations.add(EventRegistration(
          memberId: m.id,
          memberName: '${m.firstName} ${m.lastName}',
          attendingGolf: true,
          attendingBreakfast: attendingBreakfast,
          attendingLunch: attendingLunch,
          attendingDinner: attendingDinner,
          needsBuggy: random.nextBool(),
          hasPaid: isConfirmed || random.nextBool(), // If confirmed, MUST be paid
          isConfirmed: isConfirmed,
          cost: regCost,
          guestName: guestName,
          guestHandicap: hasGuest ? '${random.nextInt(28)}' : null,
          guestAttendingBreakfast: guestAttendingBreakfast,
          guestAttendingLunch: guestAttendingLunch,
          guestAttendingDinner: guestAttendingDinner,
          guestNeedsBuggy: guestNeedsBuggy,
          registeredAt: regTime,
          history: [
            RegistrationHistoryItem(
              timestamp: regTime,
              action: 'Registered',
              description: 'Mock registration for simulation',
              actor: '${m.firstName} ${m.lastName}',
            ),
          ],
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
