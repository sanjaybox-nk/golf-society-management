import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/events/data/events_repository.dart';
import '../../features/members/data/members_repository.dart';
import '../../features/events/presentation/events_provider.dart';
import '../../features/members/presentation/members_provider.dart';
import '../utils/mock_data_seeder.dart';
import '../../features/competitions/presentation/competitions_provider.dart';

final seedingControllerProvider = Provider((ref) {
  return SeedingController(
    eventsRepo: ref.watch(eventsRepositoryProvider),
    membersRepo: ref.watch(membersRepositoryProvider),
    ref: ref,
  );
});

class SeedingController {
  final EventsRepository eventsRepo;
  final MembersRepository membersRepo;
  final Ref ref;

  SeedingController({
    required this.eventsRepo,
    required this.membersRepo,
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
}
