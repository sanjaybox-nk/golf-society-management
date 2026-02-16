import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/golf_event.dart';
import '../../../../models/event_registration.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/domain/registration_logic.dart';
import '../../../../models/member.dart';
import '../../../events/presentation/widgets/registration_card.dart';
import 'package:intl/intl.dart';
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
        return HeadlessScaffold(
          title: 'Manage Registrations',
          subtitle: event.title,
          showBack: true,
          onBack: () => context.go('/admin/events'),
          slivers: [
            allMembersAsync.when(
              data: (members) => _buildContent(context, ref, event, members),
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error loading members: $err'))),
            ),
          ],
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

    final isRegistrationSoon = event.registrationDeadline != null && 
                               DateTime.now().isBefore(event.registrationDeadline!) &&
                               event.registrationDeadline!.difference(DateTime.now()).inDays < 3;

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
    final primary = Theme.of(context).primaryColor;
    final int capacity = event.maxParticipants ?? 0;
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

    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // METRICS CARD
            const BoxyArtSectionTitle(title: 'Registration Stats'),
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // REGISTRATION STATS
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModernMetricStat(
                            value: '${event.registrations.length}',
                            label: 'Total',
                            icon: Icons.groups_rounded,
                            color: const Color(0xFF2C3E50),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: playingValue,
                            label: 'Playing',
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xFF27AE60),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: reserveValue,
                            label: 'Reserve',
                            icon: Icons.hourglass_top_rounded,
                            color: const Color(0xFFF39C12),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '${stats.confirmedGuests + stats.reserveGuests + stats.waitlistGuests}',
                            label: 'Guests',
                            icon: Icons.person_add_rounded,
                            color: Colors.purple,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ATTENDANCE STATS
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModernMetricStat(
                            value: '${stats.buggyCount}/$buggyCapacity',
                            label: 'Buggies',
                            icon: Icons.electric_rickshaw_rounded,
                            color: const Color(0xFF455A64),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '${stats.dinnerCount}',
                            label: 'Dinner',
                            icon: Icons.restaurant_rounded,
                            color: Colors.deepPurple,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '${stats.waitlistGolfers}',
                            label: 'Waitlist',
                            icon: Icons.priority_high_rounded,
                            color: const Color(0xFFC0392B),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '${stats.breakfastCount}',
                            label: 'Breakfast',
                            icon: Icons.breakfast_dining_rounded,
                            color: const Color(0xFF795548),
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  // FINANCIAL STATS
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModernMetricStat(
                            value: '$currency${totalPaidFees.toStringAsFixed(0)}',
                            label: 'Paid',
                            icon: Icons.payments_rounded,
                            color: const Color(0xFF16A085),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '$currency${totalBreakfastFees.toStringAsFixed(0)}',
                            label: 'Breakfast',
                            icon: Icons.breakfast_dining_rounded,
                            color: const Color(0xFF795548),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '$currency${totalLunchFees.toStringAsFixed(0)}',
                            label: 'Lunch',
                            icon: Icons.lunch_dining_rounded,
                            color: const Color(0xFFD35400),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ModernMetricStat(
                            value: '$currency${totalDinnerFees.toStringAsFixed(0)}',
                            label: 'Dinner',
                            icon: Icons.restaurant_menu_rounded,
                            color: const Color(0xFF2980B9),
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // STATUS BAR
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            '${stats.confirmedGolfers}/$capacity spaces',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Container(width: 1, height: 16, color: Colors.grey.withOpacity(0.3)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isClosed ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                                size: 18,
                                color: isClosed ? const Color(0xFFC0392B) : const Color(0xFF27AE60),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isClosed ? 'Registration Closed' : 'Registration Open',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isClosed ? const Color(0xFFC0392B) : const Color(0xFF27AE60),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
          // MEMBERS - PLAYING
          if (playingMembers.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Playing (${playingMembers.length})'),
            ...playingMembers.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // MEMBERS - WAITLIST
          if (waitlistMembers.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Waitlist (${waitlistMembers.length})'),
            ...waitlistMembers.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // MEMBERS - RESERVED
          if (reservedMembers.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Reserved (${reservedMembers.length})'),
            ...reservedMembers.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // GUESTS - PLAYING
          if (playingGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Playing Guests (${playingGuests.length})'),
            ...playingGuests.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // WAITLIST GUESTS
          if (waitlistGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Waitlist Guests (${waitlistGuests.length})'),
            ...waitlistGuests.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // RESERVED GUESTS
          if (reservedGuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Reserved Guests (${reservedGuests.length})'),
            ...reservedGuests.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // DINNER ONLY
          if (dinnerModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Dinner Only (${dinnerModels.length})'),
            ...dinnerModels.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],

          // NOT PARTICIPATING
          if (withdrawnModels.isNotEmpty) ...[
            const SizedBox(height: 24),
            BoxyArtSectionTitle(title: 'Not Participating (${withdrawnModels.length})'),
            ...withdrawnModels.map((vm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RegistrationCard(
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
              ),
            )),
          ],
            const SizedBox(height: 100),
          ]),
        ),
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
