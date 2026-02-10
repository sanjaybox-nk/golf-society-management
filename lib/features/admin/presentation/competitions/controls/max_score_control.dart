import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/competitions/utils/competition_rule_translator.dart';
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
  int _teamBestXCount = 2;

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
      _teamBestXCount = widget.competition!.rules.teamBestXCount;
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
                  DropdownMenuItem(value: MaxScoreType.parPlusX, child: Text('Relative to Par (e.g. Par + 2)')),
                  DropdownMenuItem(value: MaxScoreType.netDoubleBogey, child: Text('Net Double Bogey (Par + 2 + HCP Strokes)')),
                  DropdownMenuItem(value: MaxScoreType.fixed, child: Text('Fixed Value (e.g. 10)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                       _type = val;
                       // Set sensible defaults when switching
                       if (_type == MaxScoreType.fixed) _value = 10;
                       if (_type == MaxScoreType.parPlusX) _value = 2; // Default to Par + 2 for standard Max Score
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _getMaxScoreTypeDescription(_type),
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
              if (_type != MaxScoreType.netDoubleBogey) ...[
                const SizedBox(height: 24),
                BoxyArtFormField(
                  label: _type == MaxScoreType.parPlusX ? 'Strokes Over Par (X)' : 'Max Score Value',
                  initialValue: _value.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _value = int.tryParse(val) ?? (_type == MaxScoreType.parPlusX ? 2 : 10)),
                ),
              ],
               const SizedBox(height: 24),
               _buildAllowanceSlider(),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'TEAM / GROUP SCORING'),
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
              BoxyArtDropdownField<int>(
                label: 'Best X Scores per Flight',
                value: _teamBestXCount,
                items: [1, 2, 3, 4].map((i) => DropdownMenuItem(
                  value: i,
                  child: Text('Best $i Scores'),
                )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _teamBestXCount = val);
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Decides how the Group Total is calculated in the flight view.',
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildMemberPreview(),
      ],
    );
  }

  Widget _buildMemberPreview() {
    final rules = buildRules();
    final description = CompetitionRuleTranslator.translate(rules);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'MEMBER PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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

  String _getMaxScoreTypeDescription(MaxScoreType type) {
    switch (type) {
      case MaxScoreType.parPlusX:
        return 'Scores are capped at a specific number of strokes over par (e.g. Par + 2).';
      case MaxScoreType.netDoubleBogey:
        return 'The standard tournament cap. Your score is capped at Net Double Bogey (Par + 2 + Handicap Strokes).';
      case MaxScoreType.fixed:
        return 'Every hole is capped at a single fixed value (e.g. 10), regardless of par or handicap.';
    }
  }

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.maxScore,
      mode: CompetitionMode.singles,
      handicapAllowance: _allowance,
      maxScoreConfig: MaxScoreConfig(type: _type, value: _value),
      holeByHoleRequired: true,
      teamBestXCount: _teamBestXCount,
    );
  }
}
