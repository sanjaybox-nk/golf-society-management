import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_shadows.dart';
import '../theme/contrast_helper.dart';

/// A standard BoxyArt themed button.
///
/// Variants:
/// - [isPrimary] (default): Yellow background, black text. Main actions.
/// - [isSecondary]: White background, black text. Supporting actions.
/// - [isGhost]: Transparent background, grey text. Cancel/Delete actions.
class BoxyArtButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isSecondary;
  final bool isGhost;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

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
  });

  @override
  Widget build(BuildContext context) {
    // Default Primary
    Color bgColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).colorScheme.onPrimary;
    
    // Shadows rely on context too if we want dynamic shadow colors
    List<BoxShadow>? shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ];

    if (isSecondary) {
      bgColor = Colors.grey.shade800;
      textColor = Colors.white;
      shadows = AppShadows.inputSoft;
    } else if (isGhost) {
      bgColor = Colors.transparent;
      textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
      shadows = null;
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: shadows,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      borderRadius: BorderRadius.circular(100),
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
      child: Icon(icon, color: iconColor, size: 14),
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
    final primaryColor = Theme.of(context).primaryColor;
    final defaultIconColor = widget.iconColor ?? primaryColor;
    final defaultBgColor = widget.backgroundColor ?? primaryColor.withValues(alpha: 0.1);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: defaultBgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: defaultIconColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
            boxShadow: [
              // Base Soft Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.03),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              // Sharp Close Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
