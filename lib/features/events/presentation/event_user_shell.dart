import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';

class EventUserShell extends ConsumerWidget {
  final String id;
  final Widget child;

  const EventUserShell({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);

    final List<_EventTabConfig> tabs = [
      _EventTabConfig(label: 'Info', icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded, path: '/events/$id/details'),
      _EventTabConfig(label: 'Field', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, path: '/events/$id/field'),
      _EventTabConfig(label: 'My Card', icon: Icons.edit_note_rounded, activeIcon: Icons.edit_note_rounded, path: '/events/$id/live'),
      _EventTabConfig(label: 'Scores', icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded, path: '/events/$id/scores'),
      _EventTabConfig(label: 'Stats', icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, path: '/events/$id/stats'),
    ];

    int currentIndex = tabs.indexWhere((t) => state.uri.path.endsWith(t.path.split('/').last));
    if (currentIndex == -1) {
      currentIndex = 0;
    }

    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      primary: true,
      extendBody: false,
      body: child,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (index) {
          if (index >= 0 && index < tabs.length) {
            context.go(tabs[index].path);
          }
        },
        items: tabs.map((t) => BoxyArtBottomNavItem(
          icon: t.icon,
          activeIcon: t.activeIcon,
          label: t.label,
        )).toList(),
      ),
    );
  }
}

class _EventTabConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  _EventTabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
