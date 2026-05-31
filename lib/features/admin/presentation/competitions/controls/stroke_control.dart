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
  TieBreakMethod _tieBreak = TieBreakMethod.back9;
  PickUpBehaviour _pickUpBehaviour = PickUpBehaviour.maxScore;
  MaxScoreType _maxScoreType = MaxScoreType.netDoubleBogey;
  int _maxScoreValue = 2;
  HandicapMode _handicapMode = HandicapMode.whs;

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
      _tieBreak = widget.competition!.rules.tieBreak;
      _handicapMode = widget.competition!.rules.handicapMode;
      _pickUpBehaviour = widget.competition!.rules.pickUpBehaviour;
      _maxScoreType = widget.competition!.rules.maxScoreConfig?.type ?? MaxScoreType.netDoubleBogey;
      _maxScoreValue = widget.competition!.rules.maxScoreConfig?.value ?? 2;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    
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
                  hint: "WHS standard: 100% for singles stroke play. Adjust for special formats (e.g. 85% Betterball, 50% Foursomes).",
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
              ],
            ),
          ),
        ],

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
              buildInfoBubble('Countback: fewest net strokes over the back 9 (B9→B6→B3→B1, then F9→F1) separates ties. Playoff requires a manual result.'),
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

        buildTeamSection(),

        // ── PICK UP RULE ──────────────────────────────────────
        const BoxyArtSectionTitle(title: 'PICK UP RULE'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              BoxyArtDropdownField<PickUpBehaviour>(
                label: 'When a player picks up',
                value: _pickUpBehaviour,
                items: const [
                  DropdownMenuItem(value: PickUpBehaviour.maxScore, child: Text('Apply Max Score (round continues)')),
                  DropdownMenuItem(value: PickUpBehaviour.disqualify, child: Text('Disqualify (strict rules)')),
                ],
                onChanged: (val) { if (val != null) setState(() => _pickUpBehaviour = val); },
              ),
              if (_pickUpBehaviour == PickUpBehaviour.maxScore) ...[
                const BoxyArtDivider(),
                BoxyArtDropdownField<MaxScoreType>(
                  label: 'Max Score Method',
                  value: _maxScoreType,
                  items: const [
                    DropdownMenuItem(value: MaxScoreType.netDoubleBogey, child: Text('Net Double Bogey (WHS standard)')),
                    DropdownMenuItem(value: MaxScoreType.parPlusX, child: Text('Par + X strokes')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _maxScoreType = val); },
                ),
                if (_maxScoreType == MaxScoreType.parPlusX) ...[
                  const BoxyArtDivider(),
                  buildSliderField(
                    label: 'Strokes over par',
                    valueLabel: '$_maxScoreValue',
                    value: _maxScoreValue.toDouble(),
                    min: 1, max: 10, divisions: 9,
                    onChanged: (val) => setState(() => _maxScoreValue = val.round()),
                  ),
                ],
                buildInfoBubble(
                  _maxScoreType == MaxScoreType.netDoubleBogey
                      ? 'Net Double Bogey = Par + 2 + handicap strokes on that hole. WHS recommended default.'
                      : 'Player receives Par + $_maxScoreValue on any picked-up hole.',
                ),
              ] else ...[
                buildInfoBubble('Picking up on any hole disqualifies the player from this competition. Remaining holes will be locked.'),
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
      mode: isTeams ? CompetitionMode.teams : CompetitionMode.singles,
      handicapAllowance: _isNet ? _handicapAllowance : 0.0,
      handicapCap: _handicapCap,
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _aggregation,
      tieBreak: _tieBreak,
      applyCapToIndex: _applyCapToIndex,
      teamBestXCount: _teamBestXCount,
      useMixedTeeAdjustment: _useMixedTeeAdjustment,
      pickUpBehaviour: _pickUpBehaviour,
      maxScoreConfig: _pickUpBehaviour == PickUpBehaviour.maxScore
          ? MaxScoreConfig(type: _maxScoreType, value: _maxScoreValue)
          : null,
      handicapMode: _isNet ? _handicapMode : HandicapMode.none,
      teamAName: isTeams ? teamAName : null,
      teamBName: isTeams ? teamBName : null,
    );
  }
}
