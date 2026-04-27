import "package:golf_society/design_system/design_system.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// The base card component for the BoxyArt design system.
/// Features soft diffused shadows, themed tints, and high rounded corners.
class BoxyArtCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showShadow;
  final bool isHero;
  final bool isHighlighted;
  final List<BoxShadow>? customShadows;

  const BoxyArtCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    this.gradient,
    this.showShadow = true,
    this.isHero = false,
    this.isHighlighted = false,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Radical Radius Consolidation (v4.0)
    final radius = borderRadius ?? (isHero ? config.heroRadius : config.cardRadius);
    
    // Calculate themed background
    final primary = Theme.of(context).primaryColor;
    final baseColor = backgroundColor ?? Theme.of(context).cardColor;
    
    // Enhanced Highlight Logic
    Color tintedColor = backgroundColor != null 
        ? backgroundColor! 
        : Color.alphaBlend(
            primary.withValues(alpha: config.cardTintIntensity * (isDark ? 0.15 : 0.05)),
            baseColor,
          );

    if (isHighlighted) {
      tintedColor = Color.alphaBlend(
        primary.withValues(alpha: isDark ? 0.25 : 0.12),
        tintedColor,
      );
    }

    final effectivelyShowShadow = (showShadow || isHighlighted) && config.useShadows;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: tintedColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: effectivelyShowShadow 
            ? (customShadows ?? 
               (isHighlighted 
                  ? Theme.of(context).extension<AppShadows>()?.softScale 
                  : Theme.of(context).extension<AppShadows>()?.softScale) ?? [])
            : null,
        border: (config.useBorders || isHighlighted) 
            ? (border ?? Border.all(
                color: isHighlighted 
                    ? primary.withValues(alpha: 0.5) 
                    : (isDark ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow) : Colors.black.withValues(alpha: 0.12)),
                width: isHighlighted ? config.borderWidth * 1.5 : config.borderWidth,
              ))
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(
                vertical: config.cardVerticalPadding,
                horizontal: config.cardHorizontalPadding,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A standard card for settings items.
class BoxyArtSettingsCard extends ConsumerWidget {
  final String title;
  final List<Widget> children;

  const BoxyArtSettingsCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.md),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelStrong.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(config.cardRadius),
            boxShadow: Theme.of(context).extension<AppShadows>()?.inputSoft ?? [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(config.cardRadius),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

/// A card for displaying notes or announcements.
class ModernNoteCard extends ConsumerWidget {
  final String? title;
  final String content;
  final String? imageUrl;
  final EdgeInsetsGeometry? margin;

  const ModernNoteCard({
    super.key,
    this.title,
    required this.content,
    this.imageUrl,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    return BoxyArtCard(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!.toUpperCase(),
              style: AppTypography.labelStrong.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            content,
            style: AppTypography.bodySmall,
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(config.cardRadius * 0.5),
              child: Image.network(
                imageUrl!, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 120, // Match default feel
                  color: AppColors.dark200,
                  child: const Icon(Icons.image_not_supported_rounded, color: AppColors.dark400),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
