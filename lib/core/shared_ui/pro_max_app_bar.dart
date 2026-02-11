import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/models/member.dart';
import '../theme/contrast_helper.dart';

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

  const ProMaxAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onMenuPressed,
    this.showBack = false,
    this.showLeading = true,
    this.onBack,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.leadingWidth,
    this.showAdminShortcut = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);
    
    // Watch providers for admin access
    final currentUser = ref.watch(currentUserProvider);
    final isPeekingState = ref.watch(impersonationProvider) != null;
    final isAdmin = currentUser.role == MemberRole.superAdmin || 
                    currentUser.role == MemberRole.admin;

    // Build actions with admin shortcut
    final List<Widget> finalActions = actions != null ? [...actions!] : [];
    
    if (showAdminShortcut && isAdmin && !isPeekingState && title != 'Admin Console') {
      finalActions.insert(
        0,
        _GlassIconButton(
          icon: Icons.admin_panel_settings_outlined,
          onPressed: () => context.go('/admin'),
          tooltip: 'Admin Console',
        ),
      );
    }

    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      toolbarHeight: subtitle != null ? 80 : 64,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth ?? 70,
      leading: leading ?? (showLeading
          ? (showBack
              ? TextButton(
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                )
              : Center(
                  child: _GlassIconButton(
                    icon: Icons.menu,
                    onPressed: onMenuPressed,
                  ),
                ))
          : null),
      title: Column(
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
        (subtitle != null ? 80.0 : 64.0) + (bottom?.preferredSize.height ?? 0),
      );
}

/// Glassmorphic circular icon button with blur effect
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _GlassIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: Icon(icon),
            iconSize: 20,
            color: Colors.white,
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }
}
