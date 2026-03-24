import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/design_system/constants/navigation_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';

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
    
    // Get current path to determine context
    final state = GoRouterState.of(context);
    final location = state.uri.path;
    
    // 1. Determine Navigation Context
    final bool isAdmin = location.startsWith('/admin');
    final bool isEventHub = location.contains('/events/') && 
        (location.contains('/details') || 
         location.contains('/field') || 
         location.contains('/live') || 
         location.contains('/scores') || 
         location.contains('/stats') || 
         location.contains('/photos') || 
         location.contains('/home') ||
         location.contains('/manage/'));

    // 2. Select Items & Map Index
    List<BoxyArtBottomNavItem> items = NavigationConstants.userNavItems;
    int displayIndex = navigationShell.currentIndex;

    if (isAdmin) {
      items = NavigationConstants.adminNavItems;
      // Admin branches start at index 5 in our consolidated router
      displayIndex = (navigationShell.currentIndex - 5).clamp(0, items.length - 1);
    }

    // 3. Status Bar Styling
    final statusBarIconBrightness = ContrastHelper.getContrastingText(theme.primaryColor) == AppColors.pureWhite
        ? Brightness.light  
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
      ),
      child: ResponsiveLayout(
        mobile: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          primary: false,
          body: navigationShell,
          bottomNavigationBar: isEventHub ? null : BoxyArtBottomNavBar(
            selectedIndex: displayIndex,
            onItemSelected: (index) => _onTap(context, index, isAdmin),
            items: items,
            isAdmin: isAdmin,
          ),
        ),
        desktop: Scaffold(
          body: Row(
            children: [
              if (!isEventHub)
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
              if (!isEventHub)
                VerticalDivider(
                  thickness: 1, 
                  width: 1, 
                  color: isDark ? Colors.white10 : Colors.black12
                ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index, bool isAdmin) {
    // Map UI index back to Branch index
    final int branchIndex = isAdmin ? index + 5 : index;
    
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
