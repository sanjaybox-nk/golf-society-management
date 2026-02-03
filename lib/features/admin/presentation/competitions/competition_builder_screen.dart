import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/competition.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
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
    CompetitionFormat? activeFormat;
    
    // 1. If we are editing an existing competition, use its format
    if (competition != null) {
      activeFormat = competition!.rules.format;
    } 
    // 2. If creating new, use the specific format passed
    else if (format != null) {
      activeFormat = format;
    }
    // 3. Special Case: Pairs (subtype provided) - Format might be determined inside control, 
    // but we need a non-null activeFormat to proceed. We can use format if passed, or default.
    else if (subtype != null) {
      activeFormat = CompetitionFormat.matchPlay; // Default placeholder for shell
    }

    // 3. If neither, try to fetch by ID
    // If neither, we can't show a specific control.
    if (activeFormat == null && competitionId != null) {
       if (isTemplate) {
          final templatesAsync = ref.watch(templatesListProvider);
          return templatesAsync.when(
            data: (templates) {
              final template = templates.where((t) => t.id == competitionId).firstOrNull;
              if (template == null) return const Scaffold(body: Center(child: Text("Template not found")));
              return Scaffold(
                backgroundColor: const Color(0xFFF2F2F7),
                appBar: BoxyArtAppBar(
                  title: 'EDIT TEMPLATE',
                  centerTitle: true,
                  isLarge: true,
                  leadingWidth: 80,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          'Back',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildControl(template.rules.format, context, template: template),
                ),
              );
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
          );
       }
      // For regular competitions, adding similar logic would be good, but for now specific to templates issue.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activeFormat == null) {
       return const Scaffold(body: Center(child: Text("Error: No format determined for competition builder.")));
    }

    // Determine readable game name
    String gameName;
    final compToUse = competition; 
    final activeSubtype = subtype ?? compToUse?.rules.subtype;
    
    if (activeSubtype != null) {
      if (activeSubtype == CompetitionSubtype.fourball) {
        gameName = 'FOURBALL';
      } else if (activeSubtype == CompetitionSubtype.foursomes) {
        gameName = 'FOURSOMES';
      } else {
        gameName = activeSubtype.name.toUpperCase();
      }
    } else {
      // Split camelCase format (e.g. matchPlay -> MATCH PLAY)
      gameName = activeFormat.name
          .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
          .trim()
          .toUpperCase();
    }

    final String title = gameName;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: BoxyArtAppBar(
        title: title,
        centerTitle: true,
        isLarge: true,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                'Back',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildControl(activeFormat, context),
      ),
    );
  }

  Widget _buildControl(CompetitionFormat format, BuildContext context, {Competition? template}) {
    final compToUse = competition ?? template;
    final activeSubtype = subtype ?? compToUse?.rules.subtype;

    if (activeSubtype == CompetitionSubtype.fourball || activeSubtype == CompetitionSubtype.foursomes) {
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
