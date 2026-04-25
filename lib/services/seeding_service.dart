import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/design_system/theme/theme_controller.dart';
import 'package:golf_society/features/settings/data/society_config_repository.dart';
import 'package:golf_society/domain/models/society_config.dart';

import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/course_config.dart';
import 'package:collection/collection.dart';

import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/competitions/services/leaderboard_invoker_service.dart';

import 'persistence_service.dart';
import 'seeding/course_seeder.dart';
import 'seeding/member_seeder.dart';
import 'seeding/survey_seeder.dart';
import 'seeding/event_seeder.dart';
import 'seeding/match_play_seeder.dart';
import 'seeding/scenario_seeder.dart';

final seedingServiceProvider = Provider((ref) => SeedingService(ref));

/// Unified Seeding Service for both basic and advanced demo data.
/// Refactored to delegate work to specialized sub-seeders.
class SeedingService {
  final Ref ref;
  final Random _random = Random(42); 
  
  SeedingService(this.ref);

  Future<void> seedInitialData() async {
    await CourseSeeder(ref, _random).seed();
  }

  /// The main entry point for seeding high-quality demo data.
  Future<void> seedFullDemoData() async {
    try {
      debugPrint('--- STARTING UNIFIED WIPE AND SEED ---');
      
      // Ensure we have the LATEST config from the stream, not a potentially stale/default controller state
      final currentConfig = await ref.read(societyConfigStreamProvider.future);
      debugPrint('Backing up society branding: ${currentConfig.societyName}');

      await ref.read(persistenceServiceProvider).clear();
      
      debugPrint('Wiping existing demo data (safe)...');
      await clearDemoData();
      debugPrint('Wipe completed.');

      debugPrint('Seeding new demo season foundation...');
      await _seedGlobalLeaderboardTemplates();
      await _seedCompetitionTemplates();
      await _seedDemoSeason();

      debugPrint('Restoring society branding and setting renewal defaults + sponsors...');
      final eventsRepo = ref.read(eventsRepositoryProvider);
      final events = await eventsRepo.getEvents(seasonId: 'demo_season_2025_2026');
      
      final List<Sponsor> sponsorRegistry = [
        Sponsor(
          id: 'sp_rafiki',
          name: 'Rafiki Golf',
          tier: SponsorTier.gold,
          logoUrl: 'assets/images/sponsors/rafiki.png',
          websiteUrl: 'https://www.rafiki.golf',
          description: 'Premier Golf Apparel & Accessories. Delivering premium style to the modern golfer.',
        ),
        Sponsor(
          id: 'sp_silver_demo',
          name: 'Precision Systems',
          tier: SponsorTier.silver,
          logoUrl: 'assets/images/sponsors/precision.png',
          websiteUrl: 'https://www.precision-systems.demo',
          description: 'Advanced golf analytics and tracking solutions for the competitive edge.',
        ),
        Sponsor(
          id: 'sp_bronze_demo',
          name: 'Golf Logistics',
          tier: SponsorTier.bronze,
          logoUrl: 'assets/images/sponsors/logistics.png',
          websiteUrl: 'https://www.golf-logistics.demo',
          description: 'Seamless travel and equipment transport for society away days.',
        ),
        Sponsor(
          id: 'sp_titleist',
          name: 'Titleist',
          tier: SponsorTier.standard,
          logoUrl: 'assets/images/sponsors/titleist.png',
          websiteUrl: 'https://www.titleist.com',
          description: 'The #1 ball in golf. Proud official partner.',
        ),
        Sponsor(
          id: 'sp_taylormade',
          name: 'TaylorMade',
          tier: SponsorTier.standard,
          logoUrl: 'assets/images/sponsors/taylormade.png',
          websiteUrl: 'https://www.taylormadegolf.com',
          description: 'Beyond Driven. Supporting the society pursuit of excellence.',
        ),
        Sponsor(
          id: 'sp_ping',
          name: 'PING',
          tier: SponsorTier.standard,
          logoUrl: 'assets/images/sponsors/ping.png',
          websiteUrl: 'https://www.ping.com',
          description: 'Play Your Best. Equipping our members for success.',
        ),
      ];

      final List<FinancialEntry> ledgerEntries = [
        FinancialEntry(
          id: 'spon_gold',
          type: 'Sponsorship',
          source: 'Rafiki Golf',
          sponsorId: 'sp_rafiki',
          scope: 'season',
          amount: 7500,
          date: DateTime.now(),
          isPaid: true,
          logoUrl: 'assets/images/sponsors/rafiki.png',
          description: 'Official Gold Season Partner.',
        ),
        FinancialEntry(
          id: 'spon_1',
          type: 'Sponsorship',
          source: 'Titleist',
          sponsorId: 'sp_titleist',
          scope: 'season',
          amount: 5000,
          date: DateTime.now(),
          isPaid: true,
          logoUrl: 'assets/images/sponsors/titleist.png',
          description: jsonEncode([{"insert":"The #1 ball in golf. Proud official sponsor of the 2025-2026 Season.\n","attributes":{"bold":true}}]),
        ),
        FinancialEntry(
          id: 'spon_2',
          type: 'Sponsorship',
          source: 'TaylorMade',
          sponsorId: 'sp_taylormade',
          scope: 'season',
          amount: 3500,
          date: DateTime.now(),
          isPaid: true,
          logoUrl: 'assets/images/sponsors/taylormade.png',
          description: jsonEncode([{"insert":"Beyond Driven. Supporting the society's pursuit of excellence.\n"}]),
        ),
        FinancialEntry(
          id: 'spon_3',
          type: 'Sponsorship',
          source: 'PING',
          sponsorId: 'sp_ping',
          scope: 'season',
          amount: 3000,
          date: DateTime.now(),
          isPaid: true,
          logoUrl: 'assets/images/sponsors/ping.png',
          description: jsonEncode([{"insert":"Play Your Best. Equipping our members for success.\n"}]),
        ),
      ];
      
      final eventSponsorLogos = [
        ('Rolex', 'assets/images/sponsors/rolex.png', 'Official Timekeeper and Event Partner.'),
        ('Callaway', 'assets/images/sponsors/callaway.png', 'Powering today\'s premium event.'),
        ('Omega', 'assets/images/sponsors/omega.png', 'Precision timing for precision golfers.'),
        ('Nike Golf', 'assets/images/sponsors/nike.png', 'Just Do It. Official Apparel Sponsor.'),
      ];
      
      for (int i = 0; i < min(events.length, eventSponsorLogos.length); i++) {
         final event = events[i];
         final spon = eventSponsorLogos[i];
         ledgerEntries.add(FinancialEntry(
           id: 'spon_evt_$i',
           type: 'Sponsorship',
           source: spon.$1,
           scope: 'event',
           eventId: event.id,
           amount: 1000,
           date: DateTime.now(),
           isPaid: true,
           logoUrl: spon.$2,
           description: jsonEncode([{"insert": "${spon.$3}\n"}]),
         ));
      }

      final updatedConfig = currentConfig.copyWith(
        isRenewalActive: true,
        globalMembershipEndDate: DateTime(2026, 3, 12),
        renewalWindowDays: 45,
        renewalLaunchDate: DateTime(2026, 1, 15),
        renewalDeadline: DateTime(2026, 3, 31),
        renewalPaymentDeadline: DateTime(2026, 4, 15),
        ledgerEntries: ledgerEntries,
        sponsors: sponsorRegistry,
      );
      await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(updatedConfig);
      
      debugPrint('Seeding modernized member surveys...');
      final membersList = await ref.read(membersRepositoryProvider).getMembers();
      await SurveySeeder(ref, _random).seed(membersList);
      
      debugPrint('Injecting Match Play Progression Scenario...');
      await seedMatchPlayProgression();
      
      debugPrint('--- UNIFIED WIPE AND SEED COMPLETED ---');
    } catch (e, stack) {
      debugPrint('CRITICAL SEEDER FAILURE: $e');
      debugPrint(stack.toString());
    }
  }

