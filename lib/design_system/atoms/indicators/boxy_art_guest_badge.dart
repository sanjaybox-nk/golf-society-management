import 'package:golf_society/design_system/design_system.dart';

/// Tinted purple circle badge identifying a guest player.
/// Consistent across grouping, scoring, and admin views.
class BoxyArtGuestBadge extends StatelessWidget {
  final double size;

  const BoxyArtGuestBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.guestPurple.withValues(alpha: AppColors.opacityLow),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.guestPurple.withValues(alpha: AppColors.opacityMuted),
          width: AppShapes.borderThin,
        ),
      ),
      child: Text(
        'G',
        style: AppTypography.micro.copyWith(
          color: AppColors.guestPurple,
          fontWeight: AppTypography.weightBold,
          fontSize: size * 0.5,
          height: 1.0,
        ),
      ),
    );
  }
}
