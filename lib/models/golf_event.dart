import 'package:freezed_annotation/freezed_annotation.dart';
import 'event_registration.dart';

part 'golf_event.freezed.dart';
part 'golf_event.g.dart';

@freezed
abstract class GolfEvent with _$GolfEvent {
  const GolfEvent._();
  
  const factory GolfEvent({
    required String id,
    required String title,
    required String location,
    required DateTime date,
    String? description,
    String? imageUrl,
    DateTime? regTime,
    DateTime? teeOffTime,
    @Default([]) List<EventRegistration> registrations,
    // Grouping/Tee Sheet data
    @Default({}) Map<String, dynamic> grouping,
    // Results/Leaderboard data
    @Default([]) List<Map<String, dynamic>> results,
    // Course configuration (Par, SI, holes)
    @Default({}) Map<String, dynamic> courseConfig,
    @Default([]) List<String> flashUpdates,
  }) = _GolfEvent;

  factory GolfEvent.fromJson(Map<String, dynamic> json) => _$GolfEventFromJson(json);
}
