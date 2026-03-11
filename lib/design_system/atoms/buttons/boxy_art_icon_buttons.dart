import 'package:golf_society/design_system/design_system.dart';


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
    this.iconSize = 24,
    this.padding = 6,
    this.showShadow = false,
    this.shadowOverride,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.pill,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? AppColors.dark800 : AppColors.dark50),
          shape: BoxShape.circle,
          boxShadow: showShadow ? (shadowOverride ?? Theme.of(context).extension<AppShadows>()?.floatingAlt ?? []) : null,
          border: Border.all(
            color: isDark ? AppColors.dark700 : AppColors.dark200,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon, 
          color: iconColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900), 
          size: iconSize,
        ),
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
    
    // Design 3.1: No opacity, no shadows. Solid premium look.
    final defaultIconColor = widget.iconColor ?? (isDark ? AppColors.pureWhite : AppColors.dark900);
    final defaultBgColor = widget.backgroundColor ?? (isDark 
        ? AppColors.dark800 
        : AppColors.dark50);
    
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
                  ? AppColors.dark700 
                  : AppColors.dark200,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: defaultIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
