import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/competition.dart';
import '../../../../../core/widgets/boxy_art_widgets.dart';
import 'base_competition_control.dart';
import '../../../../members/presentation/members_provider.dart';
import '../../../../../models/golf_event.dart';

class MatchPlayControl extends BaseCompetitionControl {
  const MatchPlayControl({super.key, super.competition, super.competitionId, super.isTemplate});

  @override
  ConsumerState<MatchPlayControl> createState() => _MatchPlayControlState();
}

class _MatchPlayControlState extends BaseCompetitionControlState<MatchPlayControl> {
  // Specific State
  CompetitionSubtype _subtype = CompetitionSubtype.none; // none = Singles
  double _allowance = 1.0;
  int _handicapCap = 28;
  TieBreakMethod _tieBreak = TieBreakMethod.playoff;

  @override
  CompetitionFormat get format => CompetitionFormat.matchPlay;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _subtype = widget.competition!.rules.subtype;
      _allowance = widget.competition!.rules.handicapAllowance;
      _handicapCap = widget.competition!.rules.handicapCap;
      _tieBreak = widget.competition!.rules.tieBreak;
    } else {
      _updateDefaultAllowance();
    }
  }

  void _updateDefaultAllowance() {
    if (_subtype == CompetitionSubtype.fourball) {
      _allowance = 0.90;
    } else if (_subtype == CompetitionSubtype.foursomes) {
      _allowance = 0.50;
    } else {
      _allowance = 1.0;
    }
  }


  @override
  Widget buildSpecificFields(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'MATCH FORMAT'),
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
                label: 'Format',
                value: _subtype,
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
              _buildAllowanceSlider(),
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
          ),
        ),


        const SizedBox(height: 24),
        _buildMemberPreview(),
      ],
    );
  }

  Widget _buildMemberPreview() {
    final rules = buildRules();
    // Re-use a simple translation for now or just the summary
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'MEMBER PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_subtype == CompetitionSubtype.none ? 'Singles' : (_subtype == CompetitionSubtype.fourball ? 'Fourball' : (_subtype == CompetitionSubtype.foursomes ? 'Foursomes' : (_subtype == CompetitionSubtype.ryderCup ? 'Ryder Cup' : 'Team')))} Match Play. ${(_allowance * 100).toInt()}% Handicap Allowance.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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
            Text('HANDICAP ALLOWANCE', style: TextStyle(
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
          "Applied to handicap difference", 
          style: TextStyle(color: Colors.grey, fontSize: 11),
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
  Future<void> onBeforeSave() async {
    // No-op for now as matches are managed in grouping screen
  }
}
