import 'package:golf_society/design_system/design_system.dart';

/// A standardized empty state widget for the Boxy Art design system.
class BoxyArtEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isCompact;

  const BoxyArtEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.dark700 : AppColors.dark50.withValues(alpha: AppColors.opacityHalf),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.dark600 : AppColors.dark100,
                  width: AppShapes.borderThin,
                ),
              ),
              child: Icon(
                icon,
                size: isCompact ? 32 : 48,
                color: isDark ? AppColors.dark400 : AppColors.dark300,
              ),
            ),
            SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium.copyWith(
                fontSize: isCompact ? 18 : 22,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.dark300 : AppColors.dark400,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              BoxyArtButton(
                title: actionLabel!,
                onTap: onAction!,
                isSecondary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
