import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/scoring/scorecard_constants.dart';
import 'package:golf_society/utils/guest_id_helper.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/course_config.dart' as cfg;
import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import 'package:golf_society/domain/scoring/handicap_calculator.dart';
import 'package:golf_society/domain/grouping/grouping_service.dart';
import 'package:golf_society/features/matchplay/domain/match_definition.dart';
import 'package:golf_society/features/events/logic/event_analysis_engine.dart';
import 'data_constants.dart';
import 'newsletter_templates.dart';
import 'package:golf_society/features/guests/data/guest_repository.dart';

class EventSeeder {
  final Ref ref;
  final Random random;

  EventSeeder(this.ref, this.random);

  Future<List<Map<String, dynamic>>> createFullEvent({
    required String seasonId,
    Course? course,
    required String title,
    required DateTime date,
    required CompetitionFormat format,
    required bool isInvitational,
    bool isSeasonEvent = true,
    CompetitionSubtype subtype = CompetitionSubtype.none,
    required List<Member> members,
    required Map<String, double> appliedCuts,
    required EventStatus status,
    required List<Competition> templates,
    bool isMultiDay = false,
    DateTime? endDate,
    int eventIndex = 0,
    EventType eventType = EventType.golf,
    double charityPot = 0.0,
    bool hasMatchPlayOverlay = false,
  }) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    final bool isSocial = eventType == EventType.social;
    final yellowTee = course?.tees.firstWhereOrNull((t) => t.name == 'Yellow') ?? course?.tees.firstOrNull;

    final isPrestige = title.contains('PRESTIGE');
    final double societyGreenFee = isPrestige ? (150.0 + random.nextInt(150)) : (45.0 + random.nextInt(40));
    
    final cateringCombo = isSocial ? -1 : random.nextInt(3);
    final hasBreakfast = cateringCombo == 0 || cateringCombo == 1;
    final hasLunch = cateringCombo == 2;
    final hasDinner = cateringCombo == 1 || cateringCombo == 2;

    final double breakfastCost = hasBreakfast ? 10.0 : 0.0;
    final double lunchCost = hasLunch ? 15.0 : 0.0;
    final double venueDinnerCost = hasDinner ? 30.0 : 0.0;
    
    final double eventBaseCost = societyGreenFee + breakfastCost + lunchCost;
    final double memberTotal = (eventBaseCost * 1.15).roundToDouble();
    final double guestTotal = (memberTotal + 15.0).roundToDouble();
    final double memberDinnerCost = (venueDinnerCost * 1.15).roundToDouble();

    final int regHour = 8;
    final int regMinutes = 30 + random.nextInt(75);
    final DateTime golfRegTime = date.copyWith(hour: regHour, minute: regMinutes);
    final DateTime golfTeeOff = golfRegTime.add(const Duration(minutes: 90));

    if (course != null) {
      if (kDebugMode) print('SEEDER_DIAG: Course ${course.name} has ${course.tees.length} tees');
    }

