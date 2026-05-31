import 'package:golf_society/domain/models/competition.dart';

class CompetitionRuleTranslator {
  static String translate(CompetitionRules rules) {
    final List<String> parts = [];

    // 1. Core Format & Mode
    final String modeStr = rules.effectiveMode == CompetitionMode.singles ? 'individual' : 'team';
    
    switch (rules.format) {
      case CompetitionFormat.stableford:
        parts.add('An $modeStr Stableford competition where you earn points based on your net score relative to par (2 points for a net par).');
        break;
      case CompetitionFormat.stroke:
        parts.add('A standard $modeStr Strokeplay event where every shot counts.');
        break;
      case CompetitionFormat.maxScore:
        String capDesc = '';
        if (rules.maxScoreConfig != null) {
          switch (rules.maxScoreConfig!.type) {
            case MaxScoreType.fixed:
              capDesc = 'capped at ${rules.maxScoreConfig!.value}';
              break;
            case MaxScoreType.parPlusX:
              capDesc = 'capped at Par + ${rules.maxScoreConfig!.value}';
              break;
            case MaxScoreType.netDoubleBogey:
              capDesc = 'capped at Net Double Bogey';
              break;
          }
        }
        parts.add('A $modeStr competition focused on pace of play, with scores $capDesc on every hole.');
        break;
      case CompetitionFormat.scramble:
        parts.add('A team scramble format where the best shot is selected each time.');
        break;
      case CompetitionFormat.matchPlay:
        parts.add('An $modeStr Match Play competition where scores are compared hole-by-hole.');
        break;
    }

    // 1.5. Match Play context — only when match play is added on top of another format
    if (rules.subtype == CompetitionSubtype.matchPlaySeason) {
      parts.add('This is part of a season-long match play knockout tournament.');
    } else if (rules.hasMatchPlayOverlay) {
      parts.add('Includes a Match Play overlay where you play against your opponent hole-by-hole.');
    }

    // 2. Handicap Details
    if (rules.handicapAllowance < 1.0 && rules.handicapAllowance > 0) {
      parts.add('Played with a ${(rules.handicapAllowance * 100).toInt()}% handicap allowance.');
    } else if (rules.handicapAllowance == 0) {
      parts.add('This is a Gross competition (no handicap strokes).');
    }

    // 3. Specific Rule Modifiers
    if (rules.handicapCap > 0 && rules.handicapCap < 54) {
      parts.add('Maximum playing handicap is capped at ${rules.handicapCap.toInt()}.');
    }

    if (rules.format == CompetitionFormat.scramble && rules.minDrivesPerPlayer > 0) {
      parts.add('Each player must contribute at least ${rules.minDrivesPerPlayer} drives.');
    }

    if (rules.roundsCount > 1) {
      final String agg = rules.aggregation == AggregationMethod.singleBest ? 'best single round' : 'cumulative total';
      parts.add('Played over ${rules.roundsCount} rounds, using your $agg.');
    }

    return parts.join(' ');
  }
}
