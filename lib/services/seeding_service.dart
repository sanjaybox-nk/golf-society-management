import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/theme/theme_controller.dart';
import 'package:golf_society/features/settings/data/society_config_repository.dart';
import 'package:golf_society/domain/models/society_config.dart';

import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/models/course_config.dart' as cfg;
import 'package:golf_society/domain/models/survey.dart';

import 'package:golf_society/features/competitions/presentation/competitions_provider.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/surveys/presentation/surveys_provider.dart';
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

  static const avatarUrls = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80', // Woman 1
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80', // Man 1
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80', // Woman 2
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80', // Man 2
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80', // Woman 3
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', // Man 3
    'https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=200&q=80', // Woman 4
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80', // Man 4
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=200&q=80', // Woman 5
    'https://images.unsplash.com/photo-1542156822-6924d1a71ace?auto=format&fit=crop&w=200&q=80', // Man 5
  ];

  /// The main entry point for seeding high-quality demo data.
  Future<void> seedFullDemoData() async {
    try {
      debugPrint('--- STARTING UNIFIED WIPE AND SEED ---');
      
      // 1. Backup current SocietyConfig to survive any unintended wipes
      final currentConfig = ref.read(themeControllerProvider);
      debugPrint('Backing up society branding: ${currentConfig.societyName}');

      // 2. Clear local persistence (SharedPreferences)
      await ref.read(persistenceServiceProvider).clear();
      
      // 3. Wipe Demo Data (Safe Wipe - preserves branding & templates)
      debugPrint('Wiping existing demo data (safe)...');
      await clearDemoData();
      debugPrint('Wipe completed.');

      // 4. Seeding foundation
      debugPrint('Seeding new demo season foundation...');
      await _seedDemoSeason();

      // 5. Restore SocietyConfig & Add Sponsors
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
      
      // 6. Seed Surveys with Member Participation
      debugPrint('Seeding modernized member surveys...');
      final surveyRepo = ref.read(surveysRepositoryProvider);
      final countBefore = (await surveyRepo.getSurveys()).length;
      final membersList = await ref.read(membersRepositoryProvider).getMembers();
      await _seedSurveys(membersList);
      final countAfter = (await surveyRepo.getSurveys()).length;
      debugPrint('[SURVEY SEED] Collection count before: $countBefore, after: $countAfter');
      debugPrint('Survey seeding complete.');
      
      debugPrint('--- UNIFIED WIPE AND SEED COMPLETED ---');
    } catch (e, stack) {
      debugPrint('CRITICAL SEEDER FAILURE: $e');
      debugPrint(stack.toString());
    }
  }

  /// Clears all relevant Firestore collections.
  /// The new "Safe Wipe" that preserves branding, settings, and templates.
  Future<void> clearDemoData() async {
    final firestore = FirebaseFirestore.instance;
    final currentConfig = ref.read(themeControllerProvider);

    // 0. Reset Society Config branding/alerts to "Blank Canvas"
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

    // 1. Wipe collections that store "Game/Member Data"
    final collections = [
      'scorecards', 
      'events', 
      'competitions', 
      'seasons', 
      'members',
      'notifications',
      'campaigns',
      'global_expenses',
      'surveys',
      'activities',
      // We EXPLICITLY DO NOT wipe 'templates' or 'leaderboard_templates' here
    ];

    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) continue;
      
      var batch = firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        // Special case for events: wipe registrations subcollection
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

    // 2. Wipe sponsors and ledger entries via config update (Preserves Branding)
    final cleanedConfig = currentConfig.copyWith(
      sponsors: [],
      ledgerEntries: [],
    );
    await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(cleanedConfig);

    // 3. Clear local persistence
    await ref.read(persistenceServiceProvider).clear();
    
    debugPrint('Clear Demo Data completed (Branding & Templates preserved).');
  }

  /// The destructive "Total Wipe" that removes everything including branding.
  Future<void> totalSystemWipe() async {
    final firestore = FirebaseFirestore.instance;
    
    // Comprehensive root collection list
    final collections = [
      'scorecards', 
      'events', 
      'competitions', 
      'seasons', 
      'members',
      'notifications',
      'campaigns',
      'surveys',
      'global_expenses',
      'leaderboard_templates',
      'templates', // Game templates
      'activities', // Audit logs
    ];

    for (var collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) continue;
      
      var batch = firestore.batch();
      int count = 0;
      
      for (var doc in snapshot.docs) {
        // Handle registrations subcollection
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

    // Delete society config doc (factory reset branding)
    await ref.read(societyConfigRepositoryProvider).deleteConfig();
    
    // Clear local persistence
    await ref.read(persistenceServiceProvider).clear();
    
    debugPrint('Total System Wipe completed (Factory Reset).');
  }

  @Deprecated('Use clearDemoData() or totalSystemWipe() instead')
  Future<void> clearAllData() async {
    await totalSystemWipe();
  }
  
  Future<void> _seedSurveys(List<Member> members) async {
    final surveyRepo = ref.read(surveysRepositoryProvider);
    final now = DateTime.now();
    
    // Helper to generate a participation list (50-60%)
    // CRITICAL: We exclude the Hero user 'demo_hero_sanjay' so the user actually sees the survey as available!
    List<Member> getParticipants() {
      final eligibleMembers = members.where((m) => m.id != 'demo_hero_sanjay').toList();
      final shuffled = List<Member>.from(eligibleMembers)..shuffle(_random);
      final rate = 0.5 + (_random.nextDouble() * 0.1); // 50% to 60%
      final count = (eligibleMembers.length * rate).round();
      return shuffled.take(count).toList();
    }

    // 1. Season 2026 Feedback Survey
    final seasonSurvey = Survey(
      id: 'survey_season_2026',
      title: 'Season 2026 Feedback',
      description: 'We value your input! Help us reach new heights in 2027 by sharing your thoughts on the current season organization and event variety.',
      createdAt: now.subtract(const Duration(days: 5)),
      deadline: now.add(const Duration(days: 20)),
      isPublished: true,
      questions: [
        const SurveyQuestion(
          id: 'q1_org',
          question: 'How would you rate the overall society organization this season?',
          type: SurveyQuestionType.singleChoice,
          options: ['Elite (Flawless)', 'Standard (Reliable)', 'Needs Work', 'Poor'],
        ),
        const SurveyQuestion(
          id: 'q2_events',
          question: 'Which event formats would you like to see more of next year?',
          type: SurveyQuestionType.multipleChoice,
          options: ['Stableford Majors', 'Match Play Grudge Matches', 'Texas Scrambles', 'Multi-Day Tours'],
        ),
        const SurveyQuestion(
          id: 'q3_improve',
          question: 'What is the number one thing we could improve for 2027?',
          type: SurveyQuestionType.text,
        ),
      ],
      responses: {},
    );

    // 2. Apparel Design 2026 Poll
    final apparelSurvey = Survey(
      id: 'survey_apparel_2026',
      title: 'New Apparel Design Poll',
      description: 'Vote for the official society polo shirt design. The winning combination will be our standard uniform for all 2026 Major events.',
      createdAt: now.subtract(const Duration(days: 2)),
      deadline: now.add(const Duration(days: 10)),
      isPublished: true,
      questions: [
        const SurveyQuestion(
          id: 'q1_color',
          question: 'Choose the primary base color for the 2026 Polo:',
          type: SurveyQuestionType.singleChoice,
          options: ['Midnight Navy', 'Forest Green', 'Stealth Charcoal', 'Classic White'],
        ),
        const SurveyQuestion(
          id: 'q2_logo',
          question: 'Where should the secondary society logo be placed?',
          type: SurveyQuestionType.singleChoice,
          options: ['Right Sleeve', 'Left Sleeve', 'Nape of Neck'],
        ),
        const SurveyQuestion(
          id: 'q3_comments',
          question: 'Any specific material or fit suggestions for the committee?',
          type: SurveyQuestionType.text,
        ),
      ],
      responses: {},
    );

    final surveys = [seasonSurvey, apparelSurvey];

    for (var survey in surveys) {
      final participants = getParticipants();
      final Map<String, dynamic> responses = {};
      
      for (var member in participants) {
        final Map<String, dynamic> answers = {};
        for (var q in survey.questions) {
          if (q.type == SurveyQuestionType.singleChoice) {
            answers[q.id] = q.options[_random.nextInt(q.options.length)];
          } else if (q.type == SurveyQuestionType.multipleChoice) {
            final selectedCount = _random.nextInt(q.options.length) + 1;
            final shuffledOptions = List<String>.from(q.options)..shuffle(_random);
            answers[q.id] = shuffledOptions.take(selectedCount).toList();
          } else if (q.type == SurveyQuestionType.text) {
            final comments = [
              'Great season so far, really enjoying the tour events.',
              'More weekend slots please!',
              'Love the new design 4.x branding on the app.',
              'Could we look at more prestige courses next year?',
              'Excellent work by the committee.',
            ];
            answers[q.id] = comments[_random.nextInt(comments.length)];
          }
        }
        responses[member.id] = answers;
      }
      
      await surveyRepo.addSurvey(survey.copyWith(responses: responses));
      debugPrint('Seeded survey: ${survey.title} with ${responses.length} responses.');
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
    // Course classification
    final prestigeCourses = courses.where((c) => ['St Andrews', 'Muirfield', 'Augusta', 'Royal County Down', 'Pebble Beach'].contains(c.name)).toList();
    final localCourses = courses.where((c) => !['St Andrews', 'Muirfield', 'Augusta', 'Royal County Down', 'Pebble Beach'].contains(c.name)).toList();

    // 2025-26 Complete Season (8 Season Games + Invitationals + Socials)
    // ONLY Stableford Games (isSeasonEvent: true) affect the season leaderboard.
    final now = DateTime.now();
    final List<({String title, CompetitionFormat format, bool isInvitational, bool isSeasonEvent, CompetitionSubtype subtype, DateTime date, EventStatus status, bool isMultiDay, DateTime? endDate, EventType eventType})> eventPlan = [
      // 8 Season Events (Stableford) - ALL in 2025 (Part of the OOM)
      (title: 'Season Opener', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 12), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Spring Stableford', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 4, 15), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Early Summer Classic', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 5, 10), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Midsummer Cup', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 6, 5), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'High Summer Shield', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 12), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Late Summer Series', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 8, 20), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Autumn Qualifier', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 9, 15), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'The Season Finale', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 10), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2025, 10, 11), eventType: EventType.golf),
      
      // Invitationals (Non-Stableford / Variants)
      (title: 'ALGARVE TOUR 2026', format: CompetitionFormat.stableford, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 10, 20), status: EventStatus.completed, isMultiDay: true, endDate: DateTime(2025, 10, 22), eventType: EventType.golf),
      (title: 'President\'s Cup', format: CompetitionFormat.matchPlay, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 3, 20), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Texas Scramble Away Day', format: CompetitionFormat.scramble, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 25), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),
      (title: 'Charity Scramble', format: CompetitionFormat.scramble, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 3, 25), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.golf),

      // Social Events
      (title: 'Society Summer BBQ', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2025, 7, 19), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.social),
      (title: 'Annual Awards Dinner', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: DateTime(2026, 3, 11), status: EventStatus.completed, isMultiDay: false, endDate: null, eventType: EventType.social),

      // LIVE EVENT (Today)
      (title: 'Live Invitational Match Play', format: CompetitionFormat.matchPlay, isInvitational: true, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: now, status: EventStatus.inPlay, isMultiDay: false, endDate: null, eventType: EventType.golf),

      // UPCOMING EVENT (Social / Future)
      (title: 'Spring Social Night', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: false, subtype: CompetitionSubtype.none, date: now.add(const Duration(days: 7)), status: EventStatus.published, isMultiDay: false, endDate: null, eventType: EventType.social),
      
      // UPCOMING EVENT (Season / Future)
      (title: 'May Spring Medal', format: CompetitionFormat.stableford, isInvitational: false, isSeasonEvent: true, subtype: CompetitionSubtype.none, date: now.add(const Duration(days: 14)), status: EventStatus.published, isMultiDay: false, endDate: null, eventType: EventType.golf),
    ];

    int prestigeUsed = 0;
    for (int i = 0; i < eventPlan.length; i++) {
      final config = eventPlan[i];
      
      // Select course by bucket
      final isSocial = config.eventType == EventType.social;
      
      // Select course by bucket (Only for Golf)
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
        final results = await _createFullEvent(
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
        print('❌ FAILED TO SEED EVENT ${config.title}: $e');
        print(stack);
      }
    }

    // 10. RECALCULATE ALL LEADERBOARDS (Authoritative)
    await ref.read(leaderboardInvokerServiceProvider).recalculateAll(seasonId);

    // 11. Seed Society Overheads
    await _seedNonEventExpenses();

    // DIAGNOSTIC SUMMARY
    final eventsRepo = ref.read(eventsRepositoryProvider);
    final finalEvents = await eventsRepo.getEvents(seasonId: seasonId);
    
    print('\n🚀 SEEDING DIAGNOSTICS FOR: $seasonId');
    print('---------------------------');
    print('Total Events Planned: ${eventPlan.length}');
    print('Total Events in DB: ${finalEvents.length}');
    
    for (var e in finalEvents) {
      final typeLabel = e.eventType == EventType.social ? 'SOCIAL' : (e.isInvitational ? 'INVITE' : 'SEASON');
      print(' - [$typeLabel] ${e.title} (Status: ${e.status.name})');
    }
    print('---------------------------\n');
  }

  Future<String> _seedSeason() async {
    final now = DateTime.now();
    final repo = ref.read(seasonsRepositoryProvider);
    final season = Season(
      id: 'demo_season_2025_2026',
      name: 'Demo Season 25-26',
      year: 2026,
      startDate: DateTime(2025, 3, 12),
      endDate: DateTime(2026, 4, 30), // Extended to include today (April 1st) for demo visibility
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
      role: MemberRole.superAdmin,
      societyRole: 'Admin',
      status: MemberStatus.active,
      joinedDate: DateTime(2023, 1, 1),
      membershipEndDate: DateTime.now().add(const Duration(days: 14)), // Expiring soon for demo
      renewalStatus: MemberRenewalStatus.none,
      hasPaid: true,
      gender: 'Male',
      bio: 'The Society Founder. Passionate about technology and bringing the digital edge to the game of golf.',
      phone: '+44 7700 900000',
      avatarUrl: avatarUrls[1], // Sanjay
      allowSocialEventsOnly: false,
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
        
        MemberRole systemRole = MemberRole.member;
        if (i == 0 || i == 20) systemRole = MemberRole.admin;
        if (i == 1 || i == 21) systemRole = MemberRole.restrictedAdmin;
        if (i == 36) systemRole = MemberRole.viewer;

        double hc = (i < 10) ? (1.0 + _random.nextDouble() * 5) : ((i < 40) ? (6.0 + _random.nextDouble() * 14) : (20.0 + _random.nextDouble() * 16));
        if (isFemale) hc += 2.0;         // Create a spread of renewal dates
        final membershipEnd = DateTime(2026, 1, 1).add(Duration(days: i * 10)); // Spread throughout the year
        final hasRequested = i % 15 == 0; // Every 15th member has requested renewal
        final isExpired = membershipEnd.isBefore(DateTime.now());
        final currentStatus = isExpired ? MemberStatus.expired : MemberStatus.active;
        
        // --- NEW: Financial Seeding Logic ---
        double initialCredit = 0.0;
        final bool isEricAdams = (i == 32); 
        
        if (isEricAdams) {
          // Rule: Eric Adams is owed a voucher
          initialCredit = 50.0;
        } else if (i % 5 == 0 && i != 0) {
          // Rule: ~20ish% of members (every 5th) owe money
          // Varied amounts not exceeding £100
          initialCredit = -1 * (10.0 + _random.nextInt(90).toDouble());
        }
        // ------------------------------------

        await repo.addMember(Member(
          id: 'demo_m_$i',
          firstName: fName,
          lastName: lName,
          email: '${fName.toLowerCase()}.${lName.toLowerCase()}$i@demo.org',
          handicap: double.parse(hc.toStringAsFixed(1)),
          handicapId: 'WHS${300000 + i}',
          role: systemRole,
          societyRole: role,
          status: currentStatus,
          joinedDate: DateTime(2023, 1, 1).add(Duration(days: i * 3)),
          membershipEndDate: membershipEnd,
          renewalStatus: hasRequested ? MemberRenewalStatus.renew : MemberRenewalStatus.none,
          hasPaid: !isExpired,
          gender: isFemale ? 'Female' : 'Male',
          phone: '+44 7${100000000 + i}',
          bio: bio,
          avatarUrl: avatarUrls[i % avatarUrls.length],
          allowSocialEventsOnly: false,
          accountCredit: initialCredit, // [ADDED]
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
    Course? course, // Made optional
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
  }) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final compRepo = ref.read(competitionsRepositoryProvider);

    final bool isSocial = eventType == EventType.social;
    final yellowTee = course?.tees.firstWhereOrNull((t) => t.name == 'Yellow') ?? course?.tees.firstOrNull;

    final isPrestige = title.contains('PRESTIGE');
    final double societyGreenFee = isPrestige ? (150.0 + _random.nextInt(150)) : (45.0 + _random.nextInt(40));
    
    // Catering Combinations (No "All Three" per user request)
    // 0: Just Breakfast, 1: Breakfast & Dinner, 2: Lunch & Dinner
    final cateringCombo = isSocial ? -1 : _random.nextInt(3);
    final hasBreakfast = cateringCombo == 0 || cateringCombo == 1;
    final hasLunch = cateringCombo == 2;
    final hasDinner = cateringCombo == 1 || cateringCombo == 2;

    final double breakfastCost = hasBreakfast ? 10.0 : 0.0;
    final double lunchCost = hasLunch ? 15.0 : 0.0;
    final double venueDinnerCost = hasDinner ? 30.0 : 0.0; // Base cost to society
    
    // 15% Society Markup Rule (Applied to all)
    // IMPORTANT: Dinner is separate from the main event ticket/cost
    final double eventBaseCost = societyGreenFee + breakfastCost + lunchCost;
    final double memberTotal = (eventBaseCost * 1.15).roundToDouble();
    final double guestTotal = (memberTotal + 15.0).roundToDouble();
    
    // Separate Dinner Cost for members (including markup)
    final double memberDinnerCost = (venueDinnerCost * 1.15).roundToDouble();

    // Realistic Timing Logic (Golf: 8:30-9:45 AM Reg, +90 min Tee Off)
    final int regHour = 8;
    final int regMinutes = 30 + _random.nextInt(75);
    final DateTime golfRegTime = date.copyWith(hour: regHour, minute: regMinutes);
    final DateTime golfTeeOff = golfRegTime.add(const Duration(minutes: 90));

    var event = GolfEvent(
      id: 'demo_e_${_random.nextInt(100000)}',
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
      breakfastCost: 0, // Bundled into memberTotal
      lunchCost: 0,
      dinnerCost: memberDinnerCost, // Separate dinner cost for members

      // New Dynamic Costs for Social Events
      extraCosts: isSocial ? [
        const EventExtraCost(id: 'seed_ticket', label: 'Ticket Price', amount: 30.0),
        const EventExtraCost(id: 'seed_raffle', label: 'Raffle Entry (Opt)', amount: 5.0),
      ] : [],

      expenses: isSocial ? [] : [
        EventExpense(id: 'starter_pack', label: 'Starter Pack (Water/Fruit)', amount: 1.5 * (isSocial ? 20 : 32)),
      ],

      buggyCost: isSocial ? 0.0 : 15.0,
      availableBuggies: isSocial ? 0 : (10 + _random.nextInt(20)),
      dinnerLocation: isSocial ? 'Local Bistro' : 'The Clubhouse Restaurant',
      dressCode: isSocial ? 'Casual' : 'Smart Casual / No Jeans',
      facilities: isSocial ? ['Parking', 'Bar', 'Restaurant'] : ['Pro Shop', 'Driving Range', 'Changing Rooms', 'Halfway House'],
      maxParticipants: isSocial ? 60 : 40,

      // NEW LOGIC: Only auto-publish and generate groups for Historical or Live events.
      // Future events (Published/Draft) should start with a clean slate.
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
    final targetRegCount = (isSocial ? 45 : 30) + _random.nextInt(15);
    
    for (int i = 0; i < targetRegCount; i++) {
        final memberIdx = (eventIndex * 5 + i) % members.length;
        final m = members[memberIdx];
        if (m.id == 'demo_hero_sanjay') continue;
        
        // [NEW] Skip Eric Adams for the last event (May Spring Medal, index 16)
        // to ensure he has credit available and is NOT registered.
        if (m.id == 'demo_m_32' && eventIndex == 16) continue;
        
        bool isWithdrawn = _random.nextDouble() < 0.05;
        bool isConfirmed = !isWithdrawn && regs.length < (isSocial ? 60 : 40);
        
        final attendsBreakfast = hasBreakfast && _random.nextDouble() < 0.85;
        final attendsLunch = hasLunch && _random.nextDouble() < 0.95; // Usually everyone if lunch is served
        final attendsDinner = hasDinner && _random.nextDouble() < 0.90;
        final needsBuggy = !isSocial && _random.nextDouble() < 0.15;

        // Guest logic (20% chance)
        bool hasGuest = !isWithdrawn && _random.nextDouble() < (isSocial ? 0.3 : 0.15);
        String? guestName;
        if (hasGuest) {
          final guestFirstName = maleFirstNames[_random.nextInt(maleFirstNames.length)];
          final guestLastName = lastNames[_random.nextInt(lastNames.length)];
          guestName = '$guestFirstName $guestLastName (G)';
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
        final hasFine = (isHistorical) && i % 4 == 0;
        final finePaid = hasFine && (_random.nextDouble() < 0.85); // 85% pay their fines

        regs.add(EventRegistration(
          memberId: m.id,
          memberName: m.displayName,
          attendingGolf: !isSocial && isConfirmed,
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
          hasPaid: isConfirmed && _random.nextDouble() < highPaidRate,
          isConfirmed: isConfirmed,
          guestIsConfirmed: isConfirmed && hasGuest,
          handicap: m.handicap,
          registeredAt: date.subtract(Duration(days: 30 - (i % 20))),
          statusOverride: isWithdrawn ? 'withdrawn' : (isConfirmed ? 'confirmed' : 'waitlist'),
          cost: totalCost,
          fineAmount: hasFine ? 2.0 : 0.0,
          finePaid: finePaid,
        ));
    }

    final updatedEvent = event.copyWith(registrations: regs);
    await eventRepo.addEvent(updatedEvent);

    if (isSocial) {
      // For social events, we skip competitions, grouping, and scorecards
      return [];
    }

    // --- EVERYTHING BELOW IS GOLF ONLY ---
    
    // Competition Rules
    final matchingTemplate = templates.where((t) => t.rules.format == format && t.rules.subtype == subtype).firstOrNull;
    final rules = matchingTemplate?.rules ?? CompetitionRules(
      format: format, subtype: subtype, 
      handicapAllowance: subtype == CompetitionSubtype.fourball ? 0.85 : (subtype == CompetitionSubtype.foursomes ? 0.50 : 0.95),
      mode: (subtype == CompetitionSubtype.fourball || subtype == CompetitionSubtype.foursomes) ? CompetitionMode.pairs : (format == CompetitionFormat.scramble ? CompetitionMode.teams : CompetitionMode.singles),
    );

    await compRepo.addCompetition(Competition(
      id: updatedEvent.id, name: title, type: CompetitionType.event,
      status: status == EventStatus.completed 
          ? CompetitionStatus.closed 
          : (status == EventStatus.inPlay ? CompetitionStatus.published : CompetitionStatus.open),
      rules: rules, startDate: date, endDate: date,
    ));

    final isLiveOrPast = status == EventStatus.completed || status == EventStatus.inPlay;
    
    // Grouping & Results containers
    final List<Map<String, dynamic>> results = [];
    final List<EventExpense> expenses = [
      // Manual/Extra costs can be added here. 
      // Venue costs and Prizes are tracked automatically via Registrations and Awards to prevent double-counting.
    ];
    final List<EventAward> awards = [];

    if (isLiveOrPast) {
      // 1. Generate Groups
      final items = RegistrationLogic.getSortedItems(updatedEvent, includeWithdrawn: true);
      final Map<String, double> memberHandicaps = {for (var m in members) m.id: m.handicap};
      final groups = GroupingService.generateInitialGrouping(
        event: updatedEvent, participants: items, previousEventsInSeason: [],
        memberHandicaps: memberHandicaps, prioritizeBuggyPairing: true,
        strategy: isInvitational ? 'balanced' : 'progressive',
        useWhs: true, rules: rules,
      );

      // 2. Scores/Scorecards
      final scoreRepo = ref.read(scorecardRepositoryProvider);
      await scoreRepo.deleteAllScorecards(updatedEvent.id);
      final isStableford = rules.format == CompetitionFormat.stableford;
      final cardStatus = status == EventStatus.completed ? ScorecardStatus.finalScore : ScorecardStatus.submitted;

      for (var group in groups) {
        for (var p in group.players) {
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
              if (h >= holesPassed) { holeScores.add(null); continue; }
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
              holeScores: holeScores, points: isStableford ? pointsTotal : null,
              handicapIndex: index, playingHandicap: phc,
              netTotal: grossTotal - (phc * (holesPassed / 18)).round(),
              submittedAt: (cardStatus == ScorecardStatus.submitted || cardStatus == ScorecardStatus.finalScore) && status != EventStatus.inPlay
                  ? date.copyWith(hour: 14, minute: _random.nextInt(60)) 
                  : null,
              createdAt: DateTime.now(), updatedAt: DateTime.now(),
            ));

            results.add({
              'playerId': entryId, 'playerName': p.name, 'memberId': entryId,
              'points': isStableford ? pointsTotal : (grossTotal - (phc * (holesPassed / 18)).round()), 
              'holeScores': holeScores, 'phc': phc, 'holesPlayed': holesPassed,
            });
        }
      }

      // 3. Finalize results ranking
      final isHigherBetter = rules.format == CompetitionFormat.stableford || rules.format == CompetitionFormat.scramble;
      results.sort((a, b) {
        if (isHigherBetter) {
          return (b['points'] as num).compareTo(a['points'] as num);
        } else {
          return (a['points'] as num).compareTo(b['points'] as num);
        }
      });

      for (int i = 0; i < results.length; i++) {
         int pos = i + 1;
         if (i > 0 && results[i]['points'] == results[i-1]['points']) pos = results[i-1]['position'];
         results[i]['position'] = pos;
      }

      // 4. Awards
      final memberCount = regs.where((r) => r.isConfirmed && r.attendingGolf && r.guestName == null).length;
      final totalPrizePool = memberCount * 10.0;

      if (isInvitational) {
        // Invitations: 1st Cup + Vouchers
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
        // Regular Season: Cash Prize (50 / 30 / 20)
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

      // 5. Commit grouping & results
      await eventRepo.updateEvent(updatedEvent.copyWith(
        grouping: {'groups': groups.map((g) => g.toJson()).toList(), 'isPublished': true}, 
        results: results, expenses: expenses, awards: awards,
        feedItems: _generateFeedItems(updatedEvent, results),
      ));
    } else {
      // FOR FUTURE/DRAFT EVENTS: Save with empty groups and no results
      await eventRepo.updateEvent(updatedEvent.copyWith(
        grouping: {'groups': [], 'isPublished': false}, 
        results: [], expenses: expenses, awards: [],
        feedItems: _generateFeedItems(updatedEvent, []),
      ));
    }


    
    return results;
  }

  List<String> _getGalleryPhotos(String courseName) {
    if (courseName.contains('St Andrews') || courseName.contains('Royal County Down') || courseName.contains('Muirfield')) {
      return [
        'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?auto=format&fit=crop&w=800&q=80', // Links dunes
        'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?auto=format&fit=crop&w=800&q=80', // Replacement for broken link
        'https://images.unsplash.com/photo-1591492102875-9c59508d508e?auto=format&fit=crop&w=800&q=80', // Bunkers
      ];
    }
    if (courseName.contains('Pebble Beach') || courseName.contains('Cypress Point') || courseName.contains('Royal Melbourne')) {
      return [
        'https://images.unsplash.com/photo-1500673397354-9448fefb5acc?auto=format&fit=crop&w=800&q=80', // Ocean view
        'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80', // Coastal green
        'https://images.unsplash.com/photo-1592919016327-5130ed82270a?auto=format&fit=crop&w=800&q=80', // Replacement
      ];
    }
    if (courseName.contains('Dom Pedro') || courseName.contains('Victoria')) {
      return [
        'https://images.unsplash.com/photo-1584061556814-7e8c3fc6e4ed?auto=format&fit=crop&w=800&q=80', // Mediterranean pines
        'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80', // Villa background
        'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80', // Replacement
      ];
    }
    return [
      'https://images.unsplash.com/photo-1591492102875-9c59508d508e?auto=format&fit=crop&w=800&q=80', // Replacement
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

    // 2. Membership Renewal (Active for March 2026)
    if (now.year == 2026 && now.month == 3) {
      items.add(EventFeedItem(
        id: 'news_${event.id}_renewal',
        type: FeedItemType.newsletter,
        title: '2026 Membership Renewal',
        content: 'Membership renewals are now open! Issued March 12th, the renewal window closes in 45 days (April 26th). Please ensure your fees are settled to maintain your society handicap and eligibility for the upcoming season.',
        isPublished: true,
        createdAt: DateTime(2026, 3, 12, 9, 0),
        sortOrder: -50, // High priority
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
