import '../../../../models/event_registration.dart';
import '../../../../models/golf_event.dart';

enum RegistrationStatus {
  confirmed,
  reserved,
  waitlist,
  pendingGuest,
  withdrawn,
  dinner,
  none,
}

class RegistrationLogic {
  
  /// Flattens registrations into a list of items (members + guests separate)
  /// and sorts them by registration time (FCFS).
  /// Returns a sorted list of RegistrationItem.
  static List<RegistrationItem> getSortedItems(GolfEvent event, {bool includeWithdrawn = false}) {
    final flattenedItems = <RegistrationItem>[];
    
    for (var r in event.registrations) {
      // Add Member (If attending golf OR withdrawn)
      final bool isWithdrawn = r.statusOverride == 'withdrawn' || (!r.attendingGolf && !r.attendingDinner);
      
      if (r.attendingGolf || (includeWithdrawn && isWithdrawn)) {
        flattenedItems.add(RegistrationItem(
          registration: r,
          isGuest: false,
          registeredAt: r.registeredAt ?? DateTime.now(),
          hasPaid: r.hasPaid,
          isConfirmed: r.isConfirmed,
          name: r.memberName,
          needsBuggy: r.needsBuggy,
          statusOverride: r.statusOverride,
          buggyStatusOverride: r.buggyStatusOverride,
          originalRegistration: r,
        ));
      }
      
      // Add Guest (If host attending golf OR host withdrawn)
      if ((r.attendingGolf || (includeWithdrawn && isWithdrawn)) && r.guestName != null && r.guestName!.isNotEmpty) {
        flattenedItems.add(RegistrationItem(
          registration: r,
          isGuest: true,
          registeredAt: r.registeredAt ?? DateTime.now(),
          hasPaid: r.hasPaid, // Guest payment linked to member
          isConfirmed: r.guestIsConfirmed, // Use guest-specific confirmation
          name: r.guestName!,
          needsBuggy: r.guestNeedsBuggy,
          statusOverride: null, 
          buggyStatusOverride: r.guestBuggyStatusOverride,
          originalRegistration: r,
        ));
      }
    }

    // Sort Logic (FCFS)
    // The user's requested sorting:
    // 1. Confirmed Members (Playing) - Sorted by time
    // 2. Paid but Unconfirmed Members (Reserve) - Sorted by time
    // 3. Guests - Sorted by time
    flattenedItems.sort((a, b) {
      // Primary: confirmed members first, then paid members, then guests
      int aRank = _getRank(a);
      int bRank = _getRank(b);
      
      if (aRank != bRank) return aRank.compareTo(bRank);
      
      // Secondary: Time (FCFS)
      return a.registeredAt.compareTo(b.registeredAt);
    });
    
    return flattenedItems;
  }

  static int _getRank(RegistrationItem item) {
    if (!item.isGuest && item.isConfirmed) return 0; // Confirmed Member (Playing/Waitlist)
    if (item.isGuest && item.isConfirmed) return 1;  // Confirmed Guest (Playing/Waitlist)
    if (!item.isGuest) return 2;                    // Unconfirmed Member (Reserved)
    return 3;                                       // Unconfirmed Guest (Reserved)
  }

  /// Returns a list of members who are ONLY attending dinner (not golf).
  static List<RegistrationItem> getDinnerOnlyItems(GolfEvent event) {
    final items = <RegistrationItem>[];
    
    for (var r in event.registrations) {
      // If NOT attending golf, but IS attending dinner (and not withdrawn)
      if (!r.attendingGolf && r.attendingDinner && r.statusOverride != 'withdrawn') {
         items.add(RegistrationItem(
           registration: r,
           isGuest: false,
           registeredAt: r.registeredAt ?? DateTime.now(),
           hasPaid: r.hasPaid,
           isConfirmed: r.isConfirmed,
           name: r.memberName,
           needsBuggy: false,
           statusOverride: r.statusOverride,
           originalRegistration: r,
         ));
      }
    }
    
    // Sort by time
    items.sort((a, b) => a.registeredAt.compareTo(b.registeredAt));
    
    return items;
  }

