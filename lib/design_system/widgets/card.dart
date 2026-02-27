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
  final bool showShadow;
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
    this.showShadow = true,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppTheme.fieldRadius;
    
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

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: tintedColor,
        gradient: (config.useCardGradient && backgroundColor == null)
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tintedColor,
                  isDark ? tintedColor.withValues(alpha: 0.8) : tintedColor.withValues(alpha: 0.95),
                ],
              ) 
            : null,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow 
            ? (customShadows ?? (isDark ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ] : AppShadows.softScale))
            : null,
        border: border ?? Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(24),
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
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppShadows.inputSoft,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
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
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl!, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }
}
