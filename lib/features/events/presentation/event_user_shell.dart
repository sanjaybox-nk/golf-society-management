import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventUserShell extends StatelessWidget {
  final Widget child;

  const EventUserShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    // Determine index based on current route
    if (location.endsWith('/register')) {
      currentIndex = 1;
    } else if (location.endsWith('/grouping')) {
      currentIndex = 2;
    } else if (location.endsWith('/scores')) {
      currentIndex = 3;
    } else if (location.endsWith('/gallery')) {
      currentIndex = 4;
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
            padding: const EdgeInsets.only(top: 4.0, bottom: 0.0, left: 8.0, right: 8.0),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_library_outlined),
                  activeIcon: Icon(Icons.photo_library),
                  label: 'Gallery',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // Extract ID from current location: /events/:id/...
    final location = GoRouterState.of(context).uri.toString();
    
    // We expect /events/:id or /events/:id/subroute
    final uri = Uri.parse(location);
    final segments = uri.pathSegments;
    
    // segments[0] = events
    // segments[1] = id
    
    if (segments.length < 2) return;
    final id = segments[1];
    
    // Determine current index to detect if tapping same tab
    int currentIndex = 0;
    if (location.endsWith('/register')) {
      currentIndex = 1;
    } else if (location.endsWith('/grouping')) {
      currentIndex = 2;
    } else if (location.endsWith('/scores')) {
      currentIndex = 3;
    } else if (location.endsWith('/gallery')) {
      currentIndex = 4;
    }

    switch (index) {
      case 0:
        // If already on Event details tab, go back to events list
        if (currentIndex == 0) {
          context.go('/events');
        } else {
          context.go('/events/$id');
        }
        break;
      case 1:
        context.go('/events/$id/register');
        break;
      case 2:
        context.go('/events/$id/grouping');
        break;
      case 3:
        context.go('/events/$id/scores');
        break;
      case 4:
        context.go('/events/$id/gallery');
        break;
    }
  }
}
