import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/golf_event.dart';
import '../events_provider.dart';

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
    final allMembersAsync = ref.watch(allMembersProvider);

    return eventsAsync.when(
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return const Scaffold(
            body: Center(
              child: Text('Registration data no longer available'),
            ),
          );
        }
        return HeadlessScaffold(
          title: 'Registration',
          subtitle: event.title,
          showBack: true,
          onBack: () => context.go('/events'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: allMembersAsync.when(
                  data: (members) => buildStaticContent(context, ref, event, members),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const Text('Error loading members'),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  static Widget buildStaticContent(BuildContext context, WidgetRef ref, GolfEvent event, List<Member> members) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // METRICS CARD
        const SizedBox(height: 12),
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
                        value: '${stats.totalGolfers}',
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
                        value: '${stats.totalGuests}',
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
              const SizedBox(height: 16),
              // STATUS BAR
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${stats.confirmedGolfers}/$capacity spaces',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 16, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(width: 8),
                      Icon(
                        isClosed ? Icons.lock_outline_rounded : Icons.timer_outlined,
                        size: 16,
                        color: isClosed ? const Color(0xFFC0392B) : const Color(0xFF607D8B),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isClosed ? 'Registration Closed' : 'Closing Soon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isClosed ? const Color(0xFFC0392B) : const Color(0xFF607D8B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // PLAYING MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest)) ...[
          BoxyArtSectionTitle(title: 'Playing Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).map((vm) => Padding(
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
              isGuest: false,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // PLAYING GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Playing Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).map((vm) => Padding(
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
              hasGuest: false,
              hasPaid: vm.item.registration.hasPaid,
              isGuest: true,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // WAITLIST MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Waitlist Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).map((vm) => Padding(
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
              isGuest: false,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // WAITLIST GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Waitlist Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).map((vm) => Padding(
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
              hasGuest: false,
              hasPaid: vm.item.registration.hasPaid,
              isGuest: true,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // RESERVED MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Reserved Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).map((vm) => Padding(
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
              isGuest: false,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // RESERVED GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest)) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Reserved Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).map((vm) => Padding(
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
              hasGuest: false,
              hasPaid: vm.item.registration.hasPaid,
              isGuest: true,
              isAdmin: false,
              memberProfile: vm.memberProfile,
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
              attendingBreakfast: false,
              attendingLunch: false,
              attendingDinner: true,
              hasPaid: vm.item.registration.hasPaid,
              isDinnerOnly: true,
              isAdmin: false,
              memberProfile: vm.memberProfile,
            ),
          )),
        ],

        // WITHDRAWN
        if (withdrawnModels.isNotEmpty) ...[
          const SizedBox(height: 24),
          BoxyArtSectionTitle(title: 'Withdrawn (${withdrawnModels.length})'),
          ...withdrawnModels.map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RegistrationCard(
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
            ),
          )),
        ],
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
