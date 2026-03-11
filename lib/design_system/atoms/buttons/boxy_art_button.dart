import "package:golf_society/design_system/design_system.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A standard BoxyArt themed button updated for Fairway v3.1.
class BoxyArtButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = ref.watch(themeControllerProvider);

    // Map legacy variants to new v3.1 styles
    ButtonStyle style;
    
    if (isGhost) {
      style = TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.dark200 : AppColors.dark300,
        textStyle: AppTypography.label,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.buttonRadius)),
      );
    } else if (isSecondary) {
      style = OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.dark60 : const Color(0xFF1A1A1A),
        side: config.useBorders 
            ? BorderSide(
                color: isDark ? AppColors.dark500 : AppColors.lightBorder,
                width: config.borderWidth,
              )
            : BorderSide.none,
        textStyle: AppTypography.label,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(config.buttonRadius)),
      );
    } else {
      // Solid Action - map explicitly to User-Defined Action Color (#86AD92)
      final actionColor = backgroundColor ?? AppColors.actionGreen;
      style = ElevatedButton.styleFrom(
        backgroundColor: actionColor,
        foregroundColor: textColor ?? Colors.white,
        textStyle: AppTypography.label.copyWith(fontWeight: AppTypography.weightExtraBold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonRadius),
          side: config.useBorders 
              ? BorderSide(
                  color: isDark ? AppColors.dark400 : AppColors.lightBorder,
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        elevation: config.useShadows ? 2 : 0,
        shadowColor: isDark ? Colors.black : Colors.black.withValues(alpha: 0.15),
        // Ensure no default opacity on disabled state - Solid Action
        disabledBackgroundColor: actionColor,
        disabledForegroundColor: textColor ?? ContrastHelper.getContrastingText(actionColor),
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
            child: _buildContent(style.foregroundColor?.resolve({}) ?? AppColors.textSecondary),
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
                child: _buildContent(style.foregroundColor?.resolve({}) ?? AppColors.pureWhite),
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
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, color: color, size: AppShapes.iconSm),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          title, // Removed uppercase here as the label style might handle it or it might be explicit
          style: AppTypography.label.copyWith(
            color: color,
            fontSize: 14.5,
            fontWeight: AppTypography.weightExtraBold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
