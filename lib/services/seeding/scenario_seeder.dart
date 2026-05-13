import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/matchplay/data/match_play_repository.dart';
import 'package:golf_society/features/matchplay/domain/match_play_tournament.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/domain/grouping/tee_group.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'event_seeder.dart';
import 'course_seeder.dart';
import 'member_seeder.dart';
import 'data_constants.dart';
import 'package:golf_society/features/guests/data/guest_repository.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/models/course_config.dart' as cfg;

class ScenarioSeeder {
  final Ref ref;
  final Random random;
  final String seasonId = 'demo_season_2025_2026';

  ScenarioSeeder(this.ref, [Random? seedRandom]) : random = seedRandom ?? Random(42);

  Future<String> seedVerificationScenario() async {
    final membersRepo = ref.read(membersRepositoryProvider);
    var members = await membersRepo.getMembers();
    if (members.length < 32) {
      await MemberSeeder(ref, random).seed();
      members = await membersRepo.getMembers();
    }

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final eventSeeder = EventSeeder(ref, random);
    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();
    
    final date = DateTime.now();

    // 1. Create the base event as "In Play"
    await eventSeeder.createFullEvent(
      seasonId: seasonId,
      course: course,
      title: 'Verification Test Event',
      date: date,
      format: CompetitionFormat.stableford,
      isInvitational: false,
      isSeasonEvent: true,
      members: members,
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: templates,
    );

    // Get the created event ID (EventSeeder generates a random one, but we can find it)
    final events = await ref.read(eventsRepositoryProvider).getEvents(seasonId: seasonId);
    final event = events.firstWhere((e) => e.title == 'Verification Test Event');
    
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final scorecards = await scoreRepo.getScorecards(event.id);
    
    // We want:
    // 70% completed/submitted (18 holes, Submitted)
    // 20% completed/not submitted (18 holes, Draft)
    // 10% playing last holes (16 holes, Draft)
    // 70% groups completed/submitted (18 holes)
    // 20% groups completed/not submitted (18 holes)
    // 10% groups playing last holes (16 holes)
    final List<TeeGroup> groups = (event.grouping['groups'] as List).map((g) => TeeGroup.fromJson(g)).toList();
    
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      // Group-level progress: Sequential and synchronized
      // First 70% finished, next 20% finished but draft, last 10% in play
      final double progress = i / groups.length;
      final int groupHolesPlayed = (progress < 0.9) ? 18 : 16;
      final bool isGroupSubmitted = (progress < 0.7);

      for (var p in group.players) {
        final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final s = scorecards.firstWhereOrNull((sc) => sc.entryId == entryId);
        if (s == null) continue;

        final List<int?> scores = List.generate(
          18, 
          (idx) => idx < groupHolesPlayed ? 4 + random.nextInt(3) : null
        );
        
        await scoreRepo.updateScorecard(s.copyWith(
          status: isGroupSubmitted ? ScorecardStatus.submitted : ScorecardStatus.draft,
          holeScores: scores,
          submittedAt: isGroupSubmitted 
              ? DateTime.now().subtract(Duration(minutes: (groups.length - i) * 10)) 
              : null,
        ));
      }
    }

