import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _EventRegistration;

  factory EventRegistration.fromJson(Map<String, dynamic> json) => _$EventRegistrationFromJson(json);
}
