import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_shadows.dart';

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
    Color bgColor = AppTheme.primaryYellow; // Default Primary
    Color textColor = Colors.black;
    List<BoxShadow>? shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ];

    if (isSecondary) {
      bgColor = Colors.white;
      textColor = Colors.black;
      shadows = AppShadows.inputSoft;
    } else if (isGhost) {
      bgColor = Colors.transparent;
      textColor = Colors.grey.shade600;
      shadows = null;
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        alignment: Alignment.center,
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

  const BoxyArtCircularIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.floatingAlt,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.black, size: 20),
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
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 14),
    );
  }
}
