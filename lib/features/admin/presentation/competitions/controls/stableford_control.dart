import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';

class StablefordControl extends BaseCompetitionControl {
  const StablefordControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<StablefordControl> createState() => _StablefordControlState();
}

class _StablefordControlState extends BaseCompetitionControlState<StablefordControl> {
  // Specific State
  double _allowance = 0.95;
  int _handicapCap = 28;
  TieBreakMethod _tieBreak = TieBreakMethod.back9;
  int _roundsCount = 1;
  AggregationMethod _aggregation = AggregationMethod.stablefordSum; 
  bool _isGross = false;
  bool _applyCapToIndex = true;
  int _teamBestXCount = 2;
  bool _useMixedTeeAdjustment = false;

  @override
  CompetitionFormat get format => CompetitionFormat.stableford;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      name = widget.competition!.name ?? ''; // Initialize name
      _allowance = widget.competition!.rules.handicapAllowance;
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _isGross = widget.competition!.rules.subtype == CompetitionSubtype.grossStableford;
      _applyCapToIndex = widget.competition!.rules.applyCapToIndex;
      _teamBestXCount = widget.competition!.rules.teamBestXCount;
      _useMixedTeeAdjustment = widget.competition!.rules.useMixedTeeAdjustment;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAllowanceSlider(),
        const SizedBox(height: 24),
        ModernTextField(
          label: 'Handicap Cap',
          initialValue: _handicapCap.toString(),
          keyboardType: TextInputType.number,
          icon: Icons.vertical_align_top_rounded,
          onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
        ),
        const SizedBox(height: 24),
        ModernDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          icon: Icons.low_priority_rounded,
          items: const [
            DropdownMenuItem(
              value: TieBreakMethod.back9, 
              child: Text('Standard (Back 9-6-3-1)'),
            ),
            DropdownMenuItem(
              value: TieBreakMethod.playoff, 
              child: Text('Playoff (Manual Result)'),
            ),
          ],
          onChanged: (val) {
             if (val != null) setState(() => _tieBreak = val);
          },
        ),
        const SizedBox(height: 24),
        ModernSwitchRow(
          label: 'Hard Cap Playing HC',
          subtitle: _applyCapToIndex 
              ? "Cap applies to baseline Index." 
              : "Cap applies to final Playing HC.",
          value: !_applyCapToIndex,
          icon: Icons.lock_outline_rounded,
          onChanged: (val) => setState(() => _applyCapToIndex = !val),
        ),
        const SizedBox(height: 12),
        ModernSwitchRow(
          label: 'Mixed Tee Adjustments',
          subtitle: 'Apply (Rating - Par) to Playing Handicap',
          value: _useMixedTeeAdjustment,
          icon: Icons.tune_rounded,
          onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
        ),
        const SizedBox(height: 12),
        ModernSwitchRow(
          label: 'Gross Scoring',
          subtitle: 'Points awarded against Par',
          value: _isGross,
          icon: Icons.score_rounded,
          onChanged: (val) => setState(() => _isGross = val),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        ModernTextField(
          label: 'Rounds (Series)',
          initialValue: _roundsCount.toString(),
          keyboardType: TextInputType.number,
          icon: Icons.layers_rounded,
          onChanged: (val) => setState(() => _roundsCount = int.tryParse(val) ?? 1),
        ),
        if (_roundsCount > 1) ...[
          const SizedBox(height: 24),
          ModernDropdownField<AggregationMethod>(
            label: 'Series Scoring',
            value: _aggregation,
            icon: Icons.functions_rounded,
            items: const [
              DropdownMenuItem(value: AggregationMethod.stablefordSum, child: Text('Cumulative Points')),
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
        ModernDropdownField<int>(
          label: 'Best X Scores per Flight',
          value: _teamBestXCount,
          icon: Icons.groups_rounded,
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


  Widget _buildAllowanceSlider() {
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
              'Handicap Allowance'.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
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
        AbsorbPointer(
          absorbing: _isGross,
          child: Opacity(
            opacity: _isGross ? 0.5 : 1.0,
            child: SliderTheme(
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
                value: _allowance,
                min: 0,
                max: 1.0,
                divisions: 20,
                label: '$pct%',
                onChanged: (val) => setState(() => _allowance = val),
              ),
            ),
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

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.stableford,
      subtype: _isGross ? CompetitionSubtype.grossStableford : CompetitionSubtype.none,
      mode: CompetitionMode.singles, // Default for simple stableford
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: _tieBreak, 
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      applyCapToIndex: _applyCapToIndex,
      teamBestXCount: _teamBestXCount,
      useMixedTeeAdjustment: _useMixedTeeAdjustment,
    );
  }
}
