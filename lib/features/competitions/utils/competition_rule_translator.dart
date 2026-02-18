import '../../../models/competition.dart';

class CompetitionRuleTranslator {
  static String translate(CompetitionRules rules) {
    final List<String> parts = [];

    // 1. Core Format & Mode
    final String modeStr = rules.effectiveMode == CompetitionMode.singles ? 'individual' : 'team';
    
    switch (rules.format) {
      case CompetitionFormat.stableford:
        parts.add('A $modeStr Stableford competition where you earn points based on your net score relative to par (2 points for a net par).');
        break;
      case CompetitionFormat.stroke:
        parts.add('A standard $modeStr Strokeplay event where every shot counts.');
        break;
      case CompetitionFormat.matchPlay:
        if (rules.subtype == CompetitionSubtype.fourball) {
          parts.add('A fourball match play competition where teams of two play their own ball and the best score counts for the side.');
        } else if (rules.subtype == CompetitionSubtype.foursomes) {
          parts.add('A foursomes match play competition where teams of two play alternate shots.');
        } else if (rules.subtype == CompetitionSubtype.ryderCup) {
          parts.add('A Ryder Cup style team competition where matches between sides contribute to an overall team points total.');
        } else if (rules.subtype == CompetitionSubtype.teamMatchPlay) {
          parts.add('A team-based match play competition where results from individual matches are aggregated for a team result.');
        } else {
          parts.add('A standard Match Play competition where you play against your opponent hole-by-hole.');
        }
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
    }

    // 2. Handicap Details
    if (rules.handicapAllowance < 1.0 && rules.handicapAllowance > 0) {
      parts.add('Played with a ${(rules.handicapAllowance * 100).toInt()}% handicap allowance.');
    } else if (rules.handicapAllowance == 0) {
      parts.add('This is a Gross competition (no handicap strokes).');
    }

    // 3. Specific Rule Modifiers
    if (rules.handicapCap < 54) {
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
