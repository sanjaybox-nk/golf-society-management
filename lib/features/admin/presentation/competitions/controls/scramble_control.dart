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
  double _allowance = 0.1; // 10% combined is common for 4-man
  int _minDrives = 4;
  bool _useWHSWeighting = true;

  @override
  CompetitionFormat get format => CompetitionFormat.scramble;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _subtype = widget.competition!.rules.subtype;
      _allowance = widget.competition!.rules.handicapAllowance;
      _minDrives = widget.competition!.rules.minDrivesPerPlayer;
      _useWHSWeighting = widget.competition!.rules.useWHSScrambleAllowance;
      // Team size isn't explicitly in rules, derived or stored in publishSettings? 
      // For now we'll just track it locally or assume it's part of the event setup.
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'TEAM CONFIGURATION'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              BoxyArtDropdownField<CompetitionSubtype>(
                label: 'Scramble Type',
                value: _subtype,
                items: const [
                  DropdownMenuItem(value: CompetitionSubtype.texas, child: Text('Texas Scramble (Standard)')),
                  DropdownMenuItem(value: CompetitionSubtype.florida, child: Text('Florida Scramble (Drive Out)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _subtype = val);
                },
              ),
              const SizedBox(height: 24),
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
                      // Auto-adjust typical allowance
                      if (_teamSize == 4) _allowance = 0.10;
                      if (_teamSize == 3) _allowance = 0.15;
                      if (_teamSize == 2) _allowance = 0.25; 
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 24),
              BoxyArtFormField(
                label: 'Minimum Drives per Player',
                initialValue: _minDrives.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() => _minDrives = int.tryParse(val) ?? 4);
                },
              ),
              const SizedBox(height: 24),
              _buildWHSWeightingToggle(),
              const SizedBox(height: 24),
              if (!_useWHSWeighting) _buildAllowanceSlider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWHSWeightingToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use WHS Recommended Weighting',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '4-man: 25/20/15/10% | 3-man: 30/20/10%',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: _useWHSWeighting,
          onChanged: (val) => setState(() => _useWHSWeighting = val),
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isTexas 
          ? [
              _buildInfoRow("Tee Off", "Everyone drives; team chooses the best ball."),
              const SizedBox(height: 12),
              _buildInfoRow("Drives", "Must use a minimum number of drives per player."),
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
          width: 110, // Widened from 80 for consistency
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
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text('TEAM HANDICAP ALLOWANCE', style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white70 : Colors.black87
            )),
            Text('${(_allowance * 100).toInt()}%', style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: Colors.orange
            )),
          ],
        ),
        Slider(
          value: _allowance,
          min: 0,
          max: 1.0,
          divisions: 20,
          label: '${(_allowance * 100).toInt()}%',
          onChanged: (val) => setState(() => _allowance = val),
          activeColor: Colors.orange,
          thumbColor: Colors.orange,
        ),
         const Text(
          "Percentage of combined team handicap", 
          style: TextStyle(color: Colors.grey, fontSize: 11),
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
      handicapAllowance: _allowance,
      holeByHoleRequired: true,
      aggregation: AggregationMethod.totalSum, // Scramble is total strokes (net)
      minDrivesPerPlayer: _minDrives,
      useWHSScrambleAllowance: _useWHSWeighting,
    );
  }
}
