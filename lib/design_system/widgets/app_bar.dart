import 'package:golf_society/design_system/design_system.dart';

/// The standard app bar for the Fairway v3.1 branding.
/// Maintains legacy parameters while enforcing new design tokens.
class BoxyArtAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final IconData? backIcon;
  final PreferredSizeWidget? bottom;
  final bool transparent;
  final bool showLeading;
  final double? leadingWidth;
  final bool showAdminShortcut;
  final Color? backgroundColor;

  const BoxyArtAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBack = false,
    this.onBack,
    this.backIcon,
    this.bottom,
    this.transparent = false,
    this.showLeading = false,
    this.leadingWidth,
    this.showAdminShortcut = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: theme.appBarTheme.titleTextStyle,
            ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.body.copyWith(
                fontSize: AppTypography.sizeLabel,
                color: isDark ? AppColors.dark200 : AppColors.dark300,
                height: 1.1,
              ),
            ),
        ],
      ),
      actions: actions != null ? [
        ...actions!,
        const SizedBox(width: AppSpacing.sm), // Reaches 20px total (12 default + 8)
      ] : null,
      leading: leading ?? (showBack 
        ? Center(
            child: BoxyArtGlassIconButton(
              icon: backIcon ?? Icons.arrow_back_rounded,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            ),
          )
        : (showLeading 
            ? Center(
                child: BoxyArtGlassIconButton(
                  icon: Icons.menu_rounded,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              )
            : null)),
      leadingWidth: leadingWidth ?? 80,
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: backgroundColor ?? (transparent ? Colors.transparent : null),
      scrolledUnderElevation: 0,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    (subtitle != null ? 72 : kToolbarHeight) + (bottom?.preferredSize.height ?? 0)
  );
}
