import "package:golf_society/design_system/design_system.dart";



import 'dart:ui';

/// A small circular button with an icon using BoxyArt styling.
class BoxyArtCircularIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final double padding;
  final bool showShadow;
  final List<BoxShadow>? shadowOverride;

  const BoxyArtCircularIconBtn({
    super.key, 
    required this.icon, 
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 20,
    this.padding = 0,
    this.showShadow = true,
    this.shadowOverride,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.pill,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: showShadow ? (shadowOverride ?? AppShadows.floatingAlt) : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor ?? Colors.black, size: iconSize),
      ),
    );
  }
}

/// A themed dot/circle icon wrapper, used in search bars filters.
class BoxyArtThemedCircleIcon extends StatelessWidget {
  final IconData icon;
  const BoxyArtThemedCircleIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).primaryColor;
    final iconColor = ContrastHelper.getContrastingText(backgroundColor);
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: AppShapes.iconXs),
    );
  }
}

/// Glassmorphic circular icon button with blur effect and high-fidelity shadows.
class BoxyArtGlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;

  const BoxyArtGlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 20,
  });

  @override
  State<BoxyArtGlassIconButton> createState() => _BoxyArtGlassIconButtonState();
}

class _BoxyArtGlassIconButtonState extends State<BoxyArtGlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    
    // In dark mode, favor white/light glass over dark primary tints
    final defaultIconColor = widget.iconColor ?? (isDark ? AppColors.pureWhite : primaryColor);
    final defaultBgColor = widget.backgroundColor ?? (isDark 
        ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
        : primaryColor.withValues(alpha: 0.12));
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppAnimations.fast,
        child: Container(
          width: AppSpacing.x4l,
          height: AppSpacing.x4l,
          decoration: BoxDecoration(
            color: defaultBgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark 
                  ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow) 
                  : primaryColor.withValues(alpha: AppColors.opacityMedium),
              width: 0.8,
            ),
            boxShadow: [
              if (!isDark) // Soft shadows only in light mode for glass
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppColors.opacitySubtle),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: defaultIconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
