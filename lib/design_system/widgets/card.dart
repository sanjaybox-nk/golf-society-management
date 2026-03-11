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
  final LinearGradient? gradient;
  final bool showShadow;
  final bool isHero;
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
    this.customShadows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Style Presets Mapping
    double defaultRadius;
    if (isHero) {
      defaultRadius = config.heroRadius;
    } else {
      switch (config.brandingStyle) {
        case 'classic': defaultRadius = 8.0; break;
        case 'modern':  defaultRadius = 28.0; break;
        case 'boxy':
        default:        defaultRadius = 18.0; break;
      }
    }
    
    final radius = borderRadius ?? defaultRadius;
    
    // Calculate themed background
    final primary = Theme.of(context).primaryColor;
    final baseColor = backgroundColor ?? Theme.of(context).cardColor;
    
    // Apply tint based on config if no explicit background color is provided
    final tintedColor = backgroundColor != null 
        ? backgroundColor! 
        : Color.alphaBlend(
            primary.withValues(alpha: config.cardTintIntensity * (isDark ? 0.15 : 0.05)),
            baseColor,
          );

    final effectivelyShowShadow = showShadow && config.useShadows;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: tintedColor,
        gradient: gradient ?? ((config.useCardGradient && backgroundColor == null)
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tintedColor,
                  isDark ? tintedColor.withValues(alpha: AppColors.opacityHigh) : tintedColor.withValues(alpha: 0.95),
                ],
              ) 
            : null),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: effectivelyShowShadow 
            ? (customShadows ?? Theme.of(context).extension<AppShadows>()?.softScale ?? [])
            : null,
        border: config.useBorders 
            ? (border ?? Border.all(
                color: isDark ? AppColors.pureWhite.withValues(alpha: AppColors.opacityLow) : Colors.black.withValues(alpha: 0.12),
                width: config.borderWidth,
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
              padding: padding ?? const EdgeInsets.all(AppSpacing.x2l),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A standard card for settings items.
class BoxyArtSettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const BoxyArtSettingsCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.md),
          child: Text(
            title,
            style: AppTypography.displaySection.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppShapes.pill,
            boxShadow: Theme.of(context).extension<AppShadows>()?.inputSoft ?? [],
          ),
          child: ClipRRect(
            borderRadius: AppShapes.pill,
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
class ModernNoteCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BoxyArtCard(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: AppTypography.body.copyWith(fontWeight: AppTypography.weightBold),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            content,
            style: AppTypography.bodySmall.copyWith(height: 1.4),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: AppShapes.md,
              child: Image.network(imageUrl!, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }
}
