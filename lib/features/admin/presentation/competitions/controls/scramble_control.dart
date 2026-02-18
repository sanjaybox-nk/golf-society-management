import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
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
  int? _teamCap;
  int _minDrives = 4;
  TeamHandicapMethod _teamHandicapMethod = TeamHandicapMethod.whs;
  bool _trackShotAttributions = true;

  final TextEditingController _capController = TextEditingController();

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
      _teamCap = widget.competition!.rules.teamHandicapCap;
      _trackShotAttributions = widget.competition!.rules.trackShotAttributions;
      if (_teamCap != null) {
        _capController.text = _teamCap.toString();
      }
    }
  }

  @override
  void dispose() {
    _capController.dispose();
    super.dispose();
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
        const BoxyArtSectionTitle(title: 'SCRAMBLE CONFIGURATION'),
        const SizedBox(height: 16),
        Column(
          children: [
              // 1. Scramble Type
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
              const SizedBox(height: 24),

              // 2. Base Form of Play
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
              const SizedBox(height: 24),

              // 3. Team Size
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
                      // Reset to WHS-recommended defaults when team size changes
                      if (_teamSize == 4) _allowance = 0.10;
                      if (_teamSize == 3) _allowance = 0.15;
                      if (_teamSize == 2) _allowance = 0.25; 
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // 4. Team Handicap Cap
               BoxyArtFormField(
                label: 'Maximum Team Allowance (Cap)',
                controller: _capController,
                keyboardType: TextInputType.number,
                hintText: 'Optional (e.g. 18)',
                onChanged: (val) {
                  setState(() {
                    _teamCap = int.tryParse(val);
                  });
                },
              ),
              const SizedBox(height: 32),

              _buildInfoCard(),
              const SizedBox(height: 32),
              _buildShotAttributionToggle(),
              const SizedBox(height: 24),
              _buildTeamHandicapMethodDropdown(),
              const SizedBox(height: 24),
              _buildAllowanceSlider(),
            ],
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
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '4-man: 25/20/15/10%  •  3-man: 30/20/10%  •  2-man: 35/15%',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildShotAttributionToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track Shot Attributions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text('Enables Step-aside rules & Minimum Drive tracking', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: _trackShotAttributions,
          onChanged: (val) => setState(() => _trackShotAttributions = val),
          activeThumbColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final isTexas = _subtype == CompetitionSubtype.texas;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isTexas 
          ? [
              _buildInfoRow("Tee Off", "Everyone drives; team chooses the best ball."),
              const SizedBox(height: 12),
              _buildInfoRow("Drives", "Must use a minimum number of drives per player (e.g. 3-4 drives each)."),
              const SizedBox(height: 12),
              _buildInfoRow("Fairway", "Place within 6-12\" of the chosen spot."),
              const SizedBox(height: 12),
              _buildInfoRow("Rough", "Drop within 1 club length (stay in condition)."),
              const SizedBox(height: 12),
              _buildInfoRow("Putting", "Repeat process on green until someone holes out."),
            ]
          : [
              _buildInfoRow("Tee Off", "Everyone drives; choose the best one to start."),
              const SizedBox(height: 12),
              _buildInfoRow("Step Aside", "The player whose shot was chosen sits out the NEXT shot."),
              const SizedBox(height: 12),
              _buildInfoRow("Next Shot", "Remaining teammates play from the chosen spot."),
              const SizedBox(height: 12),
              _buildInfoRow("Rotation", "Best ball chosen again; the hitter steps aside, previous sitter returns."),
              const SizedBox(height: 12),
              _buildInfoRow("Putting", "Step aside rule continues on the green until holed."),
            ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90, // Reduced from 110 for tighter layout
          child: Text(
            "$label:", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12, 
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12, 
              height: 1.3,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllowanceSlider() {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (_allowance * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TEAM HANDICAP ALLOWANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primary,
            inactiveTrackColor: primary.withValues(alpha: 0.15),
            thumbColor: primary,
            overlayColor: primary.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            valueIndicatorColor: primary,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          child: Slider(
            value: _allowance.clamp(0.0, 1.0),
            min: 0,
            max: 1.0,
            divisions: 20, // 5% steps
            label: '$pct%',
            onChanged: (val) => setState(() => _allowance = val),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
            Text(
              'Applied to combined team course handicap',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            Text('100%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
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
      teamHandicapCap: _teamCap,
      trackShotAttributions: _trackShotAttributions,
    );
  }
}
