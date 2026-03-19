import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/course_config.dart' as cfg;

import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/competitions/services/leaderboard_invoker_service.dart';
import 'persistence_service.dart';

/// Unified Seeding Service for both basic and advanced demo data.
class SeedingService {
  final Ref ref;
  final Random _random = Random(42); // Fixed seed for consistent demo data
  
  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await _seedCourses();
  }

  Future<void> seedRegistrations(String eventId, {bool forceResetStatus = false}) async {
    // Basic registration seeding or just use full demo seeder logic
    // For now, mapping this to a basic version if still needed, but seedFullDemoData is preferred.
  }

  // Male Names (50)
  static const maleFirstNames = [
    'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 
    'Daniel', 'Matthew', 'Anthony', 'Donald', 'Mark', 'Paul', 'Steven', 'Andrew', 'Kenneth', 'Joshua', 
    'Kevin', 'Brian', 'George', 'Edward', 'Ronald', 'Timothy', 'Jason', 'Jeffrey', 'Ryan', 'Jacob',
    'Gary', 'Nicholas', 'Eric', 'Stephen', 'Jonathan', 'Larry', 'Justin', 'Scott', 'Brandon', 'Frank',
    'Benjamin', 'Gregory', 'Samuel', 'Raymond', 'Patrick', 'Alexander', 'Jack', 'Dennis', 'Jerry', 'Tyler'
  ];
  
  // Female Names (25)
  static const femaleFirstNames = [
    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 
    'Nancy', 'Lisa', 'Margaret', 'Betty', 'Sandra', 'Ashley', 'Dorothy', 'Kimberly', 'Emily', 'Donna',
    'Michelle', 'Carol', 'Amanda', 'Melissa', 'Deborah'
  ];
  
  static const lastNames = [
    'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 
    'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 
    'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King',
    'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
    'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards', 'Collins'
  ];

  /// The main entry point for seeding high-quality demo data.
  Future<void> seedFullDemoData() async {
    try {
      debugPrint('--- STARTING UNIFIED WIPE AND SEED ---');
      await ref.read(persistenceServiceProvider).clear();
      
      debugPrint('Wiping existing Firestore data...');
      await clearAllData();
      debugPrint('Wipe completed.');

      debugPrint('Seeding new demo season...');
      await _seedDemoSeason();
      debugPrint('--- UNIFIED WIPE AND SEED COMPLETED ---');
    } catch (e, stack) {
      debugPrint('CRITICAL SEEDER FAILURE: $e');
      debugPrint(stack.toString());
    }
  }

  /// Clears all relevant Firestore collections.
  Future<void> clearAllData() async {
    final firestore = FirebaseFirestore.instance;
    final collections = [
      'scorecards', 
      'events', 
      'competitions', 
      'seasons', 
      'members',
      'notifications'
    ];
    
    // Explicitly delete subcollections for events (registrations)
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

    // Delete root collections
    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isNotEmpty) {
        var batch = firestore.batch();
        int count = 0;
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
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
  }

  Future<void> _seedDemoSeason() async {
    // 1. Setup Season
    final seasonId = await _seedSeason();

    // 2. Seed Members
    await _seedMembers();
    final members = await ref.read(membersRepositoryProvider).getMembers();

    // 3. Seed Courses
    final courses = await _seedCourses();

    // 4. Fetch user templates to influence seeding
    final userTemplates = await ref.read(competitionsRepositoryProvider).getTemplates();

    // 5. Track Society Cuts (Member ID -> Cumulative Cut)
    final Map<String, double> cumulativeCuts = {};

    // 6. Seed Events in Chronological order to apply cuts
    final List<({String title, CompetitionFormat format, bool isInvitational, CompetitionSubtype subtype, DateTime date, EventStatus status, bool isMultiDay, DateTime? endDate})> eventPlan = [
      // 2025 Historical Events
      (title: '2025 Season Opener', format: CompetitionFormat.stroke, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 10), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Spring Classic 25', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 4, 15), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Masters Week Sim', format: CompetitionFormat.maxScore, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 5, 20), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Summer Stability Cup', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.fourball, date: DateTime(2025, 7, 12), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Autumn Match Play', format: CompetitionFormat.matchPlay, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 9, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The October Scramble', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 18), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Winter Series Final 25', format: CompetitionFormat.stroke, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 12, 5), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Christmas Classic', format: CompetitionFormat.stableford, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 12, 28), status: EventStatus.completed, isMultiDay: false, endDate: null),
      
      // 2026 - Current Active Season
      (title: 'Happy New Year Bowl', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 1, 10), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'January Qualifier', format: CompetitionFormat.maxScore, isInvitational: true, subtype: CompetitionSubtype.none, date: DateTime(2026, 1, 25), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'Valentine\'s Scramble', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.fourball, date: DateTime(2026, 2, 14), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'The Winter Major', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 2, 27), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2026, 2, 28)),
      (title: 'St Patricks Day Special', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 3, 17), status: EventStatus.completed, isMultiDay: false, endDate: null),
      (title: 'LIVE: St Georges Day Opener', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime.now(), status: EventStatus.inPlay, isMultiDay: false, endDate: null),
      (title: 'The April Fools Cup', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 4, 1), status: EventStatus.published, isMultiDay: false, endDate: null),
      (title: 'Algarve Tour 2026', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 5, 20), status: EventStatus.published, isMultiDay: true, endDate: DateTime(2026, 5, 22)),
      (title: 'Season Finale: Championship', format: CompetitionFormat.stableford, isInvitational: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 6, 15), status: EventStatus.published, isMultiDay: false, endDate: null),
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
        templates: userTemplates,
        isMultiDay: config.isMultiDay,
        endDate: config.endDate,
        eventIndex: i,
      );

      if (!config.isInvitational && results.isNotEmpty) {
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

    // 10. RECALCULATE ALL LEADERBOARDS (Authoritative)
    await ref.read(leaderboardInvokerServiceProvider).recalculateAll(seasonId);

    // 11. Seed Society Overheads
    await _seedNonEventExpenses();
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

    try { await repo.deleteSeason(season.id); } catch (_) {}
    await repo.addSeason(season);
    await repo.setCurrentSeason(season.id);
    return season.id;
  }

  Future<void> _seedMembers() async {
    final repo = ref.read(membersRepositoryProvider);
    
    // Create Hero Member
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
      bio: 'The Society Founder. Passionate about technology and bringing the digital edge to the game of golf.',
      phone: '+44 7700 900000',
    ));

    final committeeRoles = {
       0: 'Chairman',
       1: 'Social Secretary',
       20: 'Treasurer',
       21: 'Captain',
       40: 'Handicap Secretary',
    };

    final bios = [
      'Short game specialist. Always finds the bunker on the 18th.',
      'Long hitter with a tendency to find the adjacent fairways.',
      'Putting maestro. Never met a three-putt they didn’t like.',
      'Classic swing, steady temperament. The backbone of the society.',
      'Fierce competitor. Lives for the Sunday singles.',
      'The eternal optimist. Every drive is a potential eagle.',
      'Strategic player. Knows every undulation of the home course.',
      'Social heartbeat of the club. More interested in the 19th hole.',
      'Relative newcomer with a rapidly falling handicap.',
      'Senior statesman. Plays the percentages with deadly accuracy.',
    ];

    for (int i = 0; i < 74; i++) {
        bool isFemale = i < 25;
        final fNameList = isFemale ? femaleFirstNames : maleFirstNames;
        final fName = fNameList[i % fNameList.length];
        
        // Ensure unique last name pairings
        final lName = lastNames[(i + (i ~/ 10)) % lastNames.length];
        
        final role = committeeRoles[i];
        final bio = bios[i % bios.length];

        double hc = (i < 10) ? (1.0 + _random.nextDouble() * 5) : ((i < 40) ? (6.0 + _random.nextDouble() * 14) : (20.0 + _random.nextDouble() * 16));
        if (isFemale) hc += 2.0; 

        await repo.addMember(Member(
          id: 'demo_m_$i',
          firstName: fName,
          lastName: lName,
          email: '${fName.toLowerCase()}.${lName.toLowerCase()}$i@demo.org',
          handicap: double.parse(hc.toStringAsFixed(1)),
          handicapId: 'WHS${300000 + i}',
          societyRole: role,
          status: MemberStatus.active,
          joinedDate: DateTime(2023, 1, 1).add(Duration(days: i * 3)),
          hasPaid: true,
          gender: isFemale ? 'Female' : 'Male',
          phone: '+44 7${100000000 + i}',
          bio: bio,
        ));
    }
  }

  Future<List<Course>> _seedCourses() async {
    final repo = ref.read(courseRepositoryProvider);
    final List<Course> courses = [];
    final names = [
      'St Andrews', 'Pebble Beach', 'TPC Sawgrass', 'Augusta', 
      'Royal County Down', 'Muirfield', 'Shinnecock Hills', 'Oakmont', 
      'Cypress Point', 'Pine Valley', 'Royal Melbourne',
      'Dom Pedro Old Course', 'Victoria Golf Course'
    ];
    
    final addresses = {
      'St Andrews': 'West Sands Rd, St Andrews KY16 9XL, Scotland',
      'Pebble Beach': '1700 17 Mile Dr, Pebble Beach, CA 93953, USA',
      'TPC Sawgrass': '110 Championship Way, Ponte Vedra Beach, FL 32082, USA',
      'Augusta': '2604 Washington Rd, Augusta, GA 30904, USA',
      'Royal County Down': '36 Golf Links Rd, Newcastle BT33 0AN, Northern Ireland',
      'Muirfield': 'Duncur Rd, Gullane EH31 2EG, Scotland',
      'Shinnecock Hills': '200 Tuckahoe Rd, Southampton, NY 11968, USA',
      'Oakmont': '1233 Hulton Rd, Oakmont, PA 15139, USA',
      'Cypress Point': '3150 17 Mile Dr, Pebble Beach, CA 93953, USA',
      'Pine Valley': '1 E Atlantic Ave, Pine Hill, NJ 08021, USA',
      'Royal Melbourne': 'Cheltenham Rd, Black Rock VIC 3193, Australia',
      'Dom Pedro Old Course': 'Volta do Parque 8125-507, Vilamoura, Portugal',
      'Victoria Golf Course': 'Av. dos Descobrimentos, 8125-507 Vilamoura, Portugal',
    };

    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      final holeData = _getCourseHoleData(name);
      
      final course = Course(
        id: 'demo_c_$i',
        name: name,
        address: addresses[name] ?? 'Golf Coast, Demo Land',
        isGlobal: false,
        tees: [
          TeeConfig(
            name: 'White',
            rating: 72.5, 
            slope: 132,
            holePars: holeData.pars, 
            holeSIs: holeData.si,
            yardages: holeData.yards, 
          ),
          TeeConfig(
            name: 'Yellow',
            rating: 71.0, 
            slope: 128, 
            holePars: holeData.pars,
            holeSIs: holeData.si,
            yardages: holeData.yards.map((y) => (y * 0.94).round()).toList(), 
          ),
          TeeConfig(
            name: 'Blue',
            rating: 70.0, 
            slope: 125, 
            holePars: holeData.pars,
            holeSIs: holeData.si,
            yardages: holeData.yards.map((y) => (y * 0.88).round()).toList(), 
          ),
          TeeConfig(
            name: 'Red',
            rating: 72.0, 
            slope: 124,
            holePars: holeData.pars, 
            holeSIs: holeData.si, 
            yardages: holeData.yards.map((y) => (y * 0.82).round()).toList(), 
          ),
        ],
      );
      await repo.saveCourse(course);
      courses.add(course);
    }
    return courses;
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
    required List<Competition> templates,
    bool isMultiDay = false,
    DateTime? endDate,
    int eventIndex = 0,
  }) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    final yellowTee = course.tees.firstWhere((t) => t.name == 'Yellow');

    var event = GolfEvent(
      id: 'demo_ev_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      title: title,
      seasonId: seasonId,
      date: date,
      endDate: endDate,
      isMultiDay: isMultiDay,
      regTime: date.copyWith(hour: 8),
      teeOffTime: date.copyWith(hour: 9),
      status: status,
      isInvitational: isInvitational,
      courseId: course.id,
      courseName: course.name,
      courseDetails: course.address,
      selectedTeeName: 'Yellow',
      selectedFemaleTeeName: 'Red',
      courseConfig: cfg.CourseConfig(
        tees: course.tees.map((t) => cfg.TeeConfig(
          name: t.name,
          rating: t.rating,
          slope: t.slope,
          holePars: t.holePars,
          holeSIs: t.holeSIs,
          yardages: t.yardages,
        )).toList(),
        selectedTeeName: 'Yellow',
        holes: yellowTee.holePars.asMap().entries.map((e) => cfg.CourseHole(
          hole: e.key + 1,
          par: e.value,
          si: yellowTee.holeSIs[e.key],
          yardage: yellowTee.yardages[e.key],
        )).toList(),
        par: yellowTee.holePars.fold<int>(0, (a, b) => a + b),
        slope: yellowTee.slope,
        rating: yellowTee.rating,
      ),
      hasBreakfast: true,
      hasLunch: _random.nextBool(),
      hasDinner: true,
      description: 'A fantastic day of competitive golf at ${course.name}. Join us for 18 holes of ${format.name} followed by a group dinner and prize giving ceremony. The course is in excellent condition and we look forward to a great turnout!',
      registrationDeadline: date.subtract(const Duration(days: 7)),
      
      // Society Costs
      societyGreenFee: 40.0 + _random.nextInt(20),
      societyBreakfastCost: 10.0,
      societyLunchCost: 15.0,
      societyDinnerCost: 25.0,
      
      // Retail Pricing (Cost + 10%)
      memberCost: ((40.0 + (_random.nextInt(20))) * 1.10).roundToDouble(),
      guestCost: (((40.0 + (_random.nextInt(20))) * 1.10) + 10.0).roundToDouble(),
      breakfastCost: (10.0 * 1.10).roundToDouble(),
      lunchCost: (15.0 * 1.10).roundToDouble(),
      dinnerCost: (25.0 * 1.10).roundToDouble(),
      buggyCost: (15.0 * 1.10).roundToDouble(),
      availableBuggies: 10 + _random.nextInt(20),
      dinnerLocation: 'The Clubhouse Restaurant',
      dressCode: 'Smart Casual / No Jeans',
      facilities: ['Pro Shop', 'Driving Range', 'Changing Rooms', 'Halfway House'],
      maxParticipants: 40,

      isGroupingPublished: status != EventStatus.draft,
      isStatsReleased: status == EventStatus.completed || status == EventStatus.inPlay,
      isScoringLocked: status == EventStatus.completed,
      notes: [
        EventNote(
          title: 'Welcome Message',
          content: jsonEncode([
            {'insert': 'Welcome to the '},
            {'insert': title, 'attributes': {'bold': true}},
            {'insert': '!\n\nPlease arrive at least 45 minutes before your tee time for registration and breakfast. We have some fantastic prizes lined up for the winners and runners-up.\n'}
          ]),
        ),
        EventNote(
          title: 'Course Update',
          content: jsonEncode([
            {'insert': 'The greenkeepers have been working hard to prepare the course. The greens are running fast and true. Enjoy your round!\n'}
          ]),
          imageUrl: 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=800&q=80',
        ),
        _getLocalRulesNote(course.name, date),
      ],
      galleryUrls: _getGalleryPhotos(course.name),
    );

    if (isMultiDay) {
      event = event.copyWith(
        notes: [
          ...event.notes,
          ..._getTourNotes(title),
        ],
      );
    }

    // Registration Matrix
    final List<EventRegistration> regs = [];
    final targetRegCount = 30 + _random.nextInt(15);
    
    final eventMemberCost = event.memberCost ?? 0.0;
    final eventGuestCost = event.guestCost ?? 0.0;
    final eventBreakfastCost = event.breakfastCost ?? 0.0;
    final eventLunchCost = event.lunchCost ?? 0.0;
    final eventDinnerCost = event.dinnerCost ?? 0.0;

    // Sanjay
    final hero = members.firstWhereOrNull((m) => m.id == 'demo_hero_sanjay');
    if (hero != null) {
      double totalCost = eventMemberCost;
      totalCost += eventBreakfastCost; // Always attends breakfast
      totalCost += eventLunchCost;    // Always attends lunch
      totalCost += eventDinnerCost;   // Always attends dinner
      
      // Hero Sanjay usually takes a buggy
      const needsBuggy = true;
      // Buggy cost is indicative and paid to pro shop directly, so we exclude it from totalCost

      regs.add(EventRegistration(
        memberId: hero.id,
        memberName: hero.displayName,
        attendingGolf: true,
        attendingBreakfast: true,
        attendingLunch: true,
        attendingDinner: true,
        needsBuggy: needsBuggy,
        hasPaid: true,
        isConfirmed: true,
        handicap: hero.handicap,
        registeredAt: date.subtract(const Duration(days: 25)),
        statusOverride: 'confirmed',
        cost: totalCost,
      ));
    }

    final eventHasBreakfast = event.hasBreakfast;
    final eventHasLunch = event.hasLunch;
    final eventHasDinner = event.hasDinner;

    for (int i = 0; i < targetRegCount; i++) {
        // Use a sliding window to ensure all members get picked over the season
        // Shifting by 5 members per event covers all 75 members every 15 events
        final memberIdx = (eventIndex * 5 + i) % members.length;
        final m = members[memberIdx];
        if (m.id == 'demo_hero_sanjay') continue;
        
        bool isWithdrawn = _random.nextDouble() < 0.05;
        bool isConfirmed = !isWithdrawn && regs.length < 40;
        String? regStatus = isWithdrawn ? 'withdrawn' : (regs.length >= 40 ? 'waitlist' : 'confirmed');
        
        final attendsBreakfast = eventHasBreakfast && _random.nextDouble() < 0.7;
        final attendsLunch = eventHasLunch && _random.nextDouble() < 0.3;
        final attendsDinner = eventHasDinner && _random.nextDouble() < 0.9;
        final needsBuggy = _random.nextDouble() < 0.25;

        // Guest logic (20% chance)
        bool hasGuest = !isWithdrawn && _random.nextDouble() < 0.2;
        String? guestName;
        if (hasGuest) {
          final guestFirstName = maleFirstNames[_random.nextInt(maleFirstNames.length)];
          final guestLastName = lastNames[_random.nextInt(lastNames.length)];
          guestName = '$guestFirstName $guestLastName (G)';
        }

        // Calculate Cost [NEW]
        double totalCost = 0;
        if (isConfirmed) {
          totalCost += eventMemberCost;
          if (attendsBreakfast) totalCost += eventBreakfastCost;
          if (attendsLunch) totalCost += eventLunchCost;
          if (attendsDinner) totalCost += eventDinnerCost;
          // Buggy cost is indicative and paid to pro shop directly, so we exclude it from totalCost

          if (hasGuest) {
            totalCost += eventGuestCost;
            if (attendsBreakfast) totalCost += eventBreakfastCost;
            if (attendsLunch) totalCost += eventLunchCost;
            if (attendsDinner) totalCost += eventDinnerCost;
            // Buggy cost is indicative and paid to pro shop directly, so we exclude it from totalCost
          }
        }

        regs.add(EventRegistration(
          memberId: m.id,
          memberName: m.displayName,
          attendingGolf: isConfirmed,
          attendingBreakfast: attendsBreakfast,
          attendingLunch: attendsLunch,
          attendingDinner: attendsDinner,
          needsBuggy: needsBuggy,
          guestName: guestName,
          guestHandicap: hasGuest ? (15 + _random.nextInt(15)).toString() : null,
          guestAttendingBreakfast: hasGuest && attendsBreakfast,
          guestAttendingLunch: hasGuest && attendsLunch,
          guestAttendingDinner: hasGuest && attendsDinner,
          guestNeedsBuggy: hasGuest && needsBuggy,
          hasPaid: isConfirmed && _random.nextDouble() < 0.8,
          isConfirmed: isConfirmed,
          guestIsConfirmed: isConfirmed && hasGuest,
          handicap: m.handicap,
          registeredAt: date.subtract(Duration(days: 30 - (i % 20))),
          statusOverride: regStatus,
          cost: totalCost,
        ));
    }

    final updatedEvent = event.copyWith(registrations: regs);
    await eventRepo.addEvent(updatedEvent);

    final cardStatus = status == EventStatus.completed ? ScorecardStatus.finalScore : ScorecardStatus.submitted;

    // Competition Rules
    final matchingTemplate = templates.where((t) => t.rules.format == format && t.rules.subtype == subtype).firstOrNull;
    final rules = matchingTemplate?.rules ?? CompetitionRules(
      format: format, subtype: subtype, 
      handicapAllowance: subtype == CompetitionSubtype.fourball ? 0.85 : (subtype == CompetitionSubtype.foursomes ? 0.50 : 0.95),
      mode: (subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes) ? CompetitionMode.pairs : (format == CompetitionFormat.scramble ? CompetitionMode.teams : CompetitionMode.singles),
    );

    await compRepo.addCompetition(Competition(
      id: updatedEvent.id, name: title, type: CompetitionType.event,
      status: status == EventStatus.completed ? CompetitionStatus.closed : CompetitionStatus.published,
      rules: rules, startDate: date, endDate: date,
    ));

    // Grouping
    final items = RegistrationLogic.getSortedItems(updatedEvent, includeWithdrawn: true);
    final Map<String, double> memberHandicaps = {for (var m in members) m.id: m.handicap};
    final groups = GroupingService.generateInitialGrouping(
      event: updatedEvent, participants: items, previousEventsInSeason: [],
      memberHandicaps: memberHandicaps, prioritizeBuggyPairing: true,
      strategy: isInvitational ? 'balanced' : 'progressive',
      useWhs: true, rules: CompetitionRules(format: format, subtype: subtype),
    );

    // Scores
    final scoreRepo = ref.read(scorecardRepositoryProvider);
    await scoreRepo.deleteAllScorecards(updatedEvent.id);

    final List<Map<String, dynamic>> results = [];
    final isStableford = rules.format == CompetitionFormat.stableford;
    
    for (var group in groups) {
      for (var p in group.players) {
          final memberId = p.registrationMemberId;
          final entryId = p.isGuest ? '${memberId}_guest' : memberId;
          final member = members.firstWhereOrNull((m) => m.id == memberId);
          final index = member?.handicap ?? 18.0;
          final teeName = (member?.gender == 'Female') ? 'Red' : 'Yellow';
          final tee = course.tees.firstWhere((t) => t.name == teeName, orElse: () => course.tees.first);
          
          final phc = HandicapCalculator.calculatePlayingHandicap(
              handicapIndex: index, rules: rules, 
              courseConfig: cfg.CourseConfig(
                rating: tee.rating, 
                slope: tee.slope, 
                par: tee.holePars.fold<int>(0, (a, b) => a + b), 
                holes: tee.holePars.asMap().entries.map((e) => cfg.CourseHole(hole: e.key + 1, par: e.value, si: tee.holeSIs[e.key])).toList(),
              ),
          );

          final holeScores = <int?>[];
          int grossTotal = 0;
          int pointsTotal = 0;

          // Calculate holes passed if live
          int holesPassed = 18;
          if (status == EventStatus.inPlay) {
            final now = DateTime.now();
            final groupTime = group.teeTime;
            if (now.isAfter(groupTime)) {
              final minsSince = now.difference(groupTime).inMinutes;
              holesPassed = (minsSince / 12).floor().clamp(0, 18);
            } else {
              holesPassed = 0;
            }
          }

          for (int h = 0; h < 18; h++) {
              if (h >= holesPassed) {
                holeScores.add(null);
                continue;
              }
              final par = tee.holePars[h];
              final si = tee.holeSIs[h];
              int shots = (phc / 18).floor();
              if (phc % 18 >= si) shots++;

              final rand = _random.nextDouble();
              int netScore = (rand < 0.25) ? par - 1 : ((rand < 0.80) ? par : ((rand < 0.95) ? par + 1 : par + 2));
              final gross = netScore + shots;
              holeScores.add(gross);
              grossTotal += gross;
              pointsTotal += (par - netScore + 2).clamp(0, 10).toInt();
          }

          await scoreRepo.addScorecard(Scorecard(
              id: 'seed_${updatedEvent.id}_$entryId', competitionId: updatedEvent.id,
              roundId: '1', entryId: entryId, submittedByUserId: 'system_seed',
              status: status == EventStatus.inPlay ? ScorecardStatus.draft : cardStatus, 
              holeScores: holeScores,
              points: isStableford ? pointsTotal : null,
              handicapIndex: index, playingHandicap: phc,
              netTotal: grossTotal - (phc * (holesPassed / 18)).round(), // Scaled net for live view
              submittedAt: (cardStatus == ScorecardStatus.submitted || cardStatus == ScorecardStatus.finalScore) && status != EventStatus.inPlay
                  ? date.copyWith(hour: 14, minute: _random.nextInt(60)) 
                  : null,
              createdAt: DateTime.now(), updatedAt: DateTime.now(),
          ));
          results.add({
            'playerId': entryId, 
            'playerName': p.name, 
            'points': isStableford ? pointsTotal : (grossTotal - (phc * (holesPassed / 18)).round()), 
            'holeScores': holeScores, 
            'phc': phc,
            'holesPlayed': holesPassed,
          });
      }
    }

    results.sort((a, b) => (b['points'] as num).compareTo(a['points'] as num));
    
    // Assign Positions [NEW]
    for (int i = 0; i < results.length; i++) {
      int position = i + 1;
      if (i > 0 && results[i]['points'] == results[i-1]['points']) {
        position = results[i-1]['position'];
      }
      results[i]['position'] = position;
      results[i]['memberId'] = results[i]['playerId']; // Ensure memberId is present
    }
    
    // [PHASE 1] Add sample expenses and awards for the reporting hub [REFINED]
    final double totalGreenFees = updatedEvent.societyGreenFee! * updatedEvent.playingCount;
    final double totalBreakfast = (updatedEvent.societyBreakfastCost ?? 0) * updatedEvent.registrations.where((r) => r.attendingBreakfast).length;
    final double totalLunch = (updatedEvent.societyLunchCost ?? 0) * updatedEvent.registrations.where((r) => r.attendingLunch).length;
    final double totalDinner = (updatedEvent.societyDinnerCost ?? 0) * updatedEvent.registrations.where((r) => r.attendingDinner).length;

    final List<EventExpense> expenses = [
      EventExpense(id: 'exp_${updatedEvent.id}_green_fees', label: 'Green Fees', amount: totalGreenFees, category: 'Venue'),
      EventExpense(id: 'exp_${updatedEvent.id}_catering', label: 'Catering (All Meals)', amount: totalBreakfast + totalLunch + totalDinner, category: 'Food'),
      EventExpense(id: 'exp_${updatedEvent.id}_prizes_cash', label: 'Cash Prizes', amount: 150.0, category: 'Prize'),
    ];

    final List<EventAward> awards = [
      EventAward(
        id: 'award_${updatedEvent.id}_winner', 
        label: '1st Place', 
        type: 'Cup', 
        value: 0, 
        winnerId: results.isNotEmpty ? results[0]['playerId'] : null, 
        winnerName: results.isNotEmpty ? results[0]['playerName'] : null
      ),
      EventAward(
        id: 'award_${updatedEvent.id}_cash_1', 
        label: '1st Place Cash', 
        type: 'Cash', 
        value: 75.0, 
        winnerId: results.isNotEmpty ? results[0]['playerId'] : null, 
        winnerName: results.isNotEmpty ? results[0]['playerName'] : null
      ),
    ];

    await eventRepo.updateEvent(updatedEvent.copyWith(
      grouping: {'groups': groups.map((g) => g.toJson()).toList(), 'isPublished': true}, 
      results: results,
      expenses: expenses,
      awards: awards,
      feedItems: _generateFeedItems(updatedEvent, results),
    ));
    
    return results;
  }

  List<String> _getGalleryPhotos(String courseName) {
    if (courseName.contains('St Andrews') || courseName.contains('Royal County Down') || courseName.contains('Muirfield')) {
      return [
        'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?auto=format&fit=crop&w=800&q=80', // Links dunes
        'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=800&q=80', // Green fairway
        'https://images.unsplash.com/photo-1591492102875-9c59508d508e?auto=format&fit=crop&w=800&q=80', // Bunkers
      ];
    }
    if (courseName.contains('Pebble Beach') || courseName.contains('Cypress Point') || courseName.contains('Royal Melbourne')) {
      return [
        'https://images.unsplash.com/photo-1500673397354-9448fefb5acc?auto=format&fit=crop&w=800&q=80', // Ocean view
        'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80', // Coastal green
        'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=800&q=80', // Cliff side
      ];
    }
    if (courseName.contains('Dom Pedro') || courseName.contains('Victoria')) {
      return [
        'https://images.unsplash.com/photo-1584061556814-7e8c3fc6e4ed?auto=format&fit=crop&w=800&q=80', // Mediterranean pines
        'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80', // Villa background
        'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=800&q=80', // Lush green
      ];
    }
    return [
      'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?auto=format&fit=crop&w=800&q=80', // Parkland
      'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80', // Trees
      'https://images.unsplash.com/photo-1623912150935-64903328e19e?auto=format&fit=crop&w=800&q=80', // Pond
    ];
  }

  List<EventFeedItem> _generateFeedItems(GolfEvent event, List<Map<String, dynamic>> results) {
    final List<EventFeedItem> items = [];
    final now = DateTime.now();

    // 1. Post-match report for completed events
    if (event.status == EventStatus.completed && results.isNotEmpty) {
      final winner = results[0]['playerName'];
      final points = results[0]['points'];
      
      items.add(EventFeedItem(
        id: 'news_${event.id}_report',
        type: FeedItemType.newsletter,
        title: 'Match Report: ${event.title}',
        content: 'What a day at ${event.courseName}! $winner took the victory with an impressive score of $points points. The conditions were testing, but the quality of golf remained high throughout. Congratulations to all the prize winners!',
        imageUrl: event.galleryUrls.isNotEmpty ? event.galleryUrls[0] : null,
        isPublished: true,
        createdAt: event.date.add(const Duration(hours: 6)),
        sortOrder: 10,
      ));
    }

    // 2. Poll for recent/upcoming major activities
    if (event.title.contains('Winter Major') || (event.status == EventStatus.published && event.date.isAfter(now))) {
      items.add(EventFeedItem(
        id: 'poll_${event.id}_planning',
        type: FeedItemType.poll,
        title: 'Season 2027 Planning',
        content: 'Where should we go for the 2027 Society Away Trip? Cast your vote below!',
        isPublished: true,
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 1)),
        pollData: {
          'options': ['Portugal (Vilamoura)', 'Spain (Marbella)', 'Scotland (East Coast)', 'Ireland (Killarney)'],
          'totalVotes': 42,
          'results': {'0': 15, '1': 10, '2': 12, '3': 5},
          'hasVoted': false,
        },
        sortOrder: -10,
      ));
    }

    // 3. President's Message for the Season Opener
    if (event.title.contains('Season Opener')) {
      items.add(EventFeedItem(
        id: 'news_${event.id}_president',
        type: FeedItemType.newsletter,
        title: 'Word from the President',
        content: 'Welcome to another fantastic year of golf. I am delighted to see so many returning faces and a few new guests joining our ranks. Let’s play hard, play fair, and enjoy the 19th hole!',
        isPublished: true,
        isPinned: true,
        createdAt: event.date.subtract(const Duration(days: 2)),
        sortOrder: -20,
      ));
    }

    return items;
  }



  Future<void> _seedNonEventExpenses() async {
    final repo = ref.read(eventsRepositoryProvider);
    final now = DateTime.now();
    
    final overheads = [
      EventExpense(
        id: 'oh_website',
        label: 'Annual Website Maintenance',
        amount: 150.0,
        category: 'Misc',
        date: DateTime(now.year, 1, 15),
      ),
      EventExpense(
        id: 'oh_insurance',
        label: 'Society Public Liability Insurance',
        amount: 285.0,
        category: 'Misc',
        date: DateTime(now.year, 2, 1),
      ),
      EventExpense(
        id: 'oh_trophies',
        label: 'Majors Trophies Engraving',
        amount: 45.0,
        category: 'Misc',
        date: DateTime(now.year, 3, 20),
      ),
    ];

    for (final exp in overheads) {
      await repo.saveGlobalExpense(exp);
    }
  }

  EventNote _getLocalRulesNote(String courseName, DateTime date) {
    String ruleContent = 'Standard R&A Rules apply. \n\n- Out of Bounds: Beyond any perimeter fence or white stakes.\n- Water Hazards: Defined by yellow/red stakes.\n- Immovable Obstructions: Fixed sprinkler heads and yardage markers.';
    
    // Seasonal Rules
    if (date.month >= 11 || date.month <= 3) {
      ruleContent += '\n\n- PREFERRED LIES: A ball lying on a closely mown area through the green may be marked, cleaned and replaced within 6 inches.';
    }

    // Course Specific Rules
    if (courseName.contains('St Andrews')) {
      ruleContent += '\n\n- THE ROAD HOLE (#17): The road and wall behind the green are out of bounds. The bunker is an integral part of the course.';
    } else if (courseName.contains('Sawgrass')) {
      ruleContent += '\n\n- THE ISLAND GREEN (#17): Drop zone is active to the left of the walkway for balls entering the hazard.';
    } else if (courseName.contains('Augusta')) {
      ruleContent += '\n\n- AMEN CORNER (#11-13): Rae’s Creek is a lateral water hazard. Drop zones available for #12 and #13.';
    }

    return EventNote(
      title: 'Local Rules & Info',
      content: jsonEncode([{'insert': '$ruleContent\n'}]),
    );
  }

  ({List<int> pars, List<int> si, List<int> yards}) _getCourseHoleData(String courseName) {
    if (courseName == 'St Andrews') {
      return (
        pars: [4, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4],
        si: [10, 6, 16, 8, 2, 12, 4, 14, 18, 15, 7, 3, 11, 1, 9, 13, 5, 17],
        yards: [376, 413, 370, 419, 514, 374, 359, 166, 307, 318, 174, 314, 407, 533, 413, 351, 455, 357],
      );
    }
    if (courseName == 'Pebble Beach') {
      return (
        pars: [4, 5, 4, 4, 3, 5, 3, 4, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5],
        si: [8, 10, 12, 16, 14, 2, 18, 4, 8, 7, 9, 17, 1, 5, 11, 15, 13, 3],
        yards: [378, 511, 397, 331, 189, 506, 106, 427, 481, 444, 373, 201, 399, 573, 396, 401, 177, 543],
      );
    }
    if (courseName == 'TPC Sawgrass') {
      return (
        pars: [4, 5, 3, 4, 4, 4, 4, 3, 5, 4, 5, 4, 3, 4, 4, 5, 3, 4],
        si: [11, 15, 17, 9, 3, 13, 1, 7, 5, 12, 8, 16, 18, 4, 6, 10, 14, 2],
        yards: [423, 532, 177, 384, 471, 393, 442, 237, 583, 424, 558, 369, 181, 481, 449, 523, 137, 462],
      );
    }
    if (courseName == 'Augusta') {
      return (
        pars: [4, 5, 4, 3, 4, 3, 4, 5, 4, 4, 4, 3, 5, 4, 5, 3, 4, 4],
        si: [9, 1, 13, 15, 5, 17, 11, 3, 7, 6, 8, 16, 4, 12, 2, 18, 14, 10],
        yards: [445, 575, 350, 240, 495, 180, 450, 570, 460, 495, 505, 155, 510, 440, 530, 170, 440, 465],
      );
    }
    if (courseName == 'Royal County Down') {
      return (
        pars: [5, 4, 4, 3, 4, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 4, 4, 5],
        si: [13, 9, 3, 15, 7, 11, 17, 1, 5, 18, 8, 16, 2, 12, 4, 14, 10, 6],
        yards: [539, 444, 475, 213, 443, 396, 144, 429, 483, 196, 444, 525, 446, 212, 465, 337, 436, 548],
      );
    }
    if (courseName == 'Muirfield') {
      return (
        pars: [4, 4, 4, 3, 5, 4, 5, 3, 4, 4, 5, 3, 4, 4, 5, 3, 4, 4],
        si: [14, 8, 10, 18, 2, 12, 4, 16, 6, 13, 15, 3, 7, 11, 1, 17, 9, 5],
        yards: [450, 447, 401, 203, 529, 447, 563, 202, 412, 471, 567, 184, 455, 363, 490, 201, 478, 484],
      );
    }
    if (courseName == 'Shinnecock Hills') {
      return (
        pars: [4, 3, 4, 4, 5, 4, 3, 4, 4, 4, 3, 4, 4, 4, 4, 5, 3, 4],
        si: [11, 17, 3, 7, 9, 1, 15, 13, 5, 4, 16, 2, 12, 6, 14, 8, 18, 10],
        yards: [399, 226, 500, 475, 589, 491, 189, 439, 485, 415, 158, 469, 370, 444, 419, 540, 175, 485],
      );
    }
    if (courseName == 'Oakmont') {
      return (
        pars: [4, 4, 4, 5, 4, 3, 4, 3, 5, 4, 4, 5, 3, 4, 4, 3, 4, 4],
        si: [3, 7, 1, 13, 11, 17, 9, 5, 15, 4, 10, 2, 16, 18, 8, 12, 14, 6],
        yards: [482, 340, 428, 609, 379, 194, 479, 252, 477, 462, 379, 667, 183, 358, 499, 231, 313, 484],
      );
    }
    if (courseName == 'Cypress Point') {
      return (
        pars: [4, 5, 3, 4, 5, 5, 3, 4, 4, 5, 4, 4, 4, 4, 3, 3, 4, 4],
        si: [5, 1, 17, 7, 11, 3, 15, 9, 13, 16, 4, 2, 14, 8, 18, 6, 10, 12],
        yards: [415, 541, 158, 381, 483, 514, 159, 362, 289, 476, 438, 404, 354, 393, 135, 222, 344, 331],
      );
    }
    if (courseName == 'Pine Valley') {
      return (
        pars: [4, 4, 3, 4, 3, 4, 5, 4, 4, 3, 4, 4, 4, 3, 5, 4, 4, 4],
        si: [3, 9, 17, 5, 11, 13, 1, 15, 7, 18, 10, 14, 4, 16, 2, 8, 12, 6],
        yards: [421, 351, 185, 438, 220, 385, 584, 314, 422, 142, 388, 330, 439, 180, 574, 420, 332, 425],
      );
    }
    if (courseName == 'Royal Melbourne') {
      return (
        pars: [4, 5, 4, 4, 3, 4, 3, 4, 4, 4, 4, 4, 4, 5, 4, 3, 5, 4],
        si: [5, 1, 13, 7, 17, 3, 15, 11, 9, 6, 10, 14, 18, 4, 8, 16, 2, 12],
        yards: [428, 491, 332, 439, 176, 427, 147, 311, 454, 475, 438, 433, 354, 504, 382, 201, 568, 431],
      );
    }
    if (courseName == 'Dom Pedro Old Course') {
      return (
        pars: [4, 4, 4, 3, 5, 4, 4, 3, 4, 4, 4, 3, 4, 5, 4, 4, 5, 4],
        si: [7, 13, 3, 17, 1, 11, 5, 15, 9, 8, 14, 18, 4, 10, 2, 12, 16, 6],
        yards: [325, 403, 365, 178, 498, 382, 347, 153, 310, 345, 388, 165, 395, 485, 375, 335, 510, 378],
      );
    }
    if (courseName == 'Victoria Golf Course') {
      return (
        pars: [4, 4, 4, 3, 5, 4, 3, 4, 4, 4, 4, 5, 3, 4, 3, 4, 5, 4],
        si: [9, 5, 13, 17, 1, 3, 15, 11, 7, 10, 6, 2, 18, 4, 16, 12, 8, 14],
        yards: [375, 420, 365, 185, 530, 440, 165, 410, 435, 390, 415, 560, 155, 450, 175, 430, 520, 445],
      );
    }
    return (
      pars: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
      si: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
      yards: List.generate(18, (h) => 350 + _random.nextInt(100)),
    );
  }

  List<EventNote> _getTourNotes(String tourName) {
    if (tourName.contains('Algarve')) {
      return [
        EventNote(
          title: '🏨 Accommodation: Hilton Vilamoura',
          content: jsonEncode([{'insert': 'Welcome to the Algarve! We are staying at the Hilton Vilamoura As Cascatas Golf Resort & Spa.\n\nCheck-in: From 3pm on Day 1.\nDinner: 8pm in the Cilantro restaurant.\nDress Code: Smart Casual.\n'}]),
        ),
        EventNote(
          title: '📅 Tour Itinerary',
          content: jsonEncode([{'insert': 'DAY 1: Arrival & Welcome Round (Dom Pedro Old Course)\nDAY 2: Championship Day (Victoria Golf Course) + Gala Dinner\nDAY 3: Final Round (Victoria Golf Course) + Prize Presentation at 2pm.\n'}]),
        ),
        EventNote(
          title: '🏆 Tour Scoring & Rules',
          content: jsonEncode([{'insert': 'The "Algarve Tour 2026" uses a cumulative Stableford format over 3 days. \n\nHandicaps: Fixed for the duration of the tour. \nGPS: Devices allowed. \nNo Caddies permitted.\n'}]),
        ),
      ];
    }
    return [
      EventNote(
        title: 'Multi-Day Itinerary',
        content: jsonEncode([{'insert': 'Check event notices for daily tee times and arrangements.\n'}]),
      ),
    ];
  }

  Future<void> generateTestMatches(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    final grouping = Map<String, dynamic>.from(event.grouping);
    final groups = (grouping['groups'] as List?) ?? [];
    if (groups.isEmpty) return;
    final List<Map<String, dynamic>> matches = [];
    for (var g in groups) {
      final players = (g['players'] as List);
      for (int i = 0; i < players.length - 1; i += 2) {
        final p1 = players[i];
        final p2 = players[i+1];
        matches.add({
          'id': 'match_${eventId}_${g['index']}_$i',
          'type': 'singles',
          'team1Ids': [p1['registrationMemberId'] ?? ''],
          'team2Ids': [p2['registrationMemberId'] ?? ''],
          'team1Name': p1['name'],
          'team2Name': p2['name'],
          'groupId': g['index'].toString(),
        });
      }
    }
    grouping['matches'] = matches;
    await eventRepo.updateEvent(event.copyWith(grouping: grouping));
  }

  Future<void> generateGroupStageMatches(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    final grouping = Map<String, dynamic>.from(event.grouping);
    final List<Map<String, dynamic>> matches = [];
    final groups = (grouping['groups'] as List?) ?? [];
    for (var g in groups) {
      final players = (g['players'] as List);
      final gid = g['index'].toString();
      for (int i = 0; i < players.length; i++) {
        for (int j = i + 1; j < players.length; j++) {
          final p1 = players[i];
          final p2 = players[j];
          matches.add({
            'id': 'grp_${gid}_${i}_${j}_$eventId',
            'type': 'singles',
            'team1Ids': [p1['registrationMemberId']],
            'team2Ids': [p2['registrationMemberId']],
            'team1Name': p1['name'],
            'team2Name': p2['name'],
            'round': 'group',
            'groupId': gid,
          });
        }
      }
    }
    grouping['matches'] = matches;
    await eventRepo.updateEvent(event.copyWith(grouping: grouping));
  }

  Future<void> generateTestBracket(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    final grouping = Map<String, dynamic>.from(event.grouping);
    final List<Map<String, dynamic>> matches = [];
    final players = (event.grouping['groups'] as List?)?.expand((g) => g['players'] as List).toList() ?? [];
    if (players.length < 8) return;
    final bracketId = 'test_bracket_$eventId';
    for (int i = 0; i < 4; i++) {
       final p1 = players[i * 2];
       final p2 = players[i * 2 + 1];
       matches.add({'id': 'qf_${eventId}_$i', 'type': 'singles', 'team1Ids': [p1['registrationMemberId']], 'team2Ids': [p2['registrationMemberId']], 'team1Name': p1['name'], 'team2Name': p2['name'], 'round': 'quarterFinal', 'bracketId': bracketId, 'bracketOrder': i});
    }
    grouping['matches'] = matches;
    await eventRepo.updateEvent(event.copyWith(grouping: grouping));
  }

  Future<void> simulateMatchScores(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    final matchesList = event.grouping['matches'] as List?;
    if (matchesList == null) return;
    for (var mData in matchesList) {
      final team1Ids = (mData['team1Ids'] as List).cast<String>();
      final team2Ids = (mData['team2Ids'] as List).cast<String>();
      if (team1Ids.isEmpty || team2Ids.isEmpty) continue;
      final allPlayerIds = [...team1Ids, ...team2Ids];
      final winnerSide = _random.nextBool() ? 1 : 2;
      for (var pid in allPlayerIds) {
        final isWinnerTeam = (winnerSide == 1 && team1Ids.contains(pid)) || (winnerSide == 2 && team2Ids.contains(pid));
        final holeScores = List.generate(18, (i) => isWinnerTeam ? (_random.nextInt(100) < 80 ? 4 : 3) : (_random.nextInt(100) < 40 ? 4 : 5));
        await scorecardRepo.addScorecard(Scorecard(id: '', competitionId: eventId, roundId: mData['round'] ?? 'round_1', entryId: pid, submittedByUserId: 'system_simulation', status: ScorecardStatus.finalScore, holeScores: holeScores, createdAt: DateTime.now(), updatedAt: DateTime.now()));
      }
    }
  }
}

final seedingServiceProvider = Provider((ref) => SeedingService(ref));
