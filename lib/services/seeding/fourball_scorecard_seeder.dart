import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'course_seeder.dart';
import 'event_seeder.dart';

/// Creates a single in-play Fourball (Betterball) event with clean groups of 4.
///
/// Passes 16 eligible members to createFullEvent so withdrawals (5% chance each)
/// don't reduce the confirmed count below a multiple of 4. After creation, the
/// grouping is post-processed to enforce clean groups of 4: any odd-sized groups
/// are discarded so every group has exactly 2 pairs.
///
/// Competition is NOT deleted — Fourball requires it for pair resolution,
/// bestball scoring, and the Team View. Players [0,1] and [2,3] in each group
/// form the two opposing pairs.
class FourballScorecardSeeder {
  final Ref ref;
  final Random random;
  static const String _seasonId = 'demo_season_2025_2026';

  FourballScorecardSeeder(this.ref, [Random? r]) : random = r ?? Random(77);

  Future<String> seed() async {
    if (kDebugMode) debugPrint('--- FOURBALL SHOWCASE: starting ---');

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final membersRepo = ref.read(membersRepositoryProvider);
    final allMembers = await membersRepo.getMembers();
    // Firestore returns members lexicographically; the first batch are expired.
    // Filter to eligible members so we get real golf attendees.
    final members = allMembers
        .where((m) =>
            m.id != 'demo_hero_sanjay' &&
            m.status != MemberStatus.expired &&
            m.status != MemberStatus.suspended &&
            m.status != MemberStatus.left &&
            m.status != MemberStatus.archived &&
            m.status != MemberStatus.social &&
            !m.role.isSocialMember)
        .toList();
    if (members.length < 8) {
      throw Exception('Need at least 8 eligible members. Please seed members first.');
    }

    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();

    final date = DateTime.now();

    // Pass 16 members so that even with a few withdrawals we still get ≥8 confirmed.
    await EventSeeder(ref, random).createFullEvent(
      seasonId: _seasonId,
      course: course,
      title: 'Scorecard Showcase — Fourball [${date.day}/${date.month}]',
      date: date,
      format: CompetitionFormat.stableford,
      isInvitational: false,
      isSeasonEvent: true,
      subtype: CompetitionSubtype.fourball,
      members: members.take(16).toList(),
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: templates,
    );

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final events = await eventsRepo.getEvents(seasonId: _seasonId);
    var event = events
        .where((e) => e.title.startsWith('Scorecard Showcase — Fourball'))
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    // Post-process: enforce clean groups of 4. Withdrawals can create odd-sized groups
    // which break Fourball pair logic (players [0,1] and [2,3] must both be present).
    final rawGroups = (event.grouping['groups'] as List? ?? [])
        .map((g) => TeeGroup.fromJson(g))
        .toList();
    final allParticipants = rawGroups.expand((g) => g.players).toList();
    final fourballCount = (allParticipants.length ~/ 4) * 4;

    if (fourballCount < 4) {
      throw Exception('Fourball showcase: not enough confirmed players after seeding (got ${allParticipants.length})');
    }

    final needsReshape = rawGroups.any((g) => g.players.length % 4 != 0) ||
        rawGroups.any((g) => g.players.length < 4);

    if (needsReshape) {
      final participants = allParticipants.take(fourballCount).toList();
      final t0 = rawGroups.firstOrNull?.teeTime ?? date;
      final cleanGroups = List.generate(
        fourballCount ~/ 4,
        (i) => TeeGroup(
          index: i,
          teeTime: t0.add(Duration(minutes: i * 10)),
          players: participants.sublist(i * 4, (i + 1) * 4),
        ),
      );

      // Rebuild markers cross-pair within each clean group of 4.
      // Players [0,1] = pair A, [2,3] = pair B. Offset by 2 guarantees
      // every marker is from the opposing pair (0↔2, 1↔3).
      final Map<String, String> newMarkersMap = {};
      for (final g in cleanGroups) {
        for (int j = 0; j < g.players.length; j++) {
          final p = g.players[j];
          final marker = g.players[(j + 2) % g.players.length];
          final pId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
          final markerId = marker.isGuest ? '${marker.registrationMemberId}_guest' : marker.registrationMemberId;
          newMarkersMap[pId] = markerId;
        }
      }

      final groupingData = Map<String, dynamic>.from(event.grouping);
      groupingData['groups'] = cleanGroups.map((g) => g.toJson()).toList();
      groupingData['markers'] = newMarkersMap;
      await eventsRepo.updateEvent(event.copyWith(grouping: groupingData));
      event = event.copyWith(grouping: groupingData);

      // Patch each scorecard's markerId to match the rebuilt round-robin.
      final scoreRepo = ref.read(scorecardRepositoryProvider);
      final scorecards = await scoreRepo.getScorecards(event.id);
      for (final card in scorecards) {
        final newMarkerId = newMarkersMap[card.entryId];
        if (newMarkerId != null && newMarkerId != card.markerId) {
          await scoreRepo.updateScorecard(card.copyWith(markerId: newMarkerId));
        }
      }

      if (kDebugMode) {
        debugPrint('--- FOURBALL SHOWCASE: reshaped ${allParticipants.length} participants → ${cleanGroups.length} clean group(s) of 4, markers reassigned ---');
      }
    }

    if (kDebugMode) {
      final groupCount = (event.grouping['groups'] as List? ?? []).length;
      debugPrint('--- FOURBALL SHOWCASE: event ${event.id} ready — $groupCount group(s) of 4, competition preserved ---');
    }

    return event.id;
  }
}
