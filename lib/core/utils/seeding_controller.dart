import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/events/data/events_repository.dart';
import '../../features/members/data/members_repository.dart';
import '../../features/events/presentation/events_provider.dart';
import '../../features/members/presentation/members_provider.dart';
import '../utils/mock_data_seeder.dart';
import '../../features/competitions/presentation/competitions_provider.dart';
import '../../features/competitions/data/scorecard_repository.dart';
import '../../models/event_registration.dart';

final seedingControllerProvider = Provider((ref) {
  return SeedingController(
    eventsRepo: ref.watch(eventsRepositoryProvider),
    membersRepo: ref.watch(membersRepositoryProvider),
    scorecardRepo: ref.watch(scorecardRepositoryProvider),
    ref: ref,
  );
});

class SeedingController {
  final EventsRepository eventsRepo;
  final MembersRepository membersRepo;
  final ScorecardRepository scorecardRepo;
  final Ref ref;

  SeedingController({
    required this.eventsRepo,
    required this.membersRepo,
    required this.scorecardRepo,
    required this.ref,
  });

  Future<void> seedPastEvents() async {
    final members = await membersRepo.getMembers();
    final events = await eventsRepo.getEvents();
    
    // Find past events
    final now = DateTime.now();
    final pastEvents = events.where((e) => e.date.isBefore(now)).toList();
    
    final seeder = MockDataSeeder();
    
    for (var event in pastEvents) {
      if (event.results.isNotEmpty) continue; // Skip if already seeded

      final registrationIds = event.registrations
          .map((reg) => reg.memberId)
          .where((id) => id != 'unknown_id')
          .toList();

      // Fetch competition rules if available
      final competition = await ref.read(competitionsRepositoryProvider).getCompetition(event.id);

      final results = seeder.generateFieldResults(
        members: members,
        courseConfig: event.courseConfig,
        specificMemberIds: registrationIds.isNotEmpty ? registrationIds : null,
        rules: competition?.rules,
      );

      await eventsRepo.updateEvent(event.copyWith(
        results: results,
      ));
    }
  }

  Future<void> forceRegenerateEvent(String eventId) async {
    final event = await eventsRepo.getEvent(eventId);
    if (event == null) return;
    
    // 1. Delete all existing scorecards for this event to get a clean slate
    await scorecardRepo.deleteAllScorecards(eventId);

    final members = await membersRepo.getMembers();
    final competition = await ref.read(competitionsRepositoryProvider).getCompetition(eventId);
    
    // 2. Ensure we have some guests for testing (if none exist)
    List<EventRegistration> updatedRegistrations = List<EventRegistration>.from(event.registrations);
    if (!updatedRegistrations.any((r) => r.isGuest)) {
      // Inject some mock guests
      updatedRegistrations.add(const EventRegistration(
        memberId: 'guest_1',
        memberName: 'Guest One',
        isGuest: true,
        guestName: 'Harry Wilson',
        guestHandicap: '12',
        attendingGolf: true,
      ));
      updatedRegistrations.add(const EventRegistration(
        memberId: 'guest_2',
        memberName: 'Guest Two',
        isGuest: true,
        guestName: 'Sophie Clarke',
        guestHandicap: '18',
        attendingGolf: true,
      ));
      
      // Update event with these new registrations so we can query them
      await eventsRepo.updateEvent(event.copyWith(registrations: updatedRegistrations));
    }

    final List<String> registrationIds = updatedRegistrations
          .map((reg) => reg.memberId)
          .where((id) => id != 'unknown_id')
          .toList();

    final seeder = MockDataSeeder();
    final results = seeder.generateFieldResults(
        members: members,
        courseConfig: event.courseConfig,
        specificMemberIds: registrationIds.isNotEmpty ? registrationIds : null,
        rules: competition?.rules,
    );
    
    await eventsRepo.updateEvent(event.copyWith(
      results: results,
    ));
  }
}