    var event = GolfEvent(
      id: 'demo_e_${random.nextInt(100000)}',
      seasonId: seasonId,
      courseId: course?.id ?? 'demo_c_0',
      courseName: course?.name ?? 'TBD Course',
      title: title,
      date: date,
      status: status,
      isInvitational: isInvitational,
      isSeasonEvent: isSeasonEvent,
      isMultiDay: isMultiDay,
      endDate: endDate,
      eventType: eventType,
      regTime: isSocial ? date.copyWith(hour: 18) : golfRegTime,
      teeOffTime: isSocial ? null : golfTeeOff,
      courseDetails: course?.address,
      selectedTeeName: isSocial ? null : 'Yellow',
      selectedFemaleTeeName: isSocial ? null : 'Red',
      courseConfig: (isSocial || course == null) ? const cfg.CourseConfig() : cfg.CourseConfig(
        tees: course.tees.map((t) => cfg.TeeConfig(
          name: t.name,
          color: t.color, // [FIX] Added missing color mapping
          rating: t.rating,
          slope: t.slope,
          holePars: t.holePars,
          holeSIs: t.holeSIs,
          yardages: t.yardages,
        )).toList(),
        selectedTeeName: 'Yellow',
        holes: yellowTee!.holePars.asMap().entries.map((e) => cfg.CourseHole(
          hole: e.key + 1,
          par: e.value,
          si: yellowTee.holeSIs[e.key],
          yardage: yellowTee.yardages[e.key],
        )).toList(),
        par: yellowTee.holePars.fold<int>(0, (a, b) => a + b),
        slope: yellowTee.slope,
        rating: yellowTee.rating,
      ),
      hasBreakfast: hasBreakfast,
      hasLunch: hasLunch,
      hasDinner: hasDinner,
      description: isSocial 
          ? 'Join us for the $title! A great opportunity for members to socialize and catch up away from the fairways.'
          : 'A fantastic day of competitive golf at ${course?.name}.',
      registrationDeadline: date.subtract(const Duration(days: 4)),
      societyGreenFee: societyGreenFee,
      societyBreakfastCost: breakfastCost,
      societyLunchCost: lunchCost,
      societyDinnerCost: venueDinnerCost,
      
      memberCost: isSocial ? 0.0 : memberTotal,
      guestCost: isSocial ? 0.0 : guestTotal,
      breakfastCost: 0, 
      lunchCost: 0,
      dinnerCost: memberDinnerCost,

      extraCosts: isSocial ? [
        const EventExtraCost(id: 'seed_ticket', label: 'Ticket Price', amount: 30.0),
        const EventExtraCost(id: 'seed_raffle', label: 'Raffle Entry (Opt)', amount: 5.0),
      ] : [],

      expenses: isSocial ? [] : [
        EventExpense(id: 'starter_pack', label: 'Starter Pack (Water/Fruit)', amount: 1.5 * (isSocial ? 20 : 32)),
      ],

      buggyCost: isSocial ? 0.0 : 15.0,
      availableBuggies: isSocial ? 0 : (10 + random.nextInt(20)),
      dinnerLocation: isSocial ? 'Local Bistro' : 'The Clubhouse Restaurant',
      dressCode: isSocial ? 'Casual' : 'Smart Casual / No Jeans',
      facilities: isSocial ? ['Parking', 'Bar', 'Restaurant'] : ['Pro Shop', 'Driving Range', 'Changing Rooms', 'Halfway House'],
      maxParticipants: isSocial ? 60 : 40,

      showRegistrationButton: !isSocial && status != EventStatus.cancelled,
      isGroupingPublished: !isSocial && (status == EventStatus.completed || status == EventStatus.inPlay),
      isStatsReleased: !isSocial && (status == EventStatus.completed || status == EventStatus.inPlay),
      isScoringLocked: !isSocial && status == EventStatus.completed,

      notes: [
        EventNote(
          title: 'Welcome Message',
          content: jsonEncode([
            {'insert': 'Welcome to the '},
            {'insert': title, 'attributes': {'bold': true}},
            {'insert': '!\n\n${isSocial ? "We are excited to host this social gathering. Please arrive on time as dinner will be served promptly." : "Please arrive at least 45 minutes before your tee time for registration and breakfast."}\n'}
          ]),
        ),
      ],
      galleryUrls: isSocial ? [] : _getGalleryPhotos(course?.name ?? ''),
      charityPot: charityPot,
    );

    if (isMultiDay && !isSocial) {
      event = event.copyWith(
        notes: [
          ...event.notes,
          ..._getTourNotes(title),
        ],
      );
    }

    // Registration Matrix
    final List<EventRegistration> regs = [];
    int targetRegCount = (isSocial ? 45 : 30) + random.nextInt(15);
    
    // For Match Play, ensure we have an even number of participants
    if (hasMatchPlayOverlay) {
      final bool isPairs = (subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes);
      if (isPairs) {
         // Ensure multiples of 4 for team-based match play
         targetRegCount = (targetRegCount / 4).ceil() * 4;
      } else {
         // Singles matchplay needs multiples of 2
         if (targetRegCount % 2 != 0) targetRegCount++;
      }
    }

