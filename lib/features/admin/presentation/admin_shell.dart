import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we are in the Event Management sub-shell
    final location = GoRouterState.of(context).uri.toString();
    final isEventManagement = location.contains('/admin/events/manage/');

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isEventManagement 
          ? null // Completely remove main menu in event management
          : Container(
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
            padding: const EdgeInsets.only(top: 4.0, bottom: 0.0, left: 8.0, right: 8.0),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
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
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