  /// Specialized Seeder for Match Play Laboratory testing.
  /// Allows seeding at different stages of the tournament lifecycle.
  Future<void> seedMatchPlayTestLab(MatchPlayStage stage) async {
    try {
      await MatchPlaySeeder(ref, _random).seed(stage);
    } catch (e, stack) {
      debugPrint('MATCH PLAY LAB SEEDER FAILURE: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<void> seedMatchPlayProgression() async {
    try {
      await ScenarioSeeder(ref, _random).seedMatchPlayProgression();
    } catch (e, stack) {
      debugPrint('MATCH PLAY PROGRESSION SEEDER FAILURE: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Legacy helper for the existing Sanjay Test Event button.
  /// Refactored to use the new Lab Seeder at Stage 1.
  Future<void> seedMatchPlayTestEvent() async {
    await seedMatchPlayTestLab(MatchPlayStage.registration);
  }

  Future<void> clearActivityData() async {
    final firestore = FirebaseFirestore.instance;
    
    // We explicitly EXCLUDE 'templates', 'courses', and 'society_config'
    // to preserve the scaffolding work (Branding & Rules)
    final collections = [
      'scorecards', 'events', 'competitions', 'seasons', 'members',
      'notifications', 'campaigns', 'global_expenses', 'surveys', 'activities',
    ];

    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) continue;
      
      var batch = firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        // Handle sub-collections for Events (registrations)
        if (collection == 'events') {
          final registrations = await doc.reference.collection('registrations').get();
          for (var reg in registrations.docs) {
            batch.delete(reg.reference);
            count++;
            if (count >= 400) {
              await batch.commit();
              batch = firestore.batch();
              count = 0;
            }
          }
        }
        
        // Handle sub-collections for Competitions (scorecards)
        if (collection == 'competitions') {
          final scorecards = await doc.reference.collection('scorecards').get();
          for (var card in scorecards.docs) {
            batch.delete(card.reference);
            count++;
            if (count >= 400) {
              await batch.commit();
              batch = firestore.batch();
              count = 0;
            }
          }
        }

        batch.delete(doc.reference);
        count++;
        if (count >= 400) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();
    }
    
    // Reset financial status and seasonal dates without wiping branding
    // We await the future to ensure we aren't clobbering with a default SocietyConfig()
    final currentConfig = await ref.read(societyConfigStreamProvider.future);
    final preservedConfig = currentConfig.copyWith(
      isRenewalActive: false,
      ledgerEntries: [],
      sponsors: [],
      globalMembershipEndDate: null,
      renewalLaunchDate: null,
      renewalDeadline: null,
      renewalPaymentDeadline: null,
    );
    await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(preservedConfig);
    await ref.read(persistenceServiceProvider).clear();
    
    // Hard Refresh: Invalidate the theme controller to force a fresh pull from Firestore
    ref.invalidate(themeControllerProvider);
    
    debugPrint('Clear Activity Data (Preserving Branding/Templates) completed.');
  }

  Future<void> clearDemoData() async {
    final firestore = FirebaseFirestore.instance;
    final currentConfig = await ref.read(societyConfigStreamProvider.future);

    final blankConfig = currentConfig.copyWith(
      isRenewalActive: false,
      globalMembershipEndDate: null,
      renewalLaunchDate: null,
      renewalDeadline: null,
      renewalPaymentDeadline: null,
      ledgerEntries: [],
      sponsors: [],
    );
    await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(blankConfig);

    final collections = [
      'scorecards', 'events', 'competitions', 'seasons', 'members',
      'notifications', 'campaigns', 'global_expenses', 'surveys', 'activities',
      'templates', 'leaderboard_templates',
    ];

    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) continue;
      
      var batch = firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        if (collection == 'events') {
          final registrations = await doc.reference.collection('registrations').get();
          for (var reg in registrations.docs) {
            batch.delete(reg.reference);
            count++;
            if (count >= 400) {
              await batch.commit();
              batch = firestore.batch();
              count = 0;
            }
          }
        }
        batch.delete(doc.reference);
        count++;
        if (count >= 400) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();
    }

    final cleanedConfig = currentConfig.copyWith(
      sponsors: [],
      ledgerEntries: [],
    );
    await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(cleanedConfig);
    await ref.read(persistenceServiceProvider).clear();
    
    // Hard Refresh: Invalidate the theme controller 
    ref.invalidate(themeControllerProvider);
    
    debugPrint('Clear Demo Data completed.');
  }

  Future<void> totalSystemWipe() async {
    final firestore = FirebaseFirestore.instance;
    final collections = [
      'scorecards', 'events', 'competitions', 'seasons', 'members',
      'notifications', 'campaigns', 'surveys', 'global_expenses',
      'leaderboard_templates', 'templates', 'activities',
    ];

    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) continue;
      
      var batch = firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        if (collection == 'events') {
          final registrations = await doc.reference.collection('registrations').get();
          for (var reg in registrations.docs) {
            batch.delete(reg.reference);
            count++;
            if (count >= 400) {
              await batch.commit();
              batch = firestore.batch();
              count = 0;
            }
          }
        }
        batch.delete(doc.reference);
        count++;
        if (count >= 400) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();
    }

