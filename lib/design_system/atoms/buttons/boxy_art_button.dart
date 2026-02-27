import "package:golf_society/design_system/design_system.dart";




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
    // Default Colors based on standard variants
    Color derivedBgColor;
    Color derivedTextColor;
    List<BoxShadow>? shadows;

    if (isSecondary) {
      derivedBgColor = Colors.grey.shade800;
      derivedTextColor = Colors.white;
      shadows = AppShadows.inputSoft;
    } else if (isGhost) {
      derivedBgColor = Colors.transparent;
      derivedTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
      shadows = null;
    } else {
      // Primary (default)
      derivedBgColor = Theme.of(context).primaryColor;
      derivedTextColor = Theme.of(context).colorScheme.onPrimary;
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];
    }

    // Direct overrides take precedence
    final finalBgColor = backgroundColor ?? derivedBgColor;
    final finalTextColor = textColor ?? derivedTextColor;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: finalBgColor,
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
                  valueColor: AlwaysStoppedAnimation<Color>(finalTextColor),
                ),
              ),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, color: finalTextColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: finalTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
