import 'package:golf_society/domain/models/scorecard.dart';
import 'package:golf_society/domain/scoring/scorecard_constants.dart';

class ScorecardFactory {
  ScorecardFactory._();

  /// Creates a blank placeholder scorecard when no real scorecard exists yet.
  static Scorecard createEmpty({
    required String entryId,
    required String competitionId,
  }) =>
      Scorecard(
        id: '${ScorecardConstants.emptyIdPrefix}$entryId',
        competitionId: competitionId,
        roundId: ScorecardConstants.defaultRoundId,
        entryId: entryId,
        submittedByUserId: ScorecardConstants.systemUserId,
        status: ScorecardStatus.draft,
        holeScores: List.generate(18, (_) => null),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Reconstructs a temporary scorecard from a seeded results map (Firestore result document).
  static Scorecard fromSeededResult({
    required String entryId,
    required String competitionId,
    required Map<String, dynamic> result,
  }) =>
      Scorecard(
        id: '${ScorecardConstants.tempIdPrefix}$entryId',
        competitionId: competitionId,
        roundId: ScorecardConstants.defaultRoundId,
        entryId: entryId,
        submittedByUserId: ScorecardConstants.systemUserId,
        status: ScorecardStatus.finalScore,
        holeScores: (result['holeScores'] as List)
            .map((e) => e == null ? null : (e as num).toInt())
            .toList(),
        points: result['points'] is num ? (result['points'] as num).toInt() : null,
        netTotal: result['netTotal'] is num ? (result['netTotal'] as num).toInt() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Creates a scorecard bridged directly from entry hole scores (not from Firestore results).
  static Scorecard fromDirectBridge({
    required String entryId,
    required String competitionId,
    required List<int?> holeScores,
  }) =>
      Scorecard(
        id: '${ScorecardConstants.directIdPrefix}$entryId',
        competitionId: competitionId,
        roundId: ScorecardConstants.defaultRoundId,
        entryId: entryId,
        submittedByUserId: ScorecardConstants.systemUserId,
        status: ScorecardStatus.finalScore,
        holeScores: holeScores,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
