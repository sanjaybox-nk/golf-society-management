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
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              buildAllowanceSlider(
                _allowance,
                (val) => setState(() => _allowance = val),
                disabled: _isGross,
                hint: "Fraction of course handicap applied (95% is WHS default).",
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
                subtitle: 'Adds (CR − Par) correction to equalize scores when players use different tees (e.g. Mixed/Seniors).',
                value: _useMixedTeeAdjustment,
                onChanged: (val) => setState(() => _useMixedTeeAdjustment = val),
              ),
              const BoxyArtDivider(),
              BoxyArtSwitchField(
                label: 'Gross Scoring',
                subtitle: 'Handicap is ignored; points vs par only.',
                value: _isGross,
                onChanged: (val) => setState(() => _isGross = val),
              ),
            ],
          ),
        ),

        // ── TIE BREAK ─────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'TIE BREAK'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              BoxyArtDropdownField<TieBreakMethod>(
                label: 'Tie Break Method',
                value: _tieBreak,
                items: const [
                  DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
                  DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Playoff (Manual Result)')),
                ],
                onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
              ),
              buildInfoBubble('Standard compares last holes in reverse. Playoff is sudden-death.'),
            ],
          ),
        ),

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
                    DropdownMenuItem(value: AggregationMethod.stablefordSum, child: Text('Cumulative Points')),
                    DropdownMenuItem(value: AggregationMethod.singleBest, child: Text('Best Round Counts')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _aggregation = val); },
                ),
                buildInfoBubble('Cumulative adds all rounds. Best Round counts only the highest.'),
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
      hasMatchPlayOverlay: hasMatchPlayOverlay,
    );
  }
}
