import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import '../theme/contrast_helper.dart';
import 'admin_shortcut_action.dart';
import 'buttons.dart';

/// ProMax glassmorphic app bar with modern aesthetics
class ProMaxAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMenuPressed;
  final bool showBack;
  final bool showLeading;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final double? leadingWidth;
  final bool showAdminShortcut;
  final PreferredSizeWidget? bottom;
  final bool transparent;

  const ProMaxAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onMenuPressed,
    this.showBack = false,
    this.showLeading = false,
    this.onBack,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.leadingWidth,
    this.showAdminShortcut = true,
    this.bottom,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);
    
    final isPeekingState = ref.watch(impersonationProvider) != null;
    
    // Build actions
    final List<Widget> finalActions = actions != null ? [...actions!] : [];
    
    // Add Admin Shortcut if enabled
    if (showAdminShortcut) {
      finalActions.insert(0, const AdminShortcutAction());
    }

    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    // Calculate colors based on transparency
    final defaultBgColor = transparent 
        ? onSurface.withValues(alpha: 0.1) // Slightly more visible background
        : onPrimary.withValues(alpha: 0.15); // Contrasting background for solid mode
    final defaultIconColor = transparent ? onSurface : onPrimary;

    return AppBar(
      backgroundColor: transparent ? Colors.transparent : primaryColor,
      surfaceTintColor: Colors.transparent, // Disable M3 tint
      elevation: 0,
      toolbarHeight: transparent ? 56 : (subtitle != null ? 72 : 56),
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth ?? 70,
      leading: leading ?? (showBack
          ? Center(
              child: BoxyArtGlassIconButton(
                icon: Icons.chevron_left_rounded, // Themed chevron
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                backgroundColor: defaultBgColor,
                iconColor: defaultIconColor,
                tooltip: 'Back',
                iconSize: 28, // Slightly larger for better touch target and visibility
              ),
            )
          : (showLeading
              ? Center(
                  child: BoxyArtGlassIconButton(
                    icon: Icons.menu_rounded,
                    onPressed: onMenuPressed,
                    backgroundColor: defaultBgColor,
                    iconColor: defaultIconColor,
                    tooltip: 'Menu',
                  ),
                )
              : const SizedBox.shrink())),
      title: transparent ? null : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPeekingState) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  color: onPrimary.withValues(alpha: 0.7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              title,
              style: TextStyle(
                color: onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: onPrimary.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: finalActions.isEmpty ? null : [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: finalActions,
          ),
        ),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (subtitle != null ? 72.0 : 56.0) + (bottom?.preferredSize.height ?? 0),
      );
}

