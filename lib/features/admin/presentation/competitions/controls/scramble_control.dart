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
  bool? _separateGuests;

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
      _separateGuests = widget.competition!.rules.separateGuests;
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
        const SizedBox(height: AppSpacing.lg),

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
            ? 'Standard team scramble — everyone drives, the team picks the best ball and all play from there.'
            : 'After each shot, the player whose ball was chosen steps aside and doesn\'t play the next shot.'),
        const SizedBox(height: AppSpacing.x2l),

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
        buildInfoBubble('Stroke Play counts total strokes. Stableford awards points per hole relative to par.'),
        const SizedBox(height: AppSpacing.x2l),

        BoxyArtDropdownField<int>(
          label: 'Team Size',
          value: _teamSize,
          items: const [
            DropdownMenuItem(value: 2, child: Text('2-Man Team')),
            DropdownMenuItem(value: 3, child: Text('3-Man Team')),
            DropdownMenuItem(value: 4, child: Text('4-Man Team')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _teamSize = val;
                // [FIX] DO NOT auto-set allowance to 0.10 here.
                // The allowance should be 1.0 if using WHS Method, 
                // OR manually set via the slider.
              });
            }
          },
        ),
        buildInfoBubble('Allowance defaults auto-update to WHS recommendations when you change team size.'),

        const SizedBox(height: AppSpacing.x2l),
        buildInfoCard(
          _subtype == CompetitionSubtype.texas
              ? [
                  ('Tee Off', 'Everyone drives; team chooses the best ball.'),
                  ('Drives', 'Must use a minimum number of drives per player (e.g. 3–4 each).'),
                  ('Fairway', 'Place within 6–12" of the chosen spot.'),
                  ('Rough', 'Drop within 1 club length (stay in the same condition).'),
                  ('Putting', 'Repeat process on the green until someone holes out.'),
                ]
              : [
                  ('Tee Off', 'Everyone drives; team chooses the best one to start.'),
                  ('Step Aside', 'The player whose shot was chosen sits out the NEXT shot.'),
                  ('Next Shot', 'Remaining teammates play from the chosen spot.'),
                  ('Rotation', 'Best ball chosen again; the hitter steps aside, previous sitter returns.'),
                  ('Putting', 'Step-aside rule continues on the green until holed.'),
                ],
        ),

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        const SizedBox(height: AppSpacing.lg),

        _buildTeamHandicapMethodDropdown(),
        const SizedBox(height: AppSpacing.x2l),

        buildAllowanceSlider(
          _allowance,
          (val) => setState(() => _allowance = val),
          label: 'TEAM HCP ALLOWANCE',
          hint: 'Applied to the combined team course handicap. WHS recommends 10% for a 4-man team.',
        ),
        const SizedBox(height: AppSpacing.x2l),

        buildCapSlider(
          _teamCap,
          (val) => setState(() => _teamCap = val),
        ),
        buildInfoBubble('Maximum total strokes the team can receive. Use this to prevent low-handicap teams from gaining too much advantage.'),

        const SizedBox(height: AppSpacing.x2l),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.x2l),

        // ── RULES & ATTRIBUTIONS ──────────────────────────────
        const BoxyArtSectionTitle(title: 'RULES & ATTRIBUTIONS'),
        const SizedBox(height: AppSpacing.lg),

        BoxyArtSwitchField(
          label: 'Track Shot Attributions',
          value: _trackShotAttributions,
          onChanged: (val) => setState(() => _trackShotAttributions = val),
        ),
        buildInfoBubble('Enables step-aside enforcement and minimum drives tracking per player.'),

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
      useWHSScrambleAllowance: _teamHandicapMethod == TeamHandicapMethod.whs,
      teamHandicapMethod: _teamHandicapMethod,
      underlyingFormat: _underlyingFormat,
      teamHandicapCap: _teamCap == 0 ? null : _teamCap,
      trackShotAttributions: _trackShotAttributions,
      separateGuests: _separateGuests,
    );
  }
}
