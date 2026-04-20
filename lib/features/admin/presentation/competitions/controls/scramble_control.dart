import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'base_competition_control.dart';

class ScrambleControl extends BaseCompetitionControl {
  const ScrambleControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<ScrambleControl> createState() => _ScrambleControlState();
}

class _ScrambleControlState extends BaseCompetitionControlState<ScrambleControl> {
  // Specific Scramble State
  CompetitionSubtype _subtype = CompetitionSubtype.texas;
  int _teamSize = 4;
  double _allowance = 1.0; // Default: 100%
  CompetitionFormat _underlyingFormat = CompetitionFormat.stroke;
  int _teamCap = 0;
  int _minDrives = 4;
  TeamHandicapMethod _teamHandicapMethod = TeamHandicapMethod.whs;
  bool _trackShotAttributions = true;
  bool _useWHSAllowance = true;

  @override
  CompetitionFormat get format => CompetitionFormat.scramble;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      final existingSubtype = widget.competition!.rules.subtype;
      if (existingSubtype == CompetitionSubtype.texas || 
          existingSubtype == CompetitionSubtype.florida) {
        _subtype = existingSubtype;
      }
      
      _teamSize = widget.competition!.rules.teamSize;
      _allowance = widget.competition!.rules.handicapAllowance.clamp(0.0, 1.0);
      _minDrives = widget.competition!.rules.minDrivesPerPlayer;
      _teamHandicapMethod = widget.competition!.rules.teamHandicapMethod;
      _underlyingFormat = widget.competition!.rules.underlyingFormat;
      _teamCap = widget.competition!.rules.teamHandicapCap ?? 0;
      _trackShotAttributions = widget.competition!.rules.trackShotAttributions;
      _useWHSAllowance = widget.competition!.rules.useWHSScrambleAllowance;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    var effectiveSubtype = _subtype;
    if (effectiveSubtype != CompetitionSubtype.texas && effectiveSubtype != CompetitionSubtype.florida) {
      effectiveSubtype = CompetitionSubtype.texas;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _subtype != CompetitionSubtype.texas) {
           setState(() => _subtype = CompetitionSubtype.texas);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SCRAMBLE FORMAT ───────────────────────────────────
        const BoxyArtSectionTitle(title: 'SCRAMBLE FORMAT'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              BoxyArtDropdownField<CompetitionSubtype>(
                label: 'Scramble Mode',
                value: effectiveSubtype,
                items: const [
                  DropdownMenuItem(value: CompetitionSubtype.texas, child: Text('Texas Scramble (Standard)')),
                  DropdownMenuItem(value: CompetitionSubtype.florida, child: Text('Florida Scramble (Step-aside)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _subtype = val);
                },
              ),
              buildInfoBubble(_subtype == CompetitionSubtype.texas
                  ? 'Standard team scramble — everyone drives, picks the best, all play from there.'
                  : 'Florida style — the hitter of the best ball steps aside for the next shot.'),
              const BoxyArtDivider(),
              BoxyArtDropdownField<CompetitionFormat>(
                label: 'Base Scoring Format',
                value: _underlyingFormat,
                items: const [
                  DropdownMenuItem(value: CompetitionFormat.stroke, child: Text('Regular Stroke Play (Medal)')),
                  DropdownMenuItem(value: CompetitionFormat.stableford, child: Text('Stableford (Points)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _underlyingFormat = val);
                },
              ),
              const BoxyArtDivider(),
              BoxyArtDropdownField<int>(
                label: 'Team Size',
                value: _teamSize,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2-Man Team')),
                  DropdownMenuItem(value: 3, child: Text('3-Man Team')),
                  DropdownMenuItem(value: 4, child: Text('4-Man Team')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _teamSize = val);
                },
              ),
              const BoxyArtDivider(),
              buildInfoCard(
                _subtype == CompetitionSubtype.texas
                    ? [
                        ('Tee Off', 'Everyone drives; team chooses the best ball.'),
                        ('Drives', 'Must use a minimum number of drives per player.'),
                        ('Fairway', 'Place within 6–12" of the spot.'),
                      ]
                    : [
                        ('Tee Off', 'Everyone drives; team chooses the best one.'),
                        ('Step Aside', 'The chosen hitter sits out the NEXT shot.'),
                        ('Rotation', 'Previous sitter returns, new hitter sits out.'),
                      ],
              ),
            ],
          ),
        ),

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildTeamHandicapMethodDropdown(),
              const BoxyArtDivider(),
              buildAllowanceSlider(
                _allowance,
                (val) => setState(() => _allowance = val),
                label: 'Team HCP allowance',
                hint: 'Applied to combined team HCP. WHS recommends 10% for a 4-man team.',
              ),
              const BoxyArtDivider(),
              buildCapSlider(
                _teamCap,
                (val) => setState(() => _teamCap = val),
              ),
              buildInfoBubble('Maximum total strokes the team can receive.'),
            ],
          ),
        ),

        // ── RULES & ATTRIBUTIONS ──────────────────────────────
        const BoxyArtSectionTitle(title: 'RULES & ATTRIBUTIONS'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: BoxyArtSwitchField(
            label: 'Track Shot Attributions',
            value: _trackShotAttributions,
            onChanged: (val) => setState(() => _trackShotAttributions = val),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHandicapMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtDropdownField<TeamHandicapMethod>(
          label: 'Team Handicap Method',
          value: _teamHandicapMethod,
          items: const [
            DropdownMenuItem(
              value: TeamHandicapMethod.whs, 
              child: Text('WHS Recommended (Weighted)'),
            ),
            DropdownMenuItem(
              value: TeamHandicapMethod.average, 
              child: Text('Average (Total ÷ Team Size)'),
            ),
            DropdownMenuItem(
              value: TeamHandicapMethod.sum, 
              child: Text('Combined Total (Sum)'),
            ),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _teamHandicapMethod = val);
          },
        ),
        if (_teamHandicapMethod == TeamHandicapMethod.whs)
          buildInfoBubble('Calculates team allowance using weighted percentages of each player\'s handicap (lowest to highest prevalence): e.g. 25/20/15/10% for 4-man teams.'),
      ],
    );
  }


  @override
  CompetitionRules buildRules() {
    return CompetitionRules(
      format: CompetitionFormat.scramble,
      subtype: _subtype,
      mode: CompetitionMode.teams,
      teamSize: _teamSize,
      handicapAllowance: _allowance,
      holeByHoleRequired: true,
      aggregation: AggregationMethod.totalSum, 
      minDrivesPerPlayer: _minDrives,
      useWHSScrambleAllowance: _useWHSAllowance,
      teamHandicapMethod: _teamHandicapMethod,
      underlyingFormat: _underlyingFormat,
      teamHandicapCap: _teamCap == 0 ? null : _teamCap,
      trackShotAttributions: _trackShotAttributions,
    );
  }
}
