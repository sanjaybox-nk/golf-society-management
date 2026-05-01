import 'package:golf_society/domain/models/golf_event.dart';

class DateUtils {
  /// Truncates the time component of a [DateTime] to midnight.
  static DateTime truncateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Checks if an event is today or in the future, or currently in play.
  static bool isUpcoming(GolfEvent event) {
    final now = DateTime.now();
    final today = truncateTime(now);
    final eventDate = truncateTime(event.date);
    
    return eventDate.isAtSameMomentAs(today) || 
           eventDate.isAfter(today) || 
           event.status == EventStatus.inPlay;
  }

  /// Checks if an event is today or in the past (ignoring time).
  static bool isSameDayOrPastEvent(GolfEvent event) {
    final now = DateTime.now();
    final today = truncateTime(now);
    final eventDate = truncateTime(event.date);
    
    return eventDate.isAtSameMomentAs(today) || 
           eventDate.isBefore(today);
  }

  /// Checks if an event date is strictly before today (ignoring time).
  static bool isPastEvent(GolfEvent event) {
    final now = DateTime.now();
    final today = truncateTime(now);
    final eventDate = truncateTime(event.date);
    
    return eventDate.isBefore(today);
  }

  /// Checks if a date time is strictly before now.
  static bool isPastDateTime(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  /// Helper to check if two dates are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Filters a list of events to only include upcoming ones.
  static List<GolfEvent> filterUpcoming(List<GolfEvent> events) {
    final upcoming = events.where((e) => isUpcoming(e)).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  /// Filters a list of events to only include past ones.
  static List<GolfEvent> filterPast(List<GolfEvent> events) {
    final past = events.where((e) => isPastEvent(e)).toList();
    past.sort((a, b) => b.date.compareTo(a.date));
    return past;
  }
}
