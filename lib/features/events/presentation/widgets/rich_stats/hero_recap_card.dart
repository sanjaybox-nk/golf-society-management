import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';

class SocietyHeroRecapCard extends ConsumerWidget {
  final List<int?> eclecticScores;
  final List<dynamic> holes;
  final int totalPlayers;
  final int totalHolesPlayed;
  final String topHoleName;
  final double topHoleDiff;
  final int totalBirdies;
  final int totalEagles;
  final double fieldAvgNet;

  const SocietyHeroRecapCard({
    super.key,
    required this.eclecticScores,
    required this.holes,
    required this.totalPlayers,
    required this.totalHolesPlayed,
    required this.topHoleName,
    required this.topHoleDiff,
    required this.totalBirdies,
    required this.totalEagles,
    required this.fieldAvgNet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    // Derive eclectic round stats
    int eclecticEagles = 0;
    int eclecticBirdies = 0;
    int eclecticPars = 0;

    for (int i = 0; i < eclecticScores.length; i++) {
      final score = eclecticScores[i];
      if (score == null) continue;
      int par = 4;
      if (i < holes.length) {
        final h = holes[i];
        if (h is Map) {
          par = (h['par'] as num?)?.toInt() ?? 4;
        } else if (h != null) {
          try { par = h.par as int; } catch (_) {}
        }
      }
      final diff = score - par;
      if (diff <= -2) { eclecticEagles++; }
      else if (diff == -1) { eclecticBirdies++; }
      else if (diff == 0) { eclecticPars++; }
    }

    final totalStrokes = eclecticScores.whereType<int>().fold(0, (sum, s) => sum + s);
    final parTotal = holes.fold(0, (sum, h) {
      int p = 4;
      if (h is Map) {
        p = (h['par'] as num?)?.toInt() ?? 4;
      } else if (h != null) {
        try { p = h.par as int; } catch (_) {}
      }
      return sum + p;
    });
    final vsPar = totalStrokes - parTotal;
    final vsParLabel = vsPar == 0 ? 'E' : (vsPar > 0 ? '+$vsPar' : '$vsPar');

    final heroColor = Color(config.heroTextColor);
    final heroStrong = heroColor.withValues(alpha: AppColors.opacityStrong);
    final heroMuted = heroColor.withValues(alpha: AppColors.opacitySecondary);
    final heroBg = heroColor.withValues(alpha: AppColors.opacityLow);
    final heroBorder = heroColor.withValues(alpha: 0.08);

    // Field metrics — exclude birdies (shown in eclectic row), exclude holes count
    final fieldStats = <_HeroStat>[
      _HeroStat(label: 'PLAYERS', value: '$totalPlayers', icon: Icons.people_rounded),
      if (fieldAvgNet != 0.0)
        _HeroStat(label: 'AVG NET', value: fieldAvgNet.toStringAsFixed(1), icon: Icons.analytics_rounded)
      else
        _HeroStat(label: 'FIELD BIRDIES', value: '$totalBirdies', icon: Icons.gps_fixed_rounded),
    ];

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      isHero: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(config.heroGradientColor).withValues(alpha: config.heroGradientOpacity),
          Color(config.heroGradientColorSecondary).withValues(alpha: config.heroGradientOpacity),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing?.cardHorizontalPadding ?? AppSpacing.standard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOCIETY\'S BEST ROUND',
                        style: AppTypography.micro.copyWith(
                          color: heroStrong,
                          fontWeight: AppTypography.weightHeavy,
                          letterSpacing: AppTypography.lsLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.atomic / 2),
                      Text(
                        'FIELD ECLECTIC',
                        style: AppTypography.headline.copyWith(
                          color: heroColor,
                          fontWeight: AppTypography.weightBlack,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Eclectic score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.standard,
                    vertical: AppSpacing.atomic,
                  ),
                  decoration: BoxDecoration(
                    color: heroBg,
                    borderRadius: shapes?.button,
                    border: Border.all(color: heroBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$totalStrokes',
                        style: AppTypography.display.copyWith(
                          color: heroColor,
                          fontWeight: AppTypography.weightBlack,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        vsParLabel,
                        style: AppTypography.micro.copyWith(
                          color: heroStrong,
                          fontWeight: AppTypography.weightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing?.cardVerticalPadding ?? AppSpacing.standard),

            // 2. Eclectic round breakdown — Eagles / Birdies / Pars
            Row(
              children: [
                _buildEclecticStat(context, shapes, 'EAGLES', '$eclecticEagles',
                    Icons.stars_rounded, heroColor, heroStrong, heroMuted,
                    heroBg, heroBorder, dim: eclecticEagles == 0),
                SizedBox(width: spacing?.fieldToField ?? AppSpacing.atomic),
                _buildEclecticStat(context, shapes, 'BIRDIES', '$eclecticBirdies',
                    Icons.gps_fixed_rounded, heroColor, heroStrong, heroMuted,
                    heroBg, heroBorder),
                SizedBox(width: spacing?.fieldToField ?? AppSpacing.atomic),
                _buildEclecticStat(context, shapes, 'PARS', '$eclecticPars',
                    Icons.shield_rounded, heroColor, heroStrong, heroMuted,
                    heroBg, heroBorder),
              ],
            ),

            SizedBox(height: spacing?.cardVerticalPadding ?? AppSpacing.standard),

            // Divider with label
            Row(
              children: [
                Expanded(child: Container(height: 1, color: heroBorder)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'FIELD SUMMARY',
                    style: AppTypography.micro.copyWith(
                      color: heroMuted,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: heroBorder)),
              ],
            ),

            SizedBox(height: spacing?.cardVerticalPadding ?? AppSpacing.standard),

            // 3. Field metrics — 1×2 row
            Row(
              children: [
                _buildStat(context, config, shapes, fieldStats[0], heroColor, heroStrong, heroMuted, heroBg, heroBorder),
                SizedBox(width: spacing?.fieldToField ?? AppSpacing.atomic),
                _buildStat(context, config, shapes, fieldStats[1], heroColor, heroStrong, heroMuted, heroBg, heroBorder),
              ],
            ),

            SizedBox(height: spacing?.cardVerticalPadding ?? AppSpacing.standard),

            // 3. Toughest hole footer pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.standard,
                vertical: AppSpacing.atomic,
              ),
              decoration: BoxDecoration(
                color: heroColor.withValues(alpha: 0.04),
                borderRadius: shapes?.pill,
                border: Border.all(color: heroBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terrain_rounded, size: 13, color: heroMuted),
                  const SizedBox(width: AppSpacing.atomic),
                  Text(
                    'TOUGHEST TEST  ',
                    style: AppTypography.micro.copyWith(
                      color: heroMuted,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                  Text(
                    '$topHoleName (+${topHoleDiff.toStringAsFixed(1)})',
                    style: AppTypography.label.copyWith(
                      color: heroColor,
                      fontWeight: AppTypography.weightHeavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEclecticStat(
    BuildContext context,
    AppShapeTokens? shapes,
    String label,
    String value,
    IconData icon,
    Color heroColor,
    Color heroStrong,
    Color heroMuted,
    Color heroBg,
    Color heroBorder, {
    bool dim = false,
  }) {
    final effectiveColor = dim ? heroMuted : heroColor;
    final effectiveBg = dim ? heroColor.withValues(alpha: 0.03) : heroBg;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.standard,
          horizontal: AppSpacing.atomic,
        ),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: shapes?.button,
          border: Border.all(color: heroBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: dim ? heroMuted : heroStrong),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.headline.copyWith(
                color: effectiveColor,
                fontWeight: AppTypography.weightBlack,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(
                color: dim ? heroMuted : heroStrong,
                fontWeight: AppTypography.weightBold,
                letterSpacing: AppTypography.lsLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    SocietyConfig config,
    AppShapeTokens? shapes,
    _HeroStat stat,
    Color heroColor,
    Color heroStrong,
    Color heroMuted,
    Color heroBg,
    Color heroBorder,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.standard,
          horizontal: AppSpacing.atomic,
        ),
        decoration: BoxDecoration(
          color: heroBg,
          borderRadius: shapes?.button,
          border: Border.all(color: heroBorder),
        ),
        child: Column(
          children: [
            Icon(stat.icon, size: 14, color: heroMuted),
            const SizedBox(height: AppSpacing.atomic / 2),
            Text(
              stat.value,
              style: AppTypography.headline.copyWith(
                color: heroColor,
                fontWeight: AppTypography.weightBlack,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(
                color: heroStrong,
                fontWeight: AppTypography.weightBold,
                letterSpacing: AppTypography.lsLabel,
                fontSize: AppTypography.sizeMicro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat {
  final String label;
  final String value;
  final IconData icon;
  const _HeroStat({required this.label, required this.value, required this.icon});
}
