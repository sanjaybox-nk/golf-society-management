import 'package:golf_society/design_system/design_system.dart';

/// Tinted amber circle badge identifying the group captain.
/// Consistent across grouping, scoring, and admin views.
class BoxyArtCaptainBadge extends StatelessWidget {
  final double size;

  const BoxyArtCaptainBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.amber500,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_rounded,
        size: size * 0.55,
        color: AppColors.pureWhite,
      ),
    );
  }
}
