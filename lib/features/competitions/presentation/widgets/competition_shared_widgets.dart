import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../utils/competition_rule_translator.dart';

class CompetitionBadgeRow extends StatelessWidget {
  final CompetitionRules rules;
  final String? eventId;
  final Color? baseColor;

  const CompetitionBadgeRow({
    super.key,
    required this.rules,
    this.eventId,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pills = [];

    // 1. Format Pill (Stroke Play, Match Play, etc.)
    pills.add(
      BoxyArtPill.format(
        label: rules.format == CompetitionFormat.matchPlay 
            ? rules.gameName 
            : rules.format.name,
      ),
    );

    // 2. Scoring Pill (Net or Gross)
    pills.add(
      BoxyArtPill.format(
        label: rules.scoringType,
      ),
    );

    // 3. Allowance Pill (e.g., 95% HCP)
    pills.add(
      BoxyArtPill.type(
        label: rules.defaultAllowanceLabel,
      ),
    );

    // 4. Mode Pill (Singles, Pairs, Team)
    pills.add(
      BoxyArtPill.type(
        label: rules.modeLabel,
      ),
    );

    if (rules.applyCapToIndex && 
        rules.handicapCap < 54 && 
        rules.format != CompetitionFormat.scramble && 
        rules.subtype != CompetitionSubtype.foursomes && 
        rules.subtype != CompetitionSubtype.fourball) {
      pills.add(
        BoxyArtPill.status(
          label: 'Capped @ ${rules.handicapCap.toInt()} HCP',
          color: AppColors.coral400,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pills,
    );
  }
}

class CompetitionRuleDescription extends StatelessWidget {
  final CompetitionRules rules;
  final TextStyle? style;

  const CompetitionRuleDescription({
    super.key,
    required this.rules,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final description = CompetitionRuleTranslator.translate(rules);
    
    return Text(
      description,
      style: style ?? TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
        height: 1.5,
      ),
    );
  }
}
