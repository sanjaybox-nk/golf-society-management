import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

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
    int eaglesCount = 0;
    int birdiesCount = 0;
    int parsCount = 0;

    for (int i = 0; i < eclecticScores.length; i++) {
      final score = eclecticScores[i];
      if (score == null) continue;
      final par = (holes[i] is Map ? (holes[i]['par'] as int? ?? 4) : holes[i].par) as int;

      final diff = score - par;
      if (diff <= -2) {
        eaglesCount++;
      } else if (diff == -1) {
        birdiesCount++;
      } else if (diff == 0) {
        parsCount++;
      }
    }

    final totalStrokes = eclecticScores.whereType<int>().fold(0, (sum, s) => sum + s);
    final parTotal = holes.fold(0, (sum, h) => sum + ((h is Map ? (h['par'] as int? ?? 4) : h.par) as int));
    final vsPar = totalStrokes - parTotal;

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      isHero: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(config.heroGradientColor).withValues(alpha: 0.15),
          Color(config.heroGradientColor).withValues(alpha: 0.02),
        ],
      ),
      child: Column(
        children: [
          // 1. Premium 4.x Amber Header (Achievement Focus)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2l, horizontal: AppSpacing.x2l),
            width: double.infinity,
            decoration: const BoxDecoration(
              // Background is now handled by the card's gradient for a smoother "graduated" feel
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.rLg)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOCIETY\'S BEST ROUND',
                      style: AppTypography.label.copyWith(
                        color: AppColors.amber500,
                        fontWeight: AppTypography.weightHeavy,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FIELD ECLECTIC',
                      style: AppTypography.displaySubPage.copyWith(
                        color: AppColors.dark900,
                        fontWeight: AppTypography.weightBlack,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.amber500.withValues(alpha: 0.1),
                    borderRadius: AppShapes.lg,
                  ),
                  child: Column(
                    children: [
                      Text(
                        totalStrokes.toString(),
                        style: AppTypography.displayHeading.copyWith(
                          fontSize: 24,
                          color: AppColors.amber500,
                          fontWeight: AppTypography.weightBlack,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        vsPar == 0 ? 'PAR' : (vsPar > 0 ? '+$vsPar' : '$vsPar'),
                        style: AppTypography.micro.copyWith(
                          fontWeight: AppTypography.weightBold,
                          color: AppColors.amber500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Content Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Column(
              children: [
                // a. Eclectic Highlights
                Row(
                  children: [
                    _buildCompactStat(context, 'EAGLES', eaglesCount.toString(), Icons.stars_rounded, AppColors.amber500),
                    const SizedBox(width: AppSpacing.md),
                    _buildCompactStat(context, 'BIRDIES', birdiesCount.toString(), Icons.gps_fixed, Colors.blueGrey),
                    const SizedBox(width: AppSpacing.md),
                    _buildCompactStat(context, 'PARS', parsCount.toString(), Icons.shield_rounded, AppColors.lime500),
                  ],
                ),

                const SizedBox(height: AppSpacing.x2l),
                
                // b. Subtle Divider with Section Title
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'EVENT RECAP'.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                          fontWeight: AppTypography.weightExtraBold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05))),
                  ],
                ),

                const SizedBox(height: AppSpacing.x2l),

                // c. Recap Metrics (2x2 Grid)
                Row(
                  children: [
                    Expanded(child: _buildRecapStat(context, 'PLAYERS', totalPlayers.toString())),
                    Expanded(child: _buildRecapStat(context, 'HOLES', totalHolesPlayed.toString())),
                  ],
                ),
                const SizedBox(height: AppSpacing.x2l),
                Row(
                  children: [
                    Expanded(child: _buildRecapStat(context, 'BIRDIES', totalBirdies.toString())),
                    Expanded(child: _buildRecapStat(context, 'AVG NET', fieldAvgNet.toStringAsFixed(1))),
                  ],
                ),

                const SizedBox(height: AppSpacing.x2l),

                // d. Toughest Test Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: AppShapes.pill,
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TOUGHEST TEST: '.toUpperCase(),
                        style: AppTypography.micro.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
                          fontWeight: AppTypography.weightBold,
                        ),
                      ),
                      Text(
                        '$topHoleName (+${topHoleDiff.toStringAsFixed(1)})',
                        style: AppTypography.label.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: AppTypography.weightHeavy,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
          borderRadius: AppShapes.lg,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.8), size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.headline.copyWith(
                fontWeight: AppTypography.weightBlack,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: AppTypography.micro.copyWith(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.displaySubPage.copyWith(
            fontSize: 28,
            fontWeight: AppTypography.weightHeavy,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: AppColors.opacityStrong),
            fontWeight: AppTypography.weightExtraBold,
            letterSpacing: 1.0,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
