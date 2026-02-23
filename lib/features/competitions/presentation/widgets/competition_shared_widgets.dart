import 'package:flutter/material.dart';
import '../../../../models/competition.dart';
import '../../../../core/shared_ui/badges.dart';
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
    final iconColor = baseColor ?? const Color(0xFF16A085);

    // 1. Format Pill (STABLEFORD, STROKE PLAY, MATCH PLAY, etc.)
    pills.add(
      BoxyArtStatusPill(
        text: rules.format == CompetitionFormat.matchPlay 
            ? rules.gameName.toUpperCase() 
            : rules.format.name.toUpperCase(),
        baseColor: const Color(0xFF3498DB), // Blue for format
      ),
    );

    // 2. Scoring Pill (NET or GROSS)
    pills.add(
      BoxyArtStatusPill(
        text: rules.scoringType.toUpperCase(),
        baseColor: rules.scoringType == 'GROSS' 
            ? const Color(0xFFE74C3C) 
            : (eventId?.contains('_secondary') == true ? const Color(0xFFF39C12) : const Color(0xFF16A085)),
      ),
    );

    // 3. Allowance Pill (e.g., 95% HCP)
    pills.add(
      BoxyArtStatusPill(
        text: rules.defaultAllowanceLabel,
        baseColor: iconColor,
      ),
    );

    // 4. Mode Pill (SINGLES, PAIRS, TEAM)
    pills.add(
      BoxyArtStatusPill(
        text: rules.modeLabel,
        baseColor: const Color(0xFF34495E),
      ),
    );

    // 5. Handicap Cap Pill (if applicable)
    if (rules.applyCapToIndex && 
        rules.handicapCap < 54 && 
        rules.format != CompetitionFormat.scramble && 
        rules.subtype != CompetitionSubtype.foursomes && 
        rules.subtype != CompetitionSubtype.fourball) {
      pills.add(
        BoxyArtStatusPill(
          text: 'CAPPED @ ${rules.handicapCap.toInt()} HCP',
          baseColor: const Color(0xFFD35400),
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
