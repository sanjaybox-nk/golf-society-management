import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'course_seeder.dart';
import 'event_seeder.dart';

/// Creates a single in-play singles event with 16 members across 4 groups.
/// Groups 0–2 are fully scored (18 holes, submitted).
/// Group 3 is mid-round (9 holes).
///
/// The event uses Stableford by default. Switch the competition template in
/// Admin → Event Editor to test Medal / Bogey scorecard display without
/// re-seeding scorecards.
class SinglesScorecardSeeder {
  final Ref ref;
  final Random random;
  static const String _seasonId = 'demo_season_2025_2026';

  SinglesScorecardSeeder(this.ref, [Random? r]) : random = r ?? Random(99);

  Future<String> seed() async {
    if (kDebugMode) debugPrint('--- SINGLES SHOWCASE: starting ---');

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final membersRepo = ref.read(membersRepositoryProvider);
    final allMembers = await membersRepo.getMembers();
    // Firestore returns members lexicographically (demo_m_0, demo_m_1, demo_m_10...),
    // and the first batch are expired members. Filter to eligible ones first.
    final members = _eligibleMembers(allMembers);
    if (members.length < 16) {
      throw Exception('Need at least 16 eligible members. Please seed members first.');
    }

    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();

    final date = DateTime.now();

    await EventSeeder(ref, random).createFullEvent(
      seasonId: _seasonId,
      course: course,
      title: 'Scorecard Showcase — Singles [${date.day}/${date.month}]',
      date: date,
      format: CompetitionFormat.stableford,
      isInvitational: false,
      isSeasonEvent: true,
      subtype: CompetitionSubtype.none,
      members: members.take(16).toList(),
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: templates,
    );

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final events = await eventsRepo.getEvents(seasonId: _seasonId);
    final event = events
        .where((e) => e.title.startsWith('Scorecard Showcase — Singles'))
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    // Remove the auto-created competition so the event is game-type-free.
    // Scorecards (raw hole scores) remain — attach any format in the event editor.
    await compRepo.deleteCompetition(event.id);

    if (kDebugMode) {
      debugPrint('--- SINGLES SHOWCASE: event ${event.id} ready — competition removed ---');
    }

    return event.id;
  }
}

List<Member> _eligibleMembers(List<Member> all) => all
    .where((m) =>
        m.id != 'demo_hero_sanjay' &&
        m.status != MemberStatus.expired &&
        m.status != MemberStatus.suspended &&
        m.status != MemberStatus.left &&
        m.status != MemberStatus.archived &&
        m.status != MemberStatus.social &&
        !m.role.isSocialMember)
    .toList();
