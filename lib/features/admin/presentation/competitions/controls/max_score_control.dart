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
  MaxScoreType _type = MaxScoreType.parPlusX;
  int _value = 3;
  double _allowance = 1.0;
  int _handicapCap = 28;
  TieBreakMethod _tieBreak = TieBreakMethod.back9;
  int _roundsCount = 1;
  AggregationMethod _aggregation = AggregationMethod.totalSum;
  bool _applyCapToIndex = true;
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
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _applyCapToIndex = widget.competition!.rules.applyCapToIndex;
      _teamBestXCount = widget.competition!.rules.teamBestXCount;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'SCORE CAP SETTINGS'),
        const SizedBox(height: 16),
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
                if (_type == MaxScoreType.fixed) _value = 10;
                if (_type == MaxScoreType.parPlusX) _value = 2;
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
        _buildAllowanceSlider(context),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'ADDITIONAL SETTINGS'),
        const SizedBox(height: 16),
        BoxyArtFormField(
          label: 'Handicap Cap',
          initialValue: _handicapCap.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
        ),
        const SizedBox(height: 24),
        BoxyArtDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          items: const [
            DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
            DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Playoff (Manual Result)')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _tieBreak = val);
          },
        ),
        const SizedBox(height: 24),
        ModernSwitchRow(
          label: 'Hard Cap Playing HC',
          subtitle: _applyCapToIndex
              ? 'Cap applies to baseline Index.'
              : 'Cap applies to final Playing HC.',
          value: !_applyCapToIndex,
          icon: Icons.lock_outline_rounded,
          onChanged: (val) => setState(() => _applyCapToIndex = !val),
        ),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Rounds (Series)',
          initialValue: _roundsCount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => _roundsCount = int.tryParse(val) ?? 1),
        ),
        if (_roundsCount > 1) ...[
          const SizedBox(height: 24),
          BoxyArtDropdownField<AggregationMethod>(
            label: 'Series Scoring',
            value: _aggregation,
            items: const [
              DropdownMenuItem(value: AggregationMethod.totalSum, child: Text('Cumulative Score')),
              DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _aggregation = val);
            },
          ),
        ],

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'TEAM / GROUP SCORING'),
        const SizedBox(height: 16),
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

      ],
    );
  }

  Widget _buildAllowanceSlider(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (_allowance * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HANDICAP ALLOWANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pct%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primary,
            inactiveTrackColor: primary.withValues(alpha: 0.15),
            thumbColor: primary,
            overlayColor: primary.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            valueIndicatorColor: primary,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          child: Slider(
            value: _allowance.clamp(0.0, 1.0),
            min: 0,
            max: 1.0,
            divisions: 20,
            label: '$pct%',
            onChanged: (val) => setState(() => _allowance = val),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
            Text('Applied to each player\'s course handicap', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text('100%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
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
      handicapCap: _handicapCap,
      tieBreak: _tieBreak,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      applyCapToIndex: _applyCapToIndex,
      maxScoreConfig: MaxScoreConfig(type: _type, value: _value),
      holeByHoleRequired: true,
      teamBestXCount: _teamBestXCount,
    );
  }
}
