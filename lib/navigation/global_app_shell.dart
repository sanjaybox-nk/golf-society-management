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

    // 3. Determine "Hub" mode & Override items if needed
    final location = GoRouterState.of(context).uri.path;
    final bool isUserEventHub = location.startsWith('/events/') && location != '/events';
    final bool isAdminEventHub = location.startsWith('/admin/events/manage/');
    final bool isSurveyView = location.contains('/surveys/') && !location.contains('/admin/node');
    final bool isSpecialForm = location.split('/').any((s) => s == 'new' || s == 'edit' || s == 'create');

    // Context-sensitive items for Event Hubs
    if (isUserEventHub) {
      final String id = location.split('/')[2];
      items = [
        BoxyArtBottomNavItem(label: 'Info', icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded),
        BoxyArtBottomNavItem(label: 'Field', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded),
        BoxyArtBottomNavItem(label: 'My Card', icon: Icons.edit_note_rounded, activeIcon: Icons.edit_note_rounded),
        BoxyArtBottomNavItem(label: 'Scores', icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded),
        BoxyArtBottomNavItem(label: 'Stats', icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded),
      ];
    } else if (isAdminEventHub) {
      items = [
        BoxyArtBottomNavItem(label: 'Info', icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded),
        BoxyArtBottomNavItem(label: 'Field', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded),
        BoxyArtBottomNavItem(label: 'Scores', icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded),
        BoxyArtBottomNavItem(label: 'Stats', icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded),
        BoxyArtBottomNavItem(label: 'Controls', icon: Icons.settings_rounded, activeIcon: Icons.settings_rounded),
      ];
    }

    // Determine correct display index for Hub mode
    int hubDisplayIndex = 0;
    if (isUserEventHub) {
      if (location.endsWith('details')) hubDisplayIndex = 0;
      else if (location.endsWith('field')) hubDisplayIndex = 1;
      else if (location.endsWith('live')) hubDisplayIndex = 2;
      else if (location.endsWith('scores')) hubDisplayIndex = 3;
      else if (location.endsWith('stats')) hubDisplayIndex = 4;
    } else if (isAdminEventHub) {
      if (location.endsWith('details')) hubDisplayIndex = 0;
      else if (location.endsWith('gallery')) hubDisplayIndex = 1; // Gallery/Field mapped to index 1
      else if (location.endsWith('scores')) hubDisplayIndex = 2;
      else if (location.endsWith('stats')) hubDisplayIndex = 3;
      else if (location.endsWith('controls')) hubDisplayIndex = 4;
    }

    final int finalDisplayIndex = (isUserEventHub || isAdminEventHub) ? hubDisplayIndex : displayIndex;

    final bool isWhiteListed = location.contains('renewal') || 
                               location.contains('ledger') || 
                               location.contains('/admin/surveys') || 
                               location.contains('/admin/communications') || 
                               location.contains('/admin/audience') || 
                               location.contains('compose') || 
                               location.contains('broadcast') || 
                               isSurveyView;
    final bool shouldHideMainNav = (isSpecialForm) && !isWhiteListed;

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
            return Stack(
              children: [
                Scaffold(
                  key: ValueKey('mobile_scaffold_$location'),
                  extendBody: false,
                  extendBodyBehindAppBar: true,
                  primary: false,
                  body: navigationShell,
                  bottomNavigationBar: shouldHideMainNav ? null : const SizedBox(height: 86), 
                ),
                if (!shouldHideMainNav)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BoxyArtBottomNavBar(
                      selectedIndex: finalDisplayIndex,
                      onItemSelected: (index) => _onTap(context, index, isAdmin, branchMap, isUserEventHub, isAdminEventHub, location),
                      items: items,
                      isAdmin: isAdmin,
                    ),
                  ),
              ],
            );
          }

          // Desktop/Tablet Layout
          return Scaffold(
            key: const ValueKey('desktop_scaffold'),
            body: Row(
              children: [
                if (!shouldHideMainNav)
                  NavigationRail(
                    selectedIndex: finalDisplayIndex,
                    onDestinationSelected: (index) => _onTap(context, index, isAdmin, branchMap, isUserEventHub, isAdminEventHub, location),
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

  void _onTap(BuildContext context, int index, bool isAdmin, Map<int, int> branchMap, bool isUserHub, bool isAdminHub, String location) {
    if (isUserHub) {
      final String id = location.split('/')[2];
      final List<String> paths = [
        '/events/$id/details',
        '/events/$id/field',
        '/events/$id/live',
        '/events/$id/scores',
        '/events/$id/stats',
      ];
      context.go(paths[index]);
      return;
    }

    if (isAdminHub) {
      final String id = location.split('/')[4];
      final String prefix = '/admin/events/manage/$id';
      final List<String> paths = [
        '$prefix/details',
        '$prefix/gallery',
        '$prefix/scores',
        '$prefix/stats',
        '$prefix/controls',
      ];
      context.go(paths[index]);
      return;
    }

    // Map UI index back to Branch index
    final int branchIndex = branchMap[index] ?? (isAdmin ? index + 5 : index);
    
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}

