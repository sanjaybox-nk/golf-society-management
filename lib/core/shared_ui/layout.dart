import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/contrast_helper.dart';
import 'buttons.dart';
import 'pro_max_app_bar.dart';

/// A standard clean app bar with circular action buttons.
class BoxyArtAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool showBack;
  final bool showLeading;
  final VoidCallback? onBack;

  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool isLarge;
  final bool? centerTitle;
  final Widget? leading;
  final double? leadingWidth;
  final Widget? topRow;
  final String? subtitle;
  final bool isPeeking;
  final bool transparent;

  final bool showAdminShortcut;

  const BoxyArtAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.showBack = false,
    this.showLeading = true,
    this.onBack,
    this.bottom,
    this.actions,
    this.isLarge = false,
    this.centerTitle,
    this.leading,
    this.leadingWidth,
    this.topRow,
    this.subtitle,
    this.isPeeking = false,
    this.showAdminShortcut = true,
    this.transparent = false,
  });

  static const double largeHeight = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Delegate to ProMaxAppBar for modern glassmorphic design
    return ProMaxAppBar(
      title: title,
      subtitle: subtitle,
      onMenuPressed: onMenuPressed,
      showBack: showBack,
      showLeading: showLeading,
      onBack: onBack,
      actions: actions,
      centerTitle: centerTitle ?? (isLarge ? true : false),
      leading: leading,
      leadingWidth: leadingWidth,
      showAdminShortcut: showAdminShortcut,
      bottom: bottom,
      transparent: transparent,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight((isLarge ? largeHeight : kToolbarHeight) + (bottom?.preferredSize.height ?? 0));
}

/// A floating bottom bar with Search and Filter segments.
class FloatingBottomSearch extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const FloatingBottomSearch({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Button (Left)
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.search),
                   SizedBox(width: 8),
                   Text("Search", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
          
          // Divider
          Container(width: 1, height: 24, color: Colors.white24),

          // Filter Button (Right)
          Expanded(
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   BoxyArtThemedCircleIcon(Icons.tune), // Filter icon
                   SizedBox(width: 8),
                   Text("Filter", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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
class FloatingFilterBar<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Find index of selected value for animation alignment
    final selectedIndex = options.indexWhere((o) => o.value == selectedValue);
    final count = options.length;
    
    // Calculate alignment for AnimatedAlign (-1.0 to 1.0)
    // For 2 items: 0 -> -1.0, 1 -> 1.0
    // formula: (index / (count - 1)) * 2 - 1
    final alignmentX = count > 1 ? (selectedIndex / (count - 1)) * 2 - 1 : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: 220,
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: const StadiumBorder(),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Layer 0: Border Ring
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0x339E9E9E)), // Grey with opacity 0.2 approx
                  ),
                ),
              ),
            ),

            // Layer 1: Active Indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment(alignmentX.toDouble(), 0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: (220 / count) - 8,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
            
            // Layer 2: Text Buttons
            Row(
              children: options.map((option) {
                final isSelected = option.value == selectedValue;
                
                // Calculate text color based on background
                final backgroundColor = isSelected 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                    : Colors.white;
                final textColor = ContrastHelper.getContrastingText(backgroundColor);
                final inactiveTextColor = textColor.withValues(alpha: 0.6);
                
                return Expanded(
                  child: InkWell(
                    onTap: () => onChanged(option.value),
                    borderRadius: BorderRadius.circular(25),
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? textColor : inactiveTextColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      letterSpacing: 0.5,
                      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
  final EdgeInsetsGeometry padding;
  final bool isLevel2;
  final bool isPeeking;

  const BoxyArtSectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8),
    this.isLevel2 = false,
    this.isPeeking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPeeking) ...[
              Icon(
                Icons.visibility,
                size: isLevel2 ? 10 : 12,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: isLevel2 ? 10 : 12,
                  fontWeight: FontWeight.w900, // Maximized Boldness
                  color: isDark ? Colors.white54 : Colors.grey,
                  letterSpacing: 1.5, // Increased spacing
                  fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
