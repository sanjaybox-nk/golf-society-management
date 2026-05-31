import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../events_provider.dart';

import '../../domain/registration_logic.dart';
import '../widgets/registration_card.dart';
import '../widgets/registration_stats_card.dart';


// ... (existing imports)

import 'package:golf_society/domain/models/member.dart';
import '../../../members/presentation/members_provider.dart';
import '../../../members/presentation/profile_provider.dart';

class EventRegistrationUserTab extends ConsumerWidget {
  final String eventId;
  final bool isAdminMode;

  const EventRegistrationUserTab({
    super.key,
    required this.eventId,
    this.isAdminMode = false,
  });

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
        final user = ref.watch(effectiveUserProvider);
        final isStaff = user.role != MemberRole.member;

        return HeadlessScaffold(
          title: 'Registration',
          subtitle: event.title,
          showAdminShortcut: false, 
          showBack: true,
          onBack: () => context.go('/events'),
          actions: (isAdminMode && isStaff) ? [
            BoxyArtGlassIconButton(
              icon: Icons.edit_rounded,
              tooltip: 'Manage Registrations',
              onPressed: () => context.push('/admin/events/manage/${event.id}/registrations'),
            ),
          ] : null,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
              sliver: SliverToBoxAdapter(
                child: allMembersAsync.when(
                  data: (members) => buildStaticContent(context, ref, event, members, isAdminMode: isAdminMode),
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

  static Widget buildStaticContent(
    BuildContext context, 
    WidgetRef ref, 
    GolfEvent event, 
    List<Member> members,
    {bool isAdminMode = false}
  ) {
    if (event.registrations.isEmpty) {
      final String emptyText = event.showRegistrationButton
          ? 'Registration Open'
          : event.isTargetedRegistration
              ? 'Registration open to selected members'
              : 'Registration not open yet';
          
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: Text(
            emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeBody),
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




    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Spacing handled by BoxyArtSectionTitle's internal padding (cardToLabel default)
        const BoxyArtSectionTitle(
          title: 'Registration Stats',
          topPadding: 0,
        ),
        RegistrationStatsCard(event: event),

        // PLAYING MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == false)) ...[
        BoxyArtSectionTitle(
          title: 'Playing Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == false).length})',
          followsCard: true,
        ),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == false).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: vm.item.registration.handicap,
              playingHandicap: vm.item.registration.playingHandicap,
            ),
          )),
        ],

        // PLAYING GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == true)) ...[
          BoxyArtSectionTitle(title: 'Playing Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == true).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest == true).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
              playingHandicap: null,
            ),
          )),
        ],

        // WAITLIST MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == false)) ...[
          BoxyArtSectionTitle(title: 'Waitlist Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == false).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == false).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: vm.item.registration.handicap,
              playingHandicap: vm.item.registration.playingHandicap,
            ),
          )),
        ],

        // WAITLIST GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == true)) ...[
          BoxyArtSectionTitle(title: 'Waitlist Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == true).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest == true).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
              playingHandicap: null,
            ),
          )),
        ],

        // RESERVED MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == false)) ...[
          BoxyArtSectionTitle(title: 'Reserved Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == false).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == false).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: vm.item.registration.handicap,
              playingHandicap: vm.item.registration.playingHandicap,
            ),
          )),
        ],

        // RESERVED GUESTS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == true)) ...[
          BoxyArtSectionTitle(title: 'Reserved Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == true).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest == true).map((vm) => Padding(
            padding: EdgeInsets.only(bottom: Theme.of(context).extension<AppSpacingTokens>()?.cardToCard ?? AppSpacing.md),
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
              handicap: double.tryParse(vm.item.registration.guestHandicap ?? ''),
              playingHandicap: null,
            ),
          )),
        ],

        // DINNER ONLY
        if (dinnerModels.isNotEmpty) ...[
          BoxyArtSectionTitle(title: 'Dinner Only (${dinnerModels.length})'),
          ...dinnerModels.map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: RegistrationCard(
              name: vm.item.name,
              label: 'Member',
              status: vm.status,
              buggyStatus: RegistrationStatus.none,
              attendingBreakfast: false,
              attendingLunch: false,
              attendingDinner: true,
              hasPaid: vm.item.registration.hasPaid,
              isDinnerOnly: true,
              isAdmin: false,
              memberProfile: vm.memberProfile,
              handicap: vm.item.registration.handicap,
              playingHandicap: vm.item.registration.playingHandicap,
            ),
          )),
        ],

        // WITHDRAWN
        if (withdrawnModels.isNotEmpty) ...[
          BoxyArtSectionTitle(title: 'Withdrawn (${withdrawnModels.length})'),
          ...withdrawnModels.map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: RegistrationCard(
              name: vm.item.name,
              label: 'Withdrawn',
              status: vm.status,
              buggyStatus: RegistrationStatus.none,
              attendingBreakfast: false,
              attendingLunch: false,
              attendingDinner: false,
              isAdmin: false,
              memberProfile: vm.memberProfile,
              handicap: vm.item.registration.handicap,
              playingHandicap: vm.item.registration.playingHandicap,
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
