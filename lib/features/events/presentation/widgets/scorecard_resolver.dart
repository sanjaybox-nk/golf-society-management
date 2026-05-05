import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scorecard_factory.dart';
import 'package:golf_society/utils/firestore_normalizer.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/models/member.dart';
import '../../../competitions/presentation/widgets/leaderboard_widget.dart';
import '../../../../domain/scoring/scoring_calculator.dart';
import '../../../../domain/models/course_config.dart';
import '../../../matchplay/domain/match_play_calculator.dart';
import '../../../matchplay/domain/match_definition.dart';
import 'course_info_card.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../members/presentation/profile_provider.dart';
import '../../../courses/presentation/courses_provider.dart';
import 'package:golf_society/domain/models/event_registration.dart';
import '../events_provider.dart';



/// Resolves the best available [Scorecard] for a given [LeaderboardEntry].
///
/// Applies a 7-step waterfall: direct bridge → live scorecard → team member
/// fallback → seeded team index → seeded result map → empty placeholder.
class ScorecardResolver {
  ScorecardResolver._();

  static Scorecard resolve({
    required LeaderboardEntry entry,
    required List<Scorecard> scorecards,
    required GolfEvent event,
  }) {
    if (kDebugMode) debugPrint("--- SCORECARD MODAL SHOW: ${entry.playerName} ---");
    if (kDebugMode) debugPrint("Entry ID: ${entry.entryId}");
    if (kDebugMode) debugPrint("Mode: ${entry.mode}");
    if (kDebugMode) debugPrint("TeamMemberIds: ${entry.teamMemberIds?.length} -> ${entry.teamMemberIds}");
    if (kDebugMode) debugPrint("TeamMemberNames: ${entry.teamMemberNames?.length} -> ${entry.teamMemberNames}");
    if (kDebugMode) debugPrint("HoleScores provided: ${entry.holeScores != null && entry.holeScores!.any((s) => s != null)}");
    
    // 0. Prioritize scores passed directly from Leaderboard (Fix for Scramble populating)
    Scorecard? scorecard;
    bool isScorecardEmpty = true;

    if (entry.holeScores != null && entry.holeScores!.any((s) => s != null)) {
      if (kDebugMode) debugPrint("Found scores via Direct Bridge");
      scorecard = ScorecardFactory.fromDirectBridge(
        entryId: entry.entryId,
        competitionId: event.id,
        holeScores: entry.holeScores!,
      );
      isScorecardEmpty = false;
    }

    // 1. Try to find a live scorecard if not found directly
    if (isScorecardEmpty) {
      scorecard = scorecards.firstWhereOrNull((s) => s.entryId == entry.entryId);
      isScorecardEmpty = scorecard == null || scorecard.holeScores.every((s) => s == null);
      if (kDebugMode) if (!isScorecardEmpty) debugPrint("Found scores via Step 1 (Live Scorecard)");
    }
    
    // 1b. Fallback for Team: Try each member ID if the combined team ID lookup fails or is empty
    if (isScorecardEmpty && entry.teamMemberIds != null) {
      for (final memberId in entry.teamMemberIds!) {
        final memberCard = scorecards.firstWhereOrNull((s) => s.entryId == memberId);
        if (memberCard != null && memberCard.holeScores.any((s) => s != null)) {
          scorecard = memberCard;
          isScorecardEmpty = false;
          if (kDebugMode) debugPrint("Found scores via Step 1b (Team Member Scorecard)");
          break;
        }
      }
    }
    
    // 1c. Double Fallback for Seeded Teams (team_N pattern)
    if (isScorecardEmpty && entry.teamIndex != null) {
      final seededTeamId = 'team_${entry.teamIndex}';
      final teamCard = scorecards.firstWhereOrNull((s) => s.entryId == seededTeamId);
      if (teamCard != null && teamCard.holeScores.any((s) => s != null)) {
         scorecard = teamCard;
         isScorecardEmpty = false;
         if (kDebugMode) debugPrint("Found scores via Step 1c (Seeded team_N Scorecard)");
      }
    }

    // 2. Fallback: Reconstruct from seeded results if live scorecard is missing or empty
    if (isScorecardEmpty) {
      // 2a. Direct Match
      var seededResult = event.results.firstWhereOrNull(
        (r) => FirestoreNormalizer.resolveMemberId(r) == entry.entryId,
      );

      // 2b. Fallback for Team Seeded: Try each member
      if (seededResult == null && entry.teamMemberIds != null) {
        for (final memberId in entry.teamMemberIds!) {
          final s = event.results.firstWhereOrNull(
            (r) => FirestoreNormalizer.resolveMemberId(r) == memberId,
          );
          if (s != null && s['holeScores'] != null && (s['holeScores'] as List).any((score) => score != null)) {
            seededResult = s;
            break;
          }
        }
      }

      // 2c. Last Resort: Try team index pattern in results (if stored there)
      if (seededResult == null && entry.teamIndex != null) {
        final seededTeamId = 'team_${entry.teamIndex}';
        seededResult = event.results.firstWhereOrNull(
          (r) => FirestoreNormalizer.resolveMemberId(r) == seededTeamId,
        );
      }

      if (seededResult != null && seededResult['holeScores'] != null) {
        if (kDebugMode) debugPrint("Found scores via Step 2 (Seeded Results map)");
        // Reconstruct temporary scorecard object
        scorecard = ScorecardFactory.fromSeededResult(
          entryId: entry.entryId,
          competitionId: event.id,
          result: seededResult,
        );
        isScorecardEmpty = false;
      }
    }

    // 3. Final Bail if truly missing (but allow empty modal for groups with NO scores yet)
    scorecard ??= ScorecardFactory.createEmpty(
      entryId: entry.entryId,
      competitionId: event.id,
    );

    return scorecard;
  }
}
