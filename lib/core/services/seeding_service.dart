import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:golf_society/features/events/presentation/events_provider.dart';

class SeedingService {
  final Ref ref;

  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await seedCourses();
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
          'par': selectedCourse.tees.first.holePars.fold(0, (sum, p) => sum + p),
        },
      );

      await eventRepo.addEvent(event);
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
      await repo.addCompetition(t);
    }
  }

  Future<void> seedCurrentSeason() async {
    final repo = ref.read(seasonsRepositoryProvider);
    final seasons = await repo.getSeasons();
    
    if (seasons.isEmpty) {
      final now = DateTime.now();
      final season = Season(
        id: '',
        name: '${now.year} Society Tour',
        year: now.year,
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
        status: SeasonStatus.active,
        isCurrent: true,
        leaderboards: [
          LeaderboardConfig.orderOfMerit(
            id: 'oom_2024',
            name: 'Order of Merit',
            source: OOMSource.position,
            appearancePoints: 2, // Participation points as per image
            positionPointsMap: {
              1: 25,
              2: 18,
              3: 15,
              4: 12,
            },
          ),
          LeaderboardConfig.markerCounter(
            id: 'birdie_tree_2024',
            name: 'Birdie Tree',
            targetTypes: {MarkerType.birdie, MarkerType.eagle, MarkerType.albatross},
          ),
          LeaderboardConfig.bestOfSeries(
            id: 'best_8_2024',
            name: 'Best 8 Series',
            bestN: 8,
            metric: BestOfMetric.stableford,
          ),
          LeaderboardConfig.eclectic(
            id: 'eclectic_2024',
            name: 'Season Eclectic',
            metric: EclecticMetric.strokes,
          ),
        ],
      );
      await repo.addSeason(season);
    }
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
          whsNumber: 'WHS${100000 + i}',
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
      maxParticipants: 40,
      memberCost: 45.0,
      guestCost: 65.0,
      hasBreakfast: true,
      hasLunch: true,
      hasDinner: true,
      breakfastCost: 10.0,
      lunchCost: 15.0,
      dinnerCost: 25.0,
      status: EventStatus.published,
      courseConfig: selectedCourse.tees.isNotEmpty ? {
        'holes': List.generate(18, (i) => {
          'hole': i + 1,
          'par': selectedCourse.tees.first.holePars[i],
          'si': selectedCourse.tees.first.holeSIs[i],
          'yardage': selectedCourse.tees.first.yardages[i],
        }),
        'par': selectedCourse.tees.first.holePars.fold(0, (sum, p) => sum + p),
        'slope': selectedCourse.tees.first.slope,
        'rating': selectedCourse.tees.first.rating,
      } : {},
    );

    await eventRepo.addEvent(labEvent);
    await seedRegistrations(labEvent.id);
  }

  Future<void> seedHistoricalEvents() async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final seasons = await ref.read(seasonsRepositoryProvider).getSeasons();
    if (seasons.isEmpty) return;
    
    final activeSeason = seasons.firstWhere((s) {
      return s.status == SeasonStatus.active;
    }, orElse: () => seasons.first);

    final courseRepo = ref.read(courseRepositoryProvider);
    final courses = await courseRepo.watchCourses().first;
    if (courses.isEmpty) return;

    final baseDate = DateTime.now();

    final historyConfigs = [
      {
        'id': 'hist_001',
        'title': 'Winter Stableford',
        'date': DateTime(baseDate.year, 1, 15, 9),
        'format': CompetitionFormat.stableford,
      },
      {
        'id': 'hist_002',
        'title': 'Spring Medal',
        'date': DateTime(baseDate.year, 3, 20, 10),
        'format': CompetitionFormat.stroke,
      },
      {
        'id': 'hist_003',
        'title': 'May Invitational',
        'date': DateTime(baseDate.year, 5, 12, 11),
        'format': CompetitionFormat.stableford, // Another stableford for leaderboard density
      },
    ];

    for (var config in historyConfigs) {
      final date = config['date'] as DateTime;
      final selectedCourse = courses[historyConfigs.indexOf(config) % courses.length];
      
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
        maxParticipants: 40,
        status: EventStatus.completed,
        courseConfig: selectedCourse.tees.isNotEmpty ? {
          'holes': List.generate(18, (i) => {
            'hole': i + 1,
            'par': selectedCourse.tees.first.holePars[i],
            'si': selectedCourse.tees.first.holeSIs[i],
            'yardage': selectedCourse.tees.first.yardages[i],
          }),
          'par': selectedCourse.tees.first.holePars.fold(0, (sum, p) => sum + p),
          'slope': selectedCourse.tees.first.slope,
          'rating': selectedCourse.tees.first.rating,
        } : {},
      );

      await eventRepo.addEvent(event);
      await seedRegistrations(event.id, isPast: true);
    }
  }

  Future<void> seedRegistrations(String eventId, {bool isPast = false}) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final memberRepo = ref.read(membersRepositoryProvider);
    
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;

    final members = await memberRepo.getMembers();
    if (members.isEmpty) return;

    final random = Random();
    final List<EventRegistration> registrations = [];
    
    // Fill 32 slots with members (8 groups of 4)
    final memberParticipants = members.take(32).toList();
    final isMorning = event.teeOffTime?.hour != null && event.teeOffTime!.hour < 13;

    for (var m in memberParticipants) {
      registrations.add(EventRegistration(
        memberId: m.id,
        memberName: m.displayName,
        attendingGolf: true,
        attendingBreakfast: isMorning,
        attendingLunch: !isMorning,
        attendingDinner: random.nextBool(),
        hasPaid: true,
        isConfirmed: true,
        registeredAt: DateTime.now(),
      ));
    }

    // Add 8 guests (to hit 40)
    for (int i = 0; i < 8; i++) {
      registrations.add(EventRegistration(
        memberId: 'guest_$i',
        memberName: 'Guest User $i',
        isGuest: true,
        attendingGolf: true,
        attendingBreakfast: isMorning,
        attendingLunch: !isMorning,
        attendingDinner: random.nextBool(),
        hasPaid: true,
        isConfirmed: true,
        registeredAt: DateTime.now(),
        guestHandicap: (random.nextInt(20) + 5).toString(),
      ));
    }

    // Team Grouping for Texas Scramble (Auto-grouping into 10 teams of 4)
    final Map<String, dynamic> grouping = {};
    for (int i = 0; i < 10; i++) {
        final teamId = 'team_${i + 1}';
        final membersInTeam = registrations.skip(i * 4).take(4).map((r) => r.memberId).toList();
        grouping[teamId] = {
            'name': 'Team ${i + 1}',
            'members': membersInTeam,
            'teeTime': event.teeOffTime?.add(Duration(minutes: i * 10)).toIso8601String(),
        };
    }

    await eventRepo.updateEvent(event.copyWith(
      registrations: registrations,
      grouping: grouping,
    ));

    // For Teams/Pairs, create scorecards for the ENTRIES (teams), not individual members
    final bool isTeams = grouping.isNotEmpty;
    
    if (isTeams) {
      await seedTeamScores(
        eventId, 
        grouping, 
        event.courseConfig,
        status: isPast ? ScorecardStatus.finalScore : ScorecardStatus.submitted,
      );
    } else {
      await seedScores(
        eventId, 
        registrations, 
        event.courseConfig,
        status: isPast ? ScorecardStatus.finalScore : ScorecardStatus.submitted,
      );
    }
  }

  Future<void> seedTeamScores(
    String eventId,
    Map<String, dynamic> grouping,
    Map<String, dynamic> courseConfig,
    {ScorecardStatus status = ScorecardStatus.submitted}
  ) async {
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final random = Random();
    final holes = courseConfig['holes'] as List<dynamic>? ?? [];
    if (holes.isEmpty) return;

    for (var entry in grouping.entries) {
      final teamId = entry.key;
      final List<int?> holeScores = [];
      
      for (var holeData in holes) {
        final par = holeData['par'] as int? ?? 4;
        // Teams usually score better!
        final r = random.nextDouble();
        int score = par;
        if (r < 0.3) score = par - 1; // Birdie
        if (r < 0.05) score = par - 2; // Eagle
        holeScores.add(score);
      }

      await scorecardRepo.addScorecard(Scorecard(
        id: '',
        competitionId: eventId,
        roundId: 'round_1',
        entryId: teamId,
        submittedByUserId: 'system_seed',
        status: status,
        holeScores: holeScores,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> seedScores(
    String eventId, 
    List<EventRegistration> registrations, 
    Map<String, dynamic> courseConfig,
    {ScorecardStatus status = ScorecardStatus.submitted}
  ) async {
    final scorecardRepo = ref.read(scorecardRepositoryProvider);
    final memberRepo = ref.read(membersRepositoryProvider);
    final random = Random();

    final holes = courseConfig['holes'] as List<dynamic>? ?? [];
    if (holes.isEmpty) return;

    for (var reg in registrations) {
      if (!reg.attendingGolf) {
        continue;
      }

      // Determine skill level for randomization
      double handicap = 18.0;
      if (!reg.isGuest) {
        final member = await memberRepo.getMember(reg.memberId);
        handicap = member?.handicap ?? 18.0;
      } else {
        handicap = double.tryParse(reg.guestHandicap ?? '18') ?? 18.0;
      }

      // Skill modifier: higher handicap = higher random offset
      final skillBias = (handicap / 18.0).clamp(0.5, 3.0);

      final List<int?> holeScores = [];
      for (var holeData in holes) {
          final par = holeData['par'] as int? ?? 4;
          
          // Generate a believable score
          // 0: albatross, 1: eagle, 2: birdie, 3: par, 4: bogey, 5: dbl, etc.
          // This is a rough normal distribution biased by skill
          final r = random.nextDouble() * 10;
          int score;
          
          if (r < 0.1 / skillBias) {
            score = par - 2; // Eagle (very rare)
          } else if (r < 1.0 / skillBias) {
            score = par - 1; // Birdie
          } else if (r < 5.5 / skillBias) {
            score = par; // Par
          } else if (r < 8.5) {
            score = par + 1; // Bogey
          } else if (r < 9.5) {
            score = par + 2; // Double
          } else {
            score = par + 3; // Triple+
          }

          holeScores.add(score);
      }

      final scorecard = Scorecard(
        id: '', // Firestore will assign
        competitionId: eventId,
        roundId: 'round_1',
        entryId: reg.memberId,
        submittedByUserId: 'system_seed',
        status: status,
        holeScores: holeScores,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await scorecardRepo.addScorecard(scorecard);
    }
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
}

final seedingServiceProvider = Provider((ref) => SeedingService(ref));