    await ref.read(societyConfigRepositoryProvider).deleteConfig();
    await ref.read(persistenceServiceProvider).clear();
    debugPrint('Total System Wipe completed (Factory Reset).');
  }

  Future<void> _seedDemoSeason() async {
    final seasonId = await _seedSeason();
    await MemberSeeder(ref, _random).seed();
    final members = await ref.read(membersRepositoryProvider).getMembers();
    final courses = await CourseSeeder(ref, _random).seed();
    
    final userTemplates = await ref.read(competitionsRepositoryProvider).getTemplates();
    final Map<String, double> cumulativeCuts = {};

    final prestigeCourses = courses.where((c) => ['St Andrews', 'Muirfield', 'Augusta', 'Royal County Down', 'Pebble Beach'].contains(c.name)).toList();
    final localCourses = courses.where((c) => !['St Andrews', 'Muirfield', 'Augusta', 'Royal County Down', 'Pebble Beach'].contains(c.name)).toList();

    final now = DateTime.now();
    final List<({String title, CompetitionFormat format, bool isInvitational, bool isSeasonEvent, CompetitionSubtype subtype, DateTime date, EventStatus status, bool isMultiDay, DateTime? endDate, EventType eventType})> eventPlan = [
      (title: 'Season Opener', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 12), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Spring Stableford', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 4, 15), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Early Summer Classic', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 5, 10), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Midsummer Cup', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 6, 5), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'High Summer Shield', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 12), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Late Summer Series', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 8, 20), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Autumn Qualifier', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 9, 15), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'The Season Finale', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 10), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2025, 10, 11), eventType: EventType.golf),
      
      (title: 'ALGARVE TOUR 2026', format: CompetitionFormat.stableford, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 20), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2025, 10, 22), eventType: EventType.golf),
      (title: 'President\'s Cup', format: CompetitionFormat.stableford, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 3, 20), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Texas Scramble Away Day', format: CompetitionFormat.scramble, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 25), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Charity Scramble', format: CompetitionFormat.scramble, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 25), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),

      (title: 'Society Summer BBQ', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 19), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.social),
      (title: 'Annual Awards Dinner', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 3, 11), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.social),

      (title: 'Invitational Match Play', format: CompetitionFormat.stableford, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: now, status: EventStatus.inPlay, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Spring Social Night', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: now.add(const Duration(days: 7)), status: EventStatus.published, isMultiDay: false, endDate: null, eventType: EventType.social),
      (title: 'May Spring Medal', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: now.add(const Duration(days: 14)), status: EventStatus.published, isMultiDay: false, endDate: null, eventType: EventType.golf),
    ];

    int prestigeUsed = 0;
    final eventSeeder = EventSeeder(ref, _random);
    for (int i = 0; i < eventPlan.length; i++) {
      final config = eventPlan[i];
      final isSocial = config.eventType == EventType.social;
      
      Course? course;
      if (!isSocial) {
        if (config.title.contains('PRESTIGE')) {
          course = prestigeCourses[prestigeUsed % prestigeCourses.length];
          prestigeUsed++;
        } else {
          course = localCourses[i % localCourses.length];
        }
      }
      
      try {
        final results = await eventSeeder.createFullEvent(
          seasonId: seasonId,
          course: course,
          title: config.title,
          date: config.date,
          format: config.format,
          isInvitational: config.isInvitational,
          isSeasonEvent: config.isSeasonEvent,
          subtype: config.subtype,
          members: members,
          appliedCuts: Map<String, double>.from(cumulativeCuts),
          status: config.status,
          templates: userTemplates,
          isMultiDay: config.isMultiDay,
          endDate: config.endDate,
          eventIndex: i,
          eventType: config.eventType,
          charityPot: i == 0 ? 25.0 : (i == 12 ? 40.0 : 0.0),
          hasMatchPlayOverlay: config.title.contains('Match Play') || config.title.contains('President\'s Cup'),
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
      } catch (e, stack) {
        debugPrint('❌ FAILED TO SEED EVENT ${config.title}: $e');
        debugPrint(stack.toString());
      }
    }

    await ref.read(leaderboardInvokerServiceProvider).recalculateAll(seasonId);
    await _seedNonEventExpenses();

    final eventsRepo = ref.read(eventsRepositoryProvider);
    final finalEvents = await eventsRepo.getEvents(seasonId: seasonId);
    debugPrint('\n🚀 SEEDING DIAGNOSTICS FOR: $seasonId');
    for (var e in finalEvents) {
      final typeLabel = e.eventType == EventType.social ? 'SOCIAL' : (e.isInvitational ? 'INVITE' : 'SEASON');
      debugPrint(' - [$typeLabel] ${e.title} (Status: ${e.status.name})');
    }
  }

  Future<void> _seedGlobalLeaderboardTemplates() async {
    final repo = ref.read(leaderboardTemplatesRepositoryProvider);
    
    // We define the "Big 5" standard blueprints for a society
    final templates = [
      LeaderboardConfig.orderOfMerit(
        id: 'oom_standard_blueprint',
        name: 'Order of Merit',
        scope: LeaderboardScope.global,
        source: OOMSource.position,
        appearancePoints: 2,
        positionPointsMap: {1: 25, 2: 18, 3: 15, 4: 12, 5: 10, 6: 8, 7: 6, 8: 4, 9: 2, 10: 1},
      ),
      LeaderboardConfig.bestOfSeries(
        id: 'best_of_standard_blueprint',
        name: 'Best of 5 Series',
        scope: LeaderboardScope.global,
        bestN: 5,
        metric: BestOfMetric.stableford,
      ),
      LeaderboardConfig.eclectic(
        id: 'eclectic_standard_blueprint',
        name: 'Season Eclectic',
        scope: LeaderboardScope.global,
        metric: EclecticMetric.strokes,
      ),
      LeaderboardConfig.markerCounter(
        id: 'birdie_tree_standard_blueprint',
        name: 'Birdie Tree',
        scope: LeaderboardScope.global,
        targetTypes: {MarkerType.birdie, MarkerType.eagle, MarkerType.albatross},
      ),
      LeaderboardConfig.markerCounter(
        id: 'par3_series_standard_blueprint',
        name: 'Par 3 Challenge',
        scope: LeaderboardScope.global,
        targetTypes: {MarkerType.birdie, MarkerType.eagle, MarkerType.holeInOne},
        holeFilter: HoleFilter.par3,
      ),
    ];

    for (final template in templates) {
      // Update if exists (blueprint matches), otherwise add
      await repo.updateTemplate(template).catchError((_) => repo.addTemplate(template));
    }
  }
  
  Future<void> _seedCompetitionTemplates() async {
    final repo = ref.read(competitionsRepositoryProvider);
    
    final templates = [
      Competition(
        id: 'tmpl_stableford_solo',
        name: 'Stableford Solo',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.stableford,
          mode: CompetitionMode.singles,
          handicapAllowance: 0.95,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
      Competition(
        id: 'tmpl_texas_scramble',
        name: 'Texas Scramble',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.scramble,
          subtype: CompetitionSubtype.texas,
          mode: CompetitionMode.teams,
          teamSize: 4,
          handicapAllowance: 1.0,
          useWHSScrambleAllowance: true,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
      Competition(
        id: 'tmpl_singles_match_play_event',
        name: 'Singles Match Play (Event)',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.stableford,
          mode: CompetitionMode.singles,
          handicapAllowance: 1.0,
          hasMatchPlayOverlay: true,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
      Competition(
        id: 'tmpl_match_play_season_overlay',
        name: 'Match Play Season Overlay',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.stableford,
          subtype: CompetitionSubtype.matchPlaySeason,
          mode: CompetitionMode.singles,
          handicapAllowance: 1.0,
          hasMatchPlayOverlay: true,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
      Competition(
        id: 'tmpl_ryder_cup',
        name: 'Ryder Cup (Team Match Play)',
        type: CompetitionType.game,
        rules: const CompetitionRules(
          format: CompetitionFormat.stableford,
          mode: CompetitionMode.teams,
          handicapAllowance: 1.0,
          hasMatchPlayOverlay: true,
        ),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    ];

    for (final template in templates) {
      await repo.updateTemplate(template).catchError((_) => repo.addTemplate(template));
    }
  }

  Future<String> _seedSeason() async {
    final repo = ref.read(seasonsRepositoryProvider);
    final templateRepo = ref.read(leaderboardTemplatesRepositoryProvider);
    
    // Fetch the 5 templates from the library
    final templates = await templateRepo.watchTemplates().first;
    
    final season = Season(
      id: 'demo_season_2025_2026',
      name: 'Demo Season 25-26',
      year: 2026,
      startDate: DateTime(2025, 3, 12),
      endDate: DateTime(2026, 4, 30),
      status: SeasonStatus.active,
      isCurrent: true,
      leaderboards: templates.map((t) => t.copyWith(
        id: Uuid().v4(), // Instantiate as a unique season subscription
        scope: LeaderboardScope.seasonOnly,
        // Name is preserved from 't.name'
      )).toList(),
    );

    try { await repo.deleteSeason(season.id); } catch (_) {}
    await repo.addSeason(season);
    await repo.setCurrentSeason(season.id);
    return season.id;
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
}
