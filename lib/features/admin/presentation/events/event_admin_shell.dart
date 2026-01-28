import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventAdminShell extends StatelessWidget {
  final Widget child;

  const EventAdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    if (location.endsWith('/registrations')) {
      currentIndex = 1;
    } else if (location.endsWith('/grouping')) {
      currentIndex = 2;
    } else if (location.endsWith('/scores')) {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onTap(context, index),
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined),
                  activeIcon: Icon(Icons.event_note),
                  label: 'Event',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Registration',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  activeIcon: Icon(Icons.grid_view_sharp),
                  label: 'Grouping',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Scores',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Extract ID from current location: /admin/events/manage/:id/...
    final location = GoRouterState.of(context).uri.toString();
    final parts = location.split('/');
    // admin, events, manage, :id, ...
    // parts[0] = ''
    // parts[1] = admin
    // parts[2] = events
    // parts[3] = manage
    // parts[4] = id
    
    if (parts.length < 5) return;
    final id = parts[4];

    switch (index) {
      case 0:
        context.go('/admin/events/manage/$id/event');
        break;
      case 1:
        context.go('/admin/events/manage/$id/registrations');
        break;
      case 2:
        context.go('/admin/events/manage/$id/grouping');
        break;
      case 3:
        context.go('/admin/events/manage/$id/scores');
        break;
    }
  }
}
