import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pro_max_app_bar.dart';

/// A modern "headless" scaffold that integrates the title into the scrolling content.
/// This replaces the traditional fixed AppBar with a large, bold title that scrolls.
class HeadlessScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? titleSuffix;
  final List<Widget> slivers;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showAdminShortcut;
  final double? leadingWidth;

  const HeadlessScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.titleSuffix,
    required this.slivers,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.contentPadding,
    this.showBack = false,
    this.showMenu = false,
    this.onBack,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showAdminShortcut = true,
    this.autoPrefix = true,
  });

  final bool autoPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;
    
    // Calculate top padding: Standard AppBar (56) + Dynamic Gap (64) = 120
    // This is a fixed absolute offset from the top edge of the screen.
    final contentTopPadding = 120.0;

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: ProMaxAppBar(
        title: '', // Headless
        transparent: true,
        showBack: showBack,
        showLeading: showMenu && !showBack, // Standard logic: Menu if no Back
        onBack: onBack,
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Headless Header
          SliverToBoxAdapter(
            child: Padding(
              padding: contentPadding ?? EdgeInsets.only(
                top: contentTopPadding,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            String displayTitle = title;
                            try {
                              final state = GoRouterState.of(context);
                              final isAdmin = state.matchedLocation.startsWith('/admin');
                              if (autoPrefix && isAdmin && !displayTitle.toLowerCase().contains('manage')) {
                                displayTitle = 'Manage $displayTitle';
                              }
                            } catch (_) {}
                            
                            return Text(
                              displayTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),
                      ),
                      if (titleSuffix != null) ...[
                        const SizedBox(width: 8),
                        titleSuffix!,
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
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
      ),
    );
  }
}
