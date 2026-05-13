
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A standardized 3.1 settings row with a boxed icon that navigates.
class BoxyArtNavTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? badgeColor;
  final VoidCallback onTap;

  const BoxyArtNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.lg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Boxed Icon (Standard 4.x via BoxyArtIconBadge)
            BoxyArtIconBadge(
              icon: icon,
              iconColor: iconColor ?? badgeColor,
              color: badgeColor ?? Colors.transparent,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: AppSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.labelStrong.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: AppTypography.weightBold,
                      fontSize: AppTypography.sizeLabel,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      fontWeight: AppTypography.weightMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: isDark ? AppColors.dark400 : AppColors.dark200, 
              size: AppShapes.iconXs,
            ),
          ],
        ),
      ),
    );
  }
}
