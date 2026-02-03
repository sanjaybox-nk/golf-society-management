import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';

class MatchPlayControl extends BaseCompetitionControl {
  const MatchPlayControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<MatchPlayControl> createState() => _MatchPlayControlState();
}

class _MatchPlayControlState extends BaseCompetitionControlState<MatchPlayControl> {
  // Specific State
  CompetitionSubtype _subtype = CompetitionSubtype.none; // none = Singles
  double _allowance = 1.0;

  @override
  CompetitionFormat get format => CompetitionFormat.matchPlay;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _subtype = widget.competition!.rules.subtype;
      _allowance = widget.competition!.rules.handicapAllowance;
    } else {
      // Default allowances usually differ by type (Singles 100%, Fourball 90%)
      _updateDefaultAllowance();
    }
  }

  void _updateDefaultAllowance() {
    if (_subtype == CompetitionSubtype.fourball) {
      _allowance = 0.90;
    } else if (_subtype == CompetitionSubtype.foursomes) {
      _allowance = 0.50; // Combined?
    } else {
      _allowance = 1.0;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'MATCH FORMAT'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              BoxyArtDropdownField<CompetitionSubtype>(
                label: 'Format',
                value: _subtype,
                items: const [
                  DropdownMenuItem(value: CompetitionSubtype.none, child: Text('Singles Match Play')),
                  DropdownMenuItem(value: CompetitionSubtype.fourball, child: Text('Fourball (Better Ball)')),
                  DropdownMenuItem(value: CompetitionSubtype.foursomes, child: Text('Foursomes (Alternate Shot)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                       _subtype = val;
                       _updateDefaultAllowance();
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildAllowanceSlider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllowanceSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('HANDICAP ALLOWANCE', style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white70 : Colors.black87
            )),
            Text('${(_allowance * 100).toInt()}%', style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: Colors.orange
            )),
          ],
        ),
        Slider(
          value: _allowance,
          min: 0,
          max: 1.0,
          divisions: 20,
          label: '${(_allowance * 100).toInt()}%',
          onChanged: (val) => setState(() => _allowance = val),
          activeColor: Colors.orange,
          thumbColor: Colors.orange,
        ),
        const Text(
          "Applied to handicap difference", 
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    // Mode depends on subtype
    CompetitionMode mode = CompetitionMode.singles;
    if (_subtype == CompetitionSubtype.fourball || _subtype == CompetitionSubtype.foursomes) {
      mode = CompetitionMode.pairs;
    }

    return CompetitionRules(
      format: CompetitionFormat.matchPlay,
      subtype: _subtype,
      mode: mode,
      handicapAllowance: _allowance,
      holeByHoleRequired: true, // Needed for match play scoring
      tieBreak: TieBreakMethod.playoff, // Usually playoff for matches
    );
  }
}
