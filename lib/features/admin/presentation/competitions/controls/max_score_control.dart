import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';

class MaxScoreControl extends BaseCompetitionControl {
  const MaxScoreControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<MaxScoreControl> createState() => _MaxScoreControlState();
}

class _MaxScoreControlState extends BaseCompetitionControlState<MaxScoreControl> {
  // Specific State
  MaxScoreType _type = MaxScoreType.parPlusX;
  int _value = 3; // Default Par + 3 (Triple Bogey)
  double _allowance = 1.0; // Usually full handicap

  @override
  CompetitionFormat get format => CompetitionFormat.maxScore;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      final config = widget.competition!.rules.maxScoreConfig;
      if (config != null) {
        _type = config.type;
        _value = config.value;
      }
      _allowance = widget.competition!.rules.handicapAllowance;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'SCORE CAP SETTINGS'),
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
              BoxyArtDropdownField<MaxScoreType>(
                label: 'Max Score Type',
                value: _type,
                items: const [
                  DropdownMenuItem(value: MaxScoreType.parPlusX, child: Text('Relative to Par (e.g. Par + 3)')),
                  DropdownMenuItem(value: MaxScoreType.fixed, child: Text('Fixed Value (e.g. 10)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                       _type = val;
                       // Set sensible defaults when switching
                       if (_type == MaxScoreType.fixed) _value = 10;
                       if (_type == MaxScoreType.parPlusX) _value = 3; 
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              BoxyArtFormField(
                label: _type == MaxScoreType.parPlusX ? 'Strokes Over Par (X)' : 'Max Score Value',
                initialValue: _value.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() => _value = int.tryParse(val) ?? (_type == MaxScoreType.parPlusX ? 3 : 10)),
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
      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.maxScore,
      mode: CompetitionMode.singles,
      handicapAllowance: _allowance,
      maxScoreConfig: MaxScoreConfig(type: _type, value: _value),
      holeByHoleRequired: true,
    );
  }
}
