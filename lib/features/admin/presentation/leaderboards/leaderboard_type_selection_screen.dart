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
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Leaderboard Control',
      subtitle: 'Manage standing blueprints by format',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.x4l, // Design 4.x: Standardized bottom breathing room
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'STANDARD FORMATS',
                isPeeking: true,
              ),
              StaggeredEntrance(
                index: 0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
                  child: _TypeTile(
                    title: 'Order of Merit',
                    name: 'Order of Merit',
                    subtitle: 'Accumulate points from all rounds.',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.amber500,
                    onTap: () => _navigateToBuilder(context, LeaderboardType.orderOfMerit),
                  ),
                ),
              ),
              StaggeredEntrance(
                index: 1,
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
                  child: _TypeTile(
                    title: 'Best of Series',
                    name: 'Best of Series',
                    subtitle: 'Count top N scores (e.g. Best 8 of 10).',
                    icon: Icons.list_alt_rounded,
                    color: AppColors.teamA,
                    onTap: () => _navigateToBuilder(context, LeaderboardType.bestOfSeries),
                  ),
                ),
              ),
              StaggeredEntrance(
                index: 2,
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
                  child: _TypeTile(
                    title: 'Eclectic',
                    name: 'Eclectic',
                    subtitle: 'Best score per hole across season.',
                    icon: Icons.grid_on_rounded,
                    color: AppColors.teamB,
                    onTap: () => _navigateToBuilder(context, LeaderboardType.eclectic),
                  ),
                ),
              ),
              StaggeredEntrance(
                index: 3,
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
                  child: _TypeTile(
                    title: 'Birdie Tree',
                    name: 'Birdie Tree',
                    subtitle: 'Track Birdies, Eagles, or Pars.',
                    icon: Icons.park_rounded,
                    color: AppColors.lime500,
                    onTap: () => _navigateToBuilder(context, LeaderboardType.markerCounter),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _navigateToBuilder(BuildContext context, LeaderboardType type) async {
    final typeName = type.name;
    final path = isPicker 
       ? '/admin/leaderboards/create/picker/gallery/$typeName' 
       : '/admin/settings/leaderboards/gallery/$typeName';

    final result = await context.push<LeaderboardConfig>(path);
    
    if (isPicker && result != null && context.mounted) {
      context.pop(result);
    }
  }
}

class _TypeTile extends StatelessWidget {
  final String title;
  final String name; 
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({
    required this.title,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          // Design 4.x: Square 44px Icon Badge
          BoxyArtIconBadge(
            icon: icon,
            color: color,
            isTinted: true,
            size: 44,
            iconSize: 22,
            useCircle: false, // Standard for admin selection tiles
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelStrong.copyWith(
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded, 
            color: isDark ? AppColors.dark400 : AppColors.dark200, 
            size: AppShapes.iconXs,
          ),
        ],
      ),
    );
  }
}
