import 'package:freezed_annotation/freezed_annotation.dart';
import 'event_registration.dart';

import 'package:golf_society/utils/json_converters.dart';
import 'course_config.dart';
part 'golf_event.freezed.dart';
part 'golf_event.g.dart';

enum EventStatus { draft, published, inPlay, completed, cancelled, suspended }
enum EventType { golf, social }

@freezed
abstract class EventNote with _$EventNote {
  const factory EventNote({
    String? title,
    required String content,
    String? imageUrl,
  }) = _EventNote;

  factory EventNote.fromJson(Map<String, dynamic> json) => _$EventNoteFromJson(json);
}

@freezed
abstract class EventExpense with _$EventExpense {
  const factory EventExpense({
    required String id,
    required String label,
    required double amount,
    @Default('Misc') String category, // Venue, Food, Prize, Misc
    @OptionalTimestampConverter() DateTime? date,
  }) = _EventExpense;

  factory EventExpense.fromJson(Map<String, dynamic> json) => _$EventExpenseFromJson(json);
}

@freezed
abstract class EventExtraCost with _$EventExtraCost {
  const factory EventExtraCost({
    required String id,
    required String label,
    required double amount,
  }) = _EventExtraCost;

  factory EventExtraCost.fromJson(Map<String, dynamic> json) => _$EventExtraCostFromJson(json);
}

@freezed
abstract class EventAward with _$EventAward {
  const factory EventAward({
    required String id,
    required String label,
    @Default('Cash') String type, // Cup, Cash, Voucher
    @Default(0.0) double value,
    String? winnerId,
    String? winnerName,
  }) = _EventAward;

  factory EventAward.fromJson(Map<String, dynamic> json) => _$EventAwardFromJson(json);
}

enum FeedItemType {
  flash,
  newsletter,
  gallery,
  
  // System Blocks
  headline,
  registration,
  podium,
  gallerySnippet,
  poll,
}

@freezed
abstract class EventFeedItem with _$EventFeedItem {
  const factory EventFeedItem({
    required String id,
    required FeedItemType type,
    String? title,
    @Default('') String content,
    String? imageUrl,
    @Default(false) bool isPinned,
    @Default(false) bool isPublished,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    @Default({}) Map<String, dynamic> pollData,
  }) = _EventFeedItem;

  factory EventFeedItem.fromJson(Map<String, dynamic> json) => _$EventFeedItemFromJson(json);
}

@freezed
abstract class GolfEvent with _$GolfEvent {
  const GolfEvent._();

  const factory GolfEvent({
    required String id,
    required String title,
    required String seasonId,
    @TimestampConverter() required DateTime date,
    String? description,
    String? imageUrl,
    @OptionalTimestampConverter() DateTime? regTime,
    @OptionalTimestampConverter() DateTime? teeOffTime,
    @OptionalTimestampConverter() DateTime? registrationDeadline,
    @Default([]) List<EventRegistration> registrations,
    // New detailed fields
    String? courseName,
    String? courseDetails,
    String? dressCode,
    int? availableBuggies,
    int? maxParticipants,
    @Default([]) List<String> facilities,
    double? memberCost,
    double? guestCost,
    double? breakfastCost,
    double? lunchCost,
    double? dinnerCost,
    double? buggyCost,
    @Default(false) bool hasBreakfast,
    @Default(false) bool hasLunch,
    @Default(true) bool hasDinner,
    String? dinnerLocation,
    String? dinnerAddress,
    double? societyGreenFee,
    double? societyBreakfastCost,
    double? societyLunchCost,
    double? societyDinnerCost,
    @Default([]) List<EventNote> notes, // DEPRECATED: Moving to feedItems
    @Default([]) List<String> galleryUrls,
    @Default(true) bool showRegistrationButton,
    @Default(10) int teeOffInterval,
    @Default(false) bool isGroupingPublished,
    // Multi-day support
    @Default(false) bool isMultiDay,
    @OptionalTimestampConverter() DateTime? endDate,
    // Grouping/Tee Sheet data
    @Default({}) Map<String, dynamic> grouping,
    // Results/Leaderboard data
    @Default([]) List<Map<String, dynamic>> results,
    // Course configuration (Par, SI, holes)
    String? courseId,
    @Default(CourseConfig()) CourseConfig courseConfig,
    String? selectedTeeName,
    String? selectedFemaleTeeName, // [NEW] Explicit mapping for female players
    @Default([]) List<String> flashUpdates,
    @Default([]) List<EventFeedItem> feedItems,
    @Default(false) bool isScoringLocked,
    @Default(false) bool isStatsReleased,
    @Default({}) Map<String, dynamic> finalizedStats,
    String? secondaryTemplateId, // Reference for Match Play overlay
    @Default(false) bool isSeasonEvent, // [NEW] Distinguishes league events from ad-hoc games
    @Default(false) bool isInvitational,
    @Default(EventStatus.draft) EventStatus status,
    @Default([]) List<EventExpense> expenses,
    @Default(true) bool showAwards,
    @Default([]) List<EventAward> awards,
    @Default(EventType.golf) EventType eventType,
    @Default({}) Map<String, double> manualCuts, // [NEW] Per-event player handicap adjustments
    double? eventCost,
    @Default([]) List<EventExtraCost> extraCosts,
    @Default(0.0) double charityPot,
  }) = _GolfEvent;

