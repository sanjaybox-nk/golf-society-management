import 'package:golf_society/domain/models/competition.dart';

/// Encapsulates per-format scoring behaviour: sort direction, team-based logic.
/// Used by the leaderboard processor to avoid scattered `isStableford`/`isScramble` flags.
abstract class ScoringStrategy {
  const ScoringStrategy();

  CompetitionFormat get format;

  /// Whether higher scores rank better (Stableford) vs lower scores rank better (Stroke).
  bool get higherIsBetter;

  /// Whether this format computes a team aggregate handicap (e.g. Scramble).
  bool get isTeamBased;

  /// Returns negative if [scoreA] ranks higher than [scoreB] on the leaderboard.
  int compareScores(int scoreA, int scoreB) =>
      higherIsBetter ? scoreB.compareTo(scoreA) : scoreA.compareTo(scoreB);
}

class StablefordStrategy extends ScoringStrategy {
  const StablefordStrategy();
  @override
  CompetitionFormat get format => CompetitionFormat.stableford;
  @override
  bool get higherIsBetter => true;
  @override
  bool get isTeamBased => false;
}

class StrokeStrategy extends ScoringStrategy {
  const StrokeStrategy();
  @override
  CompetitionFormat get format => CompetitionFormat.stroke;
  @override
  bool get higherIsBetter => false;
  @override
  bool get isTeamBased => false;
}

class ScrambleStrategy extends ScoringStrategy {
  const ScrambleStrategy(this._underlying);
  final CompetitionFormat _underlying;
  @override
  CompetitionFormat get format => CompetitionFormat.scramble;
  @override
  bool get higherIsBetter => _underlying == CompetitionFormat.stableford;
  @override
  bool get isTeamBased => true;
}

class MatchPlayStrategy extends ScoringStrategy {
  const MatchPlayStrategy();
  @override
  CompetitionFormat get format => CompetitionFormat.matchPlay;
  @override
  bool get higherIsBetter => false;
  @override
  bool get isTeamBased => false;
}

/// Resolves the correct [ScoringStrategy] for a given set of competition rules.
class ScoringStrategyRegistry {
  ScoringStrategyRegistry._();

  static ScoringStrategy forRules(CompetitionRules rules) {
    if (rules.isMatchPlay) return const MatchPlayStrategy();
    return switch (rules.format) {
      CompetitionFormat.stableford => const StablefordStrategy(),
      CompetitionFormat.scramble   => ScrambleStrategy(rules.underlyingFormat),
      _                            => const StrokeStrategy(),
    };
  }
}
