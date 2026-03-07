import 'package:golf_society/design_system/design_system.dart';

class AppGradients {
  static LinearGradient primary(BuildContext context) {
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
