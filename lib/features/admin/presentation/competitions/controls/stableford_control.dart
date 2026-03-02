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
  bool _isGross = false;
  bool _applyCapToIndex = true;
  int _teamBestXCount = 2;
  bool _useMixedTeeAdjustment = false;
  bool _includeGuests = true;
  bool? _separateGuests;

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
      _includeGuests = widget.competition!.rules.includeGuests;
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
        const SizedBox(height: 16),

        buildAllowanceSlider(
          _allowance,
          (val) => setState(() => _allowance = val),
          disabled: _isGross,
          hint: "Fraction of each player's course handicap applied. 95% is the WHS default for Stableford.",
        ),
        const SizedBox(height: 24),

        buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
        buildInfoBubble('0 = no cap applied. 1–54 limits each player\'s playing handicap to that maximum value.'),
        const SizedBox(height: 24),

        BoxyArtSwitchField(
          label: 'Hard Cap Playing HC',
          subtitle: 'Off = Max Cap Index + WHS\nOn = HCP + WHS',
          value: !_applyCapToIndex,
          onChanged: (val) => setState(() => _applyCapToIndex = !val),
        ),
        buildInfoBubble(_applyCapToIndex
            ? 'Cap applies to the baseline handicap index. WHS adjustments may push the playing HC above the cap.'
            : 'Cap is applied to the final playing HC — a player will never exceed $_handicapCap strokes.'),
        const SizedBox(height: 24),

        BoxyArtSwitchField(
          label: 'Mixed Tee Adjustments',
          subtitle: 'Adds (Rating − Par) correction for mixed-gender events.',
          value: _useMixedTeeAdjustment,
          onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
        ),
        const SizedBox(height: 24),

        BoxyArtSwitchField(
          label: 'Gross Scoring',
          subtitle: 'Handicap is ignored; points awarded against par only.',
          value: _isGross,
          onChanged: (val) => setState(() => _isGross = val),
        ),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── TIEBREAK ──────────────────────────────────────────
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
        buildInfoBubble('How tied scores are resolved. Back 9 compares the last 9 holes in reverse. Playoff is a sudden-death hole-off.'),

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
        buildInfoBubble('For single events leave at 1. Increase for season-long or multi-round series.'),
        if (_roundsCount > 1) ...[
          const SizedBox(height: 24),
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
        buildInfoBubble('Determines how many individual scores are combined for the group total shown in the flight view.'),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── GUEST SETTINGS ────────────────────────────────────
        buildGuestSettings(
          includeGuests: _includeGuests,
          separateGuests: _separateGuests,
          onIncludeChanged: (val) => setState(() => _includeGuests = val),
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
      includeGuests: _includeGuests,
      separateGuests: _separateGuests,
    );
  }
}
