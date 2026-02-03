import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/responsive_layout.dart';

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
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(index),
              backgroundColor: Colors.black,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 9,
              unselectedFontSize: 9,
              items: _navItems(),
            ),
          ),
        ),
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
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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
