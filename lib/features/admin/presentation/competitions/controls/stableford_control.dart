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

  @override
  CompetitionFormat get format => CompetitionFormat.stableford;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _allowance = widget.competition!.rules.handicapAllowance;
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _isGross = widget.competition!.rules.subtype == CompetitionSubtype.grossStableford;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'SCORING RULES'),
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
              _buildAllowanceSlider(),
              const SizedBox(height: 24),
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
                  DropdownMenuItem(
                    value: TieBreakMethod.back9, 
                    child: Text('Standard (Back 9-6-3-1)'),
                  ),
                  DropdownMenuItem(
                    value: TieBreakMethod.playoff, 
                    child: Text('Playoff'),
                  ),
                ],
                onChanged: (val) {
                   if (val != null) setState(() => _tieBreak = val);
                },
              ),
              if (_tieBreak == TieBreakMethod.back9)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Cascade: Last 9 → Last 6 → Last 3 → Last 1",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else if (_tieBreak == TieBreakMethod.playoff)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sudden death or specified holes (Manual Result)",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              BoxyArtSwitchField(
                label: 'Gross Scoring\n(Points against Par)',
                value: _isGross,
                onChanged: (val) {
                  setState(() {
                    _isGross = val;
                    // Reset allowance logic:
                    // Gross ON -> 0% (scratch)
                    // Gross OFF -> 100% (full handicap) as per user request
                    _allowance = _isGross ? 0.0 : 1.0; 
                  });
                },
              ),
              if (_isGross)
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8, left: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Points awarded based on unadjusted gross score.",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              // Series / Multi-Round UI
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
                    DropdownMenuItem(value: AggregationMethod.stablefordSum, child: Text('Cumulative Points')),
                    DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _aggregation = val);
                  },
                ),
              ],
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
        AbsorbPointer(
          absorbing: _isGross,
          child: Opacity(
            opacity: _isGross ? 0.5 : 1.0,
            child: Slider(
              value: _allowance,
              min: 0,
              max: 1.0,
              divisions: 20,
              label: '${(_allowance * 100).toInt()}%',
              onChanged: (val) => setState(() => _allowance = val),
              activeColor: Colors.orange,
              thumbColor: Colors.orange,
            ),
          ),
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
    );
  }
}
