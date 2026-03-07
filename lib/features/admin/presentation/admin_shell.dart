import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';

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
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: _mapBranchToUiIndex(navigationShell.currentIndex),
        onItemSelected: (index) => navigationShell.goBranch(_mapUiIndexToBranch(index)),
        borderColor: Theme.of(context).primaryColor,
        items: const [
          BoxyArtBottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Events',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Members',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.notification_add_outlined,
            activeIcon: Icons.notification_add,
            label: 'Comms',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Reporting',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _mapBranchToUiIndex(navigationShell.currentIndex),
            onDestinationSelected: (index) => navigationShell.goBranch(_mapUiIndexToBranch(index)),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.black,
            selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor.withValues(alpha: 0.4)),
            selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: AppTypography.sizeLabel, fontWeight: AppTypography.weightBold),
            unselectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), fontSize: AppTypography.sizeLabel),
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
