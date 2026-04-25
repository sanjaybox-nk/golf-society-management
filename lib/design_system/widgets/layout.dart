import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/theme/app_colors.dart';
import 'package:golf_society/theme/app_typography.dart';
import 'package:golf_society/theme/app_shapes.dart';
import 'package:golf_society/theme/app_spacing.dart';
import 'package:golf_society/design_system/theme/app_spacing_tokens.dart';
import 'package:golf_society/design_system/theme/app_shadows.dart';
import 'package:golf_society/design_system/theme/contrast_helper.dart';
import 'package:golf_society/design_system/theme/animation_constants.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../atoms/buttons/boxy_art_icon_buttons.dart';
import 'package:golf_society/design_system/theme/theme_controller.dart';

/// A floating bottom bar with Search and Filter segments.
class FloatingBottomSearch extends ConsumerWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const FloatingBottomSearch({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x2l, left: AppSpacing.x3l, right: AppSpacing.x3l),
      height: config.surfaceHeightLarge,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite,
        borderRadius: AppShapes.md,
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: Row(
        children: [
          // Search Button (Left)
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppShapes.rMd),
                bottomLeft: Radius.circular(AppShapes.rMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.search),
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     "Search", 
                     style: AppTypography.displayMedium.copyWith(
                       color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark950
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          // Divider
          Container(width: AppShapes.borderThin, height: AppSpacing.x2l, color: AppColors.dark200),

          // Filter Button (Right)
          Expanded(
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppShapes.rMd),
                bottomRight: Radius.circular(AppShapes.rMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.tune), // Filter icon
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     "Filter", 
                     style: AppTypography.displayMedium.copyWith(
                       color: Theme.of(context).brightness == Brightness.dark ? AppColors.pureWhite : AppColors.dark950
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A segment control style filter bar.
class FloatingFilterBar<T> extends ConsumerWidget {
  final T selectedValue;
  final List<FloatingFilterOption<T>> options;
  final ValueChanged<T> onChanged;

  const FloatingFilterBar({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final selectedIndex = options.indexWhere((o) => o.value == selectedValue);
    final count = options.length;
    final alignmentX = count > 1 ? (selectedIndex / (count - 1)) * 2 - 1 : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: AppShapes.borderMedium,
        height: config.surfaceHeightMedium,
        decoration: ShapeDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite,
          shape: const StadiumBorder(),
          shadows: [
            BoxShadow(
              color: AppColors.dark950.withAlpha((AppColors.opacityMedium * 255).toInt()),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(color: Color(0x339E9E9E)),
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: AppAnimations.medium,
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX.toDouble(), 0),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Container(
                  width: (220 / count) - 8,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityMedium),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
            Row(
              children: options.map((option) {
                final isSelected = option.value == selectedValue;
                final backgroundColor = isSelected 
                    ? Theme.of(context).primaryColor.withValues(alpha: AppColors.opacityHigh)
                    : (Theme.of(context).brightness == Brightness.dark ? AppColors.dark600 : AppColors.pureWhite);
                final textColor = ContrastHelper.getContrastingText(backgroundColor);
                final inactiveTextColor = Theme.of(context).brightness == Brightness.dark ? AppColors.dark300 : AppColors.dark400;
                
                return Expanded(
                  child: InkWell(
                    onTap: () => onChanged(option.value),
                    borderRadius: AppShapes.sheet,
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? textColor : inactiveTextColor,
                          fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                          fontSize: AppTypography.sizeBodySmall,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingFilterOption<T> {
  final String label;
  final T value;

  FloatingFilterOption({required this.label, required this.value});
}

/// A standard info row for profile/detail screens.
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon, 
              size: AppShapes.iconMd, 
              color: theme.primaryColor,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.labelStrong.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: AppTypography.sizeBody,
                      color: isDark ? AppColors.dark60 : AppColors.dark950,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A standard section title with BoxyArt styling (uppercase, bold, grey).
class BoxyArtSectionTitle extends StatelessWidget {
  final String title;
  final bool isLevel2;
  final bool isPeeking;
  final bool followsCard;
  final IconData? icon;
  final int? count;
  final Color? color;
  final double? topPadding;
  final Widget? trailing; // Added for flexible headers like registration voucher switch

  const BoxyArtSectionTitle({
    super.key,
    required this.title,
    this.isLevel2 = false,
    this.isPeeking = false,
    this.followsCard = false,
    this.icon,
    this.count,
    this.color,
    this.topPadding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final spacing = theme.extension<AppSpacingTokens>();
    final onSurface = theme.colorScheme.onSurface;
    final displayTitle = count != null ? '$title ($count)' : title;

    final double topPadding = this.topPadding ?? (followsCard 
      ? (spacing?.cardToLabel ?? AppSpacing.cardToLabel)
      : (isPeeking 
          ? (spacing?.labelToCard ?? AppSpacing.labelToCard) 
          : (spacing?.tabToContent ?? AppSpacing.tabToContent)));
    final double bottomPadding = spacing?.labelToCard ?? AppSpacing.labelToCard;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isLevel2 ? AppShapes.iconXs : AppShapes.iconSm,
                  color: color ?? onSurface.withValues(alpha: AppColors.opacitySecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  displayTitle.toUpperCase(),
                  style: (isLevel2 ? AppTypography.micro : AppTypography.label).copyWith(
                    color: color ?? onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A standardized subtle divider for the Boxy Art design system.
class BoxyArtDivider extends ConsumerWidget {
  final double verticalPadding;

  const BoxyArtDivider({
    super.key,
    this.verticalPadding = AppSpacing.xs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(
        height: config.dividerThickness,
        thickness: config.dividerThickness,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}

/// A standardized subtle vertical divider for the Boxy Art design system.
class BoxyArtVerticalDivider extends ConsumerWidget {
  final double horizontalPadding;
  final double? height;

  const BoxyArtVerticalDivider({
    super.key,
    this.horizontalPadding = AppSpacing.xs,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: config.dividerThickness,
        height: height,
        color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow),
      ),
    );
  }
}
