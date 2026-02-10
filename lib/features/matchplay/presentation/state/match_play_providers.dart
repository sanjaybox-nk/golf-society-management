
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/match_definition.dart';
import '../../domain/match_play_calculator.dart';
import '../../domain/golf_event_match_extensions.dart'; // Import the extension
import '../../../../features/events/presentation/events_provider.dart';
import '../../../../features/members/presentation/profile_provider.dart';
import '../../../../features/competitions/presentation/competitions_provider.dart';

part 'match_play_providers.g.dart';

@riverpod
class CurrentMatchController extends _$CurrentMatchController {
  @override
  FutureOr<MatchResult?> build(String eventId) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final user = ref.watch(effectiveUserProvider);
    
    return eventAsync.when(
      data: (event) {
        
        // 1. Find Match for Current User
        final matches = event.matches; // Uses our extension
        if (matches.isEmpty) return null;

        final myMatch = matches.firstWhere(
           (m) => m.team1Ids.contains(user.id) || m.team2Ids.contains(user.id),
           orElse: () => matches.first // Fallback: Return first match if user not found (e.g. admin viewing) - or maybe null?
           // Better: Return null if not playing.
        );
        
        // Strict check: if user not in match and matches exist, returns the first one found where user is participating.
        // If user is not in ANY match, we might return null.
        // For testing/admin, maybe we select a match?
        // Let's stick to "User's Match" for now.
        
        bool isParticipant = myMatch.team1Ids.contains(user.id) || myMatch.team2Ids.contains(user.id);
        if (!isParticipant) {
           // Try to find ANY match involved?
           // The firstWhere throws if not found without orElse.
           // Modified logic below.
        }
        
        // Correct Logic:
        final userMatch = matches.where((m) => m.team1Ids.contains(user.id) || m.team2Ids.contains(user.id)).firstOrNull;
        if (userMatch == null) return null;
        

        // 2. Verified Data Source: Use the stream of scorecards for this event
        final scorecardsAsync = ref.watch(scorecardsListProvider(eventId));
        
        // Return null while loading or error, or calculate if data available
        return scorecardsAsync.when(
          data: (scorecards) {
             return MatchPlayCalculator.calculate(
              match: userMatch, 
              scorecards: scorecards, 
              courseConfig: event.courseConfig, 
              holesToPlay: event.courseConfig['holes']?.length ?? 18
            );
          },
          loading: () => null,
          error: (_, s) => null,
        );

      },
      loading: () => null,
      error: (_, s) => null,
    );
  }
}