  static RegistrationStats getRegistrationStats(GolfEvent event) {
    int totalRegistrations = event.registrations.length;
    int confirmedGolfers = 0;
    int confirmedMembers = 0;
    int confirmedGuests = 0;
    int reserveGolfers = 0;
    int reserveMembers = 0;
    int reserveGuests = 0;
    int waitlistGolfers = 0;
    int dinnerCount = 0;
    int breakfastCount = 0;
    int lunchCount = 0;
    int buggyCount = 0;
    int withdrawnCount = 0;
    int withdrawnConfirmedCount = 0;
    int dinnerOnlyCount = 0;

    final sortedPool = getSortedItems(event);
    final isClosed = event.registrationDeadline != null && DateTime.now().isAfter(event.registrationDeadline!);
    final capacity = event.maxParticipants ?? 999;
    
    // Pass 1: Active Golf Pool (Members & Guests playing golf)
    int rollingTakenSlots = 0;
    for (int i = 0; i < sortedPool.length; i++) {
      final item = sortedPool[i];
      final status = calculateStatus(
        isGuest: item.isGuest,
        isConfirmed: item.isConfirmed,
        hasPaid: item.hasPaid,
        capacity: capacity,
        confirmedCount: rollingTakenSlots,
        isEventClosed: isClosed,
        statusOverride: item.statusOverride,
      );

      if (status == RegistrationStatus.confirmed) {
        rollingTakenSlots++;
        confirmedGolfers++;
        if (item.isGuest) {
          confirmedGuests++;
        } else {
          confirmedMembers++;
        }

        // Services for confirmed golfers
        if (item.needsBuggy) buggyCount++;
        final reg = item.registration;
        if (item.isGuest) {
          if (reg.guestAttendingBreakfast) breakfastCount++;
          if (reg.guestAttendingLunch) lunchCount++;
          if (reg.guestAttendingDinner) dinnerCount++;
        } else {
          if (reg.attendingBreakfast) breakfastCount++;
          if (reg.attendingLunch) lunchCount++;
          if (reg.attendingDinner) dinnerCount++;
        }
      } else if (status == RegistrationStatus.reserved) {
        rollingTakenSlots++;
        reserveGolfers++;
        if (item.isGuest) {
          reserveGuests++;
        } else {
          reserveMembers++;
        }
      } else if (status == RegistrationStatus.waitlist) {
        waitlistGolfers++;
      }
    }

    // Pass 2: Dinner Only Participants
    final dinnerOnlyItems = getDinnerOnlyItems(event);
    dinnerOnlyCount = dinnerOnlyItems.length;
    for (var item in dinnerOnlyItems) {
      // Dinner only are implicitly confirmed for dinner if in this list
      dinnerCount++;
      if (item.registration.attendingBreakfast) breakfastCount++;
      if (item.registration.attendingLunch) lunchCount++;
    }

    // Pass 3: Withdrawn Participants (Audit)
    final withdrawnItems = getWithdrawnItems(event);
    withdrawnCount = withdrawnItems.length;
    
    // Simulate what would have happened if NOT withdrawn to find "Withdrawn Confirmed"
    final allSorted = getSortedItems(event, includeWithdrawn: true);
    int simTakenSlots = 0;
    for (int i = 0; i < allSorted.length; i++) {
      final item = allSorted[i];
      final simStatus = calculateStatus(
        isGuest: item.isGuest,
        isConfirmed: item.isConfirmed,
        hasPaid: item.hasPaid,
        capacity: capacity,
        confirmedCount: simTakenSlots,
        isEventClosed: isClosed,
        statusOverride: null, // Ignore actual withdrawn override
      );
      if (simStatus == RegistrationStatus.confirmed || simStatus == RegistrationStatus.reserved) {
        simTakenSlots++;
        if (item.statusOverride == 'withdrawn') {
          withdrawnConfirmedCount++;
        }
      }
    }

    return RegistrationStats(
      totalRegistrations: totalRegistrations,
      confirmedGolfers: confirmedGolfers,
      confirmedMembers: confirmedMembers,
      confirmedGuests: confirmedGuests,
      reserveGolfers: reserveGolfers,
      reserveMembers: reserveMembers,
      reserveGuests: reserveGuests,
      waitlistGolfers: waitlistGolfers,
      dinnerCount: dinnerCount,
      breakfastCount: breakfastCount,
      lunchCount: lunchCount,
      buggyCount: buggyCount,
      withdrawnCount: withdrawnCount,
      withdrawnConfirmedCount: withdrawnConfirmedCount,
      dinnerOnlyCount: dinnerOnlyCount,
    );
  }

  /// Returns the total number of confirmed participants attending golf (Members + Guests).
  /// Excludes dinner-only participants.
  static int getConfirmedGolfersCount(GolfEvent event) {
    int count = 0;
    for (var r in event.registrations) {
      if (r.statusOverride == 'withdrawn') continue;

      // Member confirmed and playing golf
      if (r.attendingGolf) {
        if (r.isConfirmed) count++;
        
        // Guest confirmed (Only counted if member is playing, per getSortedItems logic)
        if (r.guestName != null && r.guestName!.isNotEmpty && r.guestIsConfirmed) {
          count++;
        }
      }
    }
    return count;
  }

