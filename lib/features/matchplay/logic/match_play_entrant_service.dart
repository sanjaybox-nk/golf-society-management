import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../domain/match_play_tournament.dart';
import 'package:golf_society/features/events/domain/registration_logic.dart';
import '../../../../domain/scoring/handicap_calculator.dart';
import 'package:uuid/uuid.dart';

class MatchPlayEntrantService {
  static const _uuid = Uuid();

  /// Map Event Registrations to Match Play Entrants
  /// Handles Singles/Pairs logic based on tournament configuration
  static List<MatchPlayEntrant> mapRegistrationsToEntrants({
    required GolfEvent event,
    required bool isPairs,
    required Map<String, Member> membersMap,
  }) {
    final List<MatchPlayEntrant> entrants = [];
    final playing = RegistrationLogic.getPlayingParticipants(event);

    if (isPairs) {
      // Logic for Pairs: Link Host with their registered guest or partner
      final processedPlayers = <String>{};
      
      for (var item in playing) {
        final reg = item.registration;
        if (processedPlayers.contains(reg.memberId)) continue;
        
        final List<String> playerIds = [reg.memberId];
        String entrantName = item.name;

        // 1. Check for registered guest
        if (reg.guestName != null && reg.guestName!.isNotEmpty) {
           playerIds.add('${reg.memberId}_guest');
           entrantName = '$entrantName & ${reg.guestName}';
        } 
        // 2. Check for chosen member partner
        else if (reg.partnerId != null) {
           playerIds.add(reg.partnerId!);
           entrantName = '$entrantName & ${reg.partnerName ?? "Partner"}';
           processedPlayers.add(reg.partnerId!); // Mark partner as processed
        }

        entrants.add(MatchPlayEntrant(
          id: _uuid.v4(),
          playerIds: playerIds,
          name: entrantName,
        ));
        
        processedPlayers.add(reg.memberId);
      }
    } else {
      // Logic for Singles
      for (var item in playing) {
        entrants.add(MatchPlayEntrant(
          id: _uuid.v4(),
          playerIds: [item.isGuest ? '${item.registration.memberId}_guest' : item.registration.memberId],
          name: item.name,
        ));
      }
    }

    return entrants;
  }

  /// Map Leaderboard Results to Match Play Entrants (Qualifiers)
  /// Recalculates handicaps based on current index if required
  static List<MatchPlayEntrant> mapLeaderboardToEntrants({
    required List<Map<String, dynamic>> results,
    required int limit,
    required Map<String, Member> membersMap,
    bool autoSeed = true,
  }) {
    final List<MatchPlayEntrant> entrants = [];
    final qualifiers = results.take(limit).toList();

    for (int i = 0; i < qualifiers.length; i++) {
        final res = qualifiers[i];
        final memberId = res['memberId'] as String;
        final name = res['memberName'] as String? ?? memberId;
        
        entrants.add(MatchPlayEntrant(
          id: _uuid.v4(),
          playerIds: [memberId],
          name: name,
          seed: autoSeed ? i + 1 : null,
          qualifyingScore: (res['score'] as num?)?.toDouble() ?? 0.0,
        ));
    }

    return entrants;
  }
}
