import "package:golf_society/design_system/design_system.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A standard BoxyArt themed button updated for Fairway v3.1.
class BoxyArtButton extends ConsumerWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isSecondary;
  final bool isTertiary;
  final bool isGhost;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool isSmall;
  final double? verticalPadding;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDangerous;
  final bool isTinted;
  final VoidCallback? onLongPress;

  const BoxyArtButton({
    super.key,
    required this.title,
    this.onTap,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isTertiary = false,
    this.isGhost = false,
    this.isSmall = false,
    this.isTinted = false,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.verticalPadding,
    this.backgroundColor,
    this.textColor,
    this.isDangerous = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = ref.watch(themeControllerProvider);

    // Tinted variant: primary-coloured soft fill, primary text.
    // Fill opacity is structural (0.15) — same constant BoxyArtIconBadge uses for explicit-colour tints.
    // The colour itself is controlled via the society's primary colour in Design Lab.
    if (isTinted) {
      final primary = theme.colorScheme.primary;
      final fill = primary.withValues(alpha: 0.15);
      final tintedStyle = ElevatedButton.styleFrom(
        backgroundColor: fill,
        foregroundColor: primary,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: isSmall
            ? AppTypography.label.copyWith(fontWeight: AppTypography.weightBold)
            : AppTypography.body.copyWith(fontWeight: AppTypography.weightBold),
        padding: EdgeInsets.symmetric(
            horizontal: config.buttonHorizontalPadding,
            vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              isSmall ? config.accentRadius : config.buttonRadius),
          side: config.useBorders
              ? BorderSide(
                  color: primary.withValues(alpha: AppColors.opacitySubtle),
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        disabledBackgroundColor: fill,
        disabledForegroundColor: primary.withValues(alpha: AppColors.opacitySecondary),
      );
      final tintedButton = SizedBox(
        width: fullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: tintedStyle,
          child: _buildContent(primary),
        ),
      );
      if (onLongPress != null) {
        return GestureDetector(onLongPress: onLongPress, child: tintedButton);
      }
      return tintedButton;
    }

    // Map legacy variants to new v3.1 styles
    ButtonStyle style;

    if (isDangerous) {
      style = ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        elevation: 0,
        textStyle: isSmall ? AppTypography.micro.copyWith(fontWeight: AppTypography.weightBold) : AppTypography.label.copyWith(fontWeight: AppTypography.weightBold),
        padding: EdgeInsets.symmetric(horizontal: config.buttonHorizontalPadding, vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmall ? config.accentRadius : config.buttonRadius)),
      );
    } else if (isGhost) {
      style = OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.dark200 : AppColors.dark300,
        side: config.useBorders 
            ? BorderSide(
                color: isDark ? AppColors.dark500 : AppColors.lightBorder,
                width: 1.0,
              )
            : BorderSide.none,
        textStyle: isSmall ? AppTypography.micro : AppTypography.label,
        padding: EdgeInsets.symmetric(horizontal: config.buttonHorizontalPadding, vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmall ? config.accentRadius : config.buttonRadius)),
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
        textStyle: isSmall ? AppTypography.micro : AppTypography.label,
        padding: EdgeInsets.symmetric(horizontal: config.buttonHorizontalPadding, vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmall ? config.accentRadius : config.buttonRadius)),
      );
    } else if (isTertiary) {
      // Solid Branding Foundation (Slate)
      final actionColor = theme.colorScheme.tertiary;
      final foregroundColor = theme.colorScheme.onTertiary;
      
      style = ElevatedButton.styleFrom(
        backgroundColor: actionColor,
        foregroundColor: foregroundColor,
        textStyle: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold),
        padding: EdgeInsets.symmetric(horizontal: config.buttonHorizontalPadding, vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmall ? config.accentRadius : config.buttonRadius),
          side: config.useBorders 
              ? BorderSide(
                  color: isDark ? AppColors.dark400 : AppColors.lightBorder,
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        elevation: config.useShadows ? (isSmall ? 1 : 2) : 0,
        shadowColor: isDark ? Colors.black : Colors.black.withValues(alpha: 0.1),
      );
    } else {
      // Solid Action - map to theme primary color (Lime)
      final actionColor = backgroundColor ?? theme.colorScheme.primary;
      final foregroundColor = textColor ?? theme.colorScheme.onPrimary;
      
      style = ElevatedButton.styleFrom(
        backgroundColor: actionColor,
        foregroundColor: foregroundColor,
        textStyle: AppTypography.label.copyWith(fontWeight: AppTypography.weightBold),
        padding: EdgeInsets.symmetric(horizontal: config.buttonHorizontalPadding, vertical: verticalPadding ?? (isSmall ? 6 : 11)),
        minimumSize: Size(0, isSmall ? config.buttonSmallHeight : config.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmall ? config.accentRadius : config.buttonRadius),
          side: config.useBorders 
              ? BorderSide(
                  color: isDark ? AppColors.dark400 : AppColors.lightBorder,
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        elevation: config.useShadows ? (isSmall ? 1 : 2) : 0,
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

    final button = SizedBox(
      width: fullWidth ? double.infinity : null,
      child: (isGhost || isSecondary)
            ? OutlinedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: _buildContent(style.foregroundColor?.resolve({}) ?? (isGhost ? AppColors.textSecondary : Colors.black)),
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: style,
                child: _buildContent(style.foregroundColor?.resolve({}) ?? AppColors.pureWhite),
              ),
    );

    if (onLongPress != null) {
      return GestureDetector(onLongPress: onLongPress, child: button);
    }
    return button;
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
          Icon(icon, color: color, size: isSmall ? AppShapes.iconXs : AppShapes.iconSm),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: (isSmall ? AppTypography.label : AppTypography.body).copyWith(
              color: color,
              fontWeight: AppTypography.weightBold,
              fontSize: isSmall ? 13 : 16,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}
