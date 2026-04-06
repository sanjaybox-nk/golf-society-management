import 'dart:ui';
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
  final Widget? subtitleTrailing;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onBack;
  final IconData? backIcon;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final bool showAdminShortcut;
  final Widget? pinnedBottom;
  final double? pinnedBottomPadding;
  final bool isModal;
  final Widget? floatingActionButton;

  const HeadlessScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.subtitleTrailing,
    this.titleSuffix,
    required this.slivers,
    this.backgroundColor,
    this.contentPadding,
    this.showBack = false,
    this.showMenu = false,
    this.onBack,
    this.backIcon,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.showAdminShortcut = true,
    this.pinnedBottom,
    this.pinnedBottomPadding,
    this.isModal = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.scaffoldBackgroundColor;
    
    // 1. Calculate Notch Clearance (Hardware Padding)
    // We use viewPaddingOf to detect the physical notch even if we are inside a SafeArea-consuming parent.
    final double physicalTop = MediaQuery.viewPaddingOf(context).top;
    final double topPadding = MediaQuery.paddingOf(context).top;
    // Bottom inset: consume the bottom nav bar height so content is never occluded.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    
    // Fallback logic: 
    // 1. Use actual top padding if it's currently inset (Standard Page)
    // 2. Use physical notch padding if we are overlapping the notch (Modal Page)
    // 3. Fallback to 59.0 (iPhone 14/15 Pro Standard) for modals if both are zero
    final double notchHeight = topPadding > 0 
        ? topPadding 
        : (physicalTop > 0 ? physicalTop : (isModal ? 59.0 : 44.0));
    
    // 2. The Shared Header & Content Stack
    final layoutStack = Stack(
      children: [
        // Layer 1: Scrolling Content (Forced Zero Insets for Universal Parity)
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Standardized 4.x Headless Header (Absolute Rhythm parity: 120px from Physical Top)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    // Absolute Golden Rhythm: Exactly 124px from Physical Top (Grid-snapped + 4px nudge)
                    // We use a fixed value here because the GlobalAppShell and Modals now all start at Y=0
                    top: 124.0, 
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.large,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title.replaceFirst(RegExp(r'LIVE:\s*', caseSensitive: false), ''),
                              style: AppTypography.displayPage,
                            ),
                          ),
                          if (titleSuffix != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            titleSuffix!,
                          ],
                        ],
                      ),
                      if (subtitleWidget != null || (subtitle != null && subtitle!.isNotEmpty)) ...[
                        const SizedBox(height: AppSpacing.xs),
                        subtitleWidget ?? Text(
                          subtitle!,
                          style: AppTypography.subtext.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacitySecondary),
                            fontWeight: AppTypography.weightSemibold, // Semibold token as requested
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Body Content
              ...slivers,
              
              // Bottom Padding: adds bottomInset to clear the global bottom nav bar
              SliverPadding(padding: EdgeInsets.only(bottom: (pinnedBottom != null ? 280 : 100) + bottomInset)),
            ],
          ),
        ),

        // Layer 2: Fixed Navigation & Identity (Blurred App Bar)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
               // Notch/Sheet margin filler (Blur surface)
               ClipRect(
                 child: BackdropFilter(
                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                   child: Container(
                     // We fill the exact hardware padding to ensure the blur always covers the status bar
                     height: notchHeight, 
                     color: bg.withValues(alpha: 0.8),
                   ),
                 ),
               ),
                // Layer 2: Actionable Navigation Row (Fixed 48px for 8pt grid parity)
                SizedBox(
                  height: 48.0,
                  child: Row(
                    children: [
                      // Leading slot
                      SizedBox(
                        width: leadingWidth ?? 72.0,
                        child: leading ?? (showBack 
                            ? Center(
                                child: BoxyArtGlassIconButton(
                                  icon: backIcon ?? Icons.arrow_back_rounded,
                                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                                  tooltip: 'Back',
                                  iconColor: AppColors.dark900, // Force contrast
                                  iconSize: 24,
                                ),
                              )
                            : (showMenu 
                                ? Center(
                                    child: BoxyArtGlassIconButton(
                                      icon: Icons.menu_rounded,
                                      onPressed: () => Scaffold.of(context).openDrawer(),
                                      tooltip: 'Menu',
                                      iconColor: AppColors.dark900, // Force contrast
                                    ),
                                  )
                                : null)),
                      ),

                      // Spacer
                      const Expanded(child: SizedBox.shrink()),

                      // Actions slot
                      if (actions != null || showAdminShortcut)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xl),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showAdminShortcut)
                                Builder(
                                  builder: (context) {
                                    final path = GoRouterState.of(context).uri.path;
                                    if (path.contains('/admin')) return const SizedBox.shrink();
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: (actions != null && actions!.isNotEmpty) ? AppSpacing.sm : 0,
                                      ),
                                      child: const AdminShortcutAction(),
                                    );
                                  },
                                ),
                              if (actions != null)
                                ...actions!.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final widget = entry.value;
                                  final isLast = idx == actions!.length - 1;
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: isLast ? 0 : AppSpacing.sm,
                                    ),
                                    child: widget,
                                  );
                                }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Layer 3: Overlays
        if (pinnedBottom != null)
          Positioned(
            bottom: (pinnedBottomPadding ?? AppSpacing.lg) + bottomInset,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: pinnedBottom!,
          ),

        // Layer 4: Modal Grab Handle (Absolute Overlay)
        if (isModal)
          Positioned(
            top: AppSpacing.sm,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: AppShapes.grabber,
                ),
              ),
            ),
          ),

        // Layer 5: Floating Action Button
        if (floatingActionButton != null)
          Positioned(
            right: AppSpacing.xl,
            bottom: (pinnedBottom != null ? 100 : 0) + AppSpacing.xl + bottomInset,
            child: floatingActionButton!,
          ),
      ],
    );

    // 3. Final Build (True Headless Zero-Baseline Layout)
    // We avoid returning a Scaffold here to prevent nested inset consumption. 
    // HeadlessScaffold assumes its own Y=0 is the coordinate system.
    return Material(
      color: bg,
      borderRadius: isModal ? AppShapes.sheet : null,
      clipBehavior: isModal ? Clip.antiAlias : Clip.none,
      child: layoutStack,
    );
  }
}
