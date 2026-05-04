import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
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
            if (template == null) return const HeadlessScaffold(title: 'Not Found', showBack: true, slivers: [SliverFillRemaining(child: Center(child: Text("Template not found")))]);
            return _buildScaffold(context, template.rules.format, template: template);
          },
          loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
          error: (e, s) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverFillRemaining(child: Center(child: Text("Error: $e")))]),
        );
      } else {
        // Fetch event-specific competition
        final compAsync = ref.watch(competitionDetailProvider(competitionId!));
        return compAsync.when(
          data: (comp) {
            if (comp == null) return const HeadlessScaffold(title: 'Not Found', showBack: true, slivers: [SliverFillRemaining(child: Center(child: Text("Competition not found")))]);
            return _buildScaffold(context, comp.rules.format, competition: comp);
          },
          loading: () => const HeadlessScaffold(title: 'Loading...', slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
          error: (e, s) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverFillRemaining(child: Center(child: Text("Error: $e")))]),
        );
      }
    }

    // 3. If creating new, use format or subtype
    if (format != null) {
      return _buildScaffold(context, format!);
    }
    
    if (subtype != null) {
      // Default to stableford as base for specialized match play tournaments
      return _buildScaffold(context, CompetitionFormat.stableford); 
    }

    return const HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverFillRemaining(child: Center(child: Text("Error: No data provided for competition builder.")))]);
  }

  Widget _buildScaffold(BuildContext context, CompetitionFormat activeFormat, {Competition? competition, Competition? template}) {
    final compToUse = competition ?? template;
    final activeSubtype = subtype ?? compToUse?.rules.subtype;
    final gameName = CompetitionRules(
      format: activeFormat, 
      subtype: activeSubtype ?? CompetitionSubtype.none,
    ).gameName;

    return HeadlessScaffold(
      title: isTemplate
          ? (compToUse != null ? 'Edit Template' : 'Create Template')
          : 'Create $gameName game',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      subtitle: isTemplate 
          ? 'Edit saved game template' 
          : (compToUse != null ? 'Event customisation' : 'New competition setup'),
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
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

    if (activeSubtype == CompetitionSubtype.fourball || activeSubtype == CompetitionSubtype.foursomes) {
      return PairsControl(
        competition: compToUse,
        competitionId: competitionId,
        isTemplate: isTemplate,
        subtype: activeSubtype!,
      ); 
    }

    if (activeSubtype == CompetitionSubtype.matchPlaySeason || 
        activeSubtype == CompetitionSubtype.ryderCup || 
        activeSubtype == CompetitionSubtype.teamMatchPlay) {
      return MatchPlayControl(
        competition: compToUse,
        competitionId: competitionId,
        isTemplate: isTemplate,
      );
    }
    
    switch (format) {
      case CompetitionFormat.stableford:
        return StablefordControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.stroke:
        return StrokePlayControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.scramble:
        return ScrambleControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.maxScore:
        return MaxScoreControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
      case CompetitionFormat.matchPlay:
        return MatchPlayControl(competition: compToUse, competitionId: competitionId, isTemplate: isTemplate);
    }
  }

}
