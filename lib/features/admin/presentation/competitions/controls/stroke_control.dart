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
  bool? _separateGuests;

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
      _separateGuests = widget.competition!.rules.separateGuests;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── MEDAL SETTINGS ───────────────────────────────────
        const BoxyArtSectionTitle(title: 'MEDAL SETTINGS'),
        const SizedBox(height: AppSpacing.lg),

        BoxyArtDropdownField<bool>(
          label: 'Scoring Type',
          value: _isNet,
          items: const [
            DropdownMenuItem(value: true, child: Text('Net (Handicap Applied)')),
            DropdownMenuItem(value: false, child: Text('Gross (Scratch)')),
          ],
          onChanged: (val) { if (val != null) setState(() => _isNet = val); },
        ),
        buildInfoBubble('Net deducts each player\'s playing handicap from their gross score. Gross scores the raw stroke total with no adjustments.'),

        if (_isNet) ...[
          const SizedBox(height: AppSpacing.x2l),

          // ── HANDICAP ──────────────────────────────────────
          const BoxyArtSectionTitle(title: 'HANDICAP'),
          const SizedBox(height: AppSpacing.lg),

          buildAllowanceSlider(
            _handicapAllowance,
            (val) => setState(() => _handicapAllowance = val),
            hint: "Fraction of each player's course handicap applied. 100% = full handicap.",
          ),
          const SizedBox(height: AppSpacing.x2l),

          buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
          buildInfoBubble('0 = no cap applied. 1–54 limits each player\'s playing handicap to that maximum value.'),
          const SizedBox(height: AppSpacing.x2l),

          BoxyArtSwitchField(
            label: 'Hard Cap Playing HC',
            subtitle: 'Off = Max Cap Index + WHS\nOn = HCP + WHS',
            value: !_applyCapToIndex,
            onChanged: (val) => setState(() => _applyCapToIndex = !val),
          ),
          buildInfoBubble(_applyCapToIndex
              ? 'Cap applies to the baseline index. WHS course adjustments may push the playing HC above it.'
              : 'Cap is applied to the final playing HC — a player will never exceed $_handicapCap.'),
          const SizedBox(height: AppSpacing.x2l),

          BoxyArtSwitchField(
            label: 'Mixed Tee Adjustments',
            subtitle: 'Adds (Rating − Par) correction for mixed-gender events.',
            value: _useMixedTeeAdjustment,
            onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
          ),
        ],

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── SERIES / MULTI-ROUND ──────────────────────────────
        const BoxyArtSectionTitle(title: 'SERIES / MULTI-ROUND'),
        const SizedBox(height: AppSpacing.lg),

        buildSliderField(
          label: 'Number of Rounds',
          valueLabel: '$_roundsCount',
          value: _roundsCount.toDouble(),
          min: 1, max: 6, divisions: 5,
          onChanged: (val) => setState(() => _roundsCount = val.round()),
        ),
        buildInfoBubble('Leave at 1 for single events. Increase for season-long or multi-round series.'),
        if (_roundsCount > 1) ...[
          const SizedBox(height: AppSpacing.x2l),
          BoxyArtDropdownField<AggregationMethod>(
            label: 'Series Scoring',
            value: _aggregation,
            items: const [
              DropdownMenuItem(value: AggregationMethod.totalSum, child: Text('Cumulative (Total Score)')),
              DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
            ],
            onChanged: (val) { if (val != null) setState(() => _aggregation = val); },
          ),
          buildInfoBubble('Cumulative adds all round scores together. Best Round only counts a player\'s lowest round.'),
        ],

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── TEAM / GROUP SCORING ──────────────────────────────
        const BoxyArtSectionTitle(title: 'TEAM / GROUP SCORING'),
        const SizedBox(height: AppSpacing.lg),

        BoxyArtDropdownField<int>(
          label: 'Best X Scores per Flight',
          value: _teamBestXCount,
          items: [1, 2, 3, 4].map((i) => DropdownMenuItem(value: i, child: Text('Best $i Scores'))).toList(),
          onChanged: (val) { if (val != null) setState(() => _teamBestXCount = val); },
        ),
        buildInfoBubble('How many individual scores count towards the group total displayed in the flight view.'),

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── GUEST SETTINGS ────────────────────────────────────
        buildGuestSettings(
          separateGuests: _separateGuests,
          onSeparateChanged: (val) => setState(() => _separateGuests = val),
        ),
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
      separateGuests: _separateGuests,
    );
  }
}
