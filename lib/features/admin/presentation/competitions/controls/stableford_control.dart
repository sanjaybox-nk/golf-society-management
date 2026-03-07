import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'base_competition_control.dart';

class StablefordControl extends BaseCompetitionControl {
  const StablefordControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<StablefordControl> createState() => _StablefordControlState();
}

class _StablefordControlState extends BaseCompetitionControlState<StablefordControl> {
  double _allowance = 0.95;
  int _handicapCap = 28;
  TieBreakMethod _tieBreak = TieBreakMethod.back9;
  int _roundsCount = 1;
  AggregationMethod _aggregation = AggregationMethod.stablefordSum;
  bool _useMixedTeeAdjustment = false;
  bool? _separateGuests;
  bool _isGross = false;
  bool _applyCapToIndex = false;
  int _teamBestXCount = 1;

  @override
  CompetitionFormat get format => CompetitionFormat.stableford;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      name = widget.competition!.name ?? '';
      _allowance = widget.competition!.rules.handicapAllowance;
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      _aggregation = widget.competition!.rules.aggregation;
      _isGross = widget.competition!.rules.subtype == CompetitionSubtype.grossStableford;
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
        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        const SizedBox(height: AppSpacing.lg),

        buildAllowanceSlider(
          _allowance,
          (val) => setState(() => _allowance = val),
          disabled: _isGross,
          hint: "Fraction of each player's course handicap applied. 95% is the WHS default for Stableford.",
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
            ? 'Cap applies to the baseline handicap index. WHS adjustments may push the playing HC above the cap.'
            : 'Cap is applied to the final playing HC — a player will never exceed $_handicapCap strokes.'),
        const SizedBox(height: AppSpacing.x2l),

        BoxyArtSwitchField(
          label: 'Mixed Tee Adjustments',
          subtitle: 'Adds (Rating − Par) correction for mixed-gender events.',
          value: _useMixedTeeAdjustment,
          onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
        ),
        const SizedBox(height: AppSpacing.x2l),

        BoxyArtSwitchField(
          label: 'Gross Scoring',
          subtitle: 'Handicap is ignored; points awarded against par only.',
          value: _isGross,
          onChanged: (val) => setState(() => _isGross = val),
        ),

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── TIEBREAK ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'TIE BREAK'),
        const SizedBox(height: AppSpacing.lg),

        BoxyArtDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          items: const [
            DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
            DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Playoff (Manual Result)')),
          ],
          onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
        ),
        buildInfoBubble('How tied scores are resolved. Back 9 compares the last 9 holes in reverse. Playoff is a sudden-death hole-off.'),

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
        buildInfoBubble('For single events leave at 1. Increase for season-long or multi-round series.'),
        if (_roundsCount > 1) ...[
          const SizedBox(height: AppSpacing.x2l),
          BoxyArtDropdownField<AggregationMethod>(
            label: 'Series Scoring',
            value: _aggregation,
            items: const [
              DropdownMenuItem(value: AggregationMethod.stablefordSum, child: Text('Cumulative Points')),
              DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
            ],
            onChanged: (val) { if (val != null) setState(() => _aggregation = val); },
          ),
          buildInfoBubble('Cumulative adds all round scores. Best Round only counts a player\'s highest round.'),
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
        buildInfoBubble('Determines how many individual scores are combined for the group total shown in the flight view.'),

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
      format: CompetitionFormat.stableford,
      subtype: _isGross ? CompetitionSubtype.grossStableford : CompetitionSubtype.none,
      mode: CompetitionMode.singles,
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: _tieBreak,
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
