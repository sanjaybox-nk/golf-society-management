import 'dart:math';
import 'package:flutter/foundation.dart';
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
import '../utils/handicap_calculator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/debug/presentation/state/debug_providers.dart';
import 'persistence_service.dart';

class DemoSeedingService {
  final Ref ref;
  final Random _random = Random();
  DemoSeedingService(this.ref);
  
  // Male Names (50)
  static const maleFirstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Daniel', 'Matthew', 'Anthony', 'Donald', 'Mark', 'Paul', 'Steven', 'Andrew', 'Kenneth', 'Joshua', 'Kevin', 'Brian', 'George', 'Edward', 'Ronald', 'Timothy', 'Jason', 'Jeffrey', 'Ryan', 'Jacob'];
  
  // Female Names (20)
  static const femaleFirstNames = ['Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 'Nancy', 'Lisa', 'Margaret', 'Betty', 'Sandra', 'Ashley', 'Dorothy', 'Kimberly', 'Emily', 'Donna'];
  
  static const lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King'];

  Future<void> wipeAndSeed() async {
    // [FIX] Clear all local preferences AND explicitly reset providers
    await ref.read(persistenceServiceProvider).clear();
    
    // Invalidate the master Lab Mode switch. 
    // This will rebuild and read 'false' (null) from cleared persistence.
    // All other overrides watch this provider, so they will also reset to null.
    ref.invalidate(labModeEnabledProvider); 
    
    await _wipeAllData();
    await seedDemoSeason();
  }

  Future<void> _wipeAllData() async {
    final firestore = FirebaseFirestore.instance;
    // Order matters? Not really for NoSQL, but good to clean children first if relational
    final collections = [
      'scorecards', 
      'registrations', // Subcollection? No, usually root or inside events. 
      'events', 
      'competitions', 
      'seasons', 
      'members',
      'leaderboard_templates',
      'notifications'
    ];
    
    // Note: This won't delete subcollections automatically in Firestore!
    // But our structure seems to be mostly root collections.
    // 'registrations' are likely inside 'events' document in 'golf_event.dart' (embedded), so deleting events is enough.
    // Leaderboard standings are subcollections of seasons? 
    // Let's check Season model. Leaderboards are embedded in Season?
    // Leaderboard STANDINGS are likely a subcollection.
    
    // [FIX] Explicitly delete subcollections for events (registrants)
    final eventsSnapshot = await firestore.collection('events').get();
    for (var doc in eventsSnapshot.docs) {
      final sub = await doc.reference.collection('registrations').get();
      if (sub.docs.isNotEmpty) {
        var batch = firestore.batch();
        int count = 0;
        for (var subDoc in sub.docs) {
          batch.delete(subDoc.reference);
          count++;
          if (count >= 400) {
            await batch.commit();
            count = 0;
            batch = firestore.batch();
          }
        }
        if (count > 0) await batch.commit();
      }
    }

    for (var collection in collections) {
      debugPrint('Processing collection: $collection');
      final snapshot = await firestore.collection(collection).get();
      debugPrint('Found ${snapshot.docs.length} docs in $collection');
      try {
        if (snapshot.docs.isNotEmpty) {
          var batch = firestore.batch();
          int count = 0;
          for (var doc in snapshot.docs) {
            batch.delete(doc.reference);
            count++;
            if (count >= 400) { // Safety limit
               await batch.commit();
               count = 0;
               batch = firestore.batch();
            }
          }
          if (count > 0) await batch.commit();
          debugPrint('Wiped $collection successfully');
        }
      } catch (e) {
        debugPrint('Error wiping $collection: $e');
      }
    }
    
    // Explicitly handle leaderboard_standings subcollection if it exists under seasons
    // We can iterate seasons before deleting them?
    // Actually, if we delete the season document, the subcollections technically remain orphaned but inaccessible via the app.
    // For a demo reset, that's acceptable as we won't query them without the parent season ID.
    // But to be thorough:
    /*
    final seasons = await firestore.collection('seasons').get();
    for (var season in seasons.docs) {
       // potential subcollections cleanup
    }
    */
  }

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
      (title: 'October Stableford', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'November Cup', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 11, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Winter Series #1', format: CompetitionFormat.matchPlay, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 11, 20), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Post-Christmas Scramble', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 12, 28), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'New Year Bowl', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 1, 10), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Season Qualifier', format: CompetitionFormat.maxScore, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Masters Simulation', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 10), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2026, 2, 11)),
      (title: 'Foursomes Invitational', format: CompetitionFormat.stroke, isInvitational: true, subtype: CompetitionSubtype.foursomes, date: DateTime(2026, 2, 12), status: EventStatus.completed, isMultiDay: false, endDate: null),
      
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
        LeaderboardConfig.eclectic(
          id: 'eclectic_demo_2026',
          name: 'Season Eclectic',
          metric: EclecticMetric.strokes,
        ),
        LeaderboardConfig.markerCounter(
          id: 'birdie_tree_demo_2026',
          name: 'Birdie Tree',
          targetTypes: {MarkerType.birdie, MarkerType.eagle, MarkerType.albatross},
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
    // [FIX] Removed early return to ensure clean seeding after wipe
    // final existing = await repo.getMembers();
    // if (existing.length >= 75) return; 

    // 1. Create Hero Member (Sanjay Patel)
    await repo.addMember(Member(
      id: 'demo_hero_sanjay',
      firstName: 'Sanjay',
      lastName: 'Patel',
      email: 'sanjay.patel@demo.com',
      handicap: 14.5,
      handicapId: 'WHS888888',
      societyRole: 'Admin',
      status: MemberStatus.active,
      joinedDate: DateTime(2023, 1, 1),
      hasPaid: true,
      gender: 'Male',
      bio: 'The Creator. Loves a tech-infused round of golf.',
      phone: '+44 7700 900000',
      address: '123 Code Lane, Developer City',
    ));

    // 2. Seed Remaining 74 Members
    // Target: 20 Females, 54 Males (Total 74 + Sanjay = 75)

    
    for (int i = 0; i < 74; i++) {
        // Determine Gender (First 20 are female for simplicity in loop, or interleaved)
        // Let's interleave to avoid blocks: every 3rd or 4th is female until we hit 20?
        // Or just first 20. Let's do first 20 for guaranteed count.
        bool isFemale = i < 20;
        
        final fNameList = isFemale ? femaleFirstNames : maleFirstNames;
        final fName = fNameList[i % fNameList.length];
        
        // Randomize last name logic a bit more
        final lName = lastNames[(i + _random.nextInt(10)) % lastNames.length];
        
        String? role;
        if (i == 20) role = 'President'; // Male after females
        if (i == 21) role = 'Captain';
        if (i == 0) role = 'Social Sec'; // Female officer

        // Handicap Logic
        double hc;
        if (i < 10) { // Low handicappers
          hc = 1.0 + _random.nextDouble() * 5; // 1-6
        } else if (i < 40) { // Mid
          hc = 6.0 + _random.nextDouble() * 14; // 6-20
        } else { // High
          hc = 20.0 + _random.nextDouble() * 16; // 20-36
        }
        
        // Women typically have slightly higher distribution in mixed societies, adjust slightly?
        if (isFemale) hc += 2.0; 

        final bio = i % 3 == 0 
           ? 'Loves a long drive and a cold beer after the round.' 
           : (i % 3 == 1 ? 'Founding member. Still waiting for my first hole-in-one.' : 'Just happy to be out of the office.');

        await repo.addMember(Member(
          id: 'demo_m_$i',
          firstName: fName,
          lastName: lName,
          email: '${fName.toLowerCase()}.${lName.toLowerCase()}$i@demo.com',
          handicap: double.parse(hc.toStringAsFixed(1)),
          handicapId: 'WHS${300000 + i}',
          societyRole: role,
          status: MemberStatus.active,
          joinedDate: DateTime(2023, 1, 1).add(Duration(days: i * 3)),
          hasPaid: true,
          gender: isFemale ? 'Female' : 'Male',
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
      availableBuggies: 6,
      maxParticipants: 40,
      description: 'A fantastic day of competitive golf at ${course.name}. Join us for 18 holes of ${format.name.toUpperCase()} followed by a group dinner and prize giving ceremony.',
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

    // 1. Build Registration Matrix (Vary between 25-45 Players)
    final List<EventRegistration> regs = [];
    final targetRegCount = 30 + _random.nextInt(15); // 30 to 45 (Slightly higher density)
    
    // Always include Hero Member (Sanjay Patel)
    final hero = members.firstWhereOrNull((m) => m.id == 'demo_hero_sanjay');
    if (hero != null) {
      regs.add(EventRegistration(
        memberId: hero.id,
        memberName: hero.displayName,
        attendingGolf: true,
        attendingBreakfast: true,
        attendingLunch: true,
        attendingDinner: true,
        needsBuggy: false,
        hasPaid: true,
        isConfirmed: true, // Always confirmed
        handicap: hero.handicap,
        registeredAt: date.subtract(const Duration(days: 25)),
        statusOverride: 'confirmed',
      ));
    }

    for (int i = 0; i < targetRegCount; i++) {
        // Skip if this random pick is the hero (already added)
        final m = members[i % members.length];
        if (m.id == 'demo_hero_sanjay') continue;
        
        bool isWithdrawn = _random.nextDouble() < 0.08; // 8% chance
        bool attendingGolf = !isWithdrawn && regs.length < 40; // Cap at 40
        bool attendingDinner = true;
        String? status;
        
        if (isWithdrawn) {
          status = 'withdrawn';
          attendingGolf = false;
        } else if (regs.length >= 40) {
          status = 'waitlist';
        } else {
          status = 'confirmed';
        }

        // Simulating "Dinner Only" guests occasionally
        if (!attendingGolf && !isWithdrawn && _random.nextDouble() < 0.2) {
           // Keep attendingGolf = false, attendingDinner = true
        } else if (!attendingGolf && !isWithdrawn) {
           // If not playing and not dinner only, skip (waitlist logic handles excess)
        }

        var reg = EventRegistration(
          memberId: m.id,
          memberName: m.displayName,
          attendingGolf: attendingGolf,
          attendingBreakfast: attendingGolf && _random.nextBool(),
          attendingLunch: attendingGolf && event.hasLunch && _random.nextBool(),
          attendingDinner: attendingDinner,
          needsBuggy: attendingGolf && _random.nextDouble() < 0.2, // 20% buggy usage
          hasPaid: attendingGolf,
          isConfirmed: status == 'confirmed',
          handicap: m.handicap,
          registeredAt: date.subtract(Duration(days: 30 - (i % 20))),
          statusOverride: status,
          dietaryRequirements: i % 15 == 0 ? 'Vegetarian' : null,
        );

        // Add Guests Logic (occasional)
        if (regs.length < 38 && i % 10 == 0) { // Every 10th person brings a guest if space
          final isFemaleGuest = _random.nextBool();
          final gFNameList = isFemaleGuest ? femaleFirstNames : maleFirstNames;
          final gFName = gFNameList[_random.nextInt(gFNameList.length)];
          final gLName = lastNames[_random.nextInt(lastNames.length)];
          
          reg = reg.copyWith(
            guestName: '$gFName $gLName',
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

    final rules = CompetitionRules(
      format: format, 
      subtype: subtype, 
      handicapAllowance: subtype == CompetitionSubtype.fourball ? 0.85 : (subtype == CompetitionSubtype.foursomes ? 0.50 : 0.95),
      mode: (format == CompetitionFormat.scramble || subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes) ? CompetitionMode.teams : CompetitionMode.singles,
      teamSize: format == CompetitionFormat.scramble ? (2 + _random.nextInt(3)) : 4,
      underlyingFormat: format == CompetitionFormat.scramble 
          ? (_random.nextBool() ? CompetitionFormat.stroke : CompetitionFormat.stableford)
          : CompetitionFormat.stroke,
      teamHandicapCap: format == CompetitionFormat.scramble && _random.nextBool() ? 18 : null,
    );

    await compRepo.addCompetition(Competition(
      id: updatedEvent.id,
      name: title,
      type: CompetitionType.event,
      status: status == EventStatus.completed ? CompetitionStatus.closed : CompetitionStatus.published,
      rules: rules,
      startDate: date,
      endDate: date,
    ));

    // 2. Generate Grouping using GroupingService (Admin Quality)
    final items = RegistrationLogic.getSortedItems(updatedEvent, includeWithdrawn: true);
    
    // Prepare handicaps map for service
    final Map<String, double> memberHandicaps = {};
    for (var m in members) {
      memberHandicaps[m.id] = m.handicap;
    }

    // Strategy: 'progressive' for events (Low HC first), 'balanced' for Invitational
    final strategy = isInvitational ? 'balanced' : 'progressive';

    final groups = GroupingService.generateInitialGrouping(
      event: updatedEvent,
      participants: items,
      previousEventsInSeason: [], // Could pass history if available, but optional for demo seed
      memberHandicaps: memberHandicaps,
      prioritizeBuggyPairing: true,
      strategy: strategy,
      useWhs: true,
      rules: CompetitionRules(format: format, subtype: subtype),
    );

    // 3. Generate Scores with Cuts
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    await scoreRepo.deleteAllScorecards(updatedEvent.id);

    final List<Map<String, dynamic>> results = [];
    final isStableford = rules.format == CompetitionFormat.stableford;
    final mode = rules.mode;
    
    for (var group in groups) {
      // General Team/Pair Split logic
      List<List<TeeGroupParticipant>> teams = [];
      final teamSize = rules.teamSize;
      
      int effectiveTeamSize = 1;
      if (mode == CompetitionMode.pairs) {
        effectiveTeamSize = 2;
      } else if (mode == CompetitionMode.teams) {
        effectiveTeamSize = teamSize;
      }

      if (effectiveTeamSize <= 1) {
        for (var p in group.players) { teams.add([p]); }
      } else {
        for (int i = 0; i < group.players.length; i += effectiveTeamSize) {
           teams.add(group.players.skip(i).take(effectiveTeamSize).toList());
        }
      }

      for (var team in teams) {
         if (team.isEmpty) continue;

         // [NEW] Fourball Handling: Individual Cards
         if (subtype == CompetitionSubtype.fourball) {
            final isInternalStableford = format == CompetitionFormat.stableford;

            for (var p in team) {
               final memberId = p.registrationMemberId;
               double index = 18.0;
               if (p.isGuest) {
                  final reg = regs.firstWhereOrNull((r) => r.memberId == memberId);
                  index = double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
               } else {
                  final member = members.firstWhereOrNull((m) => m.id == memberId);
                  index = member?.handicap ?? 18.0;
               }

               // Calculate PHC (85% already in rules)
               final phc = HandicapCalculator.calculatePlayingHandicap(
                  handicapIndex: index,
                  rules: rules, 
                  courseConfig: updatedEvent.courseConfig,
               );

               final holeScores = <int?>[];
               int grossTotal = 0;
               int pointsTotal = 0;

               // Iterate holes
               final holes = updatedEvent.courseConfig['holes'] as List;
               for (var hole in holes) {
                  final par = (hole['par'] as num).toInt();
                  final si = (hole['si'] as num).toInt();
                  
                  int shots = (phc / 18).floor();
                  if (phc % 18 >= si) shots++;

                  // Random score generation (Net Par average)
                  final rand = _random.nextDouble();
                  // [NEW] 10% chance of "Pick-up" (null score) for Hardening
                  if (rand < 0.10) {
                     holeScores.add(null);
                     continue; 
                  }

                  int netScore;
                  if (rand < 0.25) {
                    netScore = par - 1; // Net Birdie
                  } else if (rand < 0.80) {
                    netScore = par; // Net Par
                  } else if (rand < 0.95) {
                    netScore = par + 1; // Net Bogey
                  } else {
                    netScore = par + 2; // Net Double
                  }
                  
                  final gross = netScore + shots;
                  holeScores.add(gross);
                  grossTotal += gross;
                  
                  if (isInternalStableford) {
                     pointsTotal += (par - (gross - shots) + 2).clamp(0, 10).toInt();
                  }
               }

               await scoreRepo.addScorecard(Scorecard(
                  id: 'seed_${updatedEvent.id}_$memberId',
                  competitionId: updatedEvent.id,
                  roundId: '1',
                  entryId: memberId,
                  submittedByUserId: 'system_seed',
                  status: ScorecardStatus.finalScore,
                  holeScores: holeScores,
                  points: isInternalStableford ? pointsTotal : null,
                  // gross: grossTotal, // Removed as not in constructor
                  netTotal: grossTotal - phc.round(), // Ensure integer
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
               ));
            }
            continue; // Ensure we skip the Team Shared Card logic below
         }

         final List<int> teamHoleScores = [];
         int teamGross = 0;
         int teamPts = 0;
         
         // Team PHC: Use the standardized calculation logic
         final teamPhc = HandicapCalculator.calculateTeamHandicap(
           individualIndices: team.map((p) {
              if (p.isGuest) {
                final reg = regs.firstWhereOrNull((r) => r.memberId == p.registrationMemberId);
                return double.tryParse(reg?.guestHandicap ?? '18') ?? 18.0;
              } else {
                final member = members.firstWhereOrNull((m) => m.id == p.registrationMemberId);
                return member?.handicap ?? 18.0;
              }
           }).toList(), 
           rules: rules, 
           courseConfig: updatedEvent.courseConfig,
         ).toDouble();

         final cut = appliedCuts[team.first.registrationMemberId] ?? 0.0;
         final playingHc = teamPhc - cut;

         for (int h = 0; h < 18; h++) {
           final par = (updatedEvent.courseConfig['holes'][h]['par'] as num? ?? 4).toInt();
           final si = (updatedEvent.courseConfig['holes'][h]['si'] as num? ?? 18).toInt();
           
           double performanceFactor = _random.nextDouble();
           if (team.any((p) => p.registrationMemberId == 'demo_hero_sanjay')) {
              performanceFactor *= 0.8; 
           }

           int s = par;
            if (playingHc < 8) { // Good team/player
               if (performanceFactor < 0.3) {
                 s = par - 1;
               } else if (performanceFactor < 0.8) {
                 s = par;
               } else {
                 s = par + 1;
               }
            } else { // Average
               if (performanceFactor < 0.2) {
                 s = par - 1;
               } else if (performanceFactor < 0.6) {
                 s = par;
               } else if (performanceFactor < 0.9) {
                 s = par + 1;
               } else {
                 s = par + 2;
               }
            }
           
           teamHoleScores.add(s);
           teamGross += s;
           
           int shots = (playingHc / 18).floor();
            if (playingHc % 18 >= si) {
              shots++;
            }
           teamPts += max(0, par - (s - shots) + 2);
         }

         final int teamNet = teamGross - playingHc.round();

         // Apply this result to all players in the team
         for (var player in team) {
           if (status == EventStatus.completed) {
             final entryId = player.isGuest ? '${player.registrationMemberId}_guest' : player.registrationMemberId;
             
             await scoreRepo.addScorecard(Scorecard(
               id: '',
               competitionId: updatedEvent.id,
               roundId: 'round_1',
               entryId: entryId,
               submittedByUserId: 'system_seeder',
               status: ScorecardStatus.finalScore,
               holeScores: teamHoleScores,
               shotAttributions: format == CompetitionFormat.scramble ? { for (var h in List.generate(18, (i) => i + 1)) h : team[_random.nextInt(team.length)].registrationMemberId } : {}, points: teamPts,
               grossTotal: teamGross,
               netTotal: teamNet,
               createdAt: date,
               updatedAt: date,
             ));

             results.add({
               'memberId': player.isGuest ? null : player.registrationMemberId, 
               'playerId': entryId,
               'playerName': player.name,
               'points': teamPts,
               'position': 0, 
               'netTotal': teamNet,
               'grossTotal': teamGross,
               'holeScores': teamHoleScores,
               'phc': playingHc,
               'displayValue': isStableford ? teamPts : teamNet,
             });
           }
         }
      }
    }
    // Sort Results
    results.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    for (int i = 0; i < results.length; i++) {
      results[i]['position'] = i + 1;
    }

    // Consolidate updates to prevent lost updates
    var finalEvent = updatedEvent.copyWith(
      grouping: {
        'groups': groups.map((g) => g.toJson()).toList(), 
        'locked': status == EventStatus.completed, 
        'isPublished': true
      },
      results: status == EventStatus.completed ? results : [],
      isGroupingPublished: true,
      isScoringLocked: status == EventStatus.completed,
    );
    
    if (status == EventStatus.completed) {
      final comp = await compRepo.getCompetition(updatedEvent.id);
      final cards = await ref.read(scorecardRepositoryProvider).watchScorecards(updatedEvent.id).first;
      
      final stats = EventAnalysisEngine.calculateFinalStats(
        scorecards: cards,
        event: finalEvent, // Use the event that now has groupings/results
        competition: comp,
      );
      
      finalEvent = finalEvent.copyWith(
        finalizedStats: stats,
        isStatsReleased: true,
      );
    }

    await eventRepo.updateEvent(finalEvent);

    if (status == EventStatus.completed) {
      await ref.read(leaderboardInvokerServiceProvider).recalculateAll(seasonId);
    }

    return results;
  }
}

final demoSeedingServiceProvider = Provider((ref) => DemoSeedingService(ref));
