import 'package:golf_society/design_system/design_system.dart';

class BoxyArtStatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final bool hasBottomMargin;

  const BoxyArtStatusBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.message,
    this.hasBottomMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: hasBottomMargin
          ? EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard)
          : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.standard, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityLow),
        borderRadius: shapes?.card ?? AppShapes.md,
        border: Border.all(
            color: color.withValues(alpha: AppColors.opacitySubtle),
            width: AppShapes.borderThin),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppShapes.iconSmall),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
