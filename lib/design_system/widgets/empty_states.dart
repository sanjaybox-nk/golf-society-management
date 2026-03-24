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
    final shapeTokens = theme.extension<AppShapeTokens>();
    final accentRadius = shapeTokens?.accent ?? BorderRadius.circular(12);
    final accentOpacity = shapeTokens?.accentOpacity ?? 0.15;

    return Padding(
      padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: accentOpacity),
              borderRadius: accentRadius,
            ),
            child: Icon(
              icon,
              size: isCompact ? 16 : 24,
              color: AppColors.dark900,
            ),
          ),
          SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
          Text(
            toTitleCase(title),
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              fontSize: isCompact ? 18 : 22,
              fontWeight: AppTypography.weightExtraBold,
              letterSpacing: AppTypography.lsTight,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
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
