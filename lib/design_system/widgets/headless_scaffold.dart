import "package:golf_society/design_system/design_system.dart";



import 'package:go_router/go_router.dart';

/// A modern "headless" scaffold that integrates the title into the scrolling content.
/// This replaces the traditional fixed AppBar with a large, bold title that scrolls.
class HeadlessScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? titleSuffix;
  final List<Widget> slivers;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onBack;
  final IconData? backIcon;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showAdminShortcut;
  final double? leadingWidth;
  final bool useScaffold;
  final Widget? subtitleTrailing;

  const HeadlessScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.subtitleTrailing,
    this.titleSuffix,
    required this.slivers,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.contentPadding,
    this.showBack = false,
    this.showMenu = false,
    this.onBack,
    this.backIcon,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showAdminShortcut = true,
    this.autoPrefix = true,
    this.useScaffold = true,
  });

  final bool autoPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;
    
    // Calculate top padding: Standard AppBar (56) + Dynamic Gap (64) = 120
    // This is a fixed absolute offset from the top edge of the screen.
    final contentTopPadding = 120.0;

    final scrollView = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Headless Header
        SliverToBoxAdapter(
          child: Padding(
            padding: contentPadding ?? EdgeInsets.only(
              top: contentTopPadding,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.displayPage,
                      ),
                    ),
                    if (titleSuffix != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      titleSuffix!,
                    ],
                  ],
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 6),
                  subtitleWidget!
                ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.dark200 : AppColors.dark400,
                          fontWeight: AppTypography.weightSemibold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitleTrailing != null) 
                        subtitleTrailing!,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Content Slivers
        ...slivers,
        
        // Natural Bottom Spacing
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );

    // When useScaffold=false (e.g. inside EventAdminShell), skip the Scaffold
    // wrapper to avoid nested Scaffolds causing blank-screen layout failures.
    // Instead, use a Stack to overlay the AppBar on top of the scroll view,
    // replicating Scaffold's extendBodyBehindAppBar behavior.
    if (!useScaffold) {
      return Material(
        color: bg,
        child: Stack(
          children: [
            scrollView,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BoxyArtAppBar(
                title: '',
                transparent: true,
                showBack: showBack,
                showLeading: showMenu && !showBack,
                onBack: onBack,
                backIcon: backIcon,
                actions: actions,
                leading: leading,
                leadingWidth: leadingWidth,
                bottom: bottom,
                showAdminShortcut: () {
                  if (!showAdminShortcut) return false;
                  try {
                    return !GoRouterState.of(context).uri.path.startsWith('/admin');
                  } catch (_) {
                    return false;
                  }
                }(),
              ),
            ),
            if (bottomNavigationBar != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: bottomNavigationBar!,
              ),
            if (floatingActionButton != null)
              Positioned(
                bottom: AppSpacing.lg,
                right: AppSpacing.lg,
                child: floatingActionButton!,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: BoxyArtAppBar(
        title: '', // Headless
        transparent: true,
        showBack: showBack,
        showLeading: showMenu && !showBack, // Standard logic: Menu if no Back
        onBack: onBack,
        backIcon: backIcon,
        actions: actions,
        leading: leading,
        leadingWidth: leadingWidth,
        bottom: bottom,
        showAdminShortcut: () {
          if (!showAdminShortcut) return false;
          try {
            return !GoRouterState.of(context).uri.path.startsWith('/admin');
          } catch (_) {
            return false; // Safe default for non-router contexts (like preview)
          }
        }(),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: scrollView,
    );
  }
}
