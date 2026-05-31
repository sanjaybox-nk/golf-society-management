import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'course_seeder.dart';

/// Creates a published event with confirmed registrations and no competition attached.
/// Admin manually adds the game type to test each format's full flow:
/// grouping → scoring → verify → publish.
class RegistrationScaffoldSeeder {
  final Ref ref;
  final Random random;
  static const String _seasonId = 'demo_season_2025_2026';

  RegistrationScaffoldSeeder(this.ref, [Random? r]) : random = r ?? Random(42);

  Future<String> seed({int playerCount = 16}) async {
    if (kDebugMode) debugPrint('--- REGISTRATION SCAFFOLD: seeding $playerCount players ---');

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) {
      courses = await CourseSeeder(ref, random).seed();
    }
    final course = courses.first;
    final tee = course.tees.first;

    final membersRepo = ref.read(membersRepositoryProvider);
    final members = await membersRepo.getMembers();
    if (members.length < playerCount) {
      throw Exception('Need $playerCount members. Please seed members first.');
    }

    // Sort by handicap — gives a realistic field for any draw type
    final players = (List<Member>.from(members)
          ..sort((a, b) => a.handicap.compareTo(b.handicap)))
        .take(playerCount)
        .toList();

    final eventDate = DateTime.now().add(const Duration(days: 14));
    final eventId = 'uat_scaffold_${DateTime.now().millisecondsSinceEpoch}';

    final registrations = players
        .map((m) => EventRegistration(
              memberId: m.id,
              memberName: m.displayName,
              attendingGolf: true,
              isConfirmed: true,
              handicap: m.handicap,
              registeredAt: DateTime.now().subtract(const Duration(days: 5)),
              cost: 0,
            ))
        .toList();

    final event = GolfEvent(
      id: eventId,
      seasonId: _seasonId,
      title: 'UAT Scaffold — $playerCount Players [${DateTime.now().day}/${DateTime.now().month}]',
      description:
          'Registration scaffold for UAT. $playerCount members confirmed, registration closed. '
          'Go to Event Editor → Competition Rules → Add game format to attach a game type, '
          'then test grouping, scoring, and publishing.',
      date: eventDate,
      status: EventStatus.published,
      showRegistrationButton: false, // Registration manually closed
      regTime: eventDate.subtract(const Duration(hours: 2)),
      teeOffTime: DateTime(eventDate.year, eventDate.month, eventDate.day, 9, 0),
      maxParticipants: playerCount + 4,
      registrations: registrations,
      eventType: EventType.golf,
      courseId: course.id,
      courseName: course.name,
      courseConfig: CourseConfig(
        name: course.name,
        slope: tee.slope,
        rating: tee.rating,
        par: tee.holePars.reduce((a, b) => a + b),
        selectedTeeName: tee.name,
        tees: course.tees
            .map((t) => TeeConfig(
                  name: t.name,
                  color: t.color,
                  rating: t.rating,
                  slope: t.slope,
                  holePars: t.holePars,
                  holeSIs: t.holeSIs,
                  yardages: t.yardages,
                ))
            .toList(),
        holes: List.generate(
          18,
          (i) => CourseHole(
            hole: i + 1,
            par: tee.holePars[i],
            si: tee.holeSIs[i],
            yardage: tee.yardages[i],
          ),
        ),
      ),
    );

    final eventsRepo = ref.read(eventsRepositoryProvider);
    await eventsRepo.addEvent(event);

    if (kDebugMode) {
      debugPrint('Scaffold created: $eventId — $playerCount registrations, no competition attached.');
    }
    return eventId;
  }
}
