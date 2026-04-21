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
    final user = ref.watch(effectiveUserProvider);
    final bool isDeparted = user.status == MemberStatus.left || user.status == MemberStatus.archived;
    
    // Status Bar Styling
    final statusBarIconBrightness = ContrastHelper.getContrastingText(theme.primaryColor) == AppColors.pureWhite
        ? Brightness.light  
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
      ),
      child: _ShellStructure(
        navigationShell: navigationShell,
        isDeparted: isDeparted,
      ),
    );
  }
}

class _ShellStructure extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isDeparted;

  const _ShellStructure({
    required this.navigationShell,
    required this.isDeparted,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      return _MobileShell(
        navigationShell: navigationShell,
        isDeparted: isDeparted,
      );
    }

    return _DesktopShell(
      navigationShell: navigationShell,
      isDeparted: isDeparted,
    );
  }
}

class _MobileShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isDeparted;

  const _MobileShell({
    required this.navigationShell,
    required this.isDeparted,
  });

  @override
  Widget build(BuildContext context) {
    return _ShellLayoutDelegate(
      navigationShell: navigationShell,
      isDeparted: isDeparted,
      builder: (context, props) {
        return Stack(
          children: [
            Scaffold(
              extendBody: true,
              primary: false,
              // IMPORTANT: The navigationShell (the branches) is persistent here.
              // By NOT watching location in THIS build method, we prevent 
              // the Scaffold from rebuilding during transit.
              body: navigationShell,
              // Responsive bottom padding for the floating nav bar
              bottomNavigationBar: props.shouldHideMainNav ? null : const SizedBox(height: 86),
            ),
            if (!props.shouldHideMainNav)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BoxyArtBottomNavBar(
                  selectedIndex: props.finalDisplayIndex,
                  onItemSelected: (index) => _onTap(context, index, props),
                  items: props.items,
                  isAdmin: props.isAdmin,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isDeparted;

  const _DesktopShell({
    required this.navigationShell,
    required this.isDeparted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _ShellLayoutDelegate(
      navigationShell: navigationShell,
      isDeparted: isDeparted,
      builder: (context, props) {
        return Scaffold(
          key: const ValueKey('desktop_scaffold'),
          body: Row(
            children: [
              if (!props.shouldHideMainNav)
                NavigationRail(
                  selectedIndex: props.finalDisplayIndex,
                  onDestinationSelected: (index) => _onTap(context, index, props),
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
                  destinations: props.items.map((item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
                  )).toList(),
                ),
              if (!props.shouldHideMainNav)
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
    );
  }
}

/// A reactive delegate that calculates display logic based on current GoRouter location.
/// By isolating this calculation to a builder, we ensure that location changes ONLY
/// rebuild the navbar/padding elements, NOT the entire root Scaffold or Shell.
class _ShellLayoutDelegate extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool isDeparted;
  final Widget Function(BuildContext context, _ShellProperties props) builder;

  const _ShellLayoutDelegate({
    required this.navigationShell,
    required this.isDeparted,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // This is the ONLY place where we watch the location.
    final location = GoRouter.of(context).routeInformationProvider.value.uri.path;
    final bool isAdmin = navigationShell.currentIndex >= 5;

    // 1. Calculate base items
    List<BoxyArtBottomNavItem> items;
    Map<int, int> branchMap = {};

    if (isAdmin) {
      items = NavigationConstants.adminNavItems;
      for (int i = 0; i < items.length; i++) branchMap[i] = i + 5;
    } else if (isDeparted) {
      items = [NavigationConstants.userNavItems[3], NavigationConstants.userNavItems[4]];
      branchMap = {0: 3, 1: 4};
    } else {
      items = NavigationConstants.userNavItems;
      for (int i = 0; i < items.length; i++) branchMap[i] = i;
    }

    final int baseIndex = isDeparted && !isAdmin
        ? (navigationShell.currentIndex == 4 ? 1 : 0)
        : (isAdmin 
            ? (navigationShell.currentIndex - 5).clamp(0, items.length - 1)
            : navigationShell.currentIndex);

    // 2. Hub Detection
    final bool isUserEventHub = location.startsWith('/events/') && location != '/events';
    final bool isAdminEventHub = location.startsWith('/admin/events/manage/');
    final bool isSurveyView = location.contains('/surveys/') && !location.contains('/admin/node');
    final bool isSpecialForm = location.split('/').any((s) => s == 'new' || s == 'edit' || s == 'create');

    if (isUserEventHub) {
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

    int finalIndex = baseIndex;
    if (isUserEventHub || isAdminEventHub) {
      if (location.endsWith('details')) finalIndex = 0;
      else if (location.endsWith('field') || location.endsWith('gallery')) finalIndex = 1;
      else if (location.endsWith('live') || location.endsWith('scores')) finalIndex = 2;
      else if (location.endsWith('stats')) finalIndex = 3;
      else if (location.endsWith('controls')) finalIndex = 4;
      else finalIndex = 0;
    }

    final bool isWhiteListed = location.contains('renewal') || location.contains('ledger') || 
                               location.contains('/admin/surveys') || location.contains('/admin/audience') || 
                               location.contains('compose') || location.contains('broadcast') || 
                               location.contains('game-setup') || location.contains('game-gallery') || 
                               location.contains('game-builder') || isSurveyView;

    return builder(context, _ShellProperties(
      items: items,
      finalDisplayIndex: finalIndex,
      shouldHideMainNav: isSpecialForm && !isWhiteListed,
      isAdmin: isAdmin,
      branchMap: branchMap,
      isUserHub: isUserEventHub,
      isAdminHub: isAdminEventHub,
      location: location,
      navigationShell: navigationShell,
    ));
  }
}

class _ShellProperties {
  final List<BoxyArtBottomNavItem> items;
  final int finalDisplayIndex;
  final bool shouldHideMainNav;
  final bool isAdmin;
  final Map<int, int> branchMap;
  final bool isUserHub;
  final bool isAdminHub;
  final String location;
  final StatefulNavigationShell navigationShell;

  _ShellProperties({
    required this.items,
    required this.finalDisplayIndex,
    required this.shouldHideMainNav,
    required this.isAdmin,
    required this.branchMap,
    required this.isUserHub,
    required this.isAdminHub,
    required this.location,
    required this.navigationShell,
  });
}

void _onTap(BuildContext context, int index, _ShellProperties props) {
  if (props.isUserHub) {
    final String id = props.location.split('/')[2];
    final List<String> paths = ['/events/$id/details', '/events/$id/field', '/events/$id/live', '/events/$id/scores', '/events/$id/stats'];
    context.go(paths[index]);
    return;
  }

  if (props.isAdminHub) {
    final String id = props.location.split('/')[4];
    final String prefix = '/admin/events/manage/$id';
    final List<String> paths = ['$prefix/details', '$prefix/gallery', '$prefix/scores', '$prefix/stats', '$prefix/controls'];
    context.go(paths[index]);
    return;
  }

  final int branchIndex = props.branchMap[index] ?? (props.isAdmin ? index + 5 : index);
  props.navigationShell.goBranch(branchIndex, initialLocation: branchIndex == props.navigationShell.currentIndex);
}

