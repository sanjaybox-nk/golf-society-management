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
  HandicapMode _handicapMode = HandicapMode.whs;

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
      _handicapMode = widget.competition!.rules.handicapMode;
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
                hint: "WHS standard: 95% for singles Stableford, 85% for Betterball, 50% for Foursomes.",
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
              BoxyArtDropdownField<HandicapMode>(
                label: 'Handicap System',
                value: _handicapMode,
                items: const [
                  DropdownMenuItem(value: HandicapMode.whs, child: Text('WHS (Slope & Rating Adjusted)')),
                  DropdownMenuItem(value: HandicapMode.local, child: Text('Local (Handicap Index Only)')),
                ],
                onChanged: (val) { if (val != null) setState(() => _handicapMode = val); },
              ),
              buildInfoBubble('WHS applies slope and course rating to calculate playing handicap. Local uses the raw index with no course correction.'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Tie Break Method', 'Standard (Back 9-6-3-1)'),
              buildInfoBubble('Stableford always uses countback — back 9, back 6, back 3, then back 1.'),
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

        buildTeamSection(),

      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.stableford,
      subtype: _isGross ? CompetitionSubtype.grossStableford : CompetitionSubtype.none,
      mode: isTeams ? CompetitionMode.teams : CompetitionMode.singles,
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: _tieBreak,
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      applyCapToIndex: _applyCapToIndex,
      teamBestXCount: _teamBestXCount,
      useMixedTeeAdjustment: _useMixedTeeAdjustment,
      handicapMode: _isGross ? HandicapMode.none : _handicapMode,
      teamAName: isTeams ? teamAName : null,
      teamBName: isTeams ? teamBName : null,
    );
  }
}
