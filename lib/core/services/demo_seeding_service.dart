import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/golf_event.dart';
import '../../models/season.dart';
import '../../models/competition.dart';
import '../../models/member.dart';
import '../../models/course.dart';
import '../../models/scorecard.dart';
import '../../models/event_registration.dart';
import '../../models/leaderboard_config.dart';

import 'package:collection/collection.dart';
import '../../features/competitions/presentation/competitions_provider.dart';
import '../../features/courses/presentation/courses_provider.dart';
import '../../features/members/presentation/members_provider.dart';
import '../../features/events/presentation/events_provider.dart';
import '../../features/events/logic/event_analysis_engine.dart';

import '../utils/grouping_service.dart';
import '../../features/events/domain/registration_logic.dart';
import '../../features/competitions/services/leaderboard_invoker_service.dart';

class DemoSeedingService {
  final Ref ref;
  final Random _random = Random();
  DemoSeedingService(this.ref);

  Future<void> seedDemoSeason() async {
    // 1. Setup Season
    final seasonId = await _seedSeason();

    // 2. Seed 60 Members
    await _seedMembers();
    final members = await ref.read(membersRepositoryProvider).getMembers();

    // 3. Seed 11 Unique Courses
    final courses = await _seedCourses();

    // 4. Track Society Cuts (Member ID -> Cumulative Cut)
    final Map<String, double> cumulativeCuts = {};

    // 5. Seed Events in Chronological order to apply cuts
    // Timeline: 2025 Jan -> 2026 Feb (Past) | 2026 Feb 25 (Ready)
    final List<({String title, CompetitionFormat format, bool isInvitational, CompetitionSubtype subtype, DateTime date, EventStatus status, bool isMultiDay, DateTime? endDate})> eventPlan = [
      // PAST EVENTS (8 Completed)
      (title: 'Season Opener: The Frozen Tee', format: CompetitionFormat.stroke, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 1, 21), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Spring Classic', format: CompetitionFormat.scramble, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 15), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Mid-Summer Open', format: CompetitionFormat.stableford, isInvitational: true, subtype: CompetitionSubtype.fourball, date: DateTime(2025, 7, 15), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Autumn Series #1', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 9, 10), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Winter Series #1', format: CompetitionFormat.matchPlay, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 11, 20), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Post-Christmas Scramble', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 12, 28), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Season Qualifier', format: CompetitionFormat.maxScore, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Masters Simulation', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 10), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2026, 2, 11)),
      
      // READY/READY-TO-PLAY (2 Published)
      (title: 'The Penultimate Round', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 18), status: EventStatus.published, isMultiDay: false, endDate: null),
      (title: 'Season Finale: Championship', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 21), status: EventStatus.published, isMultiDay: false, endDate: null),
    ];

    for (int i = 0; i < eventPlan.length; i++) {
      final config = eventPlan[i];
      final course = courses[i % courses.length];

      final results = await _createFullEvent(
        seasonId: seasonId,
        course: course,
        title: config.title,
        date: config.date,
        format: config.format,
        isInvitational: config.isInvitational,
        subtype: config.subtype,
        members: members,
        appliedCuts: Map<String, double>.from(cumulativeCuts),
        status: config.status,
        isMultiDay: config.isMultiDay,
        endDate: config.endDate,
      );

      // Apply logic for "Winner's Cut" if not invitational
      if (!config.isInvitational && results.isNotEmpty) {
         // Apply cuts for next round (1st: -2.0, 2nd: -1.0, 3rd: -0.5)
         final winners = results.take(3).toList();
         if (winners.isNotEmpty) {
           cumulativeCuts[winners[0]['playerId']] = (cumulativeCuts[winners[0]['playerId']] ?? 0) + 2.0;
         }
         if (winners.length >= 2) {
           cumulativeCuts[winners[1]['playerId']] = (cumulativeCuts[winners[1]['playerId']] ?? 0) + 1.0;
         }
         if (winners.length >= 3) {
           cumulativeCuts[winners[2]['playerId']] = (cumulativeCuts[winners[2]['playerId']] ?? 0) + 0.5;
         }
      }
    }
  }

  Future<String> _seedSeason() async {
    final repo = ref.read(seasonsRepositoryProvider);
    final season = Season(
      id: 'demo_season_2025_2026',
      name: 'Demo Season 25-26',
      year: 2026,
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2026, 12, 31),
      status: SeasonStatus.active,
      isCurrent: true,
      leaderboards: [
        LeaderboardConfig.orderOfMerit(
          id: 'oom_demo_2026',
          name: 'Order of Merit',
          source: OOMSource.position,
          appearancePoints: 2,
          positionPointsMap: {1: 25, 2: 18, 3: 15, 4: 12, 5: 10, 6: 8, 7: 6, 8: 4, 9: 2, 10: 1},
        ),
        LeaderboardConfig.bestOfSeries(
          id: 'best_5_demo_2026',
          name: 'Best of 5 Series',
          bestN: 5,
          metric: BestOfMetric.stableford,
        ),
      ],
    );

    // Use a try-catch for deletions as it might not exist
    try { await repo.deleteSeason(season.id); } catch (_) {}
    await repo.addSeason(season);
    await repo.setCurrentSeason(season.id);
    return season.id;
  }

  Future<void> _seedMembers() async {
    final repo = ref.read(membersRepositoryProvider);
    final existing = await repo.getMembers();
    if (existing.length >= 60) return;

    final firstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson'];

    for (int i = 0; i < 60; i++) {
        final fName = firstNames[i % firstNames.length];
        final lName = lastNames[(i / firstNames.length).floor() % lastNames.length];
        
        String? role;
        if (i == 0) role = 'President';
        if (i == 1) role = 'Captain';
        if (i == 2) role = 'Secretary';
        if (i == 3) role = 'Treasurer';

        double hc;
        if (i < 5) {
          hc = 1.0 + _random.nextDouble() * 6;
        } else if (i < 25) {
          hc = 10.0 + _random.nextDouble() * 8;
        } else if (i < 50) {
          hc = 19.0 + _random.nextDouble() * 8;
        } else {
          hc = 28.0 + _random.nextDouble() * 10;
        }

        final bio = i % 2 == 0 
           ? 'Loves a long drive and a cold beer after the round.' 
           : 'Founding member. Still waiting for my first hole-in-one.';

        await repo.addMember(Member(
          id: 'demo_m_$i',
          firstName: fName,
          lastName: lName,
          email: '${fName.toLowerCase()}.${lName.toLowerCase()}$i@demo.com',
          handicap: double.parse(hc.toStringAsFixed(1)),
          handicapId: 'WHS${300000 + i}',
          societyRole: role,
          status: MemberStatus.active,
          joinedDate: DateTime(2023, 1, 1).add(Duration(days: i * 5)),
          hasPaid: true,
          bio: bio,
          phone: '+44 7${100000000 + i}',
          address: 'Golf View, Demo Town, DG1 1AA',
        ));
    }
  }

  Future<List<Course>> _seedCourses() async {
    final repo = ref.read(courseRepositoryProvider);
    final List<Course> courses = [];
    final names = ['St Andrews', 'Pebble Beach', 'TPC Sawgrass', 'Augusta', 'Royal County Down', 'Muirfield', 'Shinnecock Hills', 'Oakmont', 'Cypress Point', 'Pine Valley', 'Royal Melbourne'];

    for (int i = 0; i < 11; i++) {
      final course = Course(
        id: 'demo_c_$i',
        name: names[i],
        address: 'Golf Coast, Demo Land',
        isGlobal: false,
        tees: [
          TeeConfig(
            name: 'White',
            rating: 70.0 + i % 5,
            slope: 120 + (i * 3) % 40,
            holePars: List.generate(18, (h) => [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5][h]),
            holeSIs: _generateSI(),
            yardages: List.generate(18, (h) => 150 + _random.nextInt(350)),
          ),
        ],
      );
      await repo.saveCourse(course);
      courses.add(course);
    }
    return courses;
  }

  List<int> _generateSI() {
    final sis = List.generate(18, (i) => i + 1);
    sis.shuffle(_random);
    return sis;
  }

  Future<List<Map<String, dynamic>>> _createFullEvent({
    required String seasonId,
    required Course course,
    required String title,
    required DateTime date,
    required CompetitionFormat format,
    required bool isInvitational,
    CompetitionSubtype subtype = CompetitionSubtype.none,
    required List<Member> members,
    required Map<String, double> appliedCuts,
    required EventStatus status,
    bool isMultiDay = false,
    DateTime? endDate,
  }) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    final event = GolfEvent(
      id: 'demo_ev_${title.replaceAll(' ', '_').toLowerCase()}',
      title: title,
      seasonId: seasonId,
      date: date,
      endDate: endDate,
      isMultiDay: isMultiDay,
      teeOffTime: date.copyWith(hour: 9),
      status: status,
      isInvitational: isInvitational,
      courseId: course.id,
      courseName: course.name,
      selectedTeeName: 'White',
      courseConfig: {
        'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': course.tees.first.holePars[i],
          'si': course.tees.first.holeSIs[i],
        }),
        'par': course.tees.first.holePars.fold(0, (a, b) => a + b),
        'slope': course.tees.first.slope,
        'rating': course.tees.first.rating,
      },
      hasBreakfast: true,
      hasLunch: _random.nextBool(),
      hasDinner: true,
      availableBuggies: 20,
      maxParticipants: 60,
      description: 'A fantastic day of competitive golf at ${course.name}. Join us for 18 holes of $format followed by a group dinner and prize giving ceremony.',
      registrationDeadline: date.subtract(const Duration(days: 7)),
      memberCost: 45.0 + _random.nextInt(20),
      guestCost: 55.0 + _random.nextInt(20),
      breakfastCost: 12.0,
      lunchCost: 15.0,
      dinnerCost: 25.0,
      buggyCost: 30.0,
      dressCode: 'Soft spikes required. Smart casual for dinner.',
      facilities: ['Driving Range', 'Pro Shop', 'Putting Green', 'Buggy Hire'],
      dinnerLocation: 'The Clubhouse Restaurant',
    );

    // 1. Build Registration Matrix (60 Players)
    final List<EventRegistration> regs = [];
    for (int i = 0; i < 55; i++) {
        final m = members[i];
        
        // Distribution Logic:
        // 0-35: Confirmed Members (Golf)
        // 36-40: Confirmed Members + Confirmed Guests (Golf)
        // 41-45: Waitlisted Members (Golf)
        // 46-49: Withdrawn Members
        // 50-54: Dinner Only Members
        
        bool attendingGolf = i < 46;
        bool attendingDinner = true;
        String? status;
        
        if (i >= 46 && i <= 49) {
          status = 'withdrawn';
          attendingGolf = false; // Withdrawn people don't play
        } else if (i >= 41 && i <= 45) {
          status = 'waitlist';
        } else if (i >= 50) {
          attendingGolf = false; // Dinner only
        } else {
          status = 'confirmed';
        }

        var reg = EventRegistration(
          memberId: m.id,
          memberName: m.displayName,
          attendingGolf: attendingGolf,
          attendingBreakfast: attendingGolf && _random.nextBool(),
          attendingLunch: attendingGolf && event.hasLunch && _random.nextBool(),
          attendingDinner: attendingDinner,
          needsBuggy: attendingGolf && i < 15,
          hasPaid: i < 45,
          isConfirmed: status == 'confirmed',
          handicap: m.handicap,
          registeredAt: date.subtract(Duration(days: 30 - (i % 20))),
          statusOverride: status,
          dietaryRequirements: i % 10 == 0 ? 'Vegetarian' : null,
        );

        // Add Guests for 36-40
        if (i >= 36 && i <= 40) {
          reg = reg.copyWith(
            guestName: 'Guest of ${m.lastName}',
            guestHandicap: '24.0',
            guestIsConfirmed: true,
            guestAttendingDinner: true,
            guestNeedsBuggy: _random.nextBool(),
          );
        }

        regs.add(reg);
    }

    final updatedEvent = event.copyWith(registrations: regs);
    await eventRepo.addEvent(updatedEvent);

    await compRepo.addCompetition(Competition(
      id: updatedEvent.id,
      name: title,
      type: CompetitionType.event,
      status: status == EventStatus.completed ? CompetitionStatus.closed : CompetitionStatus.published,
      rules: CompetitionRules(format: format, subtype: subtype, handicapAllowance: 0.95),
      startDate: date,
      endDate: date,
    ));

    // 2. Generate Grouping
    final items = RegistrationLogic.getSortedItems(updatedEvent);
    final confirmed = items.where((p) => p.isConfirmed && p.registration.attendingGolf).toList();
    final List<TeeGroup> groups = [];
    for (int i = 0; i < (confirmed.length / 4).ceil(); i++) {
        groups.add(TeeGroup(
          index: i,
          teeTime: updatedEvent.teeOffTime!.add(Duration(minutes: i * 10)),
          players: confirmed.skip(i * 4).take(4).map((p) {
            final m = p.isGuest ? null : members.firstWhereOrNull((m) => m.id == p.registration.memberId);
            final hc = p.isGuest ? 18.0 : (m?.handicap ?? 18.0);
            return TeeGroupParticipant(
              registrationMemberId: p.registration.memberId,
              name: p.name,
              isGuest: p.isGuest,
              handicapIndex: hc,
              playingHandicap: hc, 
              needsBuggy: p.needsBuggy,
              status: RegistrationStatus.confirmed,
            );
          }).toList(),
        ));
    }

    // 3. Generate Scores with Cuts
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    final List<Map<String, dynamic>> results = [];
    
    for (var group in groups) {
      for (var player in group.players) {
        final baseHc = player.playingHandicap;
        final cut = appliedCuts[player.registrationMemberId] ?? 0.0;
        final playingHc = baseHc - cut;

        final List<int> scores = [];
        int strokes = 0;
        int pts = 0;

        for (int h = 0; h < 18; h++) {
          final par = updatedEvent.courseConfig['holes'][h]['par'];
          final si = updatedEvent.courseConfig['holes'][h]['si'];
          
          final r = _random.nextDouble() * 10;
          int s = (r < (playingHc < 12 ? 4.5 : 2.5)) ? par : (r < 8.5 ? par + 1 : par + 2);
          if (r < 0.05) s = par - 1;

          scores.add(s);
          strokes += s;
          
          int shots = (playingHc / 18).floor();
          if (playingHc % 18 >= si) shots++;
          pts += max(0, par - (s - shots) + 2);
        }

        if (status == EventStatus.completed) {
          await scoreRepo.addScorecard(Scorecard(
            id: '',
            competitionId: updatedEvent.id,
            roundId: 'round_1',
            entryId: player.isGuest ? '${player.registrationMemberId}_guest' : player.registrationMemberId,
            submittedByUserId: 'system_seeder',
            status: ScorecardStatus.finalScore,
            holeScores: scores,
            points: pts,
            grossTotal: strokes,
            netTotal: (strokes - playingHc).round(),
            createdAt: date,
            updatedAt: date,
          ));

          results.add({
            'memberId': player.isGuest ? null : player.registrationMemberId, // stats provider needs memberId or guest naming
            'playerId': player.isGuest ? '${player.registrationMemberId}_guest' : player.registrationMemberId,
            'playerName': player.name,
            'points': pts,
            'position': 0, // Assigned below
          });
        }
      }
    }

    results.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    for (int i = 0; i < results.length; i++) {
      results[i]['position'] = i + 1;
    }

    await eventRepo.updateEvent(updatedEvent.copyWith(
      grouping: {
        'groups': groups.map((g) => g.toJson()).toList(), 
        'locked': status == EventStatus.completed, 
        'isPublished': true
      },
      results: status == EventStatus.completed ? results : [],
      isGroupingPublished: true,
    ));

    if (status == EventStatus.completed) {
      final comp = await compRepo.getCompetition(updatedEvent.id);
      final cards = await ref.read(scorecardRepositoryProvider).watchScorecards(updatedEvent.id).first;
      
      final stats = EventAnalysisEngine.calculateFinalStats(
        scorecards: cards,
        event: updatedEvent,
        competition: comp,
      );
      
      await eventRepo.updateEvent(updatedEvent.copyWith(
        finalizedStats: stats,
        isStatsReleased: true,
        isScoringLocked: true,
      ));
      
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(seasonId);
    }

    return results;
  }
}


final demoSeedingServiceProvider = Provider((ref) => DemoSeedingService(ref));
