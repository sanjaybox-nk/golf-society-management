import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../events_provider.dart';

import '../../domain/registration_logic.dart';
import '../widgets/registration_card.dart';

// ... (existing imports)

import 'package:golf_society/domain/models/member.dart';
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
              padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
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
        SizedBox(height: AppTheme.cardSpacing),
        const BoxyArtSectionTitle(title: 'Registration Stats'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: playingValue,
                        label: 'Playing',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: reserveValue,
                        label: 'Reserve',
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.totalGuests}',
                        label: 'Guests',
                        icon: Icons.person_add_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.dinnerCount}',
                        label: 'Dinner',
                        icon: Icons.restaurant_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.waitlistGolfers}',
                        label: 'Waitlist',
                        icon: Icons.priority_high_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernMetricStat(
                        value: '${stats.breakfastCount}',
                        label: 'Breakfast',
                        icon: Icons.breakfast_dining_rounded,
                        color: AppColors.lime500,
                        iconColor: AppColors.dark900,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              // STATUS BAR
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${stats.confirmedGolfers}/$capacity spaces',
                          style: const TextStyle(
                            fontSize: AppTypography.sizeBodySmall,
                            fontWeight: AppTypography.weightSemibold,
                            color: Color(0xFF2C3E50),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      BoxyArtPill.status(
                        label: isClosed ? 'Registration Closed' : (isClosed ? 'Registration Closed' : 'Closing Soon'),
                        color: isClosed 
                            ? (Theme.of(context).brightness == Brightness.dark ? AppColors.dark150 : AppColors.dark400)
                            : AppColors.coral400,
                        icon: isClosed ? Icons.lock_outline_rounded : Icons.hourglass_bottom_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.cardSpacing),

        // PLAYING MEMBERS
        if (itemViewModels.any((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest)) ...[
          BoxyArtSectionTitle(title: 'Playing Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && !vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
          BoxyArtSectionTitle(title: 'Playing Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.confirmed && vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
          BoxyArtSectionTitle(title: 'Waitlist Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && !vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
          BoxyArtSectionTitle(title: 'Waitlist Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.waitlist && vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
          BoxyArtSectionTitle(title: 'Reserved Members (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && !vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
          BoxyArtSectionTitle(title: 'Reserved Guests (${itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).length})'),
          ...itemViewModels.where((vm) => vm.status == RegistrationStatus.reserved && vm.item.isGuest).map((vm) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          SizedBox(height: AppTheme.cardSpacing),
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
            ),
          )),
        ],

        // WITHDRAWN
        if (withdrawnModels.isNotEmpty) ...[
          SizedBox(height: AppTheme.cardSpacing),
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
