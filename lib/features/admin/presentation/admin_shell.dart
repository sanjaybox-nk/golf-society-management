import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/boxy_art_nav_bar.dart';

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
        selectedIndex: navigationShell.currentIndex,
        onItemSelected: (index) => navigationShell.goBranch(index),
        unselectedColor: Theme.of(context).primaryColor,
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
            icon: Icons.leaderboard_outlined,
            activeIcon: Icons.leaderboard,
            label: 'Results',
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
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.black,
            selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor.withValues(alpha: 0.4)),
            selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), fontSize: 12),
            destinations: _navItems().map((item) => NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.activeIcon,
              label: Text(item.label ?? ''),
            )).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
          Expanded(child: navigationShell),
        ],
      ),
    );
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
        icon: Icon(Icons.leaderboard_outlined),
        activeIcon: Icon(Icons.leaderboard),
        label: 'Results',
      ),
    ];
  }
}
