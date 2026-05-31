import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'base_competition_control.dart';

class MatchPlayControl extends BaseCompetitionControl {
  final CompetitionSubtype? initialSubtype;
  final bool isOverlay;

  const MatchPlayControl({
    super.key,
    super.competition,
    super.competitionId,
    super.isTemplate,
    this.initialSubtype,
    this.isOverlay = false,
  });

  @override
  ConsumerState<MatchPlayControl> createState() => _MatchPlayControlState();
}

class _MatchPlayControlState extends BaseCompetitionControlState<MatchPlayControl> {
  CompetitionSubtype _subtype = CompetitionSubtype.none;
  double _allowance = 1.0;
  int _handicapCap = 28;
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
      _tournamentFormat = rules.tournamentFormat;
      _seedingLogic = rules.seedingLogic;
      _progression = rules.progressionMode;
      _seasonMode = rules.mode;
    } else {
      if (widget.initialSubtype != null) {
        _subtype = widget.initialSubtype!;
      }
      _updateDefaultAllowance();
      name = CompetitionRules(format: CompetitionFormat.matchPlay, subtype: _subtype).gameName;
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
    final isSeason = _subtype == CompetitionSubtype.matchPlaySeason;

    return BoxyArtFormColumn(
      children: [
        if (isSeason) ...[
          // ── TOURNAMENT SETTINGS ────────────────────────────────
          const BoxyArtSectionTitle(title: 'TOURNAMENT SETTINGS'),
          BoxyArtCard(
            child: BoxyArtFormColumn(
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
        ] else ...[
          // ── HOW IT WORKS ──────────────────────────────────────
          const BoxyArtSectionTitle(title: 'HOW IT WORKS'),
          buildInfoCard([
            ('Goal', 'Win more holes than your opponent across 18.'),
            ('Scoring', 'Lowest score on a hole wins it and goes \'1-up\'.'),
            ('Concessions', 'You can concede a putt or hole to speed up play.'),
            ('Result', 'Match ends when holes up > holes remaining (e.g. 3 & 2).'),
            ('Handicap', 'Lower index gives strokes on the SI-ranked holes.'),
          ]),
        ],

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        BoxyArtCard(
          child: BoxyArtFormColumn(
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

        if (!isSeason)
          buildTeamSection(),
      ],
    );
  }

  @override
  CompetitionRules buildRules() {
    final CompetitionMode mode;
    if (_subtype == CompetitionSubtype.matchPlaySeason) {
      mode = _seasonMode;
    } else if (_subtype == CompetitionSubtype.fourball || _subtype == CompetitionSubtype.foursomes) {
      mode = CompetitionMode.pairs;
    } else {
      mode = isTeams ? CompetitionMode.teams : CompetitionMode.singles;
    }

    final bool isSinglesTeam = _subtype == CompetitionSubtype.none && isTeams;

    return CompetitionRules(
      format: CompetitionFormat.matchPlay,
      subtype: _subtype,
      mode: mode,
      handicapAllowance: _allowance,
      handicapCap: _handicapCap,
      tieBreak: TieBreakMethod.playoff,
      holeByHoleRequired: true,
      tournamentFormat: _tournamentFormat,
      seedingLogic: _seedingLogic,
      progressionMode: _progression,
      hasMatchPlayOverlay: widget.isOverlay,
      teamAName: isSinglesTeam ? teamAName : null,
      teamBName: isSinglesTeam ? teamBName : null,
    );
  }

  @override
  Future<void> onBeforeSave() async {}
}
