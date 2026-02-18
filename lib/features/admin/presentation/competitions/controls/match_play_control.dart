import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
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
    } else {
      _updateDefaultAllowance();
    }
  }

  void _updateDefaultAllowance() {
    if (_subtype == CompetitionSubtype.fourball) {
      _allowance = 1.0;
    } else if (_subtype == CompetitionSubtype.foursomes) {
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
        const BoxyArtSectionTitle(title: 'MATCH FORMAT'),
        const SizedBox(height: 16),
        BoxyArtDropdownField<CompetitionSubtype>(
          label: 'Format',
          value: effectiveSubtype,
          items: const [
            DropdownMenuItem(value: CompetitionSubtype.none, child: Text('Singles Match Play')),
            DropdownMenuItem(value: CompetitionSubtype.fourball, child: Text('Fourball (Better Ball)')),
            DropdownMenuItem(value: CompetitionSubtype.foursomes, child: Text('Foursomes (Alternate Shot)')),
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
        const SizedBox(height: 24),
        _buildAllowanceSlider(context),
        const SizedBox(height: 24),
        BoxyArtFormField(
          label: 'Handicap Cap',
          initialValue: _handicapCap.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => _handicapCap = int.tryParse(val) ?? 28),
        ),
        const SizedBox(height: 24),
        BoxyArtDropdownField<TieBreakMethod>(
          label: 'Tie Break Method',
          value: _tieBreak,
          items: const [
            DropdownMenuItem(value: TieBreakMethod.playoff, child: Text('Manual Playoff')),
            DropdownMenuItem(value: TieBreakMethod.back9, child: Text('Standard (Back 9-6-3-1)')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _tieBreak = val);
          },
        ),
      ],
    );
  }

  Widget _buildAllowanceSlider(BuildContext context) {
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
              'HANDICAP ALLOWANCE',
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary),
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
            divisions: 20,
            label: '$pct%',
            onChanged: (val) => setState(() => _allowance = val),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
            Text('Applied to handicap difference', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text('100%', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
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
    );
  }

  @override
  Future<void> onBeforeSave() async {}
}
