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
          hasPaid: r.hasPaid, // Guest payment usually linked to member payment
          isConfirmed: r.guestIsConfirmed,
          name: r.guestName!,
          needsBuggy: r.guestNeedsBuggy,
          statusOverride: null, // Guests don't have overrides yet, or we use member's?
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
    if (!item.isGuest && item.hasPaid && item.isConfirmed) return 0; // Playing (Confirmed)
    if (!item.isGuest) return 1; // All Other Members (Paid or Unpaid)
    return 2; // Guests 
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

  /// Returns a list of members who are NOT attending golf AND NOT attending dinner (Withdrawn).
  static List<RegistrationItem> getWithdrawnItems(GolfEvent event) {
    final items = <RegistrationItem>[];
    
    for (var r in event.registrations) {
      // Member Withdrawn (Either explicitly or by deselecting everything)
      final bool explicitlyWithdrawn = r.statusOverride == 'withdrawn';
      final bool nothingSelected = !r.attendingGolf && !r.attendingDinner;

      if (explicitlyWithdrawn || nothingSelected) {
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
      
      // Guest Withdrawn (Member is playing but guest was deselected)
      if (r.attendingGolf && (r.guestName == null || r.guestName!.isEmpty)) {
        // We don't necessarily track "withdrawn guests" unless they were previously there.
        // But the user mentioned "a guest where the member has deselected the guest toggle".
        // This is hard to track without history, but if the registration had a guest name 
        // and now doesn't, it's withdrawn.
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
    required int indexInList,
    required int capacity,
    required int confirmedCount,
    required bool isEventClosed,
    String? statusOverride,
  }) {
    // 1. Manual Override
    if (statusOverride != null) {
      if (statusOverride == 'confirmed') return RegistrationStatus.confirmed;
      if (statusOverride == 'reserved') return RegistrationStatus.reserved;
      if (statusOverride == 'waitlist') return RegistrationStatus.waitlist;
      if (statusOverride == 'withdrawn') return RegistrationStatus.withdrawn;
    }

    // 2. Guests: Must wait until event is closed (unless manual override above handled it)
    if (isGuest && !isEventClosed) {
      return RegistrationStatus.reserved;
    }

    if (isConfirmed) return RegistrationStatus.confirmed;

    // 3. Capacity Check (Waitlist)
    // They only appear in the waitlist if all the slots are taken (confirmed).
    if (capacity > 0 && confirmedCount >= capacity) {
      return RegistrationStatus.waitlist;
    }

    // Irrespective of available slots everyone is on a reserve list until confirmed.
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
    
    // 2. Confirmation Check
    if (isConfirmed) return RegistrationStatus.confirmed;

    // 3. Capacity Check
    if (buggyCapacity > 0 && confirmedBuggyCount >= buggyCapacity) {
      return RegistrationStatus.waitlist;
    }
    
    return RegistrationStatus.reserved;
  }
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
