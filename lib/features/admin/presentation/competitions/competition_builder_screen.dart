import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/competition.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';
import 'controls/stableford_control.dart';
import 'controls/stroke_control.dart';
import 'controls/match_play_control.dart';
import 'controls/scramble_control.dart';
import 'controls/max_score_control.dart';
import 'controls/pairs_control.dart';
import '../../../competitions/presentation/competitions_provider.dart';

class CompetitionBuilderScreen extends ConsumerWidget {
  final Competition? competition;
  final String? competitionId;
  final CompetitionFormat? format;
  final CompetitionSubtype? subtype;
  final bool isTemplate;

  const CompetitionBuilderScreen({
    super.key, 
    this.competition, 
    this.competitionId,
    this.format,
    this.subtype,
    this.isTemplate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. If we have a competition object already, we can use it directly
    if (competition != null) {
      return _buildScaffold(context, competition!.rules.format, competition: competition);
    }

    // 2. If we have an ID, we need to fetch it
    if (competitionId != null) {
      if (isTemplate) {
        final templatesAsync = ref.watch(templatesListProvider);
        return templatesAsync.when(
          data: (templates) {
            final template = templates.where((t) => t.id == competitionId).firstOrNull;
            if (template == null) return const Scaffold(body: Center(child: Text("Template not found")));
            return _buildScaffold(context, template.rules.format, template: template);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
        );
      } else {
        // Fetch event-specific competition
        final compAsync = ref.watch(competitionDetailProvider(competitionId!));
        return compAsync.when(
          data: (comp) {
            if (comp == null) return const Scaffold(body: Center(child: Text("Competition not found")));
            return _buildScaffold(context, comp.rules.format, competition: comp);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
        );
      }
    }

    // 3. If creating new, use format or subtype
    if (format != null) {
      return _buildScaffold(context, format!);
    }
    
    if (subtype != null) {
      // Default placeholder format for shell, pairs control will handle reality
      return _buildScaffold(context, CompetitionFormat.matchPlay); 
    }

    return const Scaffold(body: Center(child: Text("Error: No data provided for competition builder.")));
  }

  Widget _buildScaffold(BuildContext context, CompetitionFormat activeFormat, {Competition? competition, Competition? template}) {
    final compToUse = competition ?? template;
    final activeSubtype = subtype ?? compToUse?.rules.subtype;
    final gameName = CompetitionRules(
      format: activeFormat, 
      subtype: activeSubtype ?? CompetitionSubtype.none,
    ).gameName;

    return HeadlessScaffold(
      title: gameName,
      subtitle: isTemplate 
          ? 'edit saved game' 
          : (compToUse != null ? 'event customization' : 'new competition'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverToBoxAdapter(
            child: _buildControl(activeFormat, context, competition: competition, template: template),
          ),
        ),
      ],
    );
  }

  Widget _buildControl(CompetitionFormat format, BuildContext context, {Competition? competition, Competition? template}) {
    final compToUse = competition ?? this.competition ?? template;
    final activeSubtype = subtype ?? compToUse?.rules.subtype;

    if ((activeSubtype == CompetitionSubtype.fourball || activeSubtype == CompetitionSubtype.foursomes) && format != CompetitionFormat.matchPlay) {
      return PairsControl(
        competition: compToUse,
        competitionId: competitionId,
        isTemplate: isTemplate,
        subtype: activeSubtype!,
      ); 
    }
    
    switch (format) {
      case CompetitionFormat.stableford:
        return StablefordControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.stroke:
        return StrokePlayControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.matchPlay:
        return MatchPlayControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.scramble:
        return ScrambleControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.maxScore:
        return MaxScoreControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
    }
  }

}
