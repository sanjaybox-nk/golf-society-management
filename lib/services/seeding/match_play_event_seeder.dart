import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:golf_society/domain/scoring/scorecard_constants.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'course_seeder.dart';

enum MatchPlayEventStage {
  registration,
  draw,
  scores,
  stablefordOverlay,
  medalOverlay,
}

class MatchPlayEventSeeder {
  final Ref ref;
  final Random random;
  static const String _seasonId = 'demo_season_2025_2026';
  static const int _playerCount = 16;

  MatchPlayEventSeeder(this.ref, [Random? r]) : random = r ?? Random(42);

  Future<void> seed(MatchPlayEventStage stage) async {
    switch (stage) {
      case MatchPlayEventStage.registration:
        await _seedRegistration();
      case MatchPlayEventStage.draw:
        await _seedDraw();
      case MatchPlayEventStage.scores:
        await _seedScores();
      case MatchPlayEventStage.stablefordOverlay:
        await _seedOverlayEvent(CompetitionFormat.stableford);
      case MatchPlayEventStage.medalOverlay:
        await _seedOverlayEvent(CompetitionFormat.stroke);
    }
  }

  Future<String> _seedRegistration() async {
    if (kDebugMode) debugPrint('--- MATCHPLAY EVENT UAT: STAGE 1 (REGISTRATION) ---');

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) {
      courses = await CourseSeeder(ref, random).seed();
    }
    final course = courses.first;
    final tee = course.tees.first;

    final membersRepo = ref.read(membersRepositoryProvider);
    final members = await membersRepo.getMembers();
    if (members.length < _playerCount) {
      throw Exception('Need $_playerCount members. Please seed members first.');
    }

    final players = (List<Member>.from(members)
          ..sort((a, b) => a.handicap.compareTo(b.handicap)))
        .take(_playerCount)
        .toList();

    final eventDate = DateTime.now().add(const Duration(days: 21));
    final eventId = 'mp_event_uat_${DateTime.now().millisecondsSinceEpoch}';

    final registrations = players
        .map((m) => EventRegistration(
              memberId: m.id,
              memberName: m.displayName,
              attendingGolf: true,
              isConfirmed: true,
              handicap: m.handicap,
              registeredAt: DateTime.now().subtract(const Duration(days: 3)),
              cost: 0,
            ))
        .toList();

    final event = GolfEvent(
      id: eventId,
      seasonId: _seasonId,
      title: 'Singles Match Play — Knockout [UAT]',
      description:
          'Stage 1 — 16 members registered. Admin: go to Grouping and create 2-ball '
          'pairings to generate the R16 draw.',
      date: eventDate,
      status: EventStatus.published,
      regTime: eventDate.subtract(const Duration(hours: 2)),
      teeOffTime: DateTime(eventDate.year, eventDate.month, eventDate.day, 9, 0),
      maxParticipants: 32,
      registrations: registrations,
      eventType: EventType.golf,
      courseId: course.id,
      courseName: course.name,
      secondaryTemplateId: 'matchplay',
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

    final comp = Competition(
      id: eventId,
      name: 'Singles Match Play — Knockout',
      type: CompetitionType.event,
      startDate: eventDate,
      endDate: eventDate,
      rules: const CompetitionRules(
        format: CompetitionFormat.matchPlay,
        mode: CompetitionMode.singles,
        handicapMode: HandicapMode.whs,
        handicapAllowance: 1.0,
        holeByHoleRequired: true,
      ),
    );

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);
    await eventsRepo.addEvent(event);
    await compRepo.addCompetition(comp);

