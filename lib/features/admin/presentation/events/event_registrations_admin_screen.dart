import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../events/domain/registration_logic.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../events/presentation/widgets/registration_card.dart';
import '../../../events/presentation/widgets/registration_stats_card.dart';


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
          title: 'Registrations',
          titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, GolfEvent event, List<Member> members) {
    return buildSliver(context, ref, event, members);
  }

  static Widget buildSliver(BuildContext context, WidgetRef ref, GolfEvent event, List<Member> members) {
    // Shared Logic for groups/sorting
    final sortedItems = RegistrationLogic.getSortedItems(event);
    final dinnerOnlyItems = RegistrationLogic.getDinnerOnlyItems(event);

    final maxParticipants = event.maxParticipants ?? 999;
    final availableBuggies = event.availableBuggies ?? 0;
    final buggyCapacity = availableBuggies * 2;
    final buggyQueue = sortedItems.where((i) => i.needsBuggy).toList();

    // Map profile data
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

    final playingMembers = memberModels.where((vm) => vm.status == RegistrationStatus.confirmed).toList();
    final playingGuests = guestModels.where((vm) => vm.status == RegistrationStatus.confirmed).toList();
    final reservedMembers = memberModels.where((vm) => vm.status == RegistrationStatus.reserved).toList();
    final reservedGuests = guestModels.where((vm) => vm.status == RegistrationStatus.reserved).toList();
    final waitlistMembers = memberModels.where((vm) => vm.status == RegistrationStatus.waitlist).toList();
    final waitlistGuests = guestModels.where((vm) => vm.status == RegistrationStatus.waitlist).toList();


    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, 
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // METRICS CARD
            const BoxyArtSectionTitle(
              title: 'Registration Stats',
              isPeeking: false, // Uses tabToContent (16.0) for standard top gap
            ),
            RegistrationStatsCard(event: event, isCompact: true, showAdminMetrics: true),


          // MEMBERS - PLAYING
          if (playingMembers.isNotEmpty) ...[
            BoxyArtSectionTitle(
              title: 'Playing (${playingMembers.length})', 
              isPeeking: true,
              followsCard: true, // Uses cardToLabel (16.0) from metrics card
            ),
            ...playingMembers.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == playingMembers.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: vm.item.registration.handicap,
                  playingHandicap: vm.item.registration.playingHandicap,
                  onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
                  onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
                  onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
                  onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
                  onPaidToggle: () => _togglePaid(ref, event, vm.item.registration, false),
                ),
              );
            }),
          ],

          // MEMBERS - WAITLIST
          if (waitlistMembers.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Waitlist', count: waitlistMembers.length, isPeeking: true, followsCard: true),
            ...waitlistMembers.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == waitlistMembers.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: vm.item.registration.handicap,
                  playingHandicap: vm.item.registration.playingHandicap,
                  onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
                  onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
                  onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
                  onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
                  onPaidToggle: () => _togglePaid(ref, event, vm.item.registration, false),
                ),
              );
            }),
          ],

          // MEMBERS - RESERVED
          if (reservedMembers.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Reserved', count: reservedMembers.length, isPeeking: true, followsCard: true),
            ...reservedMembers.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == reservedMembers.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: vm.item.registration.handicap,
                  playingHandicap: vm.item.registration.playingHandicap,
                  onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, false),
                  onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, false),
                  onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, false),
                  onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, false),
                  onPaidToggle: () => _togglePaid(ref, event, vm.item.registration, false),
                ),
              );
            }),
          ],

          // GUESTS - PLAYING
          if (playingGuests.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Playing Guests', count: playingGuests.length, isPeeking: true, followsCard: true),
            ...playingGuests.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == playingGuests.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
                  playingHandicap: null,
                  onStatusChanged: (newStatus) => _updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => _toggleBuggyStatus(ref, event, vm.item.registration, true),
                  onBreakfastToggle: () => _toggleBreakfast(ref, event, vm.item.registration, true),
                  onLunchToggle: () => _toggleLunch(ref, event, vm.item.registration, true),
                  onDinnerToggle: () => _toggleDinner(ref, event, vm.item.registration, true),
                  onPaidToggle: () => _togglePaid(ref, event, vm.item.registration, true),
                ),
              );
            }),
          ],

          // WAITLIST GUESTS
          if (waitlistGuests.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Waitlist Guests', count: waitlistGuests.length, isPeeking: true, followsCard: true),
            ...waitlistGuests.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == waitlistGuests.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
                  playingHandicap: null,
                  onStatusChanged: (newStatus) => EventRegistrationsAdminScreen._updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => EventRegistrationsAdminScreen._toggleBuggyStatus(ref, event, vm.item.registration, true),
                  onBreakfastToggle: () => EventRegistrationsAdminScreen._toggleBreakfast(ref, event, vm.item.registration, true),
                  onLunchToggle: () => EventRegistrationsAdminScreen._toggleLunch(ref, event, vm.item.registration, true),
                  onDinnerToggle: () => EventRegistrationsAdminScreen._toggleDinner(ref, event, vm.item.registration, true),
                  onPaidToggle: () => EventRegistrationsAdminScreen._togglePaid(ref, event, vm.item.registration, true),
                ),
              );
            }),
          ],

          // RESERVED GUESTS
          if (reservedGuests.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Reserved Guests', count: reservedGuests.length, isPeeking: true, followsCard: true),
            ...reservedGuests.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == reservedGuests.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
                  playingHandicap: null,
                  onStatusChanged: (newStatus) => EventRegistrationsAdminScreen._updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => EventRegistrationsAdminScreen._toggleBuggyStatus(ref, event, vm.item.registration, true),
                  onBreakfastToggle: () => EventRegistrationsAdminScreen._toggleBreakfast(ref, event, vm.item.registration, true),
                  onLunchToggle: () => EventRegistrationsAdminScreen._toggleLunch(ref, event, vm.item.registration, true),
                  onDinnerToggle: () => EventRegistrationsAdminScreen._toggleDinner(ref, event, vm.item.registration, true),
                  onPaidToggle: () => EventRegistrationsAdminScreen._togglePaid(ref, event, vm.item.registration, true),
                ),
              );
            }),
          ],

          // DINNER ONLY
          if (dinnerModels.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Dinner Only', count: dinnerModels.length, isPeeking: true, followsCard: true),
            ...dinnerModels.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == dinnerModels.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: vm.item.registration.handicap,
                  playingHandicap: vm.item.registration.playingHandicap,
                  onStatusChanged: (newStatus) => EventRegistrationsAdminScreen._updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: null,
                  onBreakfastToggle: () => EventRegistrationsAdminScreen._toggleBreakfast(ref, event, vm.item.registration, false),
                  onLunchToggle: () => EventRegistrationsAdminScreen._toggleLunch(ref, event, vm.item.registration, false),
                  onDinnerToggle: () => EventRegistrationsAdminScreen._toggleDinner(ref, event, vm.item.registration, false),
                  onPaidToggle: () => EventRegistrationsAdminScreen._togglePaid(ref, event, vm.item.registration, false),
                ),
              );
            }),
          ],

          // NOT PARTICIPATING
          if (withdrawnModels.isNotEmpty) ...[
            BoxyArtSectionTitle(title: 'Not Participating', count: withdrawnModels.length, isPeeking: true, followsCard: true),
            ...withdrawnModels.asMap().entries.map((entry) {
              final idx = entry.key;
              final vm = entry.value;
              final isLast = idx == withdrawnModels.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.md)),
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
                  handicap: vm.item.registration.handicap,
                  playingHandicap: vm.item.registration.playingHandicap,
                  onStatusChanged: (newStatus) => EventRegistrationsAdminScreen._updateStatus(ref, event, vm.item.registration, newStatus),
                  onBuggyToggle: () => EventRegistrationsAdminScreen._toggleBuggyStatus(ref, event, vm.item.registration, false),
                  onBreakfastToggle: () => EventRegistrationsAdminScreen._toggleBreakfast(ref, event, vm.item.registration, false),
                  onLunchToggle: () => EventRegistrationsAdminScreen._toggleLunch(ref, event, vm.item.registration, false),
                  onDinnerToggle: () => EventRegistrationsAdminScreen._toggleDinner(ref, event, vm.item.registration, false),
                  onPaidToggle: () => EventRegistrationsAdminScreen._togglePaid(ref, event, vm.item.registration, false),
                ),
              );
            }),
          ],
            SizedBox(height: AppSpacing.hero),
          ]),
        ),
    );
  }

  

  static void _updateStatus(WidgetRef ref, GolfEvent event, EventRegistration reg, RegistrationStatus newStatus) {
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
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }

  static void _toggleBuggyStatus(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
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
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }

  static void _toggleBreakfast(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingBreakfast: !reg.guestAttendingBreakfast)
      : reg.copyWith(attendingBreakfast: !reg.attendingBreakfast);
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }

  static void _toggleLunch(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingLunch: !reg.guestAttendingLunch)
      : reg.copyWith(attendingLunch: !reg.attendingLunch);
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }


  static void _toggleDinner(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    final updated = isGuest 
      ? reg.copyWith(guestAttendingDinner: !reg.guestAttendingDinner)
      : reg.copyWith(attendingDinner: !reg.attendingDinner);
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }

  static void _togglePaid(WidgetRef ref, GolfEvent event, EventRegistration reg, bool isGuest) {
    // Note: Membership fee paid is member.hasPaid. Event fee is reg.hasPaid.
    final updated = reg.copyWith(hasPaid: !reg.hasPaid);
    EventRegistrationsAdminScreen._updateRegistration(ref, event, updated);
  }

  static void _updateRegistration(WidgetRef ref, GolfEvent event, EventRegistration updated) {
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
