import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../utils/competition_rule_translator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../competitions_provider.dart';

class CompetitionBadgeRow extends StatelessWidget {
  final CompetitionRules rules;
  final String? eventId;
  final Color? baseColor;

  const CompetitionBadgeRow({
    super.key,
    required this.rules,
    this.eventId,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pills = [];

    // 1. Format Pill (Stroke Play, Match Play, etc.)
    pills.add(
      BoxyArtPill.format(
        label: rules.format == CompetitionFormat.matchPlay 
            ? rules.gameName 
            : rules.format.name,
      ),
    );

    // 2. Scoring Pill (Net or Gross)
    pills.add(
      BoxyArtPill.format(
        label: rules.scoringType,
      ),
    );

    // 3. Allowance Pill (e.g., 95% HCP)
    pills.add(
      BoxyArtPill.type(
        label: rules.defaultAllowanceLabel,
      ),
    );

    // 4. Mode Pill (Singles, Pairs, Team)
    pills.add(
      BoxyArtPill.type(
        label: rules.modeLabel,
      ),
    );

    if (rules.applyCapToIndex && 
        rules.handicapCap < 54 && 
        rules.format != CompetitionFormat.scramble && 
        rules.subtype != CompetitionSubtype.foursomes && 
        rules.subtype != CompetitionSubtype.fourball) {
      pills.add(
        BoxyArtPill.status(
          label: 'Capped @ ${rules.handicapCap.toInt()} HCP',
          color: AppColors.coral400,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: pills,
    );
  }
}

class CompetitionRuleDescription extends StatelessWidget {
  final CompetitionRules rules;
  final TextStyle? style;

  const CompetitionRuleDescription({
    super.key,
    required this.rules,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final description = CompetitionRuleTranslator.translate(rules);
    
    return Text(
      description,
      textAlign: TextAlign.start,
      style: style ?? TextStyle(
        fontSize: AppTypography.sizeBodySmall,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: AppColors.opacityHigh),
        height: 1.5,
      ),
    );
  }
}

class CompetitionRulesCard extends ConsumerWidget {
  final String eventId;
  final String title;
  final bool isSecondary;
  final VoidCallback? onTap;
  final VoidCallback? onChevronTap;
  final bool showChevron;
  final List<Widget>? extraBadges;
  final Competition? competition; // Optional direct competition object

  const CompetitionRulesCard({
    super.key,
    required this.eventId,
    required this.title,
    this.isSecondary = false,
    this.onTap,
    this.onChevronTap,
    this.showChevron = false,
    this.extraBadges,
    this.competition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we have direct data, use it.
    if (competition != null) return _buildContent(context, competition!);

    // Watch the dynamic provider
    if (eventId.isEmpty) return _buildFallbackContent(context);
    final compsAsync = ref.watch(competitionDetailProvider(eventId));
    
    return compsAsync.when(
      data: (comp) {
        // If data is null, we show a "TEMPLATE" version instead of disappearing
        if (comp == null) {
           return _buildFallbackContent(context);
        }
        return _buildContent(context, comp);
      },
      loading: () => _buildLoadingState(),
      error: (e, _) => _buildErrorState(e),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.x3l),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), // Hardened dark color
        borderRadius: AppShapes.x2l,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(Object e) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: AppShapes.x2l,
        border: Border.all(color: AppColors.coral500.withValues(alpha: AppColors.opacityMuted)),
      ),
      child: Text("Problem loading rules: $e", style: const TextStyle(color: AppColors.coral500)),
    );
  }

  Widget _buildFallbackContent(BuildContext context) {
    // Return a generic template version so it's ALWAY there
    return _buildContent(context, Competition(
      id: 'template',
      type: CompetitionType.game,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      rules: const CompetitionRules(
        format: CompetitionFormat.stableford,
        mode: CompetitionMode.singles,
      ),
      name: 'SETUP COMPETITION...',
    ));
  }

  Widget _buildContent(BuildContext context, Competition comp) {
    final primary = AppColors.lime500; // Hardcoded fallback to ensure visibility
    final accent = isSecondary ? AppColors.amber500 : primary;
    final isTemplate = comp.id == 'template';
    
    return Material(
      color: Colors.transparent, // Ensures standard text styles from theme
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppColors.dark600, size: AppShapes.iconXs),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTypography.sizeCaptionStrong,
                      fontWeight: AppTypography.weightBlack,
                      color: AppColors.dark500,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            
          // THE HARDENED CARD
          Container(
            width: double.infinity, // FORCE WIDE
            decoration: BoxDecoration(
              color: const Color(0xFF151515), // DEEP OPAQUE BLACK
              borderRadius: AppShapes.x2l,
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle), 
                width: AppShapes.borderThin,
              ),
              boxShadow: AppShadows.softScale,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: AppShapes.x2l,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x2l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TOP ROW: ICON | TITLES
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LEFT COL: ICON
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: AppColors.opacityMedium),
                            borderRadius: AppShapes.lg,
                            border: Border.all(color: accent.withValues(alpha: 0.4), width: AppShapes.borderLight),
                          ),
                          child: Icon(comp.rules.gameIcon, color: accent, size: AppShapes.iconXl),
                        ),
                        const SizedBox(width: 18),
                        // RIGHT COL: TEXTS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  (comp.name ?? 'COMPETITION').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: AppTypography.sizeLargeBody,
                                    fontWeight: AppTypography.weightBlack,
                                    color: AppColors.pureWhite,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  isSecondary ? 'SECONDARY OVERLAY' : comp.rules.gameName,
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeBodySmall,
                                    color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHalf),
                                    fontWeight: AppTypography.weightBold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showChevron)
                          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityMedium), size: AppShapes.iconSm),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.x2l),
                    Divider(color: AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle), height: 1),
                    const SizedBox(height: AppSpacing.x2l),
                    
                    // RULES TEXT
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isTemplate ? 'Fetching competition specific rules...' : CompetitionRuleTranslator.translate(comp.rules),
                        style: TextStyle(
                          fontSize: AppTypography.sizeButton,
                          height: 1.6,
                          color: AppColors.pureWhite.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // BADGES
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CompetitionBadgeRow(
                        rules: comp.rules,
                        eventId: eventId,
                        baseColor: accent,
                      ),
                    ),
                    
                    if (extraBadges != null && extraBadges!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.start,
                          children: extraBadges!,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
