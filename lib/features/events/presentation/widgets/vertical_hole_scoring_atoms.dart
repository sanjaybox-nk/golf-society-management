part of 'vertical_hole_scoring_list.dart';

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isLong = label.length > 1;
    return Container(
      height: 14,
      padding: EdgeInsets.symmetric(horizontal: isLong ? 3 : 0),
      constraints: BoxConstraints(minWidth: isLong ? 18 : 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: AppTypography.micro.copyWith(
        color: AppColors.pureWhite,
        fontWeight: AppTypography.weightHeavy,
        fontSize: 7,
        height: 1.0,
      )),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _StoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _StoryButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = theme.extension<AppShapeTokens>();
    final primary = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? primary.withValues(alpha: 0.55)
              : primary.withValues(alpha: AppColors.opacityLow),
          borderRadius: shapes?.tabIndicator ?? BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppShapes.iconSm, color: isActive ? AppColors.pureWhite : primary),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: AppAnimations.fast,
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: isActive ? AppColors.pureWhite : primary,
                  letterSpacing: AppTypography.lsLabel,
                ),
                child: Text(label.toUpperCase(), overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavigationArrow({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.transparent : AppColors.dark50,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.transparent : AppColors.dark100,
            width: 1,
          ),
          boxShadow: isDisabled ? null : [
            BoxShadow(color: AppColors.dark950.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 16, color: isDisabled ? AppColors.dark200 : AppColors.dark950),
      ),
    );
  }
}
