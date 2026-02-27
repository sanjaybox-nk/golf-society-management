import 'dart:math';
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

import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'persistence_service.dart';

/// Unified Seeding Service for both basic and advanced demo data.
class SeedingService {
  final Ref ref;
  final Random _random = Random();
  
  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await _seedCourses();
  }

  Future<void> seedRegistrations(String eventId, {bool forceResetStatus = false}) async {
    // Basic registration seeding or just use full demo seeder logic
    // For now, mapping this to a basic version if still needed, but seedFullDemoData is preferred.
  }

  // Male Names (50)
  static const maleFirstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Daniel', 'Matthew', 'Anthony', 'Donald', 'Mark', 'Paul', 'Steven', 'Andrew', 'Kenneth', 'Joshua', 'Kevin', 'Brian', 'George', 'Edward', 'Ronald', 'Timothy', 'Jason', 'Jeffrey', 'Ryan', 'Jacob'];
  
  // Female Names (20)
  static const femaleFirstNames = ['Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 'Nancy', 'Lisa', 'Margaret', 'Betty', 'Sandra', 'Ashley', 'Dorothy', 'Kimberly', 'Emily', 'Donna'];
  
  static const lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King'];

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
      'leaderboard_templates',
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
        templates: userTemplates,
        isMultiDay: config.isMultiDay,
        endDate: config.endDate,
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
      bio: 'The Creator. Loves a tech-infused round of golf.',
      phone: '+44 7700 900000',
    ));

    for (int i = 0; i < 74; i++) {
        bool isFemale = i < 20;
        final fNameList = isFemale ? femaleFirstNames : maleFirstNames;
        final fName = fNameList[i % fNameList.length];
        final lName = lastNames[(i + _random.nextInt(10)) % lastNames.length];
        
        String? role;
        if (i == 20) role = 'President';
        if (i == 21) role = 'Captain';
        if (i == 0) role = 'Social Sec';

        double hc = (i < 10) ? (1.0 + _random.nextDouble() * 5) : ((i < 40) ? (6.0 + _random.nextDouble() * 14) : (20.0 + _random.nextDouble() * 16));
        if (isFemale) hc += 2.0; 

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
          phone: '+44 7${100000000 + i}',
        ));
    }
  }

  Future<List<Course>> _seedCourses() async {
    final repo = ref.read(courseRepositoryProvider);
    final List<Course> courses = [];
    final names = ['St Andrews', 'Pebble Beach', 'TPC Sawgrass', 'Augusta', 'Royal County Down', 'Muirfield', 'Shinnecock Hills', 'Oakmont', 'Cypress Point', 'Pine Valley', 'Royal Melbourne'];

    for (int i = 0; i < names.length; i++) {
      final course = Course(
        id: 'demo_c_$i',
        name: names[i],
        address: 'Golf Coast, Demo Land',
        isGlobal: false,
        tees: [
          TeeConfig(
            name: 'White',
            rating: 71.0 + i % 5, 
            slope: 128 + (i * 3) % 30,
            holePars: [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5], 
            holeSIs: _generateSI(),
            yardages: List.generate(18, (h) => 380 + _random.nextInt(200)), 
          ),
          TeeConfig(
            name: 'Yellow',
            rating: 70.0 + i % 5, 
            slope: 125 + (i * 3) % 30, 
            holePars: [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5],
            holeSIs: _generateSI(),
            yardages: List.generate(18, (h) => 350 + _random.nextInt(200)), 
          ),
          TeeConfig(
            name: 'Blue',
            rating: 69.0 + i % 5, 
            slope: 122 + (i * 3) % 30, 
            holePars: [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5],
            holeSIs: _generateSI(),
            yardages: List.generate(18, (h) => 320 + _random.nextInt(200)), 
          ),
          TeeConfig(
            name: 'Red',
            rating: 72.0 + i % 4, 
            slope: 120 + (i * 2) % 30,
            holePars: [4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5], 
            holeSIs: _generateSI(), 
            yardages: List.generate(18, (h) => 280 + _random.nextInt(150)), 
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
    required List<Competition> templates,
    bool isMultiDay = false,
    DateTime? endDate,
  }) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    final yellowTee = course.tees.firstWhere((t) => t.name == 'Yellow');

    final event = GolfEvent(
      id: 'demo_ev_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
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
      selectedTeeName: 'Yellow',
      selectedFemaleTeeName: 'Red',
      courseConfig: {
        'tees': course.tees.map((t) => t.toMap()).toList(),
        'mensTeeName': 'Yellow',
        'ladiesTeeName': 'Red',
        'holes': yellowTee.holePars.asMap().entries.map((e) => {
          'hole': e.key + 1,
          'par': e.value,
          'si': yellowTee.holeSIs[e.key],
          'yardage': yellowTee.yardages[e.key],
        }).toList(),
        'par': yellowTee.holePars.fold(0, (a, b) => a + b),
        'slope': yellowTee.slope,
        'rating': yellowTee.rating,
      },
      hasBreakfast: true,
      hasDinner: true,
      maxParticipants: 40,
      description: 'A fantastic day of competitive golf at ${course.name}. Join us for 18 holes of $format followed by a group dinner and prize giving ceremony.',
      registrationDeadline: date.subtract(const Duration(days: 7)),
      memberCost: 45.0 + _random.nextInt(20),
      guestCost: 55.0 + _random.nextInt(20),
    );

    // Registration Matrix
    final List<EventRegistration> regs = [];
    final targetRegCount = 30 + _random.nextInt(15);
    final cardStatus = status == EventStatus.completed ? ScorecardStatus.finalScore : ScorecardStatus.draft;
    
    // Sanjay
    final hero = members.firstWhereOrNull((m) => m.id == 'demo_hero_sanjay');
    if (hero != null) {
      regs.add(EventRegistration(
        memberId: hero.id, memberName: hero.displayName, attendingGolf: true,
        attendingBreakfast: true, attendingLunch: true, attendingDinner: true,
        hasPaid: true, isConfirmed: true, handicap: hero.handicap,
        registeredAt: date.subtract(const Duration(days: 25)), statusOverride: 'confirmed',
      ));
    }

    for (int i = 0; i < targetRegCount; i++) {
        final m = members[i % members.length];
        if (m.id == 'demo_hero_sanjay') continue;
        
        bool isWithdrawn = _random.nextDouble() < 0.08;
        bool attendingGolf = !isWithdrawn && regs.length < 40;
        String? regStatus = isWithdrawn ? 'withdrawn' : (regs.length >= 40 ? 'waitlist' : 'confirmed');

        regs.add(EventRegistration(
          memberId: m.id, memberName: m.displayName, attendingGolf: attendingGolf,
          attendingDinner: true, hasPaid: attendingGolf, isConfirmed: regStatus == 'confirmed',
          handicap: m.handicap, registeredAt: date.subtract(Duration(days: 30 - (i % 20))),
          statusOverride: regStatus,
        ));
    }

    final updatedEvent = event.copyWith(registrations: regs);
    await eventRepo.addEvent(updatedEvent);

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
              courseConfig: {'rating': tee.rating, 'slope': tee.slope, 'par': tee.holePars.fold(0, (a, b) => a + b), 'holes': tee.holePars.asMap().entries.map((e) => {'hole': e.key + 1, 'par': e.value, 'si': tee.holeSIs[e.key]}).toList()},
          );

          final holeScores = <int?>[];
          int grossTotal = 0;
          int pointsTotal = 0;

          for (int h = 0; h < 18; h++) {
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
              status: cardStatus, holeScores: holeScores,
              points: isStableford ? pointsTotal : null,
              handicapIndex: index, playingHandicap: phc,
              netTotal: grossTotal - phc.round(),
              createdAt: DateTime.now(), updatedAt: DateTime.now(),
          ));
          results.add({'playerId': entryId, 'playerName': p.name, 'points': isStableford ? pointsTotal : (grossTotal - phc.round()), 'holeScores': holeScores, 'phc': phc});
      }
    }

    results.sort((a, b) => (b['points'] as num).compareTo(a['points'] as num));
    await eventRepo.updateEvent(updatedEvent.copyWith(grouping: {'groups': groups.map((g) => g.toJson()).toList(), 'isPublished': true}, results: status == EventStatus.completed ? results : []));
    
    return results;
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
