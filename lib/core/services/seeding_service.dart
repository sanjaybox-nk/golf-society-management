import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/models/competition.dart';
import 'package:golf_society/models/season.dart';
import 'package:golf_society/models/leaderboard_config.dart';
import 'package:golf_society/models/course.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/member.dart';
import 'package:golf_society/models/golf_event.dart';
import 'package:golf_society/models/event_registration.dart';
import 'package:golf_society/models/scorecard.dart';
import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/core/utils/grouping_service.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';

class SeedingService {
  final Ref ref;

  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await seedCourses();
    await seedTemplates();
    await seedCurrentSeason();
  }

  Future<void> clearAllData() async {
    final db = FirebaseFirestore.instance;
    
    final collections = [
      'members',
      'events',
      'scorecards',
      'competitions',
      'seasons',
    ];

    for (var collName in collections) {
      final snapshot = await db.collection(collName).get();
      final batch = db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> seedTeamsPhase() async {
    await seedInitialData();
    await seedMembers(60);
    
    // Seed 2 Historical Team Events
    final eventRepo = ref.read(eventsRepositoryProvider);
    final seasons = await ref.read(seasonsRepositoryProvider).getSeasons();
    if (seasons.isEmpty) return;
    final activeSeason = seasons.firstWhere((s) => s.status == SeasonStatus.active, orElse: () => seasons.first);
    final courseRepo = ref.read(courseRepositoryProvider);
    final courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) return;
    final selectedCourse = courses.first;

    final historyConfigs = [
      {
        'id': 'team_hist_001',
        'title': 'Spring Scramble (Teams)',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'format': CompetitionFormat.scramble,
        'mode': CompetitionMode.teams,
      },
      {
        'id': 'team_hist_002',
        'title': 'Early Summer 4BBB (Pairs)',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'format': CompetitionFormat.stableford,
        'subtype': CompetitionSubtype.fourball,
        'mode': CompetitionMode.pairs,
      },
    ];

    for (var config in historyConfigs) {
      final date = config['date'] as DateTime;
      final event = GolfEvent(
        id: config['id'] as String,
        title: config['title'] as String,
        seasonId: activeSeason.id,
        date: date,
        teeOffTime: date,
        status: EventStatus.completed,
        courseId: selectedCourse.id,
        courseName: selectedCourse.name,
        selectedTeeName: selectedCourse.tees.first.name,
        courseConfig: {
          'holes': List.generate(18, (i) => {
            'hole': i + 1,
            'par': selectedCourse.tees.first.holePars[i],
            'si': selectedCourse.tees.first.holeSIs[i],
          }),
          'par': selectedCourse.tees.first.holePars.fold(0, (total, val) => total + val),
        },
      );

      await eventRepo.addEvent(event);
      if (event.id.isEmpty) {
        throw Exception('Historical event created with empty ID: ${event.title}');
      }
      await seedRegistrations(event.id, isPast: true);
    }
  }

  Future<void> seedHardeningPhase() async {
    // Stress test: Multiple players with exact same scores to test tie-breaks
    await seedInitialData();
    await seedMembers(60);
    
    final eventRepo = ref.read(eventsRepositoryProvider);
    final seasons = await ref.read(seasonsRepositoryProvider).getSeasons();
    if (seasons.isEmpty) return;
    final activeSeason = seasons.firstWhere((s) => s.status == SeasonStatus.active, orElse: () => seasons.first);
    final courseRepo = ref.read(courseRepositoryProvider);
    final courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) return;
    final selectedCourse = courses.first;

    final date = DateTime.now().subtract(const Duration(days: 5));
    final event = GolfEvent(
      id: 'hardening_001',
      title: 'The Tie-Break Open',
      seasonId: activeSeason.id,
      date: date,
      status: EventStatus.completed,
      courseId: selectedCourse.id,
      courseName: selectedCourse.name,
      selectedTeeName: selectedCourse.tees.first.name,
      courseConfig: {
        'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': selectedCourse.tees.first.holePars[i],
          'si': selectedCourse.tees.first.holeSIs[i],
        }),
      },
    );

    await eventRepo.addEvent(event);
    
    // Manual scorecard seeding for exact ties
    final memberRepo = ref.read(membersRepositoryProvider);
    final members = await memberRepo.getMembers();
    final participants = members.take(10).toList();
    
    for (var m in participants) {
      final scorecardRepo = ref.read(scorecardRepositoryProvider);
      // All getting 36 points exactly
      await scorecardRepo.addScorecard(Scorecard(
        id: '',
        competitionId: event.id,
        roundId: 'round_1',
        entryId: m.id,
        submittedByUserId: 'system_seed',
        status: ScorecardStatus.finalScore,
        points: 36,
        holeScores: List.generate(18, (i) => 4), // All pars
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> seedStableFoundation() async {
    await seedInitialData();
    await seedMembers(60);
    await seedLabEvent();
    await seedHistoricalEvents();
  }

  Future<void> seedTemplates() async {
    final repo = ref.read(competitionsRepositoryProvider);
    
    final templates = [
      _createTemplate(
        name: 'Stableford Open',
        format: CompetitionFormat.stableford,
        allowance: 0.95,
      ),
      _createTemplate(
        name: 'Texas Scramble (4-Man)',
        format: CompetitionFormat.scramble,
        subtype: CompetitionSubtype.texas,
        mode: CompetitionMode.teams,
        minDrives: 4,
        useWHS: true,
      ),
      _createTemplate(
        name: '4BBB Stableford',
        format: CompetitionFormat.stableford,
        subtype: CompetitionSubtype.fourball,
        mode: CompetitionMode.pairs,
        allowance: 0.85,
      ),
      _createTemplate(
        name: 'Match Play Singles',
        format: CompetitionFormat.matchPlay,
        mode: CompetitionMode.singles,
        allowance: 1.0,
      ),
    ];

    for (var t in templates) {
      // Generate a unique ID for each template based on the format
      final templateId = 'template_${t.rules.format.name.toLowerCase()}_${t.rules.subtype.name}_${t.rules.mode.name}';
      final templateWithId = t.copyWith(id: templateId);
      await repo.addCompetition(templateWithId);
    }
  }

  Future<void> seedCurrentSeason() async {
    final repo = ref.read(seasonsRepositoryProvider);
    final seasons = await repo.getSeasons();
    
    if (seasons.isEmpty) {
      final now = DateTime.now();
      
      // 2026 Season (Current)
      final season2026 = Season(
        id: 'season_2026',
        name: '${now.year} Society Tour',
        year: now.year,
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
        status: SeasonStatus.active,
        isCurrent: true,
        leaderboards: _defaultLeaderboards(now.year.toString()),
      );
      await repo.addSeason(season2026);
    }
  }

  List<LeaderboardConfig> _defaultLeaderboards(String suffix) {
    return [
      LeaderboardConfig.orderOfMerit(
        id: 'oom_$suffix',
        name: 'Order of Merit',
        source: OOMSource.position,
        appearancePoints: 2,
        positionPointsMap: {1: 25, 2: 18, 3: 15, 4: 12},
      ),
      LeaderboardConfig.markerCounter(
        id: 'birdie_tree_$suffix',
        name: 'Birdie Tree',
        targetTypes: {MarkerType.birdie, MarkerType.eagle, MarkerType.albatross},
      ),
      LeaderboardConfig.bestOfSeries(
        id: 'best_8_$suffix',
        name: 'Best 8 Series',
        bestN: 8,
        metric: BestOfMetric.stableford,
      ),
      LeaderboardConfig.eclectic(
        id: 'eclectic_$suffix',
        name: 'Season Eclectic',
        metric: EclecticMetric.strokes,
      ),
    ];
  }

  Future<void> seedCourses() async {
    final repo = ref.read(courseRepositoryProvider);
    
    // Check if courses already exist to avoid duplicates
    final existing = await repo.watchCourses().first;
    if (existing.isNotEmpty) return;

    final courses = [
      Course(
        id: '',
        name: 'St Andrews (Old Course)',
        address: 'St Andrews, Scotland',
        isGlobal: true,
        tees: [
          TeeConfig(
            name: 'White',
            rating: 73.1,
            slope: 132,
            holePars: [4, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4],
            holeSIs: [10, 6, 16, 8, 2, 12, 4, 14, 18, 15, 7, 3, 11, 1, 9, 13, 5, 17],
            yardages: [376, 411, 370, 419, 514, 374, 359, 166, 307, 311, 174, 316, 418, 523, 412, 351, 455, 357],
          ),
          TeeConfig(
            name: 'Yellow',
            rating: 71.4,
            slope: 129,
            holePars: [4, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4],
            holeSIs: [10, 6, 16, 8, 2, 12, 4, 14, 18, 15, 7, 3, 11, 1, 9, 13, 5, 17],
            yardages: [339, 375, 352, 406, 471, 334, 335, 145, 289, 285, 164, 304, 392, 516, 391, 345, 436, 342],
          ),
        ],
      ),
      Course(
        id: '',
        name: 'Pebble Beach Golf Links',
        address: 'California, USA',
        isGlobal: true,
        tees: [
          TeeConfig(
            name: 'Championship',
            rating: 74.9,
            slope: 144,
            holePars: [4, 5, 4, 4, 3, 5, 3, 4, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5],
            holeSIs: [8, 10, 12, 16, 14, 2, 18, 6, 4, 7, 5, 17, 9, 1, 13, 11, 15, 3],
            yardages: [378, 511, 390, 327, 188, 506, 106, 418, 466, 444, 373, 201, 399, 573, 396, 401, 178, 543],
          ),
        ],
      ),
      Course(
        id: '',
        name: 'TPC Sawgrass (Stadium)',
        address: 'Florida, USA',
        isGlobal: true,
        tees: [
          TeeConfig(
            name: 'Blue',
            rating: 73.9,
            slope: 148,
            holePars: [4, 5, 3, 4, 4, 4, 4, 3, 5, 4, 5, 4, 3, 4, 4, 5, 3, 4],
            holeSIs: [11, 15, 17, 9, 3, 13, 1, 7, 5, 12, 8, 16, 18, 4, 6, 10, 14, 2],
            yardages: [392, 532, 177, 384, 471, 393, 442, 237, 583, 424, 558, 358, 181, 481, 449, 523, 137, 462],
          ),
        ],
      ),
    ];

    for (var c in courses) {
      await repo.saveCourse(c);
    }
  }

  Future<void> seedMembers(int count) async {
    final repo = ref.read(membersRepositoryProvider);
    final existing = await repo.getMembers();
    if (existing.length >= count) {
      return;
    }

    final random = Random();
    final firstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson'];

    for (int i = 0; i < count; i++) {
        final firstName = firstNames[random.nextInt(firstNames.length)];
        final lastName = lastNames[random.nextInt(lastNames.length)];
        
        // Finalize committee roles for first 5 members
        String? societyRole;
        if (i == 0) societyRole = 'President';
        if (i == 1) societyRole = 'Captain';
        if (i == 2) societyRole = 'Vice Captain';
        if (i == 3) societyRole = 'Secretary';
        if (i == 4) societyRole = 'Treasurer';

        // Distribution of handicaps
        double handicap;
        int rand = random.nextInt(100);
        if (rand < 20) {
          handicap = random.nextDouble() * 8; // Low
        } else if (rand < 60) {
          handicap = 9 + random.nextDouble() * 9; // Mid
        } else if (rand < 85) {
          handicap = 19 + random.nextDouble() * 9; // High
        } else {
          handicap = 28 + random.nextDouble() * 26; // Newbies
        }

        await repo.addMember(Member(
          id: '',
          firstName: firstName,
          lastName: lastName,
          email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com',
          phone: '07700 900${random.nextInt(999).toString().padLeft(3, '0')}',
          handicap: double.parse(handicap.toStringAsFixed(1)),
          handicapId: 'WHS${100000 + i}',
          societyRole: societyRole,
          status: MemberStatus.active,
          joinedDate: DateTime.now().subtract(Duration(days: random.nextInt(365 * 5))),
          hasPaid: true, // As requested: assume all paid
        ));
    }
  }

  Future<void> seedLabEvent() async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final seasons = await ref.read(seasonsRepositoryProvider).getSeasons();
    if (seasons.isEmpty) {
      return;
    }

    final activeSeason = seasons.firstWhere((s) {
      return s.status == SeasonStatus.active;
    }, orElse: () => seasons.first);
    final courseRepo = ref.read(courseRepositoryProvider);
    final courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) {
      return;
    }

    final selectedCourse = courses.first;
    final teeOffTime = DateTime.now().add(const Duration(days: 14)).copyWith(hour: 10, minute: 0);
    
    final labEvent = GolfEvent(
      id: 'lab_open_001',
      title: 'The Lab Open',
      seasonId: activeSeason.id,
      date: teeOffTime,
      teeOffTime: teeOffTime,
      regTime: teeOffTime.subtract(const Duration(hours: 1)),
      registrationDeadline: teeOffTime.subtract(const Duration(days: 2)),
      description: 'Master Testing Event for all game formats.',
      courseId: selectedCourse.id,
      courseName: selectedCourse.name,
      courseDetails: selectedCourse.address,
      selectedTeeName: selectedCourse.tees.isNotEmpty ? selectedCourse.tees.first.name : null,
      dressCode: 'Smart casual. Tailored shorts permitted. No denim or collarless shirts.',
      maxParticipants: 40,
      memberCost: 45.0,
      guestCost: 65.0,
      hasBreakfast: true,
      hasLunch: true,
      hasDinner: true,
      breakfastCost: 10.0,
      lunchCost: 15.0,
      dinnerCost: 25.0,
      availableBuggies: 10,
      buggyCost: 30.0,
      facilities: ['Driving Range', 'Practice Greens', 'Clubhouse Bar', 'Pro Shop'],
      dinnerLocation: 'The Old Course Clubhouse, Main Dining Room',
      notes: [
        EventNote(
          title: 'Welcome',
          content: jsonEncode([{"insert": "Looking forward to seeing everyone at The Lab Open! This is our flagship event of the season.\n"}]),
        ),
        EventNote(
          title: 'Weather Update',
          content: jsonEncode([{"insert": "Forecast looking good for the day - sunny intervals with light winds. Pack sunscreen!\n"}]),
        ),
        EventNote(
          title: 'Prize Giving',
          content: jsonEncode([{"insert": "Prize presentation will take place immediately after dinner in the main lounge. Trophies for 1st, 2nd, 3rd places plus nearest-the-pin and longest drive.\n"}]),
        ),
        EventNote(
          content: jsonEncode([{"insert": "Please ensure golf shoes have soft spikes only. Metal spikes are not permitted on the course.\n"}]),
        ),
      ],
      flashUpdates: [
        'Early bird registration discount available until ${DateFormat('MMM d').format(teeOffTime.subtract(const Duration(days: 10)))}',
        'Buggies are limited - book early to avoid disappointment',
      ],
      status: EventStatus.published,
      courseConfig: selectedCourse.tees.isNotEmpty ? {
        'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': selectedCourse.tees.first.holePars[i],
          'si': selectedCourse.tees.first.holeSIs[i],
          'yardage': selectedCourse.tees.first.yardages[i],
        }),
        'par': selectedCourse.tees.first.holePars.fold(0, (total, val) => total + val),
        'slope': selectedCourse.tees.first.slope,
        'rating': selectedCourse.tees.first.rating,
      } : {},
    );

    await eventRepo.addEvent(labEvent);
    if (labEvent.id.isEmpty) {
      throw Exception('Lab event created with empty ID');
    }

    // Create a default competition record for the Lab Event
    final compRepo = ref.read(competitionsRepositoryProvider);
    await compRepo.addCompetition(Competition(
      id: labEvent.id,
      type: CompetitionType.event,
      status: CompetitionStatus.open,
      rules: const CompetitionRules(
        format: CompetitionFormat.stableford,
        handicapAllowance: 0.95,
      ),
      startDate: teeOffTime,
      endDate: teeOffTime,
    ));

    await seedRegistrations(labEvent.id, forceResetStatus: true);
  }

  Future<void> seedHistoricalEvents() async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final seasons = await ref.read(seasonsRepositoryProvider).getSeasons();
    if (seasons.isEmpty) return;
    
    final activeSeason = seasons.firstWhere((s) {
      return s.year == 2026;
    }, orElse: () => seasons.first);

    final courseRepo = ref.read(courseRepositoryProvider);
    final courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) return;

    final compRepo = ref.read(competitionsRepositoryProvider);

    final historyConfigs = [
      {
        'id': 'hist_2026_001',
        'title': 'Season Opener (Stableford)',
        'date': DateTime(2026, 1, 10, 9),
        'format': CompetitionFormat.stableford,
        'dressCode': 'Smart casual - winter layers recommended',
        'dinnerLocation': 'The Clubhouse, Main Bar Area',
        'notes': [
          EventNote(
            title: 'Season Kickoff',
            content: jsonEncode([{"insert": "Welcome to the 2026 season! Let's start the year with a great turnout.\n"}]),
          ),
          EventNote(
            content: jsonEncode([{"insert": "Winter greens in play. Preferred lies allowed.\n"}]),
          ),
        ],
      },
      {
        'id': 'hist_2026_002',
        'title': 'Winter Medal',
        'date': DateTime(2026, 1, 24, 10),
        'format': CompetitionFormat.stroke,
        'dressCode': 'Traditional golf attire required',
        'dinnerLocation': 'The Halfway House Restaurant',
        'notes': [
          EventNote(
            title: 'Medal Competition',
            content: jsonEncode([{"insert": "This is our first medal of the season - play well for Order of Merit points!\n"}]),
          ),
          EventNote(
            title: 'Course Conditions',
            content: jsonEncode([{"insert": "Course playing firm and fast. Check pin positions carefully.\n"}]),
          ),
          EventNote(
            content: jsonEncode([{"insert": "Photography station set up at the 18th green for post-round photos.\n"}]),
          ),
        ],
      },
      {
        'id': 'hist_2026_003',
        'title': 'February Invitational',
        'date': DateTime(2026, 2, 1, 11),
        'format': CompetitionFormat.stableford,
        'dressCode': 'Smart casual. Guests welcome.',
        'dinnerLocation': 'The Grand Hall, Banquet Room',
        'notes': [
          EventNote(
            title: 'Invitational Event',
            content: jsonEncode([{"insert": "Bring your guests! This is our annual invitational with prizes for best guest score.\n"}]),
          ),
          EventNote(
            content: jsonEncode([{"insert": "Special menu available for dinner - pre-orders close 2 days before event.\n"}]),
          ),
        ],
      },
    ];

    for (var config in historyConfigs) {
      final date = config['date'] as DateTime;
      final selectedCourse = courses[historyConfigs.indexOf(config) % courses.length];
      final format = config['format'] as CompetitionFormat? ?? CompetitionFormat.stableford;
      
      final event = GolfEvent(
        id: config['id'] as String,
        title: config['title'] as String,
        seasonId: activeSeason.id,
        date: date,
        teeOffTime: date,
        regTime: date.subtract(const Duration(hours: 1)),
        registrationDeadline: date.subtract(const Duration(days: 7)),
        description: 'Historical seeding for end-to-end testing.',
        courseId: selectedCourse.id,
        courseName: selectedCourse.name,
        courseDetails: selectedCourse.address,
        selectedTeeName: selectedCourse.tees.isNotEmpty ? selectedCourse.tees.first.name : null,
        dressCode: config['dressCode'] as String?,
        maxParticipants: 40,
        memberCost: 40.0,
        guestCost: 60.0,
        hasBreakfast: date.hour < 12,
        hasLunch: date.hour >= 11,
        hasDinner: true,
        breakfastCost: 8.0,
        lunchCost: 12.0,
        dinnerCost: 22.0,
        availableBuggies: 8,
        buggyCost: 25.0,
        facilities: ['Driving Range', 'Putting Green', 'Clubhouse'],
        dinnerLocation: config['dinnerLocation'] as String?,
        notes: config['notes'] as List<EventNote>? ?? [],
        status: EventStatus.completed,
        courseConfig: selectedCourse.tees.isNotEmpty ? {
          'holes': List.generate(18, (i) => {
            'hole': i + 1,
            'par': selectedCourse.tees.first.holePars[i],
            'si': selectedCourse.tees.first.holeSIs[i],
            'yardage': selectedCourse.tees.first.yardages[i],
          }),
          'par': selectedCourse.tees.first.holePars.fold(0, (total, val) => total + val),
          'slope': selectedCourse.tees.first.slope,
          'rating': selectedCourse.tees.first.rating,
        } : {},
      );

      await eventRepo.addEvent(event);
      
      // Create associated competition record
      await compRepo.addCompetition(Competition(
        id: event.id,
        type: CompetitionType.event,
        status: CompetitionStatus.closed,
        rules: CompetitionRules(
          format: format,
          handicapAllowance: 0.95,
        ),
        startDate: date,
        endDate: date,
      ));

      if (event.id.isEmpty) {
        throw Exception('Historical event created with empty ID: ${event.title}');
      }
      await seedRegistrations(event.id, isPast: true);
    }
  }

  Future<void> seedRegistrations(String eventId, {bool isPast = false, bool forceResetStatus = false}) async {
    // Validate eventId before attempting Firestore access
    if (eventId.isEmpty) {
      throw Exception('Cannot seed registrations: Event ID is empty');
    }

    final eventRepo = ref.read(eventsRepositoryProvider);
    final memberRepo = ref.read(membersRepositoryProvider);
    
    final event = await eventRepo.getEvent(eventId);
    if (event == null) {
      throw Exception('Cannot seed registrations: Event "$eventId" not found. Please run "Seed Stable Foundation" first.');
    }

    final members = await memberRepo.getMembers();
    if (members.isEmpty) return;

    final random = Random();
    final List<EventRegistration> registrations = [];
    
    // Realistic guest names
    final guestNames = [
      'Emma Thompson',
      'Oliver Bennett',
      'Sophie Clarke',
      'Harry Wilson',
      'Charlotte Davis',
      'George Walker',
      'Amelia Foster',
      'William Hughes',
      'Lucy Martinez',
      'Jack Anderson',
    ];
    
    // 1. Set random event capacity (28, 32, 36) - must be multiple of 4
    final eventCapacity = (7 + random.nextInt(3)) * 4; // 28, 32, or 36
    
    // 2. Over-register by 5-12 people
    final totalRegistrations = eventCapacity + 5 + random.nextInt(8); // capacity + 5-12
    final numGuests = 6 + random.nextInt(5); // 6-10 guests
    final numMembers = totalRegistrations - numGuests;
    
    // 3. Add 2-4 dinner-only members
    final numDinnerOnly = 2 + random.nextInt(3); // 2-4
    
    final isMorning = event.teeOffTime?.hour != null && event.teeOffTime!.hour < 13;
    
    // Calculate buggy assignments
    final availableBuggies = event.availableBuggies ?? 10;
    final buggyCapacity = availableBuggies * 2;
    final buggiesNeeded = (buggyCapacity * (0.5 + random.nextDouble() * 0.4)).round();
    
    // Member golfers (playing golf)
    final memberParticipants = members.take(numMembers).toList();
    final memberIndicesWithBuggies = <int>{};
    while (memberIndicesWithBuggies.length < buggiesNeeded && memberIndicesWithBuggies.length < memberParticipants.length) {
      memberIndicesWithBuggies.add(random.nextInt(memberParticipants.length));
    }

    // Create member registrations - some will bring guests
    int nextGuestIndex = 0;
    final guestBringingMembers = <int>{}; // Track which members bring guests
    
    // Randomly select members to bring guests (up to numGuests total)
    while (guestBringingMembers.length < numGuests && guestBringingMembers.length < numMembers) {
      final memberIndex = random.nextInt(numMembers);
      guestBringingMembers.add(memberIndex);
    }
    
    for (int i = 0; i < memberParticipants.length; i++) {
      final m = memberParticipants[i];
      
      // Randomly assign some as withdrawn (2-5%)
      final isWithdrawn = random.nextDouble() < 0.03;
      final registrationTime = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      
      // Does this member bring a guest?
      final bringsGuest = guestBringingMembers.contains(i) && nextGuestIndex < numGuests && !isWithdrawn;
      
      registrations.add(EventRegistration(
        memberId: m.id,
        memberName: m.displayName,
        attendingGolf: true,
        attendingBreakfast: isMorning,
        attendingLunch: !isMorning,
        attendingDinner: random.nextBool(),
        needsBuggy: !isWithdrawn && memberIndicesWithBuggies.contains(i),
        hasPaid: !isWithdrawn,
        isConfirmed: !isWithdrawn,
        statusOverride: isWithdrawn ? 'withdrawn' : null,
        registeredAt: registrationTime,
        // Guest data if this member brings a guest (same registration time and payment status)
        guestName: bringsGuest ? guestNames[nextGuestIndex % guestNames.length] : null,
        guestHandicap: bringsGuest ? (random.nextInt(20) + 5).toString() : null,
        guestAttendingBreakfast: bringsGuest && isMorning,
        guestAttendingLunch: bringsGuest && !isMorning,
        guestAttendingDinner: bringsGuest && random.nextBool(),
        guestNeedsBuggy: bringsGuest && random.nextBool() && (buggiesNeeded - memberIndicesWithBuggies.length) > 0,
        guestIsConfirmed: bringsGuest,
      ));
      
      if (bringsGuest) nextGuestIndex++;
    }

    // Add dinner-only members
    final dinnerOnlyMembers = members.skip(numMembers).take(numDinnerOnly).toList();
    for (final m in dinnerOnlyMembers) {
      registrations.add(EventRegistration(
        memberId: m.id,
        memberName: m.displayName,
        attendingGolf: false,
        attendingBreakfast: false,
        attendingLunch: false,
        attendingDinner: true,
        hasPaid: true,
        isConfirmed: true,
        registeredAt: DateTime.now().subtract(Duration(days: random.nextInt(20))),
      ));
    }

    // Flatten and sort by Rank (Priority) then Time
    // Rank logic: Member (Confirmed candidate) > Guest (Confirmed candidate)
    
    final pool = <({int regIndex, bool isGuest, DateTime time, int rank})>[];
    for (int i = 0; i < registrations.length; i++) {
      final r = registrations[i];
      if (!r.attendingGolf || r.statusOverride == 'withdrawn') continue;
      
      final time = r.registeredAt ?? DateTime.now();
      pool.add((regIndex: i, isGuest: false, time: time, rank: 0));
      if (r.guestName != null && r.guestName!.isNotEmpty) {
        pool.add((regIndex: i, isGuest: true, time: time, rank: 1));
      }
    }

    // Sort by Priority (Member > Guest) then FCFS
    pool.sort((a, b) {
      if (a.rank != b.rank) return a.rank.compareTo(b.rank);
      return a.time.compareTo(b.time);
    });
    
    // Now allocate slots in this priority order
    int slotsAllocated = 0;
    final confirmedSet = <String>{}; // "index_isGuest"
    
    for (var item in pool) {
      // Determine if they can play (confirmed)
      // Most who get a slot pay (93%), but 7% stay "reserved" (unconfirmed)
      bool getsSlot = slotsAllocated < eventCapacity;
      bool isPaid = getsSlot && (random.nextDouble() > 0.07);
      
      // If over capacity, they can still have paid but they are waitlisted
      // In seeding terms, we'll mark them as isConfirmed = true so they hit the waitlist
      if (!getsSlot) {
        isPaid = random.nextBool();
      }

      if (isPaid || getsSlot) {
         confirmedSet.add("${item.regIndex}_${item.isGuest}");
         if (isPaid && getsSlot) slotsAllocated++;
      }
    }

    // Apply back to registrations
    for (int i = 0; i < registrations.length; i++) {
        final reg = registrations[i];
        if (!reg.attendingGolf || reg.statusOverride == 'withdrawn') continue;

        final memberConfirmed = confirmedSet.contains("${i}_false");
        final guestConfirmed = confirmedSet.contains("${i}_true");
        
        // Final hasPaid is true if either member or guest is confirmed/paid
        // (Guest payment is linked to member)
        final hasPaid = memberConfirmed || guestConfirmed;

        registrations[i] = reg.copyWith(
          hasPaid: hasPaid,
          isConfirmed: memberConfirmed,
          guestIsConfirmed: guestConfirmed,
        );
    }

    // 4. GENERATE REALISTIC GROUPING USING APP LOGIC (GroupingService)
    // This replaces the old generic Texas Scramble grouping logic
    final allEvents = await eventRepo.watchEvents().first; 
    final history = allEvents.where((e) => e.seasonId == event.seasonId && e.date.isBefore(event.date)).toList();
    final handicapMap = {for (var m in members) m.id: m.handicap};

    // IMPORTANT: Create an updated event object so the logic uses the registrations we just generated
    final updatedEvent = event.copyWith(
      registrations: registrations,
      maxParticipants: eventCapacity,
      status: (isPast && !forceResetStatus) ? event.status : EventStatus.published, // Reset status to published if not past OR if forced
    );

    final flattenedItems = RegistrationLogic.getSortedItems(updatedEvent);
    
    final groups = GroupingService.generateInitialGrouping(
      event: updatedEvent,
      participants: flattenedItems,
      previousEventsInSeason: history,
      memberHandicaps: handicapMap,
    );

    final Map<String, dynamic> groupingData = {
      'groups': groups.map((g) => g.toJson()).toList(),
      'locked': true,
      'isPublished': true,
    };

    // 5. SEED SCORES
    final bool isTexasScramble = event.title.toLowerCase().contains('scramble');
    List<Map<String, dynamic>> results = [];
    
    if (isTexasScramble) {
      results = await seedTeamScores(
        eventId, 
        groupingData, 
        event.courseConfig,
        status: isPast ? ScorecardStatus.finalScore : ScorecardStatus.submitted,
      );
    } else {
      results = await seedScores(
        eventId, 
        flattenedItems, 
        event.courseConfig,
        eventCapacity,
        event.isRegistrationClosed,
        handicapMap,
        status: isPast ? ScorecardStatus.finalScore : ScorecardStatus.submitted,
        skipScorecardDocuments: !isPast,
      );
    }

    await eventRepo.updateEvent(updatedEvent.copyWith(
      grouping: groupingData,
      isGroupingPublished: true,
      results: isPast ? results : [], // Skip leaderboard results for future events
    ));
  }

  Future<List<Map<String, dynamic>>> seedTeamScores(
    String eventId,
    Map<String, dynamic> groupingData,
    Map<String, dynamic> courseConfig,
    {ScorecardStatus status = ScorecardStatus.submitted}
  ) async {
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final random = Random();
    final holes = courseConfig['holes'] as List<dynamic>? ?? [];
    if (holes.isEmpty) return [];

    final groupsList = groupingData['groups'] as List? ?? [];
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < groupsList.length; i++) {
      final gData = groupsList[i];
      final group = TeeGroup.fromJson(gData);
      final teamId = 'team_${group.index}'; 
      final List<int?> holeScores = [];
      int grossTotal = 0;
      
      for (var holeData in holes) {
        final par = holeData['par'] as int? ?? 4;
        final r = random.nextDouble();
        int score = par;
        if (r < 0.3) score = par - 1; 
        if (r < 0.05) score = par - 2; 
        holeScores.add(score);
        grossTotal += score;
      }
      
      // Calculate Team Points (Mock for seeding)
      int totalPoints = 0;
      int grossPoints = 0;
      for (int h = 0; h < holeScores.length; h++) {
         final hole = holes[h];
         final par = hole['par'] as int? ?? 4;
         final score = holeScores[h] ?? par;
         
         // Net Points (Mock handicap application?)
         // For teams, maybe just assume some default?
         totalPoints += max(0, par - (score - 1) + 2).toInt(); // Assume 1 shot per hole for team
         grossPoints += max(0, par - score + 2).toInt();
      }

      await scorecardRepo.addScorecard(Scorecard(
        id: '',
        competitionId: eventId,
        roundId: 'round_1',
        entryId: teamId,
        submittedByUserId: 'system_seed',
        status: status,
        holeScores: holeScores,
        grossTotal: grossTotal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      results.add({
        'playerId': teamId,
        'playerName': 'Team ${group.index + 1}',
        'holeScores': holeScores,
        'grossTotal': grossTotal,
        'grossPoints': grossPoints,
        'points': totalPoints,
        'status': status.name,
        'rank': i + 1,
      });
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> seedScores(
    String eventId, 
    List<RegistrationItem> items, 
    Map<String, dynamic> courseConfig,
    int capacity,
    bool isClosed,
    Map<String, double> memberHandicaps,
    {ScorecardStatus status = ScorecardStatus.submitted, bool skipScorecardDocuments = false}
  ) async {
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final random = Random();

    final holes = courseConfig['holes'] as List<dynamic>? ?? [];
    if (holes.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    int confirmedCount = 0;
    
    for (var item in items) {
      final regStatus = RegistrationLogic.calculateStatus(
        isGuest: item.isGuest, 
        isConfirmed: item.isConfirmed, 
        hasPaid: item.hasPaid, 
        confirmedCount: confirmedCount, 
        capacity: capacity, 
        isEventClosed: isClosed,
        statusOverride: item.statusOverride,
      );

      if (regStatus != RegistrationStatus.confirmed) continue;
      confirmedCount++;

      final String entryId = item.isGuest ? "${item.registration.memberId}_guest" : item.registration.memberId;
      final String displayName = item.isGuest ? (item.registration.guestName ?? 'Guest') : item.registration.memberName;

      double handicap = 18.0;
      if (item.isGuest) {
        handicap = double.tryParse(item.registration.guestHandicap ?? '18') ?? 18.0;
      } else {
        handicap = memberHandicaps[item.registration.memberId] ?? 18.0;
      }

      final skillBias = (handicap / 18.0).clamp(0.5, 3.0);
      final List<int?> holeScores = [];
      int grossTotal = 0;
      
      for (var holeData in holes) {
          final par = holeData['par'] as int? ?? 4;
          final r = random.nextDouble() * 10;
          int score;
          
          if (r < 0.1 / skillBias) {
            score = par - 2;
          } else if (r < 1.0 / skillBias) {
            score = par - 1;
          } else if (r < 5.5 / skillBias) {
            score = par;
          } else if (r < 8.5) {
            score = par + 1;
          } else if (r < 9.5) {
            score = par + 2;
          } else {
            score = par + 3;
          }

          holeScores.add(score);
          grossTotal += score;
      }

      // Calculate Stableford points (Simplified for seeding)
      int totalPoints = 0;
      int grossPoints = 0;
      final pHandicap = handicap.round();
      for (int i = 0; i < holeScores.length; i++) {
        final par = holes[i]['par'] as int? ?? 4;
        final si = holes[i]['si'] as int? ?? (i + 1);
        final score = holeScores[i]!;
        int shots = (pHandicap / 18).floor();
        if (pHandicap % 18 >= si) shots++;
        final netScore = score - shots;
        totalPoints += max(0, par - netScore + 2).toInt();
        grossPoints += max(0, par - score + 2).toInt();
      }

      if (!skipScorecardDocuments) {
        await scorecardRepo.addScorecard(Scorecard(
          id: '',
          competitionId: eventId,
          roundId: 'round_1',
          entryId: entryId,
          submittedByUserId: 'system_seed',
          status: status,
          holeScores: holeScores,
          grossTotal: grossTotal,
          netTotal: grossTotal - pHandicap,
          points: totalPoints,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      results.add({
        'playerId': entryId,
        'playerName': displayName,
        'handicap': handicap,
        'playingHandicap': pHandicap,
        'holeScores': holeScores,
        'grossTotal': grossTotal,
        'netTotal': grossTotal - pHandicap,
        'points': totalPoints,
        'grossPoints': grossPoints,
        'status': status.name,
      });
    }

    // Sort by points descending for Stableford events
    results.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    for (int i = 0; i < results.length; i++) {
      results[i]['rank'] = i + 1;
    }

    return results;
  }

  Future<void> swapLabEventFormat(String templateId) async {
    final compRepo = ref.read(competitionsRepositoryProvider);
    final templates = await compRepo.getTemplates();
    
    // Fallback: fetch from templatesListProvider if available
    final template = templates.firstWhere((t) => t.id == templateId, 
      orElse: () => throw Exception('Template not found: $templateId'));

    // Update the competition linked to the lab event
    final labComp = Competition(
      id: 'lab_open_001', // Must match Event ID
      type: CompetitionType.event,
      status: CompetitionStatus.draft,
      rules: template.rules,
      startDate: DateTime.now(), // Dates will be overridden by event if needed
      endDate: DateTime.now(),
      publishSettings: {},
      isDirty: true,
    );

    await compRepo.updateCompetition(labComp);
  }

  Competition _createTemplate({
    required String name,
    required CompetitionFormat format,
    CompetitionSubtype subtype = CompetitionSubtype.none,
    CompetitionMode mode = CompetitionMode.singles,
    double allowance = 0.95,
    int minDrives = 0,
    bool useWHS = false,
  }) {
    return Competition(
      id: '',
      type: CompetitionType.game,
      rules: CompetitionRules(
        format: format,
        subtype: subtype,
        mode: mode,
        handicapAllowance: allowance,
        minDrivesPerPlayer: minDrives,
        useWHSScrambleAllowance: useWHS,
      ),
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      status: CompetitionStatus.open,
    );
  }

  Future<void> generateTestMatches(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    
    // Check if matches already exist
    final grouping = Map<String, dynamic>.from(event.grouping);
    if (grouping.containsKey('matches')) {
       // Already has matches, maybe clear them or just return?
       // For testing convenience, let's clear and regen if called.
    }
    
    final groups = (grouping['groups'] as List?) ?? [];
    if (groups.isEmpty) return;
    
    final List<Map<String, dynamic>> matches = [];
    
    for (var g in groups) {
      final players = (g['players'] as List);
      // Create Singles Matches: P1 vs P2, P3 vs P4
      for (int i = 0; i < players.length - 1; i += 2) {
        final p1 = players[i];
        final p2 = players[i+1];
        
        // Simple Singles Match
        final matchId = 'match_${eventId}_${g['index']}_$i';
        
        matches.add({
          'id': matchId,
          'type': 'singles', // MatchType.singles.name
          'team1Ids': [p1['registrationMemberId'] ?? ''],
          'team2Ids': [p2['registrationMemberId'] ?? ''],
          'strokesReceived': {}, // Flat match for now, or random?
          'team1Name': p1['name'],
          'team2Name': p2['name'],
          'groupId': g['index'].toString(), // Use index or ID
        });
      }
    }
    
    grouping['matches'] = matches;
    
    // Update event
    final updatedEvent = event.copyWith(grouping: grouping);
    await eventRepo.updateEvent(updatedEvent);
  }

  Future<void> generateTestBracket(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    
    final grouping = Map<String, dynamic>.from(event.grouping);
    final List<Map<String, dynamic>> matches = [];
    final players = (event.grouping['groups'] as List?)?.expand((g) => g['players'] as List).toList() ?? [];
    
    if (players.length < 8) return; // Need at least 8 for a decent bracket

    final bracketId = 'test_bracket_$eventId';
    
    // 1. Quarter Finals (8 players)
    for (int i = 0; i < 4; i++) {
       final p1 = players[i * 2];
       final p2 = players[i * 2 + 1];
       matches.add({
         'id': 'qf_${eventId}_$i',
         'type': 'singles',
         'team1Ids': [p1['registrationMemberId']],
         'team2Ids': [p2['registrationMemberId']],
         'team1Name': p1['name'],
         'team2Name': p2['name'],
         'round': 'quarterFinal',
         'bracketId': bracketId,
         'bracketOrder': i,
       });
    }

    // 2. Semi Finals (Placeholders)
    for (int i = 0; i < 2; i++) {
       matches.add({
         'id': 'sf_${eventId}_$i',
         'type': 'singles',
         'team1Ids': [], // TBD
         'team2Ids': [], // TBD
         'team1Name': 'Winner QF ${i*2 + 1}',
         'team2Name': 'Winner QF ${i*2 + 2}',
         'round': 'semiFinal',
         'bracketId': bracketId,
         'bracketOrder': i,
       });
    }

    // 3. Final
    matches.add({
       'id': 'f_$eventId',
       'type': 'singles',
       'team1Ids': [],
       'team2Ids': [],
       'team1Name': 'Winner SF 1',
       'team2Name': 'Winner SF 2',
       'round': 'finalRound',
       'bracketId': bracketId,
       'bracketOrder': 0,
    });
    
    grouping['matches'] = matches;
    final updatedEvent = event.copyWith(grouping: grouping);
    await eventRepo.updateEvent(updatedEvent);
  }

  Future<void> simulateMatchScores(String eventId) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;

    final matchesList = event.grouping['matches'] as List?;
    if (matchesList == null) return;

    final random = Random();
    
    for (var mData in matchesList) {
      final team1Ids = (mData['team1Ids'] as List).cast<String>();
      final team2Ids = (mData['team2Ids'] as List).cast<String>();
      if (team1Ids.isEmpty || team2Ids.isEmpty) continue;

      // Seed scores for both teams
      final allPlayerIds = [...team1Ids, ...team2Ids];
      
      // Determine a winner for the simulation
      final winnerSide = random.nextBool() ? 1 : 2;

      
      for (var pid in allPlayerIds) {
        final isWinnerTeam = (winnerSide == 1 && team1Ids.contains(pid)) || (winnerSide == 2 && team2Ids.contains(pid));
        
        final holeScores = List.generate(18, (i) {
          // Winner gets more pars/birdies, loser gets more bogeys
          final rand = random.nextInt(100);
          if (isWinnerTeam) {
            if (rand < 20) return 3; // Birdie
            if (rand < 80) return 4; // Par
            return 5; // Bogey
          } else {
            if (rand < 5) return 3;
            if (rand < 40) return 4;
            if (rand < 90) return 5;
            return 6; // Double
          }
        });

        await scorecardRepo.addScorecard(Scorecard(
          id: '',
          competitionId: eventId,
          roundId: mData['round'] ?? 'round_1',
          entryId: pid,
          submittedByUserId: 'system_simulation',
          status: ScorecardStatus.finalScore,
          holeScores: holeScores,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> advanceBracket(String eventId) async {
    // This would require MatchPlayCalculator to find winners
    // For now, it's a placeholder for the logic that takes winners of Round 1
    // and places them into the TBD slots of Round 2.
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
      
      // Round Robin within the group
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
    final updatedEvent = event.copyWith(grouping: grouping);
    await eventRepo.updateEvent(updatedEvent);
  }
}

final seedingServiceProvider = Provider((ref) => SeedingService(ref));
