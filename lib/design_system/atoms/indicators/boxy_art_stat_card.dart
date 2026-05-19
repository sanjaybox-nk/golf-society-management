import 'package:golf_society/design_system/design_system.dart';

/// A KPI stat card — icon, large value, sub-label, and colored category label.
/// Designed to sit in a Row of 3 across a dashboard pulse strip.
class BoxyArtStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String sub;
  final String label;
  final Color color;

  const BoxyArtStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.sub,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row — context first
            Row(
              children: [
                Icon(icon, size: AppShapes.iconXs, color: color),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTypography.micro.copyWith(
                      color: color,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Value
            Text(
              value,
              style: AppTypography.displaySection.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: AppTypography.weightHeavy,
              ),
            ),
            // Sub-label
            Text(
              sub,
              style: AppTypography.micro.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
