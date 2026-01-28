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
  static List<RegistrationItem> getSortedItems(GolfEvent event) {
    
    final flattenedItems = <RegistrationItem>[];
    
    for (var r in event.registrations) {
       // Add Member
       if (r.attendingGolf) {
         flattenedItems.add(RegistrationItem(
           registration: r,
           isGuest: false,
           registeredAt: r.registeredAt ?? DateTime.now(),
           hasPaid: r.hasPaid,
           name: r.memberName,
           needsBuggy: r.needsBuggy,
           originalRegistration: r,
         ));
       }
       
       // Add Guest (if exists and member is attending golf)
       // Usually guests only play if the member plays golf
       if (r.attendingGolf && r.guestName != null && r.guestName!.isNotEmpty) {
         flattenedItems.add(RegistrationItem(
           registration: r,
           isGuest: true,
           registeredAt: r.registeredAt ?? DateTime.now(),
           hasPaid: r.hasPaid, 
           name: r.guestName!,
           needsBuggy: r.guestNeedsBuggy,
           originalRegistration: r,
         ));
       }
    }

    // Sort Logic
    // 1. Time (FCFS)
    // 2. Members before Guests (if time equal)
    flattenedItems.sort((a, b) {
      int timeCmp = a.registeredAt.compareTo(b.registeredAt);
      if (timeCmp != 0) return timeCmp;
      
      if (!a.isGuest && b.isGuest) return -1;
      if (a.isGuest && !b.isGuest) return 1;
      
      return 0;
    });
    
    return flattenedItems;
  }

  /// Returns a list of members who are ONLY attending dinner (not golf).
  static List<RegistrationItem> getDinnerOnlyItems(GolfEvent event) {
    final items = <RegistrationItem>[];
    
    for (var r in event.registrations) {
      // If NOT attending golf, but IS attending dinner 
      if (!r.attendingGolf && r.attendingDinner) {
         items.add(RegistrationItem(
           registration: r,
           isGuest: false,
           registeredAt: r.registeredAt ?? DateTime.now(),
           hasPaid: r.hasPaid,
           name: r.memberName,
           needsBuggy: false,
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
      if (!r.attendingGolf && !r.attendingDinner) {
         items.add(RegistrationItem(
           registration: r,
           isGuest: false,
           registeredAt: r.registeredAt ?? DateTime.now(),
           hasPaid: r.hasPaid,
           name: r.memberName,
           needsBuggy: false,
           originalRegistration: r,
         ));
      }
    }
    
    // Sort by name or time
    items.sort((a, b) => a.name.compareTo(b.name));
    
    return items;
  }

  /// Calculates the main registration status (Golf/Dinner)
  static RegistrationStatus calculateStatus({
    required bool isGuest,
    required DateTime? registeredAt,
    required bool hasPaid,
    required int indexInList,
    required int capacity,
    required DateTime? deadline,
  }) {
    if (isGuest) {
      final now = DateTime.now();
      if (deadline != null && now.isBefore(deadline)) {
        return RegistrationStatus.pendingGuest;
      }
    }

    if (capacity > 0 && indexInList >= capacity) {
      return RegistrationStatus.waitlist;
    }

    if (hasPaid) {
      return RegistrationStatus.confirmed;
    } else {
      return RegistrationStatus.reserved;
    }
  }

  /// Calculates buggy allocation status
  static RegistrationStatus calculateBuggyStatus({
    required bool needsBuggy,
    required bool hasPaid,
    required int buggyIndexInQueue,
    required int buggyCapacity,
  }) {
    if (!needsBuggy) return RegistrationStatus.none;
    
    if (buggyCapacity > 0 && buggyIndexInQueue >= buggyCapacity) {
      return RegistrationStatus.waitlist;
    }
    
    if (hasPaid) {
      return RegistrationStatus.confirmed;
    } else {
      return RegistrationStatus.reserved;
    }
  }
}

class RegistrationItem {
  final EventRegistration registration; // The parent registration object
  final EventRegistration originalRegistration; // Keep ref to original for updates
  final bool isGuest;
  final DateTime registeredAt;
  final bool hasPaid;
  final String name;
  final bool needsBuggy;

  RegistrationItem({
    required this.registration,
    required this.isGuest,
    required this.registeredAt,
    required this.hasPaid,
    required this.name,
    required this.needsBuggy,
    required this.originalRegistration,
  });
}
