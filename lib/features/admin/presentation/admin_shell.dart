import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/design_system/constants/navigation_constants.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isEventManagement = location.contains('/admin/events/manage/');

    if (isEventManagement) return navigationShell;

    return ResponsiveLayout(
      mobile: _buildMobile(context),
      desktop: _buildDesktop(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: _mapBranchToUiIndex(navigationShell.currentIndex),
        onItemSelected: _onTap,
        borderColor: theme.primaryColor,
        items: NavigationConstants.adminNavItems,
      ),
    );
  }

  void _onTap(int index) {
    final branchIndex = _mapUiIndexToBranch(index);
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _mapBranchToUiIndex(navigationShell.currentIndex),
            onDestinationSelected: _onTap,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.black,
            selectedIconTheme: IconThemeData(color: theme.primaryColor),
            unselectedIconTheme: IconThemeData(color: theme.primaryColor.withValues(alpha: 0.4)),
            selectedLabelTextStyle: TextStyle(color: theme.primaryColor, fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold),
            unselectedLabelTextStyle: TextStyle(color: theme.primaryColor.withValues(alpha: 0.4), fontSize: AppTypography.sizeLabel),
            destinations: _navItems().map((item) => NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.activeIcon,
              label: Text(item.label ?? ''),
            )).toList(),
          ),
          VerticalDivider(thickness: 1, width: AppShapes.borderThin, color: AppColors.pureWhite.withValues(alpha: 0.10)),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  int _mapUiIndexToBranch(int index) {
    // UI: Dashboard(0), Events(1), Members(2), Comms(3), Reporting(4)
    // Branches: Dashboard(0), Events(1), Members(2), Comms(3), Surveys(4), Reporting(5)
    if (index >= 4) return index + 1; // Skip Surveys (index 4)
    return index;
  }

  int _mapBranchToUiIndex(int index) {
    if (index == 4) return 0; // Surveys (as a fallback, show dashboard active)
    if (index == 5) return 4; // Reporting
    return index;
  }

  List<BottomNavigationBarItem> _navItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: 'Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Members',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notification_add_outlined),
        activeIcon: Icon(Icons.notification_add),
        label: 'Comms',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Reporting',
      ),
    ];
  }
}