    int processedIndex = 0;
    while (regs.length < targetRegCount && processedIndex < members.length * 2) {
        final memberIdx = (eventIndex * 5 + processedIndex) % members.length;
        processedIndex++;
        
        final m = members[memberIdx];
        if (m.id == 'demo_hero_sanjay') continue;
        if (regs.any((r) => r.memberId == m.id)) continue;
        
        bool isWithdrawn = random.nextDouble() < 0.05;
        final int capacity = isSocial ? 60 : 40;
        final int confirmedSoFar = regs.where((r) => r.isConfirmed).length +
            regs.where((r) => r.isConfirmed && r.guestName != null).length;
        bool isConfirmed = !isWithdrawn && confirmedSoFar < capacity;

        final attendsBreakfast = hasBreakfast && random.nextDouble() < 0.85;
        final attendsLunch = hasLunch && random.nextDouble() < 0.95;
        final attendsDinner = hasDinner && random.nextDouble() < 0.90;
        final needsBuggy = !isSocial && random.nextDouble() < 0.15;

        // Only allow a guest if there's still room in the capacity for them
        final confirmedWithGuest = regs.where((r) => r.isConfirmed).length +
            regs.where((r) => r.isConfirmed && r.guestName != null).length;
        bool hasGuest = !isWithdrawn && isConfirmed &&
            (confirmedWithGuest + 1) < capacity &&
            random.nextDouble() < (isSocial ? 0.3 : 0.15);
        String? guestName;
        String? guestEmail;
        String? guestId;
        double? guestHcp;
        if (hasGuest) {
          final seedGuest = SeedingData.seedGuests[random.nextInt(SeedingData.seedGuests.length)];
          guestName = seedGuest['name'] as String;
          guestEmail = seedGuest['email'] as String;
          guestHcp = seedGuest['handicap'] as double;
          try {
            final guestRepo = ref.read(guestRepositoryProvider);
            final profile = await guestRepo.findOrCreate(
              email: guestEmail,
              name: guestName,
              handicap: guestHcp,
            );
            guestId = profile.id;
          } catch (_) {
            // Seeding continues even if guest persistence fails
          }
        }

        double totalCost = 0;
        if (isConfirmed) {
          if (isSocial) {
            final baseCost = event.extraCosts.fold<double>(0, (total, item) => total + item.amount);
            totalCost = hasGuest ? baseCost * 2 : baseCost;
          } else {
            totalCost += memberTotal;
            if (hasGuest) totalCost += guestTotal;
          }
        }

        final isHistorical = status == EventStatus.completed || status == EventStatus.inPlay;
        final highPaidRate = isHistorical ? 0.95 : 0.40;
        final hasFine = (isHistorical) && processedIndex % 4 == 0;
        final finePaid = hasFine && (random.nextDouble() < 0.85);

        regs.add(EventRegistration(
          memberId: m.id,
          memberName: m.displayName,
          attendingGolf: !isSocial && isConfirmed,
          attendingBreakfast: attendsBreakfast,
          attendingLunch: attendsLunch,
          attendingDinner: attendsDinner,
          needsBuggy: needsBuggy,
          guestId: guestId,
          guestEmail: guestEmail,
          guestName: guestName,
          teeName: (m.gender == 'Female') ? 'Red' : 'Yellow',
          guestTeeName: 'Yellow',
          guestHandicap: hasGuest ? guestHcp!.toStringAsFixed(1) : null,
          guestAttendingBreakfast: hasGuest && attendsBreakfast,
          guestAttendingLunch: hasGuest && attendsLunch,
          guestAttendingDinner: hasGuest && attendsDinner,
          guestIsConfirmed: isConfirmed && hasGuest,
          guestNeedsBuggy: hasGuest && needsBuggy,
          hasPaid: isConfirmed && random.nextDouble() < highPaidRate,
          isConfirmed: isConfirmed,
          handicap: m.handicap,
          registeredAt: date.subtract(Duration(days: 30 - (processedIndex % 20))),
          statusOverride: isWithdrawn ? 'withdrawn' : (isConfirmed ? 'confirmed' : 'waitlist'),
          cost: totalCost,
          fineAmount: hasFine ? 2.0 : 0.0,
          finePaid: finePaid,
        ));
    }

    final updatedEvent = event.copyWith(registrations: regs);
    await eventRepo.addEvent(updatedEvent);

    if (isSocial) {
      await eventRepo.updateEvent(updatedEvent.copyWith(
        feedItems: _generateFeedItems(updatedEvent, []),
      ));
      return [];
    }

