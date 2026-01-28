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
    @Default(false) bool attendingDinner,
    @Default(false) bool hasPaid,
    @Default(0.0) double cost,
    // New fields for registration form
    @Default(false) bool needsBuggy,
    String? dietaryRequirements,
    String? specialNeeds,
    // Guest details (for registrations that include a guest)
    String? guestName,
    String? guestHandicap,
    @Default(false) bool guestAttendingDinner,
    @Default(false) bool guestNeedsBuggy,
    @OptionalTimestampConverter() DateTime? registeredAt,
  }) = _EventRegistration;

  factory EventRegistration.fromJson(Map<String, dynamic> json) => _$EventRegistrationFromJson(json);
  @override
  Map<String, dynamic> toJson();
}
