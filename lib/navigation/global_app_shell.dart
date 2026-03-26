import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/design_system/constants/navigation_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalAppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const GlobalAppShell({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 1. Determine Navigation Context from Shell State
    // Branches 0-4 are User, 5+ are Admin
    final bool isAdmin = navigationShell.currentIndex >= 5;
    
    // 2. Map indices and select items
    // This allows the shell to remain robust regardless of the current URL string parsing.
    final List<BoxyArtBottomNavItem> items = isAdmin 
        ? NavigationConstants.adminNavItems 
        : NavigationConstants.userNavItems;
        
    final int displayIndex = isAdmin 
        ? (navigationShell.currentIndex - 5).clamp(0, items.length - 1)
        : navigationShell.currentIndex;

    // 3. Determine "Hub" mode (Event User Tabs use a specific secondary shell)
    // We check the specific branch indices that represent the Event Hub (Branch 1)
    // and verify we are actually inside an event sub-route (e.g. /events/123/details)
    // rather than the root list (/events).
    final location = GoRouterState.of(context).uri.path;
    
    // Determine if we should hide the main nav (deep inside an event hub)
    final bool isUserEventHub = !isAdmin && 
        navigationShell.currentIndex == 1 && 
        (location.contains('/details') || location.contains('/field') || location.contains('/live') || location.contains('/scores') || location.contains('/stats'));
        
    final bool isAdminEventHub = isAdmin && 
        navigationShell.currentIndex == 6 && 
        location.contains('/manage/');

    final bool shouldHideMainNav = isUserEventHub || isAdminEventHub;

    // 4. Status Bar Styling
    final statusBarIconBrightness = ContrastHelper.getContrastingText(theme.primaryColor) == AppColors.pureWhite
        ? Brightness.light  
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 1024;
          
          if (isMobile) {
            // Bypass global scaffold entirely when sub-hub is active to prevent gesture blocking
            if (shouldHideMainNav) {
              return navigationShell;
            }

            return Scaffold(
              key: const ValueKey('mobile_scaffold'),
              extendBody: true,
              extendBodyBehindAppBar: true,
              primary: false,
              body: navigationShell,
              bottomNavigationBar: BoxyArtBottomNavBar(
                selectedIndex: displayIndex,
                onItemSelected: (index) => _onTap(context, index, isAdmin),
                items: items,
                isAdmin: isAdmin,
              ),
            );
          }

          // Desktop/Tablet Layout
          return Scaffold(
            key: const ValueKey('desktop_scaffold'),
            body: Row(
              children: [
                if (!shouldHideMainNav)
                  NavigationRail(
                    selectedIndex: displayIndex,
                    onDestinationSelected: (index) => _onTap(context, index, isAdmin),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: isDark ? AppColors.dark900 : AppColors.dark50,
                    selectedIconTheme: IconThemeData(color: theme.primaryColor),
                    unselectedIconTheme: IconThemeData(color: theme.primaryColor.withValues(alpha: 0.4)),
                    selectedLabelTextStyle: TextStyle(
                      color: theme.primaryColor, 
                      fontSize: AppTypography.sizeLabel, 
                      fontWeight: AppTypography.weightBold
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: isDark ? AppColors.dark200 : AppColors.dark400, 
                      fontSize: AppTypography.sizeLabel
                    ),
                    destinations: items.map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: Text(item.label),
                    )).toList(),
                  ),
                if (!shouldHideMainNav)
                  VerticalDivider(
                    thickness: 1, 
                    width: 1, 
                    color: isDark ? Colors.white10 : Colors.black12
                  ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onTap(BuildContext context, int index, bool isAdmin) {
    // Map UI index back to Branch index
    final int branchIndex = isAdmin ? index + 5 : index;
    
    navigationShell.goBranch(
      branchIndex,
      // If tapping the already selected branch, go back to its initial location
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
