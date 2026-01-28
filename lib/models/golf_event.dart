import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_registration.dart';

import '../core/utils/json_converters.dart';

part 'golf_event.freezed.dart';
part 'golf_event.g.dart';

enum EventStatus { draft, published }

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
    double? dinnerCost,
    String? dinnerLocation,
    @Default([]) List<EventNote> notes,
    @Default([]) List<String> galleryUrls,
    @Default(true) bool showRegistrationButton,
    // Grouping/Tee Sheet data
    @Default({}) Map<String, dynamic> grouping,
    // Results/Leaderboard data
    @Default([]) List<Map<String, dynamic>> results,
    // Course configuration (Par, SI, holes)
    @Default({}) Map<String, dynamic> courseConfig,
    @Default([]) List<String> flashUpdates,
    @Default(EventStatus.draft) EventStatus status,
  }) = _GolfEvent;

  factory GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);
  @override
  Map<String, dynamic> toJson();
}
