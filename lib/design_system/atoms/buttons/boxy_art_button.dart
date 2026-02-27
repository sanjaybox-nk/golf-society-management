import "package:golf_society/design_system/design_system.dart";

/// A standard BoxyArt themed button updated for Fairway v3.1.
class BoxyArtButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isSecondary;
  final bool isGhost;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const BoxyArtButton({
    super.key,
    required this.title,
    this.onTap,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isGhost = false,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Map legacy variants to new v3.1 styles
    ButtonStyle style;
    
    if (isGhost) {
      style = TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.dark200 : AppColors.dark300,
        textStyle: AppTypography.label,
        shape: AppShapes.pillShape,
      );
    } else if (isSecondary) {
      style = OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.dark60 : const Color(0xFF1A1A1A),
        side: BorderSide(
          color: isDark ? AppColors.dark500 : AppColors.lightBorder,
          width: 1.5,
        ),
        textStyle: AppTypography.label,
        shape: AppShapes.pillShape,
      );
    } else {
      // Primary
      style = ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.lime500 : AppColors.lime700,
        foregroundColor: isDark ? AppColors.actionText : AppColors.pureWhite,
        textStyle: AppTypography.label,
        shape: AppShapes.pillShape,
        elevation: 0,
      );
    }

    // Apply manual overrides if provided
    if (backgroundColor != null || textColor != null) {
      style = style.copyWith(
        backgroundColor: backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
        foregroundColor: textColor != null ? WidgetStateProperty.all(textColor) : null,
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: isGhost 
        ? TextButton(
            onPressed: isLoading ? null : onTap,
            style: style,
            child: _buildContent(style.foregroundColor?.resolve({}) ?? Colors.grey),
          )
        : isSecondary
            ? OutlinedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: _buildContent(style.foregroundColor?.resolve({}) ?? Colors.black),
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: _buildContent(style.foregroundColor?.resolve({}) ?? Colors.white),
              ),
    );
  }

  Widget _buildContent(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          title, // Removed uppercase here as the label style might handle it or it might be explicit
          style: AppTypography.label.copyWith(color: color),
        ),
      ],
    );
  }
}
