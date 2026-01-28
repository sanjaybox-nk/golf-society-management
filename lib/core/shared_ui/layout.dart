import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/contrast_helper.dart';
import '../theme/app_shadows.dart';
import 'buttons.dart';

/// A standard clean app bar with circular action buttons.
class BoxyArtAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final bool showBack;
  final bool showLeading;
  final VoidCallback? onBack;

  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const BoxyArtAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onProfilePressed,
    this.showBack = false,
    this.showLeading = true,
    this.onBack,
    this.bottom,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: showLeading
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: BoxyArtCircularIconBtn(
                icon: showBack ? Icons.arrow_back : Icons.menu,
                onTap: showBack 
                    ? (onBack ?? () => Navigator.maybePop(context)) 
                    : onMenuPressed,
              ),
            )
          : null,
      automaticallyImplyLeading: showLeading,
      actions: actions ?? const [],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
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
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
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
