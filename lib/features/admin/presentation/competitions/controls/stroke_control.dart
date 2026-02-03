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
  // Specific State
  bool _isNet = true; // Default to Net
  int _handicapCap = 28;
  int _roundsCount = 1;
  AggregationMethod _aggregation = AggregationMethod.totalSum;

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
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'MEDAL SETTINGS'),
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
               const SizedBox(height: 24),
              if (_isNet)
                BoxyArtFormField(
                  label: 'Handicap Cap',
                  initialValue: _handicapCap.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const BoxyArtSectionTitle(title: 'SERIES / MULTI-ROUND'),
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
            ],
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
    );
  }
}
