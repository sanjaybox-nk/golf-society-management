import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:golf_society/features/matchplay/domain/match_play_tournament.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/features/matchplay/logic/match_play_draw_service.dart';
import 'package:golf_society/features/matchplay/data/match_play_repository.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'course_seeder.dart';
import 'package:uuid/uuid.dart';

enum MatchPlayStage {
  registration,
  drawPublished,
  midRoundResults,
}

class MatchPlaySeeder {
  final Ref ref;
  final Random random;
  final String seasonId = 'demo_season_2025_2026';

  MatchPlaySeeder(this.ref, [Random? seedRandom]) : random = seedRandom ?? Random(42);

  Future<void> seed(MatchPlayStage stage) async {
    switch (stage) {
      case MatchPlayStage.registration:
        await _seedRegistration();
        break;
      case MatchPlayStage.drawPublished:
        await _seedDrawPublished();
        break;
      case MatchPlayStage.midRoundResults:
        await _seedMidRoundResults();
        break;
    }
  }

  Future<String> _seedRegistration() async {
    debugPrint('--- SEEDING MATCH PLAY: STAGE 1 (REGISTRATION) ---');
    
    final eventsRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    // 1. Fetch or Seed a Course
    final courseRepo = ref.read(courseRepositoryProvider);
    var courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) {
      debugPrint('No courses found, seeding default course library...');
      courses = await CourseSeeder(ref, random).seed();
    }
    final course = courses.first;
    final tee = course.tees.first;

    // 2. Prepare Registrations (32 members)
    final membersRepo = ref.read(membersRepositoryProvider);
    final members = await membersRepo.getMembers();
    if (members.length < 32) {
      throw Exception('Need 32 members. Please seed members first.');
    }
    final participants = members.take(32).toList();

    final registrations = participants.map((m) => EventRegistration(
      memberId: m.id,
      memberName: m.displayName,
      attendingGolf: true,
      isConfirmed: true,
      handicap: m.handicap,
      registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      cost: 0,
    )).toList();

    // 3. Build Event Shell with Course Data
    final eventId = 'matchplay_lab_${DateTime.now().millisecondsSinceEpoch}';
    final event = GolfEvent(
      id: eventId,
      seasonId: seasonId,
      title: 'Season Long Match Play [LAB: REG]',
      description: 'Stage 1 Lab Seeding: Event created and members registered. No draw generated.',
      date: DateTime.now().add(const Duration(days: 14)),
      status: EventStatus.published,
      regTime: DateTime.now().add(const Duration(days: 14, hours: 8)),
      teeOffTime: DateTime.now().add(const Duration(days: 14, hours: 9, minutes: 30)),
      hasBreakfast: true,
      maxParticipants: 64,
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
        holes: List.generate(18, (i) => CourseHole(
          hole: i + 1,
          par: tee.holePars[i],
          si: tee.holeSIs[i],
          yardage: tee.yardages[i],
        )),
      ),
    );

    // 4. Persist Event & Competition shell
    await eventsRepo.addEvent(event);
    await compRepo.addCompetition(Competition(
      id: eventId,
      name: event.title,
      type: CompetitionType.event,
      startDate: event.date,
      endDate: event.date,
      rules: const CompetitionRules(
        format: CompetitionFormat.matchPlay,
        handicapAllowance: 1.0,
      ),
    ));

    return eventId;
  }

  Future<void> _seedDrawPublished() async {
    final eventId = await _seedRegistration();
    debugPrint('--- SEEDING MATCH PLAY: STAGE 2 (DRAW PUBLISHED) ---');

    final mpRepo = ref.read(matchPlayRepositoryProvider);
    final eventsRepo = ref.read(eventsRepositoryProvider);
    
    final event = await eventsRepo.getEvent(eventId);
    if (event == null) return;

    // 1. Create Entrants
    final entrants = event.registrations.map((r) => MatchPlayEntrant(
      id: const Uuid().v4(),
      playerIds: [r.memberId],
      name: r.memberName,
    )).toList();

    // 2. Generate Draw
    final matches = MatchPlayDrawService.generateKnockoutDraw(
      entrants: entrants,
      seedingType: SeedingType.random,
      startRound: MatchRoundType.roundOf32,
    );

    // 3. Create Tournament
    final tournament = MatchPlayTournament(
      id: eventId, // ID matching the event
      name: 'Season Long Match Play [LAB: DRAW]',
      type: TournamentType.knockout,
      entrants: entrants,
      matches: matches,
      isPublished: true,
      createdAt: DateTime.now(),
    );

    // 4. Update Event Title & Persist
    await eventsRepo.updateEvent(event.copyWith(
      title: 'Season Long Match Play [LAB: DRAW]',
      description: 'Stage 2 Lab Seeding: Draw generated and published with 16 Round of 32 matches.',
    ));
    await mpRepo.saveTournament(tournament);
  }

  Future<void> _seedMidRoundResults() async {
    debugPrint('--- SEEDING MATCH PLAY: STAGE 3 (PARTIAL RESULTS) ---');
    
    final mpRepo = ref.read(matchPlayRepositoryProvider);
    final eventsRepo = ref.read(eventsRepositoryProvider);

    // 1. Setup Stage 2 first
    await _seedDrawPublished();
    
    // 2. Fetch the newly created tournament (using Title filter as we can't easily pass ID back)
    final events = await eventsRepo.getEvents(seasonId: seasonId);
    final labEvent = events.firstWhereOrNull((e) => e.title == 'Season Long Match Play [LAB: DRAW]');
    
    if (labEvent == null) {
      throw Exception('Could not find the Stage 2 event to upgrade to Stage 3.');
    }

    final tournament = await mpRepo.getTournament(labEvent.id);
    if (tournament == null) return;

    // 3. Update Event Details
    await eventsRepo.updateEvent(labEvent.copyWith(
      title: 'Season Long Match Play [LAB: RESULTS]',
      description: 'Stage 3 Lab Seeding: 8 Round of 32 results entered. Ready for progression testing.',
    ));

    // 4. Inject 8 Results into Round of 32
    final updatedMatches = tournament.matches.map((m) {
      final order = m.bracketOrder ?? 0;
      if (m.round == MatchRoundType.roundOf32 && order < 8 && !m.isBye && m.team1Ids.isNotEmpty && m.team2Ids.isNotEmpty) {
        // Winner is either Team 1 or Team 2 (50/50 split for data variance)
        final winningTeamIndex = order % 2 == 0 ? 0 : 1;
        final scoreText = order % 3 == 0 ? '4&3' : '1up';
        
        return m.copyWith(
          manualResult: MatchResult(
            matchId: m.id,
            winningTeamIndex: winningTeamIndex,
            status: scoreText,
            score: order % 3 == 0 ? 4 : 1, // Simplified score mapping
            holesPlayed: order % 3 == 0 ? 15 : 18,
            isFinal: true,
          ),
        );
      }
      return m;
    }).toList();

    // 5. Persist Stage 3 Tournament
    await mpRepo.saveTournament(tournament.copyWith(
      name: 'Season Long Match Play [LAB: RESULTS]',
      matches: updatedMatches,
    ));
  }

  CourseConfig _getLaboratoryCourseConfig() {
    return CourseConfig(
      name: 'Laboratory Championship Course',
      holes: List.generate(18, (i) => CourseHole(
        hole: i + 1,
        par: 4,
        si: ((i * 3) % 18) + 1,
      )),
    );
  }
}
