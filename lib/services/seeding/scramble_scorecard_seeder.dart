import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:collection/collection.dart';
import 'course_seeder.dart';
import 'event_seeder.dart';

/// Creates a single in-play Texas Scramble event with 12 members across 3 teams of 4.
///
/// Post-processes scorecards so all 4 members in each team share identical hole scores
/// (the chosen team drive) and carries realistic shotAttributions for the drive rule check.
///
/// Group 0 — 18 holes, submitted, drives evenly distributed (≥3 per player: compliant).
/// Group 1 — 9 holes, draft (mid-round), deliberate drive violation: player 0 took 6 drives,
///           players 1-3 took 1 each — triggers the amber drive-warning banner on submission.
/// Group 2 — 18 holes, submitted, drives evenly distributed (compliant).
///
/// minDrivesPerPlayer = 3 so the Group 1 violation is clearly visible.
class ScrambleScorecardSeeder {
  final Ref ref;
  final Random random;
  static const String _seasonId = 'demo_season_2025_2026';

  ScrambleScorecardSeeder(this.ref, [Random? r]) : random = r ?? Random(55);

  Future<String> seed() async {
    if (kDebugMode) debugPrint('--- SCRAMBLE SHOWCASE: starting ---');

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
    if (members.length < 12) {
      throw Exception('Need at least 12 eligible members. Please seed members first.');
    }

    final compRepo = ref.read(competitionsRepositoryProvider);

    // Build rules explicitly so minDrivesPerPlayer and teamSize are set correctly.
    final rules = const CompetitionRules(
      format: CompetitionFormat.scramble,
      subtype: CompetitionSubtype.texas,
      mode: CompetitionMode.teams,
      teamSize: 4,
      handicapAllowance: 1.0,
      useWHSScrambleAllowance: true,
      minDrivesPerPlayer: 3,
    );

    // Inject a throwaway template so EventSeeder picks up our custom rules.
    const tempTemplateId = '_scramble_showcase_tmp';
    await compRepo.addTemplate(Competition(
      id: tempTemplateId,
      name: '_ScrambleShowcaseTmp',
      type: CompetitionType.game,
      rules: rules,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    ));

    final templates = await compRepo.getTemplates();
    final date = DateTime.now();

    await EventSeeder(ref, random).createFullEvent(
      seasonId: _seasonId,
      course: course,
      title: 'Scorecard Showcase — Scramble [${date.day}/${date.month}]',
      date: date,
      format: CompetitionFormat.scramble,
      isInvitational: false,
      isSeasonEvent: true,
      subtype: CompetitionSubtype.texas,
      members: members.take(12).toList(),
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: templates,
    );

    // Remove throwaway template
    try { await compRepo.deleteTemplate(tempTemplateId); } catch (_) {}

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final events = await eventsRepo.getEvents(seasonId: _seasonId);
    final event = events
        .where((e) => e.title.startsWith('Scorecard Showcase — Scramble'))
        .reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    // Post-process: replace individual scorecards with team-coherent data.
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final scorecards = await scoreRepo.getScorecards(event.id);
    final groups = (event.grouping['groups'] as List? ?? [])
        .map((g) => TeeGroup.fromJson(g))
        .toList();

    final yellowTee = course.tees.firstWhereOrNull((t) => t.name == 'Yellow') ?? course.tees.first;

    for (int gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      final playerIds = group.players
          .map((p) => p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId)
          .toList();

      // Group 0 and 2: full 18 holes, submitted.
      // Group 1: 9 holes, draft (tests mid-round + drive violation warning).
      final int holesPlayed = gi == 1 ? 9 : 18;
      final bool isSubmitted = gi != 1;

      // Generate ONE set of team hole scores shared by all 4 players.
      final teamScores = _generateTeamScores(yellowTee.holePars, holesPlayed);

      // Generate shotAttributions for the holes played.
      // Group 1 is deliberately unbalanced: p0 gets 6 drives, p1/p2/p3 get 1 each.
      final Map<int, String?> attrs = gi == 1
          ? _buildViolatingAttributions(playerIds, holesPlayed)
          : _buildCompliantAttributions(playerIds, holesPlayed);

      for (final playerId in playerIds) {
        final card = scorecards.firstWhereOrNull((s) => s.entryId == playerId);
        if (card == null) continue;

        await scoreRepo.updateScorecard(card.copyWith(
          holeScores: teamScores,
          shotAttributions: attrs,
          status: isSubmitted ? ScorecardStatus.submitted : ScorecardStatus.draft,
          verifiedByMarker: isSubmitted,
          verifiedByPlayer: isSubmitted,
          submittedAt: isSubmitted
              ? date.copyWith(hour: 14, minute: 10 + gi * 15)
              : null,
        ));
      }
    }

    if (kDebugMode) {
      debugPrint('--- SCRAMBLE SHOWCASE: event ${event.id} ready ---');
      debugPrint('    Group 0: 18h submitted, drives compliant');
      debugPrint('    Group 1: 9h draft, p0 has 6 drives (violation for p1/p2/p3 < 3)');
      debugPrint('    Group 2: 18h submitted, drives compliant');
    }

    return event.id;
  }

  List<int?> _generateTeamScores(List<int> pars, int holesPlayed) {
    return List.generate(18, (h) {
      if (h >= holesPlayed) return null;
      final par = pars[h];
      // Scramble teams tend to score well — bias toward par/birdie.
      final roll = random.nextDouble();
      if (roll < 0.15) return par - 2; // Eagle
      if (roll < 0.45) return par - 1; // Birdie
      if (roll < 0.80) return par;      // Par
      if (roll < 0.95) return par + 1;  // Bogey
      return par + 2;                   // Double
    });
  }

  /// Group 1 violation: player 0 takes 6 of 9 drives; players 1-3 take 1 each.
  Map<int, String?> _buildViolatingAttributions(List<String> playerIds, int holesPlayed) {
    final attrs = <int, String?>{};
    // Player 0 drives holes 0-5 (6 drives), player 1 drives 6, player 2 drives 7, player 3 drives 8.
    for (int h = 0; h < holesPlayed; h++) {
      if (h < 6) {
        attrs[h] = playerIds.isNotEmpty ? playerIds[0] : null;
      } else {
        final pIdx = h - 5; // 1, 2, 3
        attrs[h] = pIdx < playerIds.length ? playerIds[pIdx] : playerIds.last;
      }
    }
    return attrs;
  }

  /// Compliant distribution: cycle through all 4 players, ensuring ≥3 drives each over 18 holes.
  Map<int, String?> _buildCompliantAttributions(List<String> playerIds, int holesPlayed) {
    final attrs = <int, String?>{};
    // Give each player 4 or 5 drives (18 / 4 ≈ 4.5).
    // Pattern: 0,1,2,3,0,1,2,3... with slight random variation but still ≥3 each.
    final counts = List.filled(playerIds.length, 0);
    for (int h = 0; h < holesPlayed; h++) {
      // Find player with fewest drives, with random tiebreak for variety.
      int chosen = 0;
      int minCount = counts[0];
      for (int p = 1; p < playerIds.length; p++) {
        if (counts[p] < minCount || (counts[p] == minCount && random.nextBool())) {
          minCount = counts[p];
          chosen = p;
        }
      }
      attrs[h] = playerIds[chosen];
      counts[chosen]++;
    }
    return attrs;
  }
}
