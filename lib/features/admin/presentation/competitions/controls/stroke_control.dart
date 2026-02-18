import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';

class StrokePlayControl extends BaseCompetitionControl {
  const StrokePlayControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<StrokePlayControl> createState() => _StrokePlayControlState();
}

class _StrokePlayControlState extends BaseCompetitionControlState<StrokePlayControl> {
  bool _isNet = true;
  int _handicapCap = 28;
  int _roundsCount = 1;
  AggregationMethod _aggregation = AggregationMethod.totalSum;
  bool _applyCapToIndex = true;
  int _teamBestXCount = 2;
  bool _useMixedTeeAdjustment = false;

  @override
  CompetitionFormat get format => CompetitionFormat.stroke;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _isNet = widget.competition!.rules.handicapAllowance > 0;
      _handicapCap = widget.competition!.rules.handicapCap;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _applyCapToIndex = widget.competition!.rules.applyCapToIndex;
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
        const BoxyArtSectionTitle(title: 'MEDAL SETTINGS'),
        const SizedBox(height: 16),
        BoxyArtDropdownField<bool>(
          label: 'Scoring Type',
          value: _isNet,
          items: const [
            DropdownMenuItem(value: true, child: Text('Net (Handicap Applied)')),
            DropdownMenuItem(value: false, child: Text('Gross (Scratch)')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _isNet = val);
          },
        ),
        if (_isNet) ...[
          const SizedBox(height: 24),
          BoxyArtFormField(
            label: 'Handicap Cap',
            initialValue: _handicapCap.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
          ),
          const SizedBox(height: 24),
          BoxyArtSwitchField(
            label: 'Hard Cap Playing HC\n(Off = Cap Index + WHS)',
            value: !_applyCapToIndex,
            onChanged: (val) => setState(() => _applyCapToIndex = !val),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _applyCapToIndex
                  ? 'Cap applies to baseline Index. WHS adjustments can exceed the cap.'
                  : 'Cap applies to final Playing HC. Player will never exceed $_handicapCap.',
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 24),
          ModernSwitchRow(
            label: 'Mixed Tee Adjustments',
            subtitle: 'Apply (Rating - Par) to Playing Handicap',
            value: _useMixedTeeAdjustment,
            icon: Icons.tune_rounded,
            onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
          ),
        ],

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'SERIES / MULTI-ROUND'),
        const SizedBox(height: 16),
        BoxyArtFormField(
          label: 'Number of Rounds',
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
              DropdownMenuItem(value: AggregationMethod.totalSum, child: Text('Cumulative (Total Score)')),
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
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Decides how the Group Total is calculated in the flight view.',
            style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.stroke,
      mode: CompetitionMode.singles,
      handicapAllowance: _isNet ? 1.0 : 0.0,
      handicapCap: _handicapCap,
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      applyCapToIndex: _applyCapToIndex,
      teamBestXCount: _teamBestXCount,
      useMixedTeeAdjustment: _useMixedTeeAdjustment,
    );
  }
}