    if (kDebugMode) debugPrint('Created matchplay event $eventId with $_playerCount registrations.');
    return eventId;
  }

  Future<String> _seedDraw({
    CompetitionFormat primaryFormat = CompetitionFormat.matchPlay,
    bool hasOverlay = false,
    String? titleOverride,
  }) async {
    final eventId = await _seedRegistration();
    if (kDebugMode) debugPrint('--- MATCHPLAY EVENT UAT: DRAW ---');

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);
    final event = await eventsRepo.getEvent(eventId);
    if (event == null) return eventId;

    if (primaryFormat != CompetitionFormat.matchPlay || hasOverlay) {
      final formatName = primaryFormat == CompetitionFormat.stableford ? 'Stableford' : 'Medal';
      final overlayRules = CompetitionRules(
        format: primaryFormat,
        mode: CompetitionMode.singles,
        handicapMode: HandicapMode.whs,
        handicapAllowance: 1.0,
        holeByHoleRequired: true,
        hasMatchPlayOverlay: true,
      );
      await compRepo.addCompetition(Competition(
        id: eventId,
        name: titleOverride ?? 'Match Play + $formatName Overlay',
        type: CompetitionType.event,
        startDate: event.date,
        endDate: event.date,
        rules: overlayRules,
      ));
      // Secondary slot — required by event_details_screen and event_user_details_tab
      // which load competitionDetailProvider('${event.id}_secondary') for the overlay card.
      await compRepo.addCompetition(Competition(
        id: '${eventId}_secondary',
        name: 'Match Play Overlay',
        type: CompetitionType.event,
        startDate: event.date,
        endDate: event.date,
        rules: overlayRules,
      ));
    }

    final teeName = event.courseConfig.tees.isNotEmpty
        ? event.courseConfig.tees.first.name
        : 'Yellow';
    final teeOffBase = event.teeOffTime ?? event.date;
    final regs = List.from(event.registrations)..shuffle(random);

    final groups = <TeeGroup>[];
    final matches = <MatchDefinition>[];

    for (int i = 0; i < regs.length - 1; i += 2) {
      final regA = regs[i];
      final regB = regs[i + 1];
      final groupIndex = i ~/ 2;
      final matchId = const Uuid().v4();
      final teeTime = teeOffBase.add(Duration(minutes: groupIndex * 10));

      final double phcA = regA.handicap.clamp(0.0, 28.0);
      final double phcB = regB.handicap.clamp(0.0, 28.0);
      final int diff = (phcA - phcB).abs().round();
      final String higherHcId = phcA >= phcB ? regA.memberId : regB.memberId;

      groups.add(TeeGroup(
        index: groupIndex,
        teeTime: teeTime,
        players: [
          TeeGroupParticipant(
            registrationMemberId: regA.memberId,
            name: regA.memberName,
            isGuest: false,
            handicapIndex: regA.handicap,
            playingHandicap: phcA,
            needsBuggy: false,
            teeName: teeName,
          ),
          TeeGroupParticipant(
            registrationMemberId: regB.memberId,
            name: regB.memberName,
            isGuest: false,
            handicapIndex: regB.handicap,
            playingHandicap: phcB,
            needsBuggy: false,
            teeName: teeName,
          ),
        ],
      ));

      matches.add(MatchDefinition(
        id: matchId,
        type: MatchType.singles,
        team1Ids: [regA.memberId],
        team2Ids: [regB.memberId],
        team1Name: regA.memberName,
        team2Name: regB.memberName,
        strokesReceived: diff > 0 ? {higherHcId: diff} : {},
        strokesGiven: diff,
        groupId: groupIndex.toString(),
        round: MatchRoundType.roundOf16,
        bracketOrder: groupIndex,
      ));
    }

    final baseTitle = titleOverride ?? 'Singles Match Play — Knockout [UAT — Draw]';
    await eventsRepo.updateEvent(event.copyWith(
      title: baseTitle,
      description: 'R16 draw published. ${matches.length} matches paired. Score hole-by-hole.',
      isGroupingPublished: true,
      grouping: {
        'groups': groups.map((g) => g.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
        'locked': false,
        'matches': matches.map((m) => m.toJson()).toList(),
      },
    ));

    if (kDebugMode) debugPrint('Draw seeded: ${matches.length} R16 matches across ${groups.length} groups.');
    return eventId;
  }

  Future<void> _seedScores() async {
    final eventId = await _seedDraw(titleOverride: 'Singles Match Play — Knockout [UAT — Scores]');
    if (kDebugMode) debugPrint('--- MATCHPLAY EVENT UAT: STAGE 3 (SCORES) ---');

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final membersRepo = ref.read(membersRepositoryProvider);
    final scoreRepo = ref.read(scorecardRepositoryProvider);

    final event = await eventsRepo.getEvent(eventId);
    if (event == null) return;

    final today = DateTime.now();
    await eventsRepo.updateEvent(event.copyWith(
      status: EventStatus.inPlay,
      date: today,
      teeOffTime: DateTime(today.year, today.month, today.day, 9, 0),
    ));

    final members = await membersRepo.getMembers();
    final membersMap = {for (var m in members) m.id: m};
    final courseConfig = event.courseConfig;
    final rules = const CompetitionRules(
      format: CompetitionFormat.matchPlay,
      handicapAllowance: 1.0,
    );

    final matchesRaw = event.grouping['matches'] as List? ?? [];
    final matches = matchesRaw
        .map((m) => MatchDefinition.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();

    for (final match in matches) {
      if (match.team1Ids.isEmpty || match.team2Ids.isEmpty) continue;
      final p1Id = match.team1Ids.first;
      final p2Id = match.team2Ids.first;
      final m1 = membersMap[p1Id];
      final m2 = membersMap[p2Id];
      if (m1 == null || m2 == null) continue;

      // Group 0 = live match (through hole 9). All others = complete round.
      final isLive = match.bracketOrder == 0;

      for (final (playerId, member, opponentId) in [(p1Id, m1, p2Id), (p2Id, m2, p1Id)]) {
        final phc = HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: member.handicap,
          rules: rules,
          courseConfig: courseConfig,
        );
        final allScores = _generateScores(courseConfig, member.handicap);
        final holeScores = isLive
            ? [...allScores.take(9), ...List<int?>.filled(9, null)]
            : List<int?>.from(allScores);

        await scoreRepo.addScorecard(Scorecard(
          id: 'seed_mp_${event.id}_$playerId',
          competitionId: event.id,
          roundId: ScorecardConstants.defaultRoundId,
          entryId: playerId,
          markerId: opponentId,
          submittedByUserId: ScorecardConstants.systemUserId,
          status: isLive ? ScorecardStatus.draft : ScorecardStatus.submitted,
          holeScores: holeScores,
          playerVerifierScores: holeScores,
          conflictedHoles: [],
          handicapIndex: member.handicap,
          playingHandicap: phc,
          assignedTeeName: courseConfig.selectedTeeName,
          verifiedByMarker: !isLive,
          verifiedByPlayer: false,
          markerVerifiedAt: isLive ? null : DateTime.now().subtract(const Duration(minutes: 30)),
          submittedAt: isLive ? null : DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        if (kDebugMode) {
          final label = isLive ? 'LIVE (9 holes)' : 'complete';
          debugPrint('  [$label] $playerId ← marked by $opponentId (HC ${member.handicap}, PHC $phc)');
        }
      }
    }

    if (kDebugMode) debugPrint('Match play scores seeded: ${matches.length} matches (1 live, ${matches.length - 1} complete).');
  }

  Future<void> _seedOverlayEvent(CompetitionFormat primaryFormat) async {
    final formatLabel = primaryFormat == CompetitionFormat.stableford ? 'Stableford' : 'Medal';
    final title = 'Match Play + $formatLabel Overlay [UAT — Scores]';

    if (kDebugMode) debugPrint('--- MATCHPLAY UAT: $formatLabel OVERLAY ---');

    final eventId = await _seedDraw(
      primaryFormat: primaryFormat,
      hasOverlay: true,
      titleOverride: title,
    );

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final membersRepo = ref.read(membersRepositoryProvider);
    final scoreRepo = ref.read(scorecardRepositoryProvider);

    final event = await eventsRepo.getEvent(eventId);
    if (event == null) return;

    final today = DateTime.now();
    await eventsRepo.updateEvent(event.copyWith(
      status: EventStatus.inPlay,
      date: today,
      teeOffTime: DateTime(today.year, today.month, today.day, 9, 0),
    ));

    final members = await membersRepo.getMembers();
    final membersMap = {for (var m in members) m.id: m};
    final courseConfig = event.courseConfig;

    final rules = CompetitionRules(
      format: primaryFormat,
      handicapAllowance: 1.0,
      hasMatchPlayOverlay: true,
    );

    final matchesRaw = event.grouping['matches'] as List? ?? [];
    final matches = matchesRaw
        .map((m) => MatchDefinition.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();

    for (final match in matches) {
      if (match.team1Ids.isEmpty || match.team2Ids.isEmpty) continue;
      final p1Id = match.team1Ids.first;
      final p2Id = match.team2Ids.first;
      final m1 = membersMap[p1Id];
      final m2 = membersMap[p2Id];
      if (m1 == null || m2 == null) continue;

      if (match.bracketOrder == 0) {
        _logDivergencePoints(match, m1, m2, courseConfig, rules);
      }

      // Group 0 = live match (through hole 9). All others = complete round.
      final isLive = match.bracketOrder == 0;

      for (final (playerId, member, opponentId) in [(p1Id, m1, p2Id), (p2Id, m2, p1Id)]) {
        final phc = HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: member.handicap,
          rules: rules,
          courseConfig: courseConfig,
        );
        final allScores = _generateScores(courseConfig, member.handicap);
        final holeScores = isLive
            ? [...allScores.take(9), ...List<int?>.filled(9, null)]
            : List<int?>.from(allScores);
        final grossTotal = holeScores.whereType<int>().fold(0, (a, b) => a + b);
        final netTotal = primaryFormat == CompetitionFormat.stroke ? grossTotal - phc : null;
        final stablefordPoints = primaryFormat == CompetitionFormat.stableford && !isLive
            ? _calculateStablefordPoints(holeScores, courseConfig, phc)
            : null;

        await scoreRepo.addScorecard(Scorecard(
          id: 'seed_overlay_${event.id}_$playerId',
          competitionId: event.id,
          roundId: ScorecardConstants.defaultRoundId,
          entryId: playerId,
          markerId: opponentId,
          submittedByUserId: ScorecardConstants.systemUserId,
          status: isLive ? ScorecardStatus.draft : ScorecardStatus.submitted,
          holeScores: holeScores,
          playerVerifierScores: holeScores,
          conflictedHoles: [],
          handicapIndex: member.handicap,
          playingHandicap: phc,
          assignedTeeName: courseConfig.selectedTeeName,
          points: stablefordPoints,
          grossTotal: isLive ? null : grossTotal,
          netTotal: isLive ? null : netTotal,
          verifiedByMarker: !isLive,
          verifiedByPlayer: false,
          markerVerifiedAt: isLive ? null : DateTime.now().subtract(const Duration(minutes: 30)),
          submittedAt: isLive ? null : DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        if (kDebugMode) {
          final label = isLive ? 'LIVE (9 holes)' : 'complete';
          debugPrint('  [$label] $playerId ← marked by $opponentId (HC ${member.handicap}, PHC $phc)');
        }
      }
    }

    if (kDebugMode) debugPrint('$formatLabel overlay scores seeded: ${matches.length} matches (1 live, ${matches.length - 1} complete).');
  }

  // ---------------------------------------------------------------------------
  // Score generation helpers
  // ---------------------------------------------------------------------------

  List<int?> _generateScores(CourseConfig courseConfig, double handicapIndex) {
    final holes = courseConfig.holes;
    final phc = handicapIndex.clamp(0.0, 36.0).round();

    return List.generate(18, (i) {
      if (i >= holes.length) return null;
      final par = holes[i].par;
      final si = holes[i].si;

      // Shots received on this hole based on full course handicap
      final shotsOnHole = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);

      // Deterministic net score: varies by hole index and handicap to produce realistic variance
      final seed = (i * 13 + phc * 7) % 100;
      final netOffset = seed < 15 ? -1 : (seed < 65 ? 0 : (seed < 88 ? 1 : 2));
      return (par + shotsOnHole + netOffset).clamp(1, par + 5);
    });
  }

  int _calculateStablefordPoints(List<int?> holeScores, CourseConfig courseConfig, int phc) {
    int total = 0;
    for (int i = 0; i < holeScores.length && i < courseConfig.holes.length; i++) {
      final gross = holeScores[i];
      if (gross == null) continue;
      final par = courseConfig.holes[i].par;
      final si = courseConfig.holes[i].si;
      final shotsOnHole = (phc ~/ 18) + (si <= (phc % 18) ? 1 : 0);
      final net = gross - shotsOnHole;
      final points = (par - net + 2).clamp(0, 10);
      total += points;
    }
    return total;
  }

  // Prints holes where Stableford and match play stroke allocations diverge for the focus match.
  void _logDivergencePoints(
    MatchDefinition match,
    Member m1,
    Member m2,
    CourseConfig courseConfig,
    CompetitionRules rules,
  ) {
    if (!kDebugMode) return;
    final phc1 = HandicapCalculator.calculatePlayingHandicap(handicapIndex: m1.handicap, rules: rules, courseConfig: courseConfig);
    final phc2 = HandicapCalculator.calculatePlayingHandicap(handicapIndex: m2.handicap, rules: rules, courseConfig: courseConfig);
    final mpDiff = (phc1 - phc2).abs();
    final higherPhc = phc1 >= phc2 ? phc1 : phc2;
    final higherName = phc1 >= phc2 ? m1.displayName : m2.displayName;

    debugPrint('--- HANDICAP DIVERGENCE CHECK (Match 1: ${m1.displayName} vs ${m2.displayName}) ---');
    debugPrint('  $higherName: Full Course HC $higherPhc (Stableford strokes on SI 1–$higherPhc)');
    debugPrint('  Match Play: $higherName receives $mpDiff strokes (SI 1–$mpDiff only)');
    debugPrint('  Divergence holes (Stableford stroke, NO match play stroke): SI ${mpDiff + 1}–$higherPhc');
    debugPrint('  On these holes: a bogey gross = net par for Stableford (2pts) but net bogey for match play (lose hole)');
  }
}
