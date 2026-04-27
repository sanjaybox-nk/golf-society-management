import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/features/competitions/presentation/standings/standings_providers.dart';

class LeaderboardTemplateSelector extends ConsumerWidget {
  final Function(LeaderboardConfig) onSelected;

  const LeaderboardTemplateSelector({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(leaderboardTemplatesProvider);

    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Template',
                  style: AppTypography.displaySection.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          Flexible(
            child: templatesAsync.when(
              data: (templates) {
                if (templates.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.x3l),
                    child: Center(
                      child: Text('No global templates defined yet.'),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _TemplateTile(
                      template: template,
                      onTap: () {
                        onSelected(template);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
                  child: Text('Error loading templates: $err'),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final LeaderboardConfig template;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final typeIcon = template.map(
      orderOfMerit: (_) => Icons.format_list_numbered_rounded,
      bestOfSeries: (_) => Icons.stars_rounded,
      eclectic: (_) => Icons.grid_on_rounded,
      markerCounter: (_) => Icons.emoji_events_rounded,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.dark600 : AppColors.lightHeader,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: isDark ? AppColors.dark500 : AppColors.dark100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: typeIcon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: AppTypography.cardTitle,
                  ),
                  Text(
                    _getFormatLabel(template),
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatLabel(LeaderboardConfig config) {
    return config.map(
      orderOfMerit: (o) => 'Order of Merit - ${o.rankingBasis.name.toUpperCase()}',
      bestOfSeries: (b) => 'Best of ${b.bestN} Rounds',
      eclectic: (e) => 'Eclectic - ${e.metric.name.toUpperCase()}',
      markerCounter: (m) => '${m.targetTypes.length} Target Markers',
    );
  }
}
