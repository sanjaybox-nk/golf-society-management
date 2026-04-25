import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'base_competition_control.dart';

class StrokePlayControl extends BaseCompetitionControl {
  const StrokePlayControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<StrokePlayControl> createState() => _StrokePlayControlState();
}

class _StrokePlayControlState extends BaseCompetitionControlState<StrokePlayControl> {
  bool _isNet = true;
  int _handicapCap = 28;
  double _handicapAllowance = 1.0;
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
      _handicapAllowance = widget.competition!.rules.handicapAllowance > 0
          ? widget.competition!.rules.handicapAllowance.clamp(0.0, 1.0)
          : 1.0;
      _handicapCap = widget.competition!.rules.handicapCap;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _applyCapToIndex = widget.competition!.rules.applyCapToIndex;
      _teamBestXCount = widget.competition!.rules.teamBestXCount;
      _useMixedTeeAdjustment = widget.competition!.rules.useMixedTeeAdjustment;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SCORING ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'SCORING'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              BoxyArtDropdownField<bool>(
                label: 'Scoring Type',
                value: _isNet,
                items: const [
                  DropdownMenuItem(value: true, child: Text('Net (Handicap Applied)')),
                  DropdownMenuItem(value: false, child: Text('Gross (Scratch)')),
                ],
                onChanged: (val) { if (val != null) setState(() => _isNet = val); },
              ),
              buildInfoBubble('Net deducts each player\'s playing handicap. Gross scores the raw stroke total.'),
            ],
          ),
        ),

        if (_isNet) ...[
          // ── HANDICAP ──────────────────────────────────────
          const BoxyArtSectionTitle(title: 'HANDICAP'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                buildAllowanceSlider(
                  _handicapAllowance,
                  (val) => setState(() => _handicapAllowance = val),
                  hint: "Fraction of each player's course handicap applied. 100% = full handicap.",
                ),
                const BoxyArtDivider(),
                buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
                buildInfoBubble('0 = no cap. 1–54 limits the playing handicap.'),
                const BoxyArtDivider(),
                BoxyArtSwitchField(
                  label: 'Hard Cap Playing HC',
                  subtitle: 'Off = Max Cap Index + WHS\nOn = HCP + WHS',
                  value: !_applyCapToIndex,
                  onChanged: (val) => setState(() => _applyCapToIndex = !val),
                ),
                const BoxyArtDivider(),
                BoxyArtSwitchField(
                  label: 'Mixed Tee Adjustments',
                  subtitle: 'Adds (Rating − Par) correction.',
                  value: _useMixedTeeAdjustment,
                  onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
                ),
              ],
            ),
          ),
        ],

        // ── SERIES / MULTI-ROUND ──────────────────────────────
        const BoxyArtSectionTitle(title: 'ROUNDS'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              buildSliderField(
                label: 'Number of Rounds',
                valueLabel: '$_roundsCount',
                value: _roundsCount.toDouble(),
                min: 1, max: 6, divisions: 5,
                onChanged: (val) => setState(() => _roundsCount = val.round()),
              ),
              if (_roundsCount > 1) ...[
                const BoxyArtDivider(),
                BoxyArtDropdownField<AggregationMethod>(
                  label: 'Series Scoring',
                  value: _aggregation,
                  items: const [
                    DropdownMenuItem(value: AggregationMethod.totalSum, child: Text('Cumulative (Total Score)')),
                    DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _aggregation = val); },
                ),
                buildInfoBubble('Cumulative adds all rounds. Best Round counts only the lowest.'),
              ],
            ],
          ),
        ),

        // ── TEAM SCORING ──────────────────────────────────────
        const BoxyArtSectionTitle(title: 'TEAM SCORING'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: BoxyArtDropdownField<int>(
            label: 'Best X Scores per Flight',
            value: _teamBestXCount,
            items: [1, 2, 3, 4].map((i) => DropdownMenuItem(value: i, child: Text('Best $i Scores'))).toList(),
            onChanged: (val) { if (val != null) setState(() => _teamBestXCount = val); },
          ),
        ),
        
        // ── OVERLAYS ──────────────────────────────────────────
        buildOverlaySection(),
      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.stroke,
      mode: CompetitionMode.singles,
      handicapAllowance: _isNet ? _handicapAllowance : 0.0,
      handicapCap: _handicapCap,
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      applyCapToIndex: _applyCapToIndex,
      teamBestXCount: _teamBestXCount,
      useMixedTeeAdjustment: _useMixedTeeAdjustment,
      hasMatchPlayOverlay: hasMatchPlayOverlay,
    );
  }
}
