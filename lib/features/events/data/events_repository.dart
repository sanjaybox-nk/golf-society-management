import '../../../../models/golf_event.dart';

abstract class EventsRepository {
  /// Stream of all events (real-time updates)
  Stream<List<GolfEvent>> watchEvents({String? seasonId, EventStatus? status});

  /// Single fetch of events
  Future<List<GolfEvent>> getEvents({String? seasonId, EventStatus? status});

  /// Get a single event by ID
  Future<GolfEvent?> getEvent(String id);

  /// Create a new event, returns the created ID
  Future<String> addEvent(GolfEvent event);

  /// Update existing event
  Future<void> updateEvent(GolfEvent event);

  /// Update event status only
  Future<void> updateStatus(String eventId, EventStatus status);

  /// Delete an event
  Future<void> deleteEvent(String eventId);
}
