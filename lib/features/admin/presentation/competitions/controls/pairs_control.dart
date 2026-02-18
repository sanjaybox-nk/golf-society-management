import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../models/competition.dart';
import '../../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';

class PairsControl extends BaseCompetitionControl {
  final CompetitionSubtype subtype;

  const PairsControl({
    super.key,
    super.competition, 
    super.competitionId, 
    super.isTemplate,
    required this.subtype,
  });

  @override
  ConsumerState<PairsControl> createState() => _PairsControlState();
}

class _PairsControlState extends BaseCompetitionControlState<PairsControl> {
  // Specific State
  late CompetitionFormat _scoringFormat; // matchPlay or stroke
  late int _handicapCap;
  late double _allowance;
  late TieBreakMethod _tieBreak;
  late int _roundsCount;

  @override
  CompetitionFormat get format => _scoringFormat;

  @override
  void initState() {
    super.initState();
    // Load initial values or defaults
    if (widget.competition != null) {
      _scoringFormat = widget.competition!.rules.format;
      _handicapCap = widget.competition!.rules.handicapCap;
      _allowance = widget.competition!.rules.handicapAllowance.clamp(0.0, 1.0);
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      
      // Validation: Ensure TieBreak matches Format
      if (_scoringFormat == CompetitionFormat.matchPlay && _tieBreak != TieBreakMethod.playoff) {
        _tieBreak = TieBreakMethod.playoff;
      }
    } else {
      _scoringFormat = CompetitionFormat.matchPlay;
      _handicapCap = 28;
      _tieBreak = TieBreakMethod.playoff; // Match Play default
      _roundsCount = 1;
      _allowance = _getDefaultAllowance(_scoringFormat);
    }
  }

