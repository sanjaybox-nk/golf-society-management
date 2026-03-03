import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';

class EventUserShell extends ConsumerWidget {
  final Widget child;

  const EventUserShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    // Determine index based on current route
    if (location.contains('/details')) {
      currentIndex = 1;
    } else if (location.contains('/field')) {
      currentIndex = 2;
    } else if (location.contains('/live')) {
      currentIndex = 3;
    } else if (location.contains('/stats')) {
      currentIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (index) => _onTap(context, index),
        items: const [
          BoxyArtBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.info_outline_rounded,
            activeIcon: Icons.info_rounded,
            label: 'Details',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            label: 'Field',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            label: 'Live',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            label: 'Stats',
          ),
        ],
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
    final id = Uri.decodeComponent(segments[1]);
    
    // Determine current index to detect if tapping same tab
    int currentIndex = 0;
    if (location.endsWith('/details')) {
      currentIndex = 1;
    } else if (location.endsWith('/field')) {
      currentIndex = 2;
    } else if (location.endsWith('/live')) {
      currentIndex = 3;
    } else if (location.endsWith('/stats')) {
      currentIndex = 4;
    }

    // Preserve query parameters (e.g. preview=true)
    final query = uri.query;
    final suffix = query.isNotEmpty ? '?$query' : '';

    final encodedId = Uri.encodeComponent(id);

    switch (index) {
      case 0:
        // If already on Home tab, go back to events list
        if (currentIndex == 0) {
          context.go('/events');
        } else {
          context.go('/events/$encodedId$suffix');
        }
        break;
      case 1:
        context.go('/events/$encodedId/details$suffix');
        break;
      case 2:
        context.go('/events/$encodedId/field$suffix');
        break;
      case 3:
        context.go('/events/$encodedId/live$suffix');
        break;
      case 4:
        context.go('/events/$encodedId/stats$suffix');
        break;
    }
  }
}