  /// Returns a list of all participants who have withdrawn.
  static List<RegistrationItem> getWithdrawnItems(GolfEvent event) {
    final items = <RegistrationItem>[];
    for (var r in event.registrations) {
      if (r.statusOverride == 'withdrawn' || (!r.attendingGolf && !r.attendingDinner)) {
        items.add(RegistrationItem(
          registration: r,
          isGuest: false,
          registeredAt: r.registeredAt ?? DateTime.now(),
          hasPaid: r.hasPaid,
          isConfirmed: r.isConfirmed,
          name: r.memberName,
          needsBuggy: r.needsBuggy,
          statusOverride: r.statusOverride,
          originalRegistration: r,
        ));

        if (r.guestName != null && r.guestName!.isNotEmpty) {
          items.add(RegistrationItem(
            registration: r,
            isGuest: true,
            registeredAt: r.registeredAt ?? DateTime.now(),
            hasPaid: r.hasPaid,
            isConfirmed: r.guestIsConfirmed, // Use guest-specific confirmation
            name: r.guestName!,
            needsBuggy: r.guestNeedsBuggy,
            statusOverride: null,
            originalRegistration: r,
          ));
        }
      }
    }
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  /// Calculates the main registration status (Golf/Dinner)
  static RegistrationStatus calculateStatus({
    required bool isGuest,
    required bool isConfirmed,
    required bool hasPaid,
    required int confirmedCount,
    required int capacity,
    required bool isEventClosed,
    String? statusOverride,
  }) {
    // 1. Manual Override
    if (statusOverride != null) {
      if (statusOverride == 'confirmed') {
        if (capacity > 0 && confirmedCount >= capacity) return RegistrationStatus.waitlist;
        return RegistrationStatus.confirmed;
      }
      if (statusOverride == 'reserved') return RegistrationStatus.reserved;
      if (statusOverride == 'waitlist') return RegistrationStatus.waitlist;
      if (statusOverride == 'withdrawn') return RegistrationStatus.withdrawn;
    }

    // 2. Explicit Confirmation (Admin Tick / Paid)
    if (isConfirmed) {
      if (capacity > 0 && confirmedCount >= capacity) return RegistrationStatus.waitlist;
      return RegistrationStatus.confirmed;
    }

    // 3. Post-Deadline Auto-Promotion (Specific cases)
    if (isEventClosed) {
      // Guests are auto-promoted once the deadline passes if space is available (Point 2)
      if (isGuest) {
        if (capacity > 0 && confirmedCount >= capacity) return RegistrationStatus.waitlist;
        return RegistrationStatus.confirmed;
      }
      
      // NOTE: Unconfirmed Members remain "Reserved" even after closure.
      // This satisfies Point 3 (Manual promotion by Admin) and Point 1 (Only confirmed count).
      // Automatic promotion for members only happens if they have the isConfirmed flag.
    }

    // 4. Default Handling (Reserved/Waitlist)
    if (capacity > 0 && confirmedCount >= capacity) return RegistrationStatus.waitlist;
    return RegistrationStatus.reserved;
  }

  /// Calculates buggy allocation status
  static RegistrationStatus calculateBuggyStatus({
    required bool needsBuggy,
    required bool isConfirmed,
    required int buggyIndexInQueue,
    required int buggyCapacity,
    required int confirmedBuggyCount,
    String? buggyStatusOverride,
  }) {
    if (!needsBuggy) return RegistrationStatus.none;

    // 1. Manual Override
    if (buggyStatusOverride != null) {
      if (buggyStatusOverride == 'confirmed') return RegistrationStatus.confirmed;
      if (buggyStatusOverride == 'reserved') return RegistrationStatus.reserved;
      if (buggyStatusOverride == 'waitlist') return RegistrationStatus.waitlist;
    }
    
    // 2. Capacity Check (FCFS)
    if (buggyCapacity > 0 && buggyIndexInQueue >= buggyCapacity) {
      return RegistrationStatus.reserved; 
    }

    // 3. Confirmation Check (Only if within capacity)
    if (isConfirmed) return RegistrationStatus.confirmed;
    
    return RegistrationStatus.reserved;
  }

}

class RegistrationStats {
  final int totalRegistrations;
  final int confirmedGolfers;
  final int confirmedMembers;
  final int confirmedGuests;
  final int reserveGolfers;
  final int reserveMembers;
  final int reserveGuests;
  final int waitlistGolfers;
  final int dinnerCount;
  final int breakfastCount;
  final int lunchCount;
  final int buggyCount;
  final int withdrawnCount;
  final int withdrawnConfirmedCount;
  final int dinnerOnlyCount;

  RegistrationStats({
    required this.totalRegistrations,
    required this.confirmedGolfers,
    required this.confirmedMembers,
    required this.confirmedGuests,
    required this.reserveGolfers,
    required this.reserveMembers,
    required this.reserveGuests,
    required this.waitlistGolfers,
    required this.dinnerCount,
    required this.breakfastCount,
    required this.lunchCount,
    required this.buggyCount,
    required this.withdrawnCount,
    required this.withdrawnConfirmedCount,
    required this.dinnerOnlyCount,
  });
}

class RegistrationItem {
  final EventRegistration registration; 
  final EventRegistration originalRegistration; 
  final bool isGuest;
  final DateTime registeredAt;
  final bool hasPaid;
  final bool isConfirmed;
  final String name;
  final bool needsBuggy;
  final String? statusOverride;
  final String? buggyStatusOverride;

  RegistrationItem({
    required this.registration,
    required this.isGuest,
    required this.registeredAt,
    required this.hasPaid,
    required this.isConfirmed,
    required this.name,
    required this.needsBuggy,
    this.statusOverride,
    this.buggyStatusOverride,
    required this.originalRegistration,
  });
}
