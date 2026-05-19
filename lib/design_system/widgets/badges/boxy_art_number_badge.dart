
import 'package:golf_society/design_system/design_system.dart';

/// A centralized number/position badge (e.g. for leaderboards).
class BoxyArtNumberBadge extends StatelessWidget {
  final int number;
  final Color? color;
  final Color? textColor;
  final double size;
  final bool isRanking;
  final bool isFilled;

  const BoxyArtNumberBadge({
    super.key,
    required this.number,
    this.color,
    this.textColor,
    this.size = 28,
    this.isRanking = true,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    
    if (isRanking) {
      if (number == 1) {
        bg = AppColors.amber500;           // Gold
        fg = AppColors.pureWhite;
      } else if (number == 2) {
        bg = const Color(0xFFADB5BD);      // Silver — cool grey, not dark
        fg = AppColors.pureWhite;
      } else if (number == 3) {
        bg = const Color(0xFFCD7F32);      // Bronze
        fg = AppColors.pureWhite;
      } else {
        bg = Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHalf);
        fg = AppColors.pureWhite;
      }
    } else {
      bg = Theme.of(context).primaryColor.withValues(alpha: 0.20);
      fg = Theme.of(context).primaryColor;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: !isFilled ? Colors.transparent : (color ?? bg),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: AppTypography.caption.copyWith(
          color: textColor ?? (!isFilled ? AppColors.pureWhite : (color != null ? AppColors.pureWhite : fg)),
          fontSize: size * 0.45,
          fontWeight: AppTypography.weightBold,
        ),
      ),
    );
  }
}
