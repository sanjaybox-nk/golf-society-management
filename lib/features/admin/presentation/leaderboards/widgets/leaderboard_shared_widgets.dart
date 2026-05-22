import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../utils/leaderboard_rule_translator.dart';

class LeaderboardBadgeRow extends StatelessWidget {
  final LeaderboardConfig config;
  final Color? baseColor;

  const LeaderboardBadgeRow({
    super.key,
    required this.config,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pills = [];

    // 1. Basis Pill (Points, Stableford, etc.)
    pills.add(
      BoxyArtPill.format(
        label: LeaderboardRuleTranslator.getBasisLabel(config),
        icon: Icons.calculate_rounded,
        isLegend: true,
      ),
    );

    // 2. Best N Pill
    final bestN = config.map(
      orderOfMerit: (c) => c.bestN,
      bestOfSeries: (c) => c.bestN,
      eclectic: (c) => 0,
      markerCounter: (c) => c.bestN,
    );
    if (bestN > 0) {
      pills.add(
        BoxyArtPill.format(
          label: 'Best $bestN',
          icon: Icons.filter_list_rounded,
          isLegend: true,
        ),
      );
    } else if (config is! EclecticConfig) {
      pills.add(
        BoxyArtPill.format(
          label: 'All Rounds',
          icon: Icons.all_inclusive_rounded,
          isLegend: true,
        ),
      );
    }

    // 3. Eclectic specific
    if (config is EclecticConfig) {
      final c = config as EclecticConfig;
      if (c.handicapPercentage > 0) {
        pills.add(
          BoxyArtPill.format(
            label: '${c.handicapPercentage}% Hcp',
            icon: Icons.percent_rounded,
            isLegend: true,
          ),
        );
      } else {
        pills.add(
          BoxyArtPill.format(
            label: 'Scratch',
            icon: Icons.shutter_speed_rounded,
            isLegend: true,
          ),
        );
      }
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: pills,
    );
  }
}

class LeaderboardRulesCard extends StatelessWidget {
  final LeaderboardConfig config;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool isSecondary;

  const LeaderboardRulesCard({
    super.key,
    required this.config,
    this.onTap,
    this.showChevron = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shapes = theme.extension<AppShapeTokens>();

    final type = config.map(
      orderOfMerit: (_) => LeaderboardType.orderOfMerit,
      bestOfSeries: (_) => LeaderboardType.bestOfSeries,
      eclectic: (_) => LeaderboardType.eclectic,
      markerCounter: (_) => LeaderboardType.markerCounter,
    );

    final color = _getFormatColor(type);

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BoxyArtIconBadge(
                  icon: _getFormatIcon(type),
                  color: color,
                  isTinted: true,
                  size: shapes?.iconBadgeSize ?? AppShapes.iconHero,
                  iconSize: shapes?.iconBadgeIconSize ?? AppShapes.iconLg,
                ),
                const SizedBox(width: AppSpacing.standard),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.name.toUpperCase(),
                        style: AppTypography.labelStrong.copyWith(
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _getFormatDisplayName(type).toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          color: isDark ? AppColors.dark200 : AppColors.dark400,
                          fontWeight: AppTypography.weightBold,
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.dark400,
                    size: AppShapes.iconSm,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.standard),
            const BoxyArtDivider(verticalPadding: 0),
            const SizedBox(height: AppSpacing.standard),

            Text(
              LeaderboardRuleTranslator.translate(config),
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.dark200 : AppColors.dark400,
              ),
            ),

            const SizedBox(height: AppSpacing.standard),

            LeaderboardBadgeRow(
              config: config,
              baseColor: color,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatDisplayName(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return 'Order of Merit';
      case LeaderboardType.bestOfSeries: return 'Best of Series';
      case LeaderboardType.eclectic: return 'Eclectic';
      case LeaderboardType.markerCounter: return 'Birdie Tree';
    }
  }

  IconData _getFormatIcon(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return Icons.emoji_events_rounded;
      case LeaderboardType.bestOfSeries: return Icons.list_alt_rounded;
      case LeaderboardType.eclectic: return Icons.grid_on_rounded;
      case LeaderboardType.markerCounter: return Icons.park_rounded;
    }
  }

  Color _getFormatColor(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return AppColors.amber500;
      case LeaderboardType.bestOfSeries: return AppColors.teamA;
      case LeaderboardType.eclectic: return AppColors.teamB;
      case LeaderboardType.markerCounter: return AppColors.lime500;
    }
  }
}
