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
        // ── SCORE CAP SETTINGS ────────────────────────────────
        const BoxyArtSectionTitle(title: 'SCORE CAP SETTINGS'),
        const SizedBox(height: 16),

        BoxyArtDropdownField<MaxScoreType>(
          label: 'Max Score Type',
          value: _type,
          items: const [
            DropdownMenuItem(value: MaxScoreType.parPlusX, child: Text('Relative to Par')),
            DropdownMenuItem(value: MaxScoreType.netDoubleBogey, child: Text('Net Double Bogey (WHS Standard)')),
            DropdownMenuItem(value: MaxScoreType.fixed, child: Text('Fixed Score')),
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
        buildInfoBubble(_getMaxScoreTypeDescription(_type)),

        if (_type != MaxScoreType.netDoubleBogey) ...[
          const SizedBox(height: 24),
          buildSliderField(
            label: _type == MaxScoreType.parPlusX ? 'Maximum Strokes Over Par' : 'Fixed Score Cap',
            valueLabel: '$_value',
            value: _value.toDouble(),
            min: 1,
            max: _type == MaxScoreType.fixed ? 15 : 6,
            divisions: _type == MaxScoreType.fixed ? 14 : 5,
            onChanged: (val) => setState(() => _value = val.round()),
          ),
        ],

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        const SizedBox(height: 16),

        buildAllowanceSlider(
          _allowance,
          (val) => setState(() => _allowance = val),
          hint: "Fraction of each player's course handicap applied to the score.",
        ),
        const SizedBox(height: 24),

        buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
        buildInfoBubble('0 = no cap applied. 1–54 limits each player\'s playing handicap to that maximum value.'),
        const SizedBox(height: 24),

        BoxyArtSwitchField(
          label: 'Hard Cap Playing HC\nOff = Max Cap Index + WHS ·\nOn = HC + WHS',
          value: !_applyCapToIndex,
          onChanged: (val) => setState(() => _applyCapToIndex = !val),
        ),
        buildInfoBubble(_applyCapToIndex
            ? 'Cap applies to the baseline index. WHS course adjustments may push the playing HC above it.'
            : 'Cap is applied to the final playing HC — a player will never exceed $_handicapCap.'),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── TIE BREAK ─────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'TIE BREAK'),
        const SizedBox(height: 16),

        BoxyArtDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          items: const [
            DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
            DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Playoff (Manual Result)')),
          ],
          onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
        ),
        buildInfoBubble('Back 9 compares the last 9 holes in reverse order. Playoff is a sudden-death hole-off decided manually.'),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── SERIES / MULTI-ROUND ──────────────────────────────
        const BoxyArtSectionTitle(title: 'SERIES / MULTI-ROUND'),
        const SizedBox(height: 16),

        buildSliderField(
          label: 'Number of Rounds',
          valueLabel: '$_roundsCount',
          value: _roundsCount.toDouble(),
          min: 1, max: 6, divisions: 5,
          onChanged: (val) => setState(() => _roundsCount = val.round()),
        ),
        buildInfoBubble('Leave at 1 for single events. Increase for season-long or multi-round series.'),
        if (_roundsCount > 1) ...[
          const SizedBox(height: 24),
          BoxyArtDropdownField<AggregationMethod>(
            label: 'Series Scoring',
            value: _aggregation,
            items: const [
              DropdownMenuItem(value: AggregationMethod.totalSum, child: Text('Cumulative Score')),
              DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
            ],
            onChanged: (val) { if (val != null) setState(() => _aggregation = val); },
          ),
          buildInfoBubble('Cumulative adds all round scores. Best Round only counts a player\'s lowest gross round.'),
        ],

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── TEAM / GROUP SCORING ──────────────────────────────
        const BoxyArtSectionTitle(title: 'TEAM / GROUP SCORING'),
        const SizedBox(height: 16),

        BoxyArtDropdownField<int>(
          label: 'Best X Scores per Flight',
          value: _teamBestXCount,
          items: [1, 2, 3, 4].map((i) => DropdownMenuItem(value: i, child: Text('Best $i Scores'))).toList(),
          onChanged: (val) { if (val != null) setState(() => _teamBestXCount = val); },
        ),
        buildInfoBubble('How many individual scores count towards the group total in the flight view.'),
      ],
    );
  }

  String _getMaxScoreTypeDescription(MaxScoreType type) {
    switch (type) {
      case MaxScoreType.parPlusX:
        return 'Scores are capped at a specific number of strokes over par (e.g. Par + 2 = double bogey cap).';
      case MaxScoreType.netDoubleBogey:
        return 'The standard tournament cap: Par + 2 + Handicap Strokes received on that hole.';
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
