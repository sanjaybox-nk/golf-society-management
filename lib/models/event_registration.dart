import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_converters.dart';

part 'event_registration.freezed.dart';
part 'event_registration.g.dart';

@freezed
abstract class EventRegistration with _$EventRegistration {
  const EventRegistration._();
  
  const factory EventRegistration({
    required String memberId,
    required String memberName,
    @Default(false) bool isGuest,
    @Default(true) bool attendingGolf,
    @Default(false) bool attendingBreakfast,
    @Default(false) bool attendingLunch,
    @Default(false) bool attendingDinner,
    @Default(false) bool hasPaid,
    @Default(0.0) double cost,
    // Handicaps
    double? handicap,
    int? playingHandicap,
    // New fields for registration form
    @Default(false) bool needsBuggy,
    String? dietaryRequirements,
    String? specialNeeds,
    // Guest details (for registrations that include a guest)
    String? guestName,
    String? guestHandicap,
    @Default(false) bool guestAttendingBreakfast,
    @Default(false) bool guestAttendingLunch,
    @Default(false) bool guestAttendingDinner,
    @Default(false) bool guestNeedsBuggy,
    @Default(false) bool isCaptain,
    @OptionalTimestampConverter() DateTime? registeredAt,
    @Default(false) bool isConfirmed,
    @Default(false) bool guestIsConfirmed,
    String? statusOverride, // 'confirmed', 'reserved', 'waitlist'
    String? buggyStatusOverride, // 'confirmed', 'reserved', 'waitlist'
    String? guestBuggyStatusOverride, // 'confirmed', 'reserved', 'waitlist'
    @Default([]) List<RegistrationHistoryItem>? history,
  }) = _EventRegistration;

  factory EventRegistration.fromJson(Map<String, dynamic> json) => _$EventRegistrationFromJson(json);
  @override
  Map<String, dynamic> toJson();

  // Helper getters
  String get displayName => isGuest && guestName != null ? guestName! : memberName;
}

@freezed
abstract class RegistrationHistoryItem with _$RegistrationHistoryItem {
  const factory RegistrationHistoryItem({
    required DateTime timestamp,
    required String action, // e.g., 'Status Update'
    required String description, // e.g., 'Changed from Reserved to Confirmed'
    String? actor, // e.g., 'Admin'
  }) = _RegistrationHistoryItem;

  factory RegistrationHistoryItem.fromJson(Map<String, dynamic> json) => _$RegistrationHistoryItemFromJson(json);
}
