import 'package:freezed_annotation/freezed_annotation.dart';
import 'event_registration.dart';

import '../core/utils/json_converters.dart';

part 'golf_event.freezed.dart';
part 'golf_event.g.dart';

enum EventStatus { draft, published, inPlay, completed, cancelled, suspended }

@freezed
abstract class EventNote with _$EventNote {
  const factory EventNote({
    String? title,
    required String content,
    String? imageUrl,
  }) = _EventNote;

  factory EventNote.fromJson(Map<String, dynamic> json) => _$EventNoteFromJson(json);
  @override
  Map<String, dynamic> toJson();
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
    @Default([]) List<EventNote> notes,
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
    @Default({}) Map<String, dynamic> courseConfig,
    String? selectedTeeName,
    @Default([]) List<String> flashUpdates,
    @Default(false) bool isScoringLocked,
    @Default(false) bool isStatsReleased,
    @Default({}) Map<String, dynamic> finalizedStats,
    String? secondaryTemplateId, // Reference for Match Play overlay
    @Default(false) bool isInvitational,
    @Default(EventStatus.draft) EventStatus status,
  }) = _GolfEvent;

  bool get isRegistrationClosed {
    if (registrationDeadline == null) return false;
    return DateTime.now().isAfter(registrationDeadline!);
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
