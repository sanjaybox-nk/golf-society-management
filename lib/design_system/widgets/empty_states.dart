import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';

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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Middle Vertically: We wrap in a constrained center container or just rely on Column + Center
          _EmptyStateContent(
            title: title,
            message: message,
            icon: icon,
            isCompact: isCompact,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ],
      ),
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isCompact;

  const _EmptyStateContent({
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark700 : AppColors.actionGreen.withValues(alpha: 0.3),
              borderRadius: AppShapes.md,
              border: Border.all(
                color: isDark ? AppColors.dark600 : AppColors.actionGreen.withValues(alpha: 0.1),
                width: AppShapes.borderThin,
              ),
            ),
            child: Icon(
              icon,
              size: isCompact ? 16 : 24,
              color: isDark ? AppColors.dark400 : AppColors.dark900,
            ),
          ),
          SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
          Text(
            toTitleCase(title),
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(
              fontSize: isCompact ? 18 : 22,
              fontWeight: AppTypography.weightExtraBold,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.dark300 : AppColors.dark900,
              height: 1.5,
              fontWeight: AppTypography.weightMedium,
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
    );
  }
}
