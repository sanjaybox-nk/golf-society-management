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
  bool? _separateGuests;

  @override
  CompetitionFormat get format => CompetitionFormat.matchPlay;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      final existingSubtype = widget.competition!.rules.subtype;
      if (existingSubtype == CompetitionSubtype.none ||
          existingSubtype == CompetitionSubtype.fourball ||
          existingSubtype == CompetitionSubtype.foursomes ||
          existingSubtype == CompetitionSubtype.ryderCup ||
          existingSubtype == CompetitionSubtype.teamMatchPlay) {
        _subtype = existingSubtype;
      }
      _allowance = widget.competition!.rules.handicapAllowance;
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
      _separateGuests = widget.competition!.rules.separateGuests;
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
        const SizedBox(height: 16),

        BoxyArtDropdownField<CompetitionSubtype>(
          label: 'Format',
          value: effectiveSubtype,
          items: const [
            DropdownMenuItem(value: CompetitionSubtype.none, child: Text('Singles Match Play')),
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
        const SizedBox(height: 16),

        // Format info card
        buildInfoCard(_getFormatRules(effectiveSubtype)),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── HANDICAP ──────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'HANDICAP'),
        const SizedBox(height: 16),

        buildAllowanceSlider(
          _allowance,
          (val) => setState(() => _allowance = val),
          hint: 'Fraction of the handicap difference given as stroke allowance.',
        ),
        const SizedBox(height: 24),

        buildCapSlider(_handicapCap, (val) => setState(() => _handicapCap = val)),
        buildInfoBubble('0 = no cap applied. 1–54 limits each player\'s playing handicap to that maximum value.'),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── TIE BREAK ─────────────────────────────────────────
        const BoxyArtSectionTitle(title: 'TIE BREAK'),
        const SizedBox(height: 16),

        BoxyArtDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          items: const [
            DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Manual Playoff (Sudden Death)')),
            DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
          ],
          onChanged: (val) { if (val != null) setState(() => _tieBreak = val); },
        ),
        buildInfoBubble('Match Play normally ends before 18 holes — a playoff is the standard resolution for all-square matches.'),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── GUEST SETTINGS ────────────────────────────────────
        buildGuestSettings(
          separateGuests: _separateGuests,
          onSeparateChanged: (val) => setState(() => _separateGuests = val),
        ),
      ],
    );
  }

  String _getFormatDescription(CompetitionSubtype subtype) {
    switch (subtype) {
      case CompetitionSubtype.none:
        return 'One player vs one player. Win a hole, go 1-up. First to win more holes than remain wins the match.';
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
    CompetitionMode mode = CompetitionMode.singles;
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
      separateGuests: _separateGuests,
    );
  }

  @override
  Future<void> onBeforeSave() async {}
}