    final matchingTemplate = templates.where((t) => t.rules.format == format && t.rules.subtype == subtype && t.rules.hasMatchPlayOverlay == hasMatchPlayOverlay).firstOrNull;
    final rules = matchingTemplate?.rules ?? CompetitionRules(
      format: format, 
      subtype: subtype, 
      handicapAllowance: subtype == CompetitionSubtype.fourball ? 0.85 : (subtype == CompetitionSubtype.foursomes ? 0.50 : 0.95),
      mode: (subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes) ? CompetitionMode.pairs : (format == CompetitionFormat.scramble ? CompetitionMode.teams : CompetitionMode.singles),
      hasMatchPlayOverlay: hasMatchPlayOverlay,
    );

    await compRepo.addCompetition(Competition(
      id: updatedEvent.id, name: title, type: CompetitionType.event,
      status: status == EventStatus.completed 
          ? CompetitionStatus.closed 
          : (status == EventStatus.inPlay ? CompetitionStatus.published : CompetitionStatus.open),
      rules: rules, startDate: date, endDate: date,
    ));

    final isLiveOrPast = status == EventStatus.completed || status == EventStatus.inPlay;
    final List<Map<String, dynamic>> results = [];
    final List<EventAward> awards = [];

    if (isLiveOrPast) {
      final items = RegistrationLogic.getSortedItems(updatedEvent)
          .where((item) => item.isConfirmed)
          .toList();
      final Map<String, double> memberHandicaps = {for (var m in members) m.id: m.handicap};
      final groups = GroupingService.generateInitialGrouping(
        event: updatedEvent, participants: items, previousEventsInSeason: [],
        memberHandicaps: memberHandicaps, prioritizeBuggyPairing: true,
        strategy: isInvitational ? 'balanced' : 'progressive',
        useWhs: true, rules: rules,
      );
      final scoreRepo = ref.read(scorecardRepositoryProvider);
      await scoreRepo.deleteAllScorecards(updatedEvent.id);
      final isStableford = rules.format == CompetitionFormat.stableford;
      final cardStatus = status == EventStatus.completed ? ScorecardStatus.finalScore : ScorecardStatus.submitted;
      final List<Scorecard> scorecards = [];

      final Map<String, String> markersMap = {};

      for (var group in groups) {
        for (int j = 0; j < group.players.length; j++) {
          final p = group.players[j];
          final marker = group.players[(j + 1) % group.players.length];
          
          final pId = p.isGuest ? '${p.registrationMemberId}_guest' : p.registrationMemberId;
          final markerId = marker.isGuest ? '${marker.registrationMemberId}_guest' : marker.registrationMemberId;
          markersMap[pId] = markerId;

          final memberId = p.registrationMemberId;
          final entryId = p.isGuest ? '${memberId}_guest' : memberId;
          final member = members.firstWhereOrNull((m) => m.id == memberId);
          final index = member?.handicap ?? 18.0;
          final teeName = (member?.gender == 'Female') ? 'Red' : 'Yellow';
          final tee = course!.tees.firstWhere((t) => t.name == teeName, orElse: () => course.tees.first);
          final phc = HandicapCalculator.calculatePlayingHandicap(
            handicapIndex: index, rules: rules, 
            courseConfig: cfg.CourseConfig(
              rating: tee.rating, slope: tee.slope, 
              par: tee.holePars.fold<int>(0, (a, b) => a + b), 
              holes: tee.holePars.asMap().entries.map((e) => cfg.CourseHole(hole: e.key + 1, par: e.value, si: tee.holeSIs[e.key])).toList(),
            ),
          );

          final holeScores = <int?>[];
          int grossTotal = 0;
          int pointsTotal = 0;

          // For inPlay: declare a deterministic snapshot by group index.
          // Groups 0-2 → done (18 holes, ready for approval).
          // Groups 3-5 → back 9 in progress (15 holes).
          // Groups 6+  → front 9 in progress (9 holes).
          // All other statuses → full 18 holes.
          final int holesPassed = status == EventStatus.inPlay
              ? (group.index < 3 ? 18 : group.index < 6 ? 15 : 9)
              : 18;

          for (int h = 0; h < 18; h++) {
            if (h >= holesPassed) { holeScores.add(null); continue; }
            final par = tee.holePars[h];
            final si = tee.holeSIs[h];
            int shots = (phc / 18).floor();
            if (phc % 18 >= si) shots++;
            final rand = random.nextDouble();
            int netScore = (rand < 0.25) ? par - 1 : ((rand < 0.80) ? par : ((rand < 0.95) ? par + 1 : par + 2));
            final gross = netScore + shots;
            holeScores.add(gross);
            grossTotal += gross;
            pointsTotal += (par - netScore + 2).clamp(0, 10).toInt();
          }

          final bool inPlayFinished = status == EventStatus.inPlay && holesPassed == 18;
          final ScorecardStatus resolvedStatus = status == EventStatus.inPlay
              ? (inPlayFinished ? ScorecardStatus.submitted : ScorecardStatus.draft)
              : cardStatus;

          final newScorecard = Scorecard(
            id: 'seed_${updatedEvent.id}_$entryId',
            competitionId: updatedEvent.id,
            roundId: ScorecardConstants.defaultRoundId,
            entryId: entryId,
            submittedByUserId: 'system_seed',
            status: resolvedStatus,
            markerId: markerId,
            holeScores: holeScores,
            points: isStableford ? pointsTotal : null,
            handicapIndex: index,
            playingHandicap: phc,
            netTotal: grossTotal - (phc * (holesPassed / 18)).round(),
            verifiedByMarker: status != EventStatus.inPlay || inPlayFinished,
            verifiedByPlayer: status != EventStatus.inPlay || inPlayFinished,
            submittedAt: resolvedStatus != ScorecardStatus.draft
                ? date.copyWith(hour: 14, minute: random.nextInt(60))
                : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await scoreRepo.addScorecard(newScorecard);
          scorecards.add(newScorecard);
        }
      }

      final comp = Competition(
        id: updatedEvent.id, name: title, type: CompetitionType.event,
        status: status == EventStatus.completed 
            ? CompetitionStatus.closed 
            : (status == EventStatus.inPlay ? CompetitionStatus.published : CompetitionStatus.open),
        rules: rules, startDate: date, endDate: date,
      );

      final stats = EventAnalysisEngine.calculateFinalStats(
        scorecards: scorecards,
        event: updatedEvent,
        competition: comp,
        isStableford: isStableford,
      );

      final List<Map<String, dynamic>> calculatedResults = List<Map<String, dynamic>>.from(stats['results'] ?? []);
      results.addAll(calculatedResults);

      final memberCount = regs.where((r) => r.isConfirmed && r.attendingGolf && r.guestName == null).length;
      final totalPrizePool = memberCount * 10.0;

      if (isInvitational) {
        if (results.isNotEmpty) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_c1', label: '1st Place', type: 'Cup', value: 0, winnerId: results[0]['playerId'], winnerName: results[0]['playerName']));
          awards.add(EventAward(id: 'award_${updatedEvent.id}_v1', label: '1st Place', type: 'Voucher', value: 40, winnerId: results[0]['playerId'], winnerName: results[0]['playerName']));
        }
        if (results.length >= 2) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_v2', label: '2nd Place', type: 'Voucher', value: 25, winnerId: results[1]['playerId'], winnerName: results[1]['playerName']));
        }
        if (results.length >= 3) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_v3', label: '3rd Place', type: 'Voucher', value: 15, winnerId: results[2]['playerId'], winnerName: results[2]['playerName']));
        }
      } else {
        if (results.isNotEmpty) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_w1', label: '1st Place', type: 'Cash', value: (totalPrizePool * 0.50).roundToDouble(), winnerId: results[0]['playerId'], winnerName: results[0]['playerName']));
        }
        if (results.length >= 2) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_w2', label: '2nd Place', type: 'Cash', value: (totalPrizePool * 0.30).roundToDouble(), winnerId: results[1]['playerId'], winnerName: results[1]['playerName']));
        }
        if (results.length >= 3) {
          awards.add(EventAward(id: 'award_${updatedEvent.id}_w3', label: '3rd Place', type: 'Cash', value: (totalPrizePool * 0.20).roundToDouble(), winnerId: results[2]['playerId'], winnerName: results[2]['playerName']));
        }
      }

      await eventRepo.updateEvent(updatedEvent.copyWith(
        grouping: {
          'groups': groups.map((g) => g.toJson()).toList(), 
          'isPublished': true,
          'markers': markersMap,
        }, 
        results: results, awards: awards,
        feedItems: _generateFeedItems(updatedEvent, results),
      ));

      // [NEW] Generate Matches for Match Play events
      if (hasMatchPlayOverlay) {
        await generateTestMatches(updatedEvent.id, rules.mode);
      }
    } else {
      await eventRepo.updateEvent(updatedEvent.copyWith(
        grouping: {'groups': [], 'isPublished': false}, 
        results: [], awards: [],
        feedItems: _generateFeedItems(updatedEvent, []),
      ));
    }
    
    return results;
  }

  List<String> _getGalleryPhotos(String courseName) {
    if (courseName.contains('St Andrews') || courseName.contains('Royal County Down') || courseName.contains('Muirfield')) {
      return [
        'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1591492102875-9c59508d508e?auto=format&fit=crop&w=800&q=80',
      ];
    }
    if (courseName.contains('Pebble Beach') || courseName.contains('Cypress Point') || courseName.contains('Royal Melbourne')) {
      return [
        'https://images.unsplash.com/photo-1500673397354-9448fefb5acc?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80',
      ];
    }
    if (courseName.contains('Dom Pedro') || courseName.contains('Victoria')) {
      return [
        'https://images.unsplash.com/photo-1584061556814-7e8c3fc6e4ed?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80',
      ];
    }
    return [
      'https://images.unsplash.com/photo-1591492102875-9c59508d508e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1623912150935-64903328e19e?auto=format&fit=crop&w=800&q=80',
    ];
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
        content: NewsletterTemplates.matchReport(event.title, event.courseName ?? 'TBD', winner, points),
        imageUrl: event.galleryUrls.isNotEmpty ? event.galleryUrls[0] : null,
        isPublished: true,
        createdAt: event.date.add(const Duration(hours: 6)),
        sortOrder: 10,
      ));

      items.add(EventFeedItem(
        id: 'news_${event.id}_recap',
        type: FeedItemType.newsletter,
        title: 'Reflections on the Day',
        content: NewsletterTemplates.seasonRecap(event.title),
        isPublished: true,
        createdAt: event.date.add(const Duration(days: 1)),
        sortOrder: 20,
      ));
    }

    // 2. Pre-event communications for Published/InPlay/Completed (Historical Context)
    items.add(EventFeedItem(
      id: 'news_${event.id}_launch',
      type: FeedItemType.newsletter,
      title: 'Event Launch: ${event.title}',
      content: NewsletterTemplates.eventLaunch(event.title, event.courseName ?? 'TBD'),
      isPublished: true,
      createdAt: event.date.subtract(const Duration(days: 7)),
      sortOrder: -100,
    ));

    if (event.status != EventStatus.draft) {
      items.add(EventFeedItem(
        id: 'news_${event.id}_teetimes',
        type: FeedItemType.newsletter,
        title: 'Tee Times Released',
        content: NewsletterTemplates.teeTimesReleased(event.title),
        isPublished: true,
        createdAt: event.date.subtract(const Duration(days: 2)),
        sortOrder: -50,
      ));
    }

    // 3. Membership Renewal (Active for March 2026 Context)
    if (now.year == 2026 && now.month == 3) {
      items.add(EventFeedItem(
        id: 'news_${event.id}_renewal',
        type: FeedItemType.newsletter,
        title: '2026 Membership Renewal',
        content: jsonEncode([{'insert': 'Membership renewals are now open! Issued March 12th, the renewal window closes in 45 days (April 26th). Please ensure your fees are settled to maintain your society handicap and eligibility for the upcoming season.\n'}]),
        isPublished: true,
        createdAt: DateTime(2026, 3, 12, 9, 0),
        sortOrder: -200, 
      ));
    }

    if (event.title.contains('Season Opener')) {
      items.add(EventFeedItem(
        id: 'news_${event.id}_president',
        type: FeedItemType.newsletter,
        title: 'Word from the President',
        content: jsonEncode([{'insert': 'Welcome to another fantastic year of golf. I am delighted to see so many returning faces and a few new guests joining our ranks. Let’s play hard, play fair, and enjoy the 19th hole!\n'}]),
        isPublished: true,
        isPinned: true,
        createdAt: event.date.subtract(const Duration(days: 2)),
        sortOrder: -150,
      ));
    }

    return items;
  }

  Future<void> generateTestMatches(String eventId, CompetitionMode mode) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final event = await eventRepo.getEvent(eventId);
    if (event == null) return;
    final grouping = Map<String, dynamic>.from(event.grouping);
    final groups = (grouping['groups'] as List?) ?? [];
    if (groups.isEmpty) return;
    final List<Map<String, dynamic>> matches = [];
    for (var g in groups) {
      final players = (g['players'] as List);
      final gid = g['index'].toString();
      
      // Determine spacing based on competition mode
      final bool isPairsMode = (mode == CompetitionMode.pairs);
      final int step = isPairsMode ? 4 : 2;

      for (int i = 0; i < players.length - (step - 1); i += step) {
        final List<dynamic> t1 = isPairsMode ? [players[i], players[i+1]] : [players[i]];
        final List<dynamic> t2 = isPairsMode ? [players[i+2], players[i+3]] : [players[i+1]];
        
        final List<String> t1Ids = t1.map((p) => GuestIdHelper.resolveEffectiveId(p)).toList();
        final List<String> t2Ids = t2.map((p) => GuestIdHelper.resolveEffectiveId(p)).toList();

        matches.add({
          'id': 'match_${eventId}_${g['index']}_$i',
          'type': isPairsMode ? MatchType.fourball.index : MatchType.singles.index,
          'team1Ids': t1Ids,
          'team2Ids': t2Ids,
          'team1Name': t1.map((p) => p['name']).join(' / '),
          'team2Name': t2.map((p) => p['name']).join(' / '),
          'groupId': gid,
          'round': MatchRoundType.group.index,
        });
      }
    }
    grouping['matches'] = matches;

    // --- NEW: Synchronize Match Results in the event.results list ---
    final List<Map<String, dynamic>> updatedResults = List.from(event.results);
    final random = Random();

    for (var match in matches) {
      final t1Ids = match['team1Ids'] as List<String>;
      final t2Ids = match['team2Ids'] as List<String>;
      
      // Random result: 45% T1 Win, 45% T2 Win, 10% Halved
      final outcomeRand = random.nextDouble();
      final String status1;
      final String status2;
      final int matchScore; // Relative: + for T1, - for T2

      if (outcomeRand < 0.1) {
        status1 = 'HALVED';
        status2 = 'HALVED';
        matchScore = 0;
      } else {
        final team1Wins = outcomeRand < 0.55;
        final winValue = random.nextInt(4) + 1;
        final holesLeft = random.nextInt(3);
        
        if (holesLeft > 0) {
          status1 = team1Wins ? 'WIN $winValue & $holesLeft' : 'LOSS $winValue & $holesLeft';
          status2 = team1Wins ? 'LOSS $winValue & $holesLeft' : 'WIN $winValue & $holesLeft';
          matchScore = team1Wins ? winValue : -winValue;
        } else {
          final upVal = random.nextInt(2) + 1;
          status1 = team1Wins ? 'WIN $upVal UP' : 'LOSS $upVal UP';
          status2 = team1Wins ? 'LOSS $upVal UP' : 'WIN $upVal UP';
          matchScore = team1Wins ? upVal : -upVal;
        }
      }

      // Apply to all participants in this match
      for (var pid in t1Ids) {
        final resIdx = updatedResults.indexWhere((r) => (r['memberId'] ?? r['playerId']) == pid);
        if (resIdx != -1) {
          updatedResults[resIdx]['status'] = status1;
          updatedResults[resIdx]['matchScore'] = matchScore;
        }
      }
      for (var pid in t2Ids) {
        final resIdx = updatedResults.indexWhere((r) => (r['memberId'] ?? r['playerId']) == pid);
        if (resIdx != -1) {
          updatedResults[resIdx]['status'] = status2;
          updatedResults[resIdx]['matchScore'] = -matchScore;
        }
      }
    }

    await eventRepo.updateEvent(event.copyWith(
      grouping: grouping,
      results: updatedResults,
    ));
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
            'type': MatchType.singles.index,
            'team1Ids': [p1['registrationMemberId'] as String? ?? ''],
            'team2Ids': [p2['registrationMemberId'] as String? ?? ''],
            'team1Name': p1['name'],
            'team2Name': p2['name'],
            'round': MatchRoundType.group.index,
            'groupId': gid,
          });
        }
      }
    }
    grouping['matches'] = matches;
    await eventRepo.updateEvent(event.copyWith(grouping: grouping));
  }
}
