import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'base_competition_control.dart';

class MatchPlayControl extends BaseCompetitionControl {
  const MatchPlayControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<MatchPlayControl> createState() => _MatchPlayControlState();
}

class _MatchPlayControlState extends BaseCompetitionControlState<MatchPlayControl> {
  CompetitionSubtype _subtype = CompetitionSubtype.none;
  double _allowance = 1.0;
  int _handicapCap = 28;
  TieBreakMethod _tieBreak = TieBreakMethod.playoff;
  TournamentFormat _tournamentFormat = TournamentFormat.knockout;
  SeedingLogic _seedingLogic = SeedingLogic.random;
  MatchPlayProgression _progression = MatchPlayProgression.bracketed;
  CompetitionMode _seasonMode = CompetitionMode.singles;

  @override
  CompetitionFormat get format => CompetitionFormat.matchPlay;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      final rules = widget.competition!.rules;
      _subtype = rules.subtype;
      _allowance = rules.handicapAllowance;
      _handicapCap = rules.handicapCap;
      _tieBreak = rules.tieBreak;
      _tournamentFormat = rules.tournamentFormat;
      _seedingLogic = rules.seedingLogic;
      _progression = rules.progressionMode;
      _seasonMode = rules.mode;
    } else {
      _updateDefaultAllowance();
    }
  }

  void _updateDefaultAllowance() {
    if (_subtype == CompetitionSubtype.foursomes) {
      _allowance = 0.50;
    } else {
      _allowance = 1.0;
    }
  }

  @override
  Widget buildSpecificFields(BuildContext context) {
    var effectiveSubtype = _subtype;
    if (effectiveSubtype != CompetitionSubtype.none &&
        effectiveSubtype != CompetitionSubtype.matchPlaySeason &&
        effectiveSubtype != CompetitionSubtype.fourball &&
        effectiveSubtype != CompetitionSubtype.foursomes &&
        effectiveSubtype != CompetitionSubtype.ryderCup &&
        effectiveSubtype != CompetitionSubtype.teamMatchPlay) {
      effectiveSubtype = CompetitionSubtype.none;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _subtype != CompetitionSubtype.none) {
          setState(() => _subtype = CompetitionSubtype.none);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── MATCH FORMAT ──────────────────────────────────────
        const BoxyArtSectionTitle(title: 'MATCH FORMAT'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              BoxyArtDropdownField<CompetitionSubtype>(
                label: 'Format',
                value: effectiveSubtype,
                items: const [
                  DropdownMenuItem(value: CompetitionSubtype.none, child: Text('Singles Match Play')),
                  DropdownMenuItem(value: CompetitionSubtype.matchPlaySeason, child: Text('Season Tournament')),
                  DropdownMenuItem(value: CompetitionSubtype.ryderCup, child: Text('Ryder Cup (Team)')),
                  DropdownMenuItem(value: CompetitionSubtype.teamMatchPlay, child: Text('Team Match Play')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _subtype = val;
                      _updateDefaultAllowance();
                    });
                  }
                },
              ),
              buildInfoBubble(_getFormatDescription(effectiveSubtype)),
              const BoxyArtDivider(),
              buildInfoCard(_getFormatRules(effectiveSubtype)),
            ],
          ),
        ),

        // ── TOURNAMENT SETTINGS (Season Only) ──────────────────
        if (_subtype == CompetitionSubtype.matchPlaySeason) ...[
          const BoxyArtSectionTitle(title: 'TOURNAMENT SETTINGS'),
          BoxyArtCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                BoxyArtDropdownField<CompetitionMode>(
                  label: 'Tournament Mode',
                  value: _seasonMode,
                  items: const [
                    DropdownMenuItem(value: CompetitionMode.singles, child: Text('Singles (1 vs 1)')),
                    DropdownMenuItem(value: CompetitionMode.pairs, child: Text('Pairs (2 vs 2)')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _seasonMode = val); },
                ),
                const BoxyArtDivider(),
                BoxyArtDropdownField<TournamentFormat>(
                  label: 'Competitive Structure',
                  value: _tournamentFormat,
                  items: const [
                    DropdownMenuItem(value: TournamentFormat.knockout, child: Text('Knockout Bracket')),
                    DropdownMenuItem(value: TournamentFormat.divisions, child: Text('Divisions (Round Robin)')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _tournamentFormat = val); },
                ),
                const BoxyArtDivider(),
                BoxyArtDropdownField<SeedingLogic>(
                  label: 'Seeding Logic',
                  value: _seedingLogic,
                  items: const [
                    DropdownMenuItem(value: SeedingLogic.random, child: Text('Random Draw')),
                    DropdownMenuItem(value: SeedingLogic.seeded, child: Text('Seeded (By Handicap)')),
                    DropdownMenuItem(value: SeedingLogic.ranking, child: Text('Merit (By OOM Ranking)')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _seedingLogic = val); },
                ),
                const BoxyArtDivider(),
                BoxyArtDropdownField<MatchPlayProgression>(
                  label: 'Advancement Mode',
                  value: _progression,
                  items: const [
                    DropdownMenuItem(value: MatchPlayProgression.bracketed, child: Text('Fixed Bracket (Full Path)')),
                    DropdownMenuItem(value: MatchPlayProgression.randomRedraw, child: Text('Random Redraw (Each Round)')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _progression = val); },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              buildAllowanceSlider(
                _allowance,
                (val) => setState(() => _allowance = val),
                hint: 'Fraction of the handicap difference given as stroke allowance.',
              ),
              const BoxyArtDivider(),
              buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
              buildInfoBubble('0 = no cap. 1–54 limits the playing handicap.'),
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
                  DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Manual Playoff (Sudden Death)')),
                  DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
                ],
                onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
              ),
              buildInfoBubble('Standard results use reverse hole comparison. Playoff is sudden-death.'),
            ],
          ),
        ),
      ],
    );
  }

  String _getFormatDescription(CompetitionSubtype subtype) {
    switch (subtype) {
      case CompetitionSubtype.none:
        return 'One player vs one player. Win a hole, go 1-up. First to win more holes than remain wins the match.';
      case CompetitionSubtype.matchPlaySeason:
        return 'Tournament series played over a season. Supports knockout brackets or divisional round-robin play.';
      case CompetitionSubtype.ryderCup:
        return 'Team event: points are accumulated from individual singles, fourball, and foursomes matches.';
      case CompetitionSubtype.teamMatchPlay:
        return 'Two teams face off. Combined match points from individual contests determine the winning team.';
      default:
        return 'Standard match play format.';
    }
  }

  List<(String, String)> _getFormatRules(CompetitionSubtype subtype) {
    if (subtype == CompetitionSubtype.ryderCup || subtype == CompetitionSubtype.teamMatchPlay) {
      return [
        ('Points', 'Win = 1 pt, Halve = ½ pt, Loss = 0 pt per match.'),
        ('Sessions', 'Admin configures which session types are played (Singles, Fourball, Foursomes).'),
        ('Concessions', 'Putts and holes may be conceded to speed play.'),
        ('Result', 'Team with most points wins; >50% needed for outright victory.'),
      ];
    }
    return [
      ('Goal', 'Win more holes than your opponent across 18.'),
      ('Scoring', 'Lowest score on a hole wins it and goes \'1-up\'.'),
      ('Concessions', 'You can concede a putt or hole to speed up play.'),
      ('Result', 'Match ends when holes up > holes remaining (e.g. 3 & 2).'),
      ('Handicap', 'Lower index gives strokes on the SI-ranked holes.'),
    ];
  }

  @override
  CompetitionRules buildRules() {
    CompetitionMode mode = _subtype == CompetitionSubtype.matchPlaySeason ? _seasonMode : CompetitionMode.singles;

    if (_subtype == CompetitionSubtype.fourball || _subtype == CompetitionSubtype.foursomes) {
      mode = CompetitionMode.pairs;
    } else if (_subtype == CompetitionSubtype.ryderCup || _subtype == CompetitionSubtype.teamMatchPlay) {
      mode = CompetitionMode.teams;
    }

    return CompetitionRules(
      format: CompetitionFormat.matchPlay,
      subtype: _subtype,
      mode: mode,
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: _tieBreak,
      holeByHoleRequired: true,
      tournamentFormat: _tournamentFormat,
      seedingLogic: _seedingLogic,
      progressionMode: _progression,
    );
  }

  @override
  Future<void> onBeforeSave() async {}
}