  double _getDefaultAllowance(CompetitionFormat format) {
    if (widget.subtype == CompetitionSubtype.foursomes) {
      return 0.5; // Foursomes: 50% of combined handicap
    }
    return 1.0; // Fourball: 100% — society adjusts as needed
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    final title = widget.subtype == CompetitionSubtype.fourball 
        ? "Fourball (Better Ball)" 
        : "Foursomes (Alternate Shot)";
        
    final description = widget.subtype == CompetitionSubtype.fourball
        ? "Two teams of two players. Players play their own ball. Best score on each hole counts."
        : "Two teams of two players. Partners alternate hitting the same ball. One score per side.";

    // Calculate effective tie break here to ensure valid value for dropdown
    final effectiveTieBreak = (_scoringFormat == CompetitionFormat.matchPlay && _tieBreak != TieBreakMethod.playoff)
        ? TieBreakMethod.playoff
        : _tieBreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(title: title.toUpperCase()),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Description
               Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                ),
              ),

              // Scoring Format
              BoxyArtDropdownField<CompetitionFormat>(
                label: 'Scoring Type',
                value: _scoringFormat,
                items: const [
                   DropdownMenuItem(
                     value: CompetitionFormat.matchPlay, 
                     child: Text('Match Play')
                   ),
                   DropdownMenuItem(
                     value: CompetitionFormat.stroke, 
                     child: Text('Stroke Play (Medal)')
                   ),
                   // Stableford is also possible for Fourball, but let's stick to Match/Stroke as per request
                   // "Both Fourball and Foursomes can be played as either match play or stroke play"
                   // "also common formats for ... Stableford tournaments"
                   // OK, I should add Stableford too? User request said "Match Play or Stroke Play" primarily, but mentioned Stableford.
                   // I'll add Stableford as an option.
                   DropdownMenuItem(
                     value: CompetitionFormat.stableford, 
                     child: Text('Stableford')
                   ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _scoringFormat = val;
                      _allowance = _getDefaultAllowance(val);
                      // Reset Tie Break to valid default for format
                      // Match Play -> Playoff
                      // Others -> Back 9 (or keep existing if not playoff, but easier to just reset)
                      if (val == CompetitionFormat.matchPlay) {
                        _tieBreak = TieBreakMethod.playoff;
                      } else {
                        _tieBreak = TieBreakMethod.back9;
                      }
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              _buildInfoCard(),
              
              const SizedBox(height: 24),

              // Allowance
              _buildAllowanceSlider(),
              
              const SizedBox(height: 24),
              
              // Cap
              BoxyArtFormField(
                label: 'Handicap Cap',
                initialValue: _handicapCap.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
              ),
              const SizedBox(height: 24),

              // Tie Break - Filtered by Format
              if (_scoringFormat != CompetitionFormat.matchPlay) ...[
                BoxyArtDropdownField<TieBreakMethod>(
                  label: 'Tie Break Method',
                  value: effectiveTieBreak,
                  items: TieBreakMethod.values
                      .where((m) {
                        return m != TieBreakMethod.playoff; // Hide 'Playoff' for Stroke/Stableford
                      })
                      .map((m) {
                        String label;
                        switch (m) {
                          case TieBreakMethod.back9: label = 'Standard (Back 9-6-3-1)'; break;
                          case TieBreakMethod.back6: label = 'Back 6'; break;
                          case TieBreakMethod.back3: label = 'Back 3'; break;
                          case TieBreakMethod.back1: label = 'Back 1'; break;
                          case TieBreakMethod.playoff: label = 'Playoff (Sudden Death)'; break;
                        }
                        return DropdownMenuItem(value: m, child: Text(label));
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tieBreak = val);
                  },
                ),
                const SizedBox(height: 24),
              ],
              
              // Rounds (Series) - Only show for Stroke/Stableford (Match Play is usually 1 off or handle manually)
              if (_scoringFormat != CompetitionFormat.matchPlay) ...[
                BoxyArtFormField(
                  label: 'Rounds (Series)',
                  initialValue: _roundsCount.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _roundsCount = int.tryParse(val) ?? 1),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildAllowanceSlider() {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelText = widget.subtype == CompetitionSubtype.foursomes ? 'TEAM HCP ALLOWANCE' : 'HANDICAP ALLOWANCE';
    final pct = (_allowance * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
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
              'Applied to each player\'s course handicap',
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
      format: _scoringFormat,
      subtype: widget.subtype,
      mode: CompetitionMode.pairs,
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: _tieBreak, 
      holeByHoleRequired: true,
      roundsCount: _roundsCount,
      aggregation: _scoringFormat == CompetitionFormat.stableford 
          ? AggregationMethod.stablefordSum 
          : AggregationMethod.totalSum,
    );
  }

  Widget _buildInfoCard() {
    if (_scoringFormat == CompetitionFormat.stableford) return const SizedBox.shrink();

    String goal = "";
    String scoring = "";
    String result = "";
    String concessions = "";
    String handicap = "";

    if (_scoringFormat == CompetitionFormat.matchPlay) {
      goal = "Win more individual holes than your opponent.";
      scoring = "Lowest score wins 1 point per hole (goes '1-up').";
      result = "Match ends when holes up > holes left (e.g. 3 & 2).";
      concessions = "You can concede a putt or hole to speed up play.";
      handicap = "90% (Fourball) or 50% (Foursomes) of difference from lowest.";
    } else {
      goal = "Finish 18 holes with lowest total strokes.";
      scoring = "Every stroke counts. Sum all holes at end.";
      result = "Team with lowest total gross/net score wins.";
      concessions = "NO CONCESSIONS. Must hole out every ball.";
      handicap = "Set % of full handicap (e.g. 85% Fourball).";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Goal", goal),
          const SizedBox(height: 8),
          _buildInfoRow("Scoring", scoring),
          const SizedBox(height: 8),
          _buildInfoRow("Result", result),
          const SizedBox(height: 8),
          _buildInfoRow("Concessions", concessions, isBold: true),
          const SizedBox(height: 8),
          _buildInfoRow("Handicap", handicap),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110, // Widened from 80 to prevent 'Concessions' wrapping
          child: Text(
            "$label:", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12, 
              color: theme.colorScheme.primary, // Themed color
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12, 
              height: 1.3, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: theme.textTheme.bodyMedium?.color, // Themed text color
            ),
          ),
        ),
      ],
    );
  }
}
