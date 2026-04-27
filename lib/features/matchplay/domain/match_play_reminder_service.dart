import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import '../../events/presentation/events_provider.dart';
import '../data/match_play_repository.dart';

class MatchPlayReminderService {
  final Ref ref;

  MatchPlayReminderService(this.ref);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Scans for uncompleted matches in a specific tournament and sends reminders if needed.
  /// If [tournamentId] is null, scans all published tournaments.
  Future<void> syncReminders({String? tournamentId}) async {
    final eventRepo = ref.read(eventsRepositoryProvider);
    final matchRepo = ref.read(matchPlayRepositoryProvider);

    // 1. Get all published events with match play
    final events = await eventRepo.getEvents();
    final publishedMatchPlayEvents = events.where((e) => 
      e.status == EventStatus.published && 
      e.grouping['tournamentId'] != null &&
      (tournamentId == null || e.grouping['tournamentId'] == tournamentId)
    ).toList();

    for (final event in publishedMatchPlayEvents) {
      final tid = event.grouping['tournamentId']!;
      final tournament = await matchRepo.getTournament(tid);
      if (tournament == null) continue;

      final roundCutoffs = event.grouping['roundCutoffs'] as Map<String, dynamic>? ?? {};
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      for (final match in tournament.matches) {
        // Skip completed or byes
        // MatchDefinition doesn't have isCompleted, we check for a result elsewhere?
        // Note: In this system, we check results collection for terminal status
        final isCompleted = await _checkMatchCompletion(match.id);
        if (isCompleted || match.isBye) continue;

        final cutoffStr = roundCutoffs[match.round.name];
        if (cutoffStr == null) continue;

        final cutoffDate = DateTime.parse(cutoffStr);
        final cutoffNormalized = DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day);

        final daysRemaining = cutoffNormalized.difference(todayNormalized).inDays;

        if (daysRemaining == 5) {
          await _sendReminder(
            tournamentName: tournament.name,
            matchId: match.id,
            playerIds: [...match.team1Ids, ...match.team2Ids],
            deadline: cutoffDate,
          );
        }
      }
    }
  }

  Future<bool> _checkMatchCompletion(String matchId) async {
    final snapshot = await _firestore
        .collection('match_results')
        .where('matchId', isEqualTo: matchId)
        .where('isFinal', isEqualTo: true)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  Future<void> _sendReminder({
    required String tournamentName,
    required String matchId,
    required List<String> playerIds,
    required DateTime deadline,
  }) async {
    final deadlineFormatted = DateFormat('d MMM').format(deadline);

    for (final playerId in playerIds) {
      // Direct Firestore write for simplicity or use notificationService
      await _firestore.collection('notifications').add({
        'recipientId': playerId,
        'title': 'Match Play Reminder',
        'message': 'Reminder: Your matchplay game in $tournamentName must be completed and submitted by $deadlineFormatted. Contact your opponent to finalize your tee time!',
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'match_play',
        'isRead': false,
        'actionUrl': '/matchplay',
      });
    }
  }
}

final matchPlayReminderServiceProvider = Provider<MatchPlayReminderService>((ref) {
  return MatchPlayReminderService(ref);
});
