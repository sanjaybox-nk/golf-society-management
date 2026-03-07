import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';

class LeaderboardTypeSelectionScreen extends StatelessWidget {
  final bool isTemplate;
  final bool isPicker;

  const LeaderboardTypeSelectionScreen({
    super.key,
    this.isTemplate = false,
    this.isPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    return HeadlessScaffold(
      title: 'Leaderboard Formats',
      subtitle: (isTemplate || isPicker) ? 'Select a type to continue' : 'Standard Season Formats',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'STANDARD FORMATS',),
              _TypeTile(
                title: 'Order of Merit',
                subtitle: 'Accumulate points from all rounds.',
                icon: Icons.emoji_events_rounded,
                color: AppColors.amber500,
                onTap: () => _navigateToBuilder(context, LeaderboardType.orderOfMerit),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TypeTile(
                title: 'Best of Series',
                subtitle: 'Count top N scores (e.g. Best 8 of 10).',
                icon: Icons.list_alt_rounded,
                color: AppColors.teamA,
                onTap: () => _navigateToBuilder(context, LeaderboardType.bestOfSeries),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TypeTile(
                title: 'Eclectic',
                subtitle: 'Best score per hole across season.',
                icon: Icons.grid_on_rounded,
                color: AppColors.teamB,
                onTap: () => _navigateToBuilder(context, LeaderboardType.eclectic),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TypeTile(
                title: 'Birdie Tree',
                subtitle: 'Track Birdies, Eagles, or Pars.',
                icon: Icons.park_rounded,
                color: AppColors.lime500,
                onTap: () => _navigateToBuilder(context, LeaderboardType.markerCounter),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  void _navigateToBuilder(BuildContext context, LeaderboardType type) async {
    final typeName = type.name;
    final path = isPicker 
       ? '/admin/settings/leaderboards/create/picker/gallery/$typeName' 
       : '/admin/settings/leaderboards/gallery/$typeName';

    final result = await context.push<LeaderboardConfig>(path);
    
    if (isPicker && result != null && context.mounted) {
      context.pop(result);
    }
  }
}

class _TypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppColors.opacityLow),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppShapes.iconLg),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: AppTypography.weightExtraBold,
                    color: isDark ? AppColors.pureWhite : AppColors.dark900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                    fontSize: AppTypography.sizeLabel,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded, 
            color: isDark ? AppColors.dark300 : AppColors.dark400,
            size: AppShapes.iconMd,
          ),
        ],
      ),
    );
  }
}
