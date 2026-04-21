import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
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
  CompetitionFormat _scoringFormat = CompetitionFormat.matchPlay;
  int _handicapCap = 28;
  double _allowance = 1.0;
  TieBreakMethod _tieBreak = TieBreakMethod.playoff;
  int _roundsCount = 1;

  @override
  CompetitionFormat get format => _scoringFormat;

  @override
  void initState() {
    if (widget.competition != null) {
      _scoringFormat = widget.competition!.rules.format;
      _handicapCap = widget.competition!.rules.handicapCap;
      _allowance = widget.competition!.rules.handicapAllowance.clamp(0.0, 1.0);
      _tieBreak = widget.competition!.rules.tieBreak;
      _roundsCount = widget.competition!.rules.roundsCount;
      if (_scoringFormat == CompetitionFormat.matchPlay && _tieBreak != TieBreakMethod.playoff) {
        _tieBreak = TieBreakMethod.playoff;
      }
    } else {
      _scoringFormat = CompetitionFormat.matchPlay;
      _handicapCap = 28;
      _tieBreak = TieBreakMethod.playoff;
      _roundsCount = 1;
      _allowance = _getDefaultAllowance(_scoringFormat);
    }
    super.initState();
  }

  double _getDefaultAllowance(CompetitionFormat format) {
    if (widget.subtype == CompetitionSubtype.foursomes) return 0.5;
    return 1.0;
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    final title = widget.subtype == CompetitionSubtype.fourball
        ? 'MATCH FORMAT'
        : 'TEAM FORMAT';

    final effectiveTieBreak = (_scoringFormat == CompetitionFormat.matchPlay && _tieBreak != TieBreakMethod.playoff)
        ? TieBreakMethod.playoff
        : _tieBreak;

    return BoxyArtFormColumn(
      children: [
        // ── FORMAT ────────────────────────────────────────────
        BoxyArtSectionTitle(title: title),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              BoxyArtDropdownField<CompetitionFormat>(
                label: 'Scoring Format',
                value: _scoringFormat,
                items: const [
                  DropdownMenuItem(value: CompetitionFormat.matchPlay, child: Text('Match Play')),
                  DropdownMenuItem(value: CompetitionFormat.stroke, child: Text('Stroke Play (Medal)')),
                  DropdownMenuItem(value: CompetitionFormat.stableford, child: Text('Stableford')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _scoringFormat = val;
                      _allowance = _getDefaultAllowance(val);
                      _tieBreak = val == CompetitionFormat.matchPlay ? TieBreakMethod.playoff : TieBreakMethod.back9;
                    });
                  }
                },
              ),
              buildInfoBubble(_getScoringFormatDescription(_scoringFormat, widget.subtype)),
              const BoxyArtDivider(),
              _buildInfoCardForFormat(),
            ],
          ),
        ),

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        BoxyArtCard(
          child: BoxyArtFormColumn(
            children: [
              buildAllowanceSlider(
                _allowance,
                (val) => setState(() => _allowance = val),
                label: widget.subtype == CompetitionSubtype.foursomes ? 'Team HCP allowance' : 'Handicap allowance',
                hint: widget.subtype == CompetitionSubtype.foursomes
                    ? 'WHS recommends 50% of combined team handicap.'
                    : '100% is standard for Fourball.',
              ),
              const BoxyArtDivider(),
              buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
              buildInfoBubble('0 = no cap. 1–54 limits each playing handicap.'),
            ],
          ),
        ),

        if (_scoringFormat != CompetitionFormat.matchPlay) ...[
          // ── TIE BREAK & ROUNDS ──────────────────────────────
          const BoxyArtSectionTitle(title: 'TIE BREAK & ROUNDS'),
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                BoxyArtDropdownField<TieBreakMethod>(
                  label: 'Tie Break Method',
                  value: effectiveTieBreak,
                  items: TieBreakMethod.values
                      .where((m) => m != TieBreakMethod.playoff)
                      .map((m) {
                        final lbl = switch (m) {
                          TieBreakMethod.back9 => 'Standard (Back 9-6-3-1)',
                          TieBreakMethod.back6 => 'Back 6',
                          TieBreakMethod.back3 => 'Back 3',
                          TieBreakMethod.back1 => 'Back 1',
                          TieBreakMethod.playoff => 'Playoff (Sudden Death)',
                        };
                        return DropdownMenuItem(value: m, child: Text(lbl));
                      }).toList(),
                  onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
                ),
                const BoxyArtDivider(),
                buildSliderField(
                  label: 'Number of Rounds',
                  valueLabel: '$_roundsCount',
                  value: _roundsCount.toDouble(),
                  min: 1, max: 6, divisions: 5,
                  onChanged: (val) => setState(() => _roundsCount = val.round()),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getScoringFormatDescription(CompetitionFormat format, CompetitionSubtype subtype) {
    final pairType = subtype == CompetitionSubtype.fourball ? 'Fourball' : 'Foursomes';
    switch (format) {
      case CompetitionFormat.matchPlay:
        return '$pairType Match Play: Win more holes than the opposing pair.';
      case CompetitionFormat.stroke:
        return '$pairType Medal: The best/combined score per hole is added for an 18-hole total.';
      case CompetitionFormat.stableford:
        return '$pairType Stableford: Points are awarded per hole based on the best score relative to par.';
      default:
        return '';
    }
  }

  Widget _buildInfoCardForFormat() {
    if (_scoringFormat == CompetitionFormat.stableford) return const SizedBox.shrink();

    final isFourball = widget.subtype == CompetitionSubtype.fourball;
    if (_scoringFormat == CompetitionFormat.matchPlay) {
      return buildInfoCard([
        ('Goal', isFourball ? 'Win more holes as a pair against the opposing pair.' : 'Your pair wins more holes playing one ball alternately.'),
        ('Scoring', 'Lowest score on a hole wins it. Halved means both pairs share the hole.'),
        ('Concessions', 'Putts and holes can be conceded. No need to hole out when conceded.'),
        ('Result', 'Match ends when holes up > holes remaining (e.g. 2 & 1).'),
        ('Handicap', isFourball ? '90–100% of the difference from the lowest handicap.' : '50% of the combined team handicap.'),
      ]);
    }
    return buildInfoCard([
      ('Goal', isFourball ? 'Lowest combined net/gross total over 18 holes.' : 'Partners alternate hitting the same ball every shot.'),
      ('Scoring', isFourball ? 'Best ball per hole counts for the pair\'s score.' : 'One combined score per hole — every stroke counts.'),
      ('Concessions', 'NO CONCESSIONS — must hole out every ball.'),
      ('Handicap', isFourball ? 'Each player\'s full (or adjusted) course handicap.' : '50% of combined team handicap distributed by WHS SI.'),
    ]);
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
      useMixedTeeAdjustment: _scoringFormat != CompetitionFormat.matchPlay,
    );
  }
}