  bool get isClosed => status == EventStatus.completed || status == EventStatus.cancelled;

  bool get occursToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventStart = DateTime(date.year, date.month, date.day);

    if (isMultiDay && endDate != null) {
      final eventEnd = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return !today.isBefore(eventStart) && !today.isAfter(eventEnd);
    }

    return today.isAtSameMomentAs(eventStart);
  }

  bool get isRegistrationClosed {
    if (registrationDeadline == null) return false;
    return DateTime.now().isAfter(registrationDeadline!);
  }

  bool get isRegistrationOpen {
    // 1. Explicit Toggle must be ON
    if (!showRegistrationButton) return false;
    
    // 2. Event must not be closed (completed/cancelled)
    if (isClosed) return false;
    
    // 3. Deadline must not have passed
    if (isRegistrationClosed) return false;
    
    // 4. Status must be published or inPlay (Live)
    return status == EventStatus.published || status == EventStatus.inPlay;
  }

  /// Synthesizes missing system blocks so older events automatically gain them natively
  /// for dynamic reordering and positioning.
  List<EventFeedItem> get effectiveFeedItems {
    final List<EventFeedItem> result = List.from(feedItems);
    
    void ensureSystemItem(FeedItemType type, int defaultSortOrder) {
      if (!result.any((item) => item.type == type)) {
        result.add(EventFeedItem(
          id: 'system_${type.name}',
          type: type,
          isPublished: true, // System items always published; hidden by internal logic if not applicable
          sortOrder: defaultSortOrder,
          createdAt: date,
        ));
      }
    }

    // Default top-down order for initial synthesis:
    ensureSystemItem(FeedItemType.registration, -110);
    ensureSystemItem(FeedItemType.headline, -100);
    ensureSystemItem(FeedItemType.podium, -90);
    ensureSystemItem(FeedItemType.gallerySnippet, -80);

    return result;
  }

  /// Returns the display status, ensuring future events are never shown as completed
  EventStatus get displayStatus {
    final now = DateTime.now();
    
    // If event is in the future, it cannot be completed
    if (date.isAfter(now) && status == EventStatus.completed) {
      return EventStatus.published;
    }
    
    // Explicit statuses take precedence
    if (status == EventStatus.suspended) return EventStatus.suspended;
    if (status == EventStatus.cancelled) return EventStatus.cancelled;
    
    // Otherwise return the stored status
    return status;
  }

  int get playingCount => registrations.where((r) => r.attendingGolf).length;
  int get guestCount => registrations.where((r) => r.guestName != null).length;
  int get waitlistCount => registrations.where((r) => r.statusOverride == 'waitlist').length;
  int? get capacity => maxParticipants;

  factory GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);
  @override
  Map<String, dynamic> toJson();
}
