import 'package:golf_society/design_system/design_system.dart';

class AppGradients {
  /// The primary brand gradient combining primary and secondary colors.
  static LinearGradient brandPrimary(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
      ],
    );
  }

  /// A decorative vertical gradient used for stat bars or cards.
  static LinearGradient verticalSurface(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withValues(alpha: AppColors.opacityMuted),
      ],
    );
  }

  /// A standard dark-to-transparent scrim for overlaying text on images/media.
  static LinearGradient scrim() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: AppColors.opacityHalf),
      ],
    );
  }
}
