import 'package:flutter_test/flutter_test.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/domain/scoring/scoring_strategy.dart';

void main() {
  group('StablefordStrategy', () {
    const strategy = StablefordStrategy();

    test('format is stableford', () => expect(strategy.format, CompetitionFormat.stableford));
    test('higherIsBetter is true', () => expect(strategy.higherIsBetter, isTrue));
    test('isTeamBased is false', () => expect(strategy.isTeamBased, isFalse));

    test('compareScores — higher score ranks first', () {
      expect(strategy.compareScores(36, 34), isNegative);
    });
    test('compareScores — equal scores tie', () {
      expect(strategy.compareScores(35, 35), 0);
    });
    test('compareScores — lower score ranks second', () {
      expect(strategy.compareScores(30, 36), isPositive);
    });
  });

  group('StrokeStrategy', () {
    const strategy = StrokeStrategy();

    test('format is stroke', () => expect(strategy.format, CompetitionFormat.stroke));
    test('higherIsBetter is false', () => expect(strategy.higherIsBetter, isFalse));
    test('isTeamBased is false', () => expect(strategy.isTeamBased, isFalse));

    test('compareScores — lower score ranks first', () {
      expect(strategy.compareScores(68, 72), isNegative);
    });
    test('compareScores — equal scores tie', () {
      expect(strategy.compareScores(72, 72), 0);
    });
    test('compareScores — higher score ranks second', () {
      expect(strategy.compareScores(76, 68), isPositive);
    });
  });

  group('ScrambleStrategy', () {
    test('isTeamBased is true', () {
      expect(const ScrambleStrategy(CompetitionFormat.stableford).isTeamBased, isTrue);
    });
    test('higherIsBetter when underlying is stableford', () {
      expect(const ScrambleStrategy(CompetitionFormat.stableford).higherIsBetter, isTrue);
    });
    test('higherIsBetter is false when underlying is stroke', () {
      expect(const ScrambleStrategy(CompetitionFormat.stroke).higherIsBetter, isFalse);
    });
    test('compareScores delegates to underlying direction', () {
      final s = const ScrambleStrategy(CompetitionFormat.stableford);
      expect(s.compareScores(36, 34), isNegative); // higher wins
    });
  });

  group('MatchPlayStrategy', () {
    const strategy = MatchPlayStrategy();

    test('format is matchPlay', () => expect(strategy.format, CompetitionFormat.matchPlay));
    test('higherIsBetter is false', () => expect(strategy.higherIsBetter, isFalse));
    test('isTeamBased is false', () => expect(strategy.isTeamBased, isFalse));
  });

  group('ScoringStrategyRegistry.forRules', () {
    CompetitionRules rules({
      CompetitionFormat format = CompetitionFormat.stableford,
      bool hasMatchPlayOverlay = false,
      CompetitionSubtype subtype = CompetitionSubtype.none,
      CompetitionFormat underlyingFormat = CompetitionFormat.stroke,
    }) =>
        CompetitionRules(
          format: format,
          hasMatchPlayOverlay: hasMatchPlayOverlay,
          subtype: subtype,
          underlyingFormat: underlyingFormat,
        );

    test('stableford → StablefordStrategy', () {
      expect(ScoringStrategyRegistry.forRules(rules(format: CompetitionFormat.stableford)), isA<StablefordStrategy>());
    });
    test('stroke → StrokeStrategy', () {
      expect(ScoringStrategyRegistry.forRules(rules(format: CompetitionFormat.stroke)), isA<StrokeStrategy>());
    });
    test('maxScore → StrokeStrategy', () {
      expect(ScoringStrategyRegistry.forRules(rules(format: CompetitionFormat.maxScore)), isA<StrokeStrategy>());
    });
    test('scramble → ScrambleStrategy', () {
      expect(ScoringStrategyRegistry.forRules(rules(format: CompetitionFormat.scramble)), isA<ScrambleStrategy>());
    });
    test('scramble strategy carries underlying format', () {
      final s = ScoringStrategyRegistry.forRules(
        rules(format: CompetitionFormat.scramble, underlyingFormat: CompetitionFormat.stableford),
      ) as ScrambleStrategy;
      expect(s.higherIsBetter, isTrue);
    });
    test('matchPlay overlay overrides format → MatchPlayStrategy', () {
      expect(
        ScoringStrategyRegistry.forRules(rules(format: CompetitionFormat.stableford, hasMatchPlayOverlay: true)),
        isA<MatchPlayStrategy>(),
      );
    });
    test('ryderCup subtype → MatchPlayStrategy', () {
      expect(
        ScoringStrategyRegistry.forRules(rules(subtype: CompetitionSubtype.ryderCup)),
        isA<MatchPlayStrategy>(),
      );
    });
  });
}
