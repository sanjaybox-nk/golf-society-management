import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
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
    
    final user = ref.watch(effectiveUserProvider);
    final bool isDeparted = user.status == MemberStatus.left || user.status == MemberStatus.archived;
    final bool isAdmin = navigationShell.currentIndex >= 5;

    // 2. Map indices and select items
    List<BoxyArtBottomNavItem> items;
    Map<int, int> branchMap = {};

    if (isAdmin) {
      items = NavigationConstants.adminNavItems;
      for (int i = 0; i < items.length; i++) {
        branchMap[i] = i + 5;
      }
    } else if (isDeparted) {
      // Locker Room and Archive Only
      items = [
        NavigationConstants.userNavItems[3], // Locker
        NavigationConstants.userNavItems[4], // Archive
      ];
      branchMap = {0: 3, 1: 4};
    } else {
      items = NavigationConstants.userNavItems;
      for (int i = 0; i < items.length; i++) {
        branchMap[i] = i;
      }
    }
        
    final int displayIndex = isDeparted && !isAdmin
        ? (navigationShell.currentIndex == 4 ? 1 : 0)
        : (isAdmin 
            ? (navigationShell.currentIndex - 5).clamp(0, items.length - 1)
            : navigationShell.currentIndex);

    // 3. Determine "Hub" mode (Event User Tabs use a specific secondary shell)
    // We check the specific branch indices that represent the Event Hub (Branch 1)
    // and verify we are actually inside an event sub-route (e.g. /events/123/details)
    // rather than the root list (/events).
    final location = GoRouterState.of(context).uri.path;
    
    // Determine if we should hide the main nav (deep inside an event hub or specific admin pages)
    // We check for any path that starts with /events/ and contains an ID or sub-route
    // This is more robust than checking for shell indices.
    final bool isUserEventHub = location.startsWith('/events/') && location != '/events';
    final bool isAdminEventHub = location.startsWith('/admin/events/manage/');
    final bool isSurveyView = location.contains('/surveys/') && !location.contains('/admin/node'); // Only hide if it's a specific internal node type if needed, but for now let's just make it consistent.
    final bool isSpecialForm = location.split('/').any((s) => s == 'new' || s == 'edit' || s == 'create');

    final bool isWhiteListed = location.contains('renewal') || location.contains('ledger') || location.contains('/admin/surveys') || location.contains('compose') || location.contains('broadcast') || isSurveyView;
    final bool shouldHideMainNav = (isUserEventHub || isAdminEventHub || isSpecialForm) && !isWhiteListed;


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
          
          if (isMobile) {
            // Bypass global scaffold entirely when sub-hub is active to prevent gesture blocking
            if (shouldHideMainNav) {
              return navigationShell;
            }

            return Scaffold(
              key: ValueKey('mobile_scaffold_$location'),
              extendBody: false,
              extendBodyBehindAppBar: true,
              primary: false,
              body: navigationShell,
              bottomNavigationBar: BoxyArtBottomNavBar(
                selectedIndex: displayIndex,
                onItemSelected: (index) => _onTap(context, index, isAdmin, branchMap),
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
                    onDestinationSelected: (index) => _onTap(context, index, isAdmin, branchMap),
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

  void _onTap(BuildContext context, int index, bool isAdmin, Map<int, int> branchMap) {
    // Map UI index back to Branch index
    final int branchIndex = branchMap[index] ?? (isAdmin ? index + 5 : index);
    
    navigationShell.goBranch(
      branchIndex,
      // If tapping the already selected branch, go back to its initial location
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
