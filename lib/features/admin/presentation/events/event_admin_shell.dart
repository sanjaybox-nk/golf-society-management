import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';

class EventAdminShell extends ConsumerWidget {
  final String id;
  final Widget child;

  const EventAdminShell({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final segments = state.uri.pathSegments;

    // Hard-coded mapping for the 5-tab Admin Spec
    int currentIndex = 0;
    if (segments.contains('details')) {
      currentIndex = 0;
    } else if (segments.contains('gallery')) {
      currentIndex = 1;
    } else if (segments.contains('scores')) {
      currentIndex = 2;
    } else if (segments.contains('stats')) {
      currentIndex = 3;
    } else if (segments.contains('controls')) {
      currentIndex = 4;
    }


    final String prefix = '/admin/events/manage/$id';

    return Scaffold(
      primary: true,
      extendBody: false,
      body: child,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (index) {
          switch (index) {
            case 0: context.go('$prefix/details'); break;
            case 1: context.go('$prefix/gallery'); break;
            case 2: context.go('$prefix/scores'); break;
            case 3: context.go('$prefix/stats'); break;
            case 4: context.go('$prefix/controls'); break;
          }
        },
        items: const [
          BoxyArtBottomNavItem(
            icon: Icons.info_outline_rounded,
            activeIcon: Icons.info_rounded,
            label: 'Info',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            label: 'Field',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            label: 'Scores',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            label: 'Stats',
          ),
          BoxyArtBottomNavItem(
            icon: Icons.settings_rounded,
            activeIcon: Icons.settings_rounded,
            label: 'Controls',
          ),
        ],
      ),
    );
  }
}