    return event.id;
  }

  Future<String> seedMedalVerificationScenario() async {
    final membersRepo = ref.read(membersRepositoryProvider);
    var members = await membersRepo.getMembers();
    if (members.length < 32) {
      await MemberSeeder(ref, random).seed();
      members = await membersRepo.getMembers();
    }

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final eventSeeder = EventSeeder(ref, random);
    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();
    
    final date = DateTime.now();

    // 1. Find or create Medal Template
    var medalTemplate = templates.firstWhereOrNull((t) => t.name?.trim().toLowerCase() == 'medal play') ??
                        templates.firstWhereOrNull((t) => t.name?.toLowerCase().contains('medal') ?? false) ??
                        templates.firstWhereOrNull((t) => t.id == 'tmpl_medal_solo');

    if (medalTemplate == null) {
      medalTemplate = Competition(
        id: 'tmpl_medal_solo',
        name: 'Medal Play',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.stroke,
          mode: CompetitionMode.singles,
          handicapAllowance: 0.95,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
      await compRepo.addTemplate(medalTemplate);
      final updatedTemplates = await compRepo.getTemplates();
      templates.clear();
      templates.addAll(updatedTemplates);
    }

    // 2. Create Event
    await eventSeeder.createFullEvent(
      seasonId: seasonId,
      course: course,
      title: 'Medal Play Verification',
      date: date,
      format: CompetitionFormat.stroke,
      isInvitational: false,
      isSeasonEvent: true,
      members: members,
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: [medalTemplate],
    );

    final events = await ref.read(eventsRepositoryProvider).getEvents(seasonId: seasonId);
    final event = events.firstWhere((e) => e.title == 'Medal Play Verification');
    
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final scorecards = await scoreRepo.getScorecards(event.id);
    
    final List<TeeGroup> groups = (event.grouping['groups'] as List).map((g) => TeeGroup.fromJson(g)).toList();
    
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      
      // Progress States
      int groupHolesPlayed = 18;
      if (i == groups.length - 1) {
        groupHolesPlayed = 16; // Last group
      } else if (i == groups.length - 2) {
        groupHolesPlayed = 15; // Second last
      } else if (i == groups.length - 3) {
        groupHolesPlayed = 18; // Third last (Verification state)
      }

      final bool isThirdLast = (i == groups.length - 3);
      final bool isGroupSubmitted = (i < groups.length - 3) && (i < groups.length * 0.5);

      for (int j = 0; j < group.players.length; j++) {
        final p = group.players[j];
        final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final s = scorecards.firstWhereOrNull((sc) => sc.entryId == entryId);
        if (s == null) continue;

        final List<int?> holeScores = List.generate(
          18, 
          (idx) => idx < groupHolesPlayed ? 4 + random.nextInt(3) : null
        );

        final List<int?> markerScores = List.from(holeScores);

        // Introduce error on 18th hole for the first player of the third-last group
        if (isThirdLast && j == 0) {
           if (markerScores[17] != null) {
             markerScores[17] = markerScores[17]! + 1;
           }
        }
        
        await scoreRepo.updateScorecard(s.copyWith(
          status: isGroupSubmitted ? ScorecardStatus.submitted : ScorecardStatus.draft,
          holeScores: holeScores,
          playerVerifierScores: markerScores,
          holeTags: _generateHoleTags(holeScores),
          submittedAt: isGroupSubmitted ? DateTime.now().subtract(Duration(minutes: (groups.length - i) * 10)) : null,
        ));
      }
    }

    return event.id;
  }

  Future<void> seedMatchPlayProgression() async {
    final membersRepo = ref.read(membersRepositoryProvider);
    var members = await membersRepo.getMembers();
    if (members.length < 33) {
      await MemberSeeder(ref, random).seed();
      members = await membersRepo.getMembers();
    }

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    // 1. Season Opener (Stableford + Match Play Round 1)
    final event1Id = await _seedEventWithMatches(
      title: 'Season Opener 2026',
      date: DateTime(2026, 3, 12),
      course: course,
      members: members.take(33).toList(),
      guestCount: 3,
      status: EventStatus.completed,
    );

    // 2. Spring Stableford (Round 2)
    // We'll need the winners from Event 1
    final tournament1 = await ref.read(matchPlayRepositoryProvider).getTournament(event1Id);
    final winners1 = tournament1?.matches
        .where((m) => m.manualResult?.isFinal == true)
        .map((m) {
          if (m.manualResult?.winningTeamIndex == 0) return m.team1Ids.firstOrNull;
          if (m.manualResult?.winningTeamIndex == 1) return m.team2Ids.firstOrNull;
          return null;
        })
        .whereType<String>()
        .toList() ?? [];
    
    // Add the bye player (who was in the guest group in Event 1)
    final byePlayerId = members[32].id;
    final entrants2 = [...winners1, byePlayerId];

    await _seedEventWithMatches(
      title: 'Spring Stableford 2026',
      date: DateTime(2026, 4, 15),
      course: course,
      members: members, // All members available for Stableford
      matchEntrantIds: entrants2,
      status: EventStatus.inPlay,
      previousTournamentId: event1Id,
    );
  }

  Future<String> _seedEventWithMatches({
    required String title,
    required DateTime date,
    required Course course,
    required List<Member> members,
    int guestCount = 0,
    List<String>? matchEntrantIds,
    required EventStatus status,
    String? previousTournamentId,
  }) async {
    final eventId = 'scenario_${title.replaceAll(' ', '_')}_${date.millisecondsSinceEpoch}';
    final eventsRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);
    final mpRepo = ref.read(matchPlayRepositoryProvider);

    // Prepare participants
    final List<EventRegistration> registrations = [];
    
    // Determine who is in the match play
    final matchPlayers = matchEntrantIds != null 
        ? members.where((m) => matchEntrantIds.contains(m.id)).toList()
        : members.take(33).toList();

    // 1. Add Match Players
    for (var m in matchPlayers) {
      registrations.add(EventRegistration(
        memberId: m.id,
        memberName: m.displayName,
        attendingGolf: true,
        isConfirmed: true,
        handicap: m.handicap,
        registeredAt: date.subtract(const Duration(days: 10)),
        cost: 45,
      ));
    }

    // 2. Add Guests from the real guest pool
    final guestRepo = ref.read(guestRepositoryProvider);
    final guestPool = SeedingData.seedGuests.take(guestCount).toList();
    for (final seedGuest in guestPool) {
      final profile = await guestRepo.findOrCreate(
        email: seedGuest['email'] as String,
        name: seedGuest['name'] as String,
        handicap: seedGuest['handicap'] as double,
      );
      // Host: first member in the list sponsors this guest
      final hostMember = matchPlayers.isNotEmpty ? matchPlayers.first : members.first;
      registrations.add(EventRegistration(
        memberId: '${hostMember.id}_guest',
        memberName: profile.name,
        attendingGolf: true,
        isConfirmed: true,
        handicap: profile.handicap,
        guestId: profile.id,
        guestEmail: profile.email,
        guestName: profile.name,
        guestHandicap: profile.handicap.toStringAsFixed(1),
        registeredAt: date.subtract(const Duration(days: 5)),
        cost: 60,
      ));
    }

    // 3. Fill up to 36 with other members for Stableford
    final others = members.where((m) => !registrations.any((r) => r.memberId == m.id)).toList();
    while (registrations.length < 36 && others.isNotEmpty) {
      final m = others.removeAt(0);
      registrations.add(EventRegistration(
        memberId: m.id,
        memberName: m.displayName,
        attendingGolf: true,
        isConfirmed: true,
        handicap: m.handicap,
        registeredAt: date.subtract(const Duration(days: 8)),
        cost: 45,
      ));
    }

    // Build Event
    final event = GolfEvent(
      id: eventId,
      seasonId: seasonId,
      title: title,
      date: date,
      status: status,
      courseId: course.id,
      courseName: course.name,
      registrations: registrations,
      isGroupingPublished: true,
      isStatsReleased: true,
    );

    await eventsRepo.addEvent(event);
    
    // Custom Grouping Logic for Scenario
    final List<TeeGroup> groups = [];
    final startTime = date.copyWith(hour: 9, minute: 0);

    // 1. Groups 1-8: 16 Matches (4 players per group, 2 matches per group)
    for (int i = 0; i < 8; i++) {
      final List<TeeGroupParticipant> players = [];
      for (int j = 0; j < 4; j++) {
        final reg = registrations[i * 4 + j];
        players.add(TeeGroupParticipant(
          registrationMemberId: reg.memberId,
          name: reg.memberName,
          handicapIndex: reg.handicap ?? 0.0,
          playingHandicap: (reg.handicap ?? 0.0).round().toDouble(),
          isGuest: reg.memberId.endsWith('_guest'),
          needsBuggy: false,
        ));
      }
      groups.add(TeeGroup(
        index: i,
        teeTime: startTime.add(Duration(minutes: i * 10)),
        players: players,
      ));
    }

    // 2. Group 9: Bye Member + 3 Guests
    final List<TeeGroupParticipant> lastGroupPlayers = [];
    // The 33rd member (index 32) is the bye player
    final byeReg = registrations[32];
    lastGroupPlayers.add(TeeGroupParticipant(
      registrationMemberId: byeReg.memberId,
      name: byeReg.memberName,
      handicapIndex: byeReg.handicap ?? 0.0,
      playingHandicap: (byeReg.handicap ?? 18.0).round().toDouble(),
      isGuest: false,
      needsBuggy: false,
    ));

    // Guests are at indices 33, 34, 35
    for (int i = 0; i < 3; i++) {
      final guestReg = registrations[33 + i];
      lastGroupPlayers.add(TeeGroupParticipant(
        registrationMemberId: guestReg.memberId,
        name: guestReg.memberName,
        handicapIndex: guestReg.handicap ?? 0.0,
        playingHandicap: (guestReg.handicap ?? 18.0).round().toDouble(),
        isGuest: true,
        needsBuggy: false,
      ));
    }

    groups.add(TeeGroup(
      index: 8,
      teeTime: startTime.add(const Duration(minutes: 80)),
      players: lastGroupPlayers,
    ));

    await eventsRepo.updateEvent(event.copyWith(
      grouping: {'groups': groups.map((g) => g.toJson()).toList(), 'isPublished': true},
    ));

    await compRepo.addCompetition(Competition(
      id: eventId,
      name: title,
      type: CompetitionType.event,
      rules: const CompetitionRules(
        format: CompetitionFormat.stableford,
        hasMatchPlayOverlay: true,
      ),
      startDate: date,
      endDate: date,
    ));

    // Create Matches
    final List<MatchDefinition> matchesList = [];
    final List<MatchPlayEntrant> entrants = matchPlayers.map((m) => MatchPlayEntrant(
      id: const Uuid().v4(),
      playerIds: [m.id],
      name: m.displayName,
    )).toList();

    // If it's the first round and we have 33 players
    if (previousTournamentId == null && entrants.length == 33) {
      // 16 matches + 1 bye
      for (int i = 0; i < 16; i++) {
        final p1 = entrants[i * 2];
        final p2 = entrants[i * 2 + 1];
        matchesList.add(MatchDefinition(
          id: 'match_${eventId}_$i',
          type: MatchType.singles,
          team1Ids: p1.playerIds,
          team2Ids: p2.playerIds,
          team1Name: p1.name,
          team2Name: p2.name,
          round: MatchRoundType.roundOf32,
          bracketOrder: i,
          groupId: (i ~/ 2).toString(), // Links match to group 0-7
        ));
      }
      // The 33rd player gets a bye
      final byePlayer = entrants[32];
      matchesList.add(MatchDefinition(
        id: 'match_${eventId}_bye',
        type: MatchType.singles,
        team1Ids: byePlayer.playerIds,
        team2Ids: [],
        team1Name: byePlayer.name,
        team2Name: 'BYE',
        round: MatchRoundType.roundOf32,
        isBye: true,
        bracketOrder: 16,
        groupId: '8', // Last group
      ));
    } else {
      // Logic for subsequent rounds (e.g. 17 players -> 8 matches + 1 bye)
      final count = (entrants.length / 2).floor();
      for (int i = 0; i < count; i++) {
        final p1 = entrants[i * 2];
        final p2 = entrants[i * 2 + 1];
        matchesList.add(MatchDefinition(
          id: 'match_${eventId}_$i',
          type: MatchType.singles,
          team1Ids: p1.playerIds,
          team2Ids: p2.playerIds,
          team1Name: p1.name,
          team2Name: p2.name,
          round: MatchRoundType.roundOf16,
          bracketOrder: i,
        ));
      }
      if (entrants.length % 2 != 0) {
        final byePlayer = entrants.last;
        matchesList.add(MatchDefinition(
          id: 'match_${eventId}_bye',
          type: MatchType.singles,
          team1Ids: byePlayer.playerIds,
          team2Ids: [],
          team1Name: byePlayer.name,
          team2Name: 'BYE',
          round: MatchRoundType.roundOf16,
          isBye: true,
          bracketOrder: count,
        ));
      }
    }

    // [NEW] Update groups with their matches in the grouping map
    await eventsRepo.updateEvent(event.copyWith(
      grouping: {
        'groups': groups.map((g) => g.toJson()).toList(), 
        'isPublished': true,
        'matches': matchesList.map((m) => m.toJson()).toList(),
      },
    ));

    // Save Tournament
    final tournament = MatchPlayTournament(
      id: eventId,
      name: '$title - Match Play',
      type: TournamentType.knockout,
      entrants: entrants,
      matches: matchesList,
      isPublished: true,
      createdAt: DateTime.now(),
    );
    await mpRepo.saveTournament(tournament);

    // Mock results if completed
    if (status == EventStatus.completed) {
      final updatedMatches = matchesList.map((m) {
        if (m.isBye) return m.copyWith(manualResult: MatchResult(matchId: m.id, winningTeamIndex: 0, status: 'BYE', score: 10, holesPlayed: 0, isFinal: true));
        final winnerIdx = random.nextInt(2);
        return m.copyWith(manualResult: MatchResult(
          matchId: m.id,
          winningTeamIndex: winnerIdx,
          status: '3&2',
          score: winnerIdx == 0 ? 3 : -3,
          holesPlayed: 16,
          isFinal: true,
        ));
      }).toList();
      
      // Also update event results for Stableford
      final List<Map<String, dynamic>> results = [];
      for (var reg in registrations) {
        final score = 30 + random.nextInt(10);
        results.add({
          'playerId': reg.memberId,
          'playerName': reg.memberName,
          'points': score,
          'position': 0, // Will sort later
          'status': updatedMatches.firstWhereOrNull((m) => m.team1Ids.contains(reg.memberId) || m.team2Ids.contains(reg.memberId))?.isBye == true 
              ? 'BYE' 
              : null,
        });
      }
      
      await mpRepo.saveTournament(tournament.copyWith(matches: updatedMatches));
      await eventsRepo.updateEvent(event.copyWith(
        results: results,
        grouping: {
          'groups': groups.map((g) => g.toJson()).toList(), 
          'isPublished': true,
          'matches': updatedMatches.map((m) => m.toJson()).toList(),
        },
      ));
    }

    return eventId;
  }
  /// Full medal event: all 18 holes complete, all cards submitted, awaiting admin final verification.
  /// Groups split across Ready / Awaiting / Outstanding states with rich hole tags and deliberate conflicts.
  Future<String> seedFinalVerificationUAT() async {
    final membersRepo = ref.read(membersRepositoryProvider);
    var members = await membersRepo.getMembers();
    if (members.length < 32) {
      await MemberSeeder(ref, random).seed();
      members = await membersRepo.getMembers();
    }

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();

    // Pick the existing medal template (the user updated pick-up to max score / NDB)
    final medalTemplate = templates.firstWhereOrNull((t) =>
            t.name?.toLowerCase().contains('medal') == true ||
            t.rules.format == CompetitionFormat.stroke) ??
        Competition(
          id: 'tmpl_medal_solo',
          name: 'Medal Play',
          type: CompetitionType.game,
          rules: const CompetitionRules(
            format: CompetitionFormat.stroke,
            mode: CompetitionMode.singles,
            handicapAllowance: 1.0,
            pickUpBehaviour: PickUpBehaviour.maxScore,
          ),
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        );

    final eventSeeder = EventSeeder(ref, random);
    final date = DateTime.now();

    await eventSeeder.createFullEvent(
      seasonId: seasonId,
      course: course,
      title: 'Medal — Final Verification UAT',
      date: date,
      format: CompetitionFormat.stroke,
      isInvitational: false,
      isSeasonEvent: true,
      members: members,
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: [medalTemplate],
    );

    final events = await ref.read(eventsRepositoryProvider).getEvents(seasonId: seasonId);
    final event = events.firstWhere((e) => e.title == 'Medal — Final Verification UAT');
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final scorecards = await scoreRepo.getScorecards(event.id);
    final rules = medalTemplate.rules;

    final List<TeeGroup> groups =
        (event.grouping['groups'] as List).map((g) => TeeGroup.fromJson(g)).toList();
    final int total = groups.length;

    // Deterministic admin ID for audit log entries
    final adminId = members.firstWhereOrNull(
      (m) => m.role == MemberRole.admin || m.role == MemberRole.superAdmin,
    )?.id ?? 'admin_seed';

    // Tier boundaries — 5 distinct states:
    //   0 .. verifiedCut-1       → Verified (approved, some with audit log)
    //   verifiedCut .. reviewCut-1  → Ready to Review (finalScore clean + reviewed with audit log)
    //   reviewCut .. conflictCut-1  → Issues (submitted, unresolved conflicts)
    //   conflictCut .. awaitCut-1   → Awaiting (player signed, marker pending)
    //   awaitCut .. total-1         → Outstanding (draft / neither signed)
    final int verifiedCut  = (total * 0.20).round().clamp(1, total);
    final int reviewCut    = (total * 0.40).round().clamp(verifiedCut, total);
    final int conflictCut  = (total * 0.55).round().clamp(reviewCut, total);
    final int awaitCut     = (total * 0.75).round().clamp(conflictCut, total);

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];

      final bool isVerified    = i < verifiedCut;
      final bool isReadyReview = i >= verifiedCut && i < reviewCut;
      final bool isIssue       = i >= reviewCut && i < conflictCut;
      final bool isAwaiting    = i >= conflictCut && i < awaitCut;
      // else outstanding

      for (int j = 0; j < group.players.length; j++) {
        final p = group.players[j];
        final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final s = scorecards.firstWhereOrNull((sc) => sc.entryId == entryId);
        if (s == null) continue;

        final member = members.firstWhereOrNull((m) => m.id == p.registrationMemberId);
        final index = member?.handicap ?? 18.0;
        final teeName = (member?.gender == 'Female') ? 'Red' : 'Yellow';
        final tee = course.tees.firstWhere((t) => t.name == teeName,
            orElse: () => course.tees.first);
        final phc = HandicapCalculator.calculatePlayingHandicap(
          handicapIndex: index,
          rules: rules,
          courseConfig: cfg.CourseConfig(
            rating: tee.rating,
            slope: tee.slope,
            par: tee.holePars.fold<int>(0, (a, b) => a + b),
            holes: tee.holePars.asMap().entries
                .map((e) => cfg.CourseHole(hole: e.key + 1, par: e.value, si: tee.holeSIs[e.key]))
                .toList(),
          ),
        );

        // Build 18 realistic hole scores
        final holeScores = <int?>[];
        for (int h = 0; h < 18; h++) {
          final par = tee.holePars[h];
          final si = tee.holeSIs[h];
          final strokes = (phc / 18).floor() + (phc % 18 >= si ? 1 : 0);
          final rand = random.nextDouble();
          final netScore = rand < 0.20 ? par - 1 : rand < 0.75 ? par : rand < 0.92 ? par + 1 : par + 2;
          holeScores.add((netScore + strokes).toInt());
        }

        final holeTags = _generateVerificationTags(holeScores, tee.holePars, tee.holeSIs, phc, rules);
        for (final entry in holeTags.entries) {
          if (entry.value.contains('PICK_UP')) {
            final hIdx = entry.key - 1;
            final par = tee.holePars[hIdx];
            final si = tee.holeSIs[hIdx];
            final strokes = (phc / 18).floor() + (phc % 18 >= si ? 1 : 0);
            holeScores[hIdx] = (par + 2 + strokes).toInt();
          }
        }

        final marker = group.players[(j + 1) % group.players.length];
        final markerId = marker.isGuest
            ? '${marker.registrationMemberId}_guest'
            : marker.registrationMemberId;

        final submittedTime = date.copyWith(hour: 14, minute: 30 + random.nextInt(60));

        // --- Conflict helpers ---
        // Odd-indexed players in conflict/verified-with-audit groups get a conflict on holes 7 & 14
        final bool seedConflict = (isIssue || isVerified || isReadyReview) && j.isOdd;

        final markerScores = List<int?>.from(holeScores);
        if (seedConflict) {
          if (markerScores[6] != null) markerScores[6] = markerScores[6]! + 1;
          if (markerScores[13] != null) markerScores[13] = markerScores[13]! + 1;
        }

        // Audit log for resolved conflict cards (verified + reviewable odd-j)
        final List<HoleAuditEntry> auditLog = [];
        if (seedConflict && !isIssue) {
          // Conflict was resolved — restore markerScores to match holeScores
          markerScores[6] = holeScores[6];
          markerScores[13] = holeScores[13];
          auditLog.addAll([
            HoleAuditEntry(
              hole: 7,
              playerScore: holeScores[6]!,
              markerScore: holeScores[6]! + 1,
              resolvedTo: holeScores[6]!,
              reason: 'Player confirmed correct score on debrief',
              editorId: adminId,
              timestamp: submittedTime.add(const Duration(minutes: 20)),
            ),
            HoleAuditEntry(
              hole: 14,
              playerScore: holeScores[13]!,
              markerScore: holeScores[13]! + 1,
              resolvedTo: holeScores[13]!,
              reason: 'Marker acknowledged counting error',
              editorId: adminId,
              timestamp: submittedTime.add(const Duration(minutes: 22)),
            ),
          ]);
        }

        final grossTotal = holeScores.whereType<int>().fold<int>(0, (a, b) => a + b);
        final approvedTime = submittedTime.add(const Duration(minutes: 45));

        ScorecardStatus status;
        bool verifiedByPlayer;
        bool verifiedByMarker;
        String? approvedBy;
        DateTime? approvedAt;

        if (isVerified) {
          status = ScorecardStatus.approved;
          verifiedByPlayer = true;
          verifiedByMarker = true;
          approvedBy = adminId;
          approvedAt = approvedTime;
        } else if (isReadyReview) {
          // Odd-j: resolved conflict → reviewed; even-j: clean → finalScore
          status = j.isOdd ? ScorecardStatus.reviewed : ScorecardStatus.finalScore;
          verifiedByPlayer = true;
          verifiedByMarker = true;
          approvedBy = null;
          approvedAt = null;
        } else if (isIssue) {
          // Odd-j: active conflict; even-j: clean submitted
          status = ScorecardStatus.submitted;
          verifiedByPlayer = true;
          verifiedByMarker = true;
          approvedBy = null;
          approvedAt = null;
        } else if (isAwaiting) {
          status = ScorecardStatus.submitted;
          verifiedByPlayer = true;
          verifiedByMarker = false;
          approvedBy = null;
          approvedAt = null;
        } else {
          // Outstanding
          status = j.isEven ? ScorecardStatus.draft : ScorecardStatus.submitted;
          verifiedByPlayer = false;
          verifiedByMarker = false;
          approvedBy = null;
          approvedAt = null;
        }

        await scoreRepo.updateScorecard(s.copyWith(
          status: status,
          markerId: markerId,
          holeScores: holeScores,
          playerVerifierScores: markerScores,
          holeTags: holeTags,
          holeAuditLog: auditLog,
          handicapIndex: index,
          playingHandicap: phc,
          grossTotal: grossTotal,
          verifiedByPlayer: verifiedByPlayer,
          verifiedByMarker: verifiedByMarker,
          approvedBy: approvedBy,
          approvedAt: approvedAt,
          submittedAt: submittedTime,
          updatedAt: DateTime.now(),
        ));
      }
    }

    // Lock scoring — event is done, pending admin final review
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(
      isScoringLocked: true,
    ));

    return event.id;
  }

  /// Rich hole tags for verification UAT:
  /// ~25% gimme on par-3 or score ≤ par+1, ~12% pick-up on blow-up holes,
  /// ~10% 1-stroke penalty, ~4% 2-stroke penalty. Never GIMME + PICK_UP together.
  Map<int, List<String>> _generateVerificationTags(
    List<int?> scores,
    List<int> pars,
    List<int> sis,
    int phc,
    CompetitionRules rules,
  ) {
    final tags = <int, List<String>>{};
    for (int i = 0; i < scores.length; i++) {
      final score = scores[i];
      if (score == null) continue;
      final par = pars[i];
      final holeTags = <String>[];
      final ts = DateTime.now().millisecondsSinceEpoch + i * 17;

      final isShortHole = par == 3;
      final isBigNumber = score >= par + 3;

      if (!isBigNumber && isShortHole && random.nextDouble() < 0.25) {
        holeTags.add('GIMME');
      } else if (isBigNumber && random.nextDouble() < 0.12) {
        holeTags.add('PICK_UP');
      }

      if (!holeTags.contains('PICK_UP')) {
        if (random.nextDouble() < 0.10) holeTags.add('PENALTY_1_$ts');
        if (random.nextDouble() < 0.04) holeTags.add('PENALTY_2_${ts + 1}');
      }

      if (holeTags.isNotEmpty) tags[i + 1] = holeTags;
    }
    return tags;
  }

  /// Generates realistic hole tags for a scorecard based on scores.
  /// ~20% gimme chance on par or better holes, ~10% pick-up on blow-up holes,
  /// ~8% chance of a 1-stroke penalty, ~3% chance of a 2-stroke penalty.
  Map<int, List<String>> _generateHoleTags(List<int?> scores) {
    final tags = <int, List<String>>{};
    for (int i = 0; i < scores.length; i++) {
      final score = scores[i];
      if (score == null) continue;
      final holeTags = <String>[];
      final ts = DateTime.now().millisecondsSinceEpoch + i * 13;
      if (score <= 4 && random.nextDouble() < 0.20) holeTags.add('GIMME');
      if (score >= 7 && random.nextDouble() < 0.10) holeTags.add('PICK_UP');
      if (random.nextDouble() < 0.08) holeTags.add('PENALTY_1_$ts');
      if (random.nextDouble() < 0.03) holeTags.add('PENALTY_2_${ts + 1}');
      if (holeTags.isNotEmpty) tags[i + 1] = holeTags;
    }
    return tags;
  }

  Future<String> seedHandshakeVerificationScenario() async {
    final membersRepo = ref.read(membersRepositoryProvider);
    var members = await membersRepo.getMembers();
    if (members.length < 32) {
      await MemberSeeder(ref, random).seed();
      members = await membersRepo.getMembers();
    }

    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    courses = await CourseSeeder(ref, random).seed();
    final course = courses.first;

    final eventSeeder = EventSeeder(ref, random);
    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();
    
    final date = DateTime.now();

    // 1. Create Event
    await eventSeeder.createFullEvent(
      seasonId: seasonId,
      course: course,
      title: 'Handshake Verification UAT',
      date: date,
      format: CompetitionFormat.stableford,
      isInvitational: false,
      isSeasonEvent: true,
      members: members,
      appliedCuts: {},
      status: EventStatus.inPlay,
      templates: templates,
    );

    final events = await ref.read(eventsRepositoryProvider).getEvents(seasonId: seasonId);
    final event = events.firstWhere((e) => e.title == 'Handshake Verification UAT');
    
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final scorecards = await scoreRepo.getScorecards(event.id);
    
    final List<TeeGroup> groups = (event.grouping['groups'] as List).map((g) => TeeGroup.fromJson(g)).toList();
    final Map<String, String> allMarkers = {};
    
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      
      // Assign Markers (Circular)
      for (int j = 0; j < group.players.length; j++) {
        final p = group.players[j];
        final marker = group.players[(j + 1) % group.players.length];
        final pId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final markerId = marker.isGuest ? '${marker.registrationMemberId}_guest' : marker.registrationMemberId;
        allMarkers[pId] = markerId;
      }

      // Progress States as per request:
      // Last group on hole 17
      // Second last on hole 16
      // Third last completed 18 holes but not submitted (Verification stage)
      int groupHolesPlayed = 18;
      if (i == groups.length - 1) {
        groupHolesPlayed = 17;
      } else if (i == groups.length - 2) {
        groupHolesPlayed = 16;
      } else if (i == groups.length - 3) {
        groupHolesPlayed = 18;
      } else {
        groupHolesPlayed = 18;
      }

      final bool isThirdLast = (i == groups.length - 3);
      final bool isGroupSubmitted = (i < groups.length - 3);

      for (int j = 0; j < group.players.length; j++) {
        final p = group.players[j];
        final entryId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
        final s = scorecards.firstWhereOrNull((sc) => sc.entryId == entryId);
        if (s == null) continue;

        final List<int?> holeScores = List.generate(
          18, 
          (idx) => idx < groupHolesPlayed ? 4 + random.nextInt(3) : null
        );

        final List<int?> markerScores = List.from(holeScores);

        // Show some errors on the third from last group for verification UAT
        if (isThirdLast && j == 1) { 
           if (markerScores[17] != null) {
             markerScores[17] = markerScores[17]! + 1; 
           }
        }
        
        await scoreRepo.updateScorecard(s.copyWith(
          status: isGroupSubmitted ? ScorecardStatus.submitted : ScorecardStatus.draft,
          markerId: allMarkers[entryId],
          holeScores: holeScores,
          playerVerifierScores: markerScores,
          holeTags: _generateHoleTags(holeScores),
          submittedAt: isGroupSubmitted ? DateTime.now().subtract(Duration(minutes: (groups.length - i) * 10)) : null,
        ));
      }
    }

    // Update event with markers map
    await ref.read(eventsRepositoryProvider).updateEvent(event.copyWith(
      grouping: {
        ...event.grouping,
        'markers': allMarkers,
      }
    ));

    return event.id;
  }
}
