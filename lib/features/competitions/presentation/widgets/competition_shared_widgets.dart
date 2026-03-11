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

    // 5. Build list with separators
    final List<Widget> children = [];
    for (int i = 0; i < pills.length; i++) {
      children.add(pills[i]);
      if (i < pills.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '•',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: AppTypography.sizeLargeBody,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
        );
      }
    }

    return Wrap(
      spacing: 0, // Using manual padding for dots
      runSpacing: 4,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
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

  final VoidCallback? onCustomize;
  final VoidCallback? onRemove;
  final String? customizeLabel;

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
    this.onCustomize,
    this.onRemove,
    this.customizeLabel,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.lime500; 
    final accent = isSecondary ? AppColors.amber500 : primary;
    final isTemplate = comp.id == 'template';
    
    return Material(
      color: Colors.transparent, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            BoxyArtSectionTitle(title: title),
            
          BoxyArtCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x2l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BoxyArtIconBadge(
                              icon: comp.rules.gameIcon,
                              color: accent,
                              size: 56,
                              iconSize: AppShapes.iconXl,
                              showFill: false,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (comp.name ?? 'COMPETITION').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: AppTypography.sizeLargeBody,
                                        fontWeight: AppTypography.weightExtraBold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (isSecondary ? 'Secondary Overlay' : comp.rules.gameName).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: AppTypography.sizeBodySmall,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                        fontWeight: AppTypography.weightBold,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showChevron)
                              Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityMedium), size: AppShapes.iconSm),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.x2l),
                        Divider(color: Theme.of(context).dividerColor, height: 1),
                        const SizedBox(height: AppSpacing.x2l),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isTemplate ? 'Fetching competition specific rules...' : CompetitionRuleTranslator.translate(comp.rules),
                            style: TextStyle(
                              fontSize: AppTypography.sizeButton,
                              height: 1.6,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.85),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
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
                              spacing: 10, runSpacing: 10,
                              alignment: WrapAlignment.start,
                              children: extraBadges!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                if (onCustomize != null || onRemove != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.x2l, right: AppSpacing.x2l, bottom: AppSpacing.x2l),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: AppSpacing.x2l),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            if (onCustomize != null)
                              BoxyArtButton(
                                title: (customizeLabel ?? 'CUSTOMIZE').toUpperCase(),
                                icon: Icons.tune_rounded,
                                onTap: onCustomize!,
                              ),
                            if (onRemove != null)
                              BoxyArtButton(
                                title: "REMOVE",
                                isGhost: true,
                                icon: Icons.delete_outline,
                                textColor: isDark ? AppColors.coral400 : AppColors.coral500,
                                onTap: onRemove!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
