import '../../../../models/golf_event.dart';

abstract class EventsRepository {
  /// Stream of all events (real-time updates)
  Stream<List<GolfEvent>> watchEvents();

  /// Single fetch of events
  Future<List<GolfEvent>> getEvents();

  /// Create a new event
  Future<void> addEvent(GolfEvent event);

  /// Update existing event
  Future<void> updateEvent(GolfEvent event);

  /// Delete an event
  Future<void> deleteEvent(String eventId);
}
