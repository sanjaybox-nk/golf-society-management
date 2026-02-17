import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/models/leaderboard_config.dart';

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
      title: (isTemplate || isPicker) ? 'Select Type' : 'New Template',
      subtitle: 'Leaderboard Formats',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'STANDARD FORMATS',
                padding: EdgeInsets.only(bottom: 16),
              ),
              _TypeTile(
                title: 'Order of Merit',
                subtitle: 'Accumulate points from all rounds.',
                icon: Icons.emoji_events_rounded,
                color: Colors.amber,
                onTap: () => _navigateToBuilder(context, LeaderboardType.orderOfMerit),
              ),
              const SizedBox(height: 16),
              _TypeTile(
                title: 'Best of Series',
                subtitle: 'Count top N scores (e.g. Best 8 of 10).',
                icon: Icons.list_alt_rounded,
                color: Colors.blue,
                onTap: () => _navigateToBuilder(context, LeaderboardType.bestOfSeries),
              ),
              const SizedBox(height: 16),
              _TypeTile(
                title: 'Eclectic',
                subtitle: 'Best score per hole across season.',
                icon: Icons.grid_on_rounded,
                color: Colors.purple,
                onTap: () => _navigateToBuilder(context, LeaderboardType.eclectic),
              ),
              const SizedBox(height: 16),
              _TypeTile(
                title: 'Birdie Tree',
                subtitle: 'Track Birdies, Eagles, or Pars.',
                icon: Icons.park_rounded,
                color: Colors.green,
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
       ? '/admin/seasons/leaderboards/create/$typeName/gallery' 
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
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}
