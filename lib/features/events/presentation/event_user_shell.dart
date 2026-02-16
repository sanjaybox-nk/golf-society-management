import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/shared_ui/modern_cards.dart';
import '../../members/presentation/profile_provider.dart';
import '../../../models/member.dart';

class EventUserShell extends ConsumerWidget {
  final Widget child;

  const EventUserShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final isAdmin = user.role != MemberRole.member;
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    // Determine index based on current route
    if (location.contains('/field')) {
      currentIndex = 1;
    } else if (location.contains('/live')) {
      currentIndex = 2;
    } else if (location.contains('/stats')) {
      currentIndex = 3;
    } else if (location.contains('/photos')) {
      currentIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ModernSubTabBar(
        selectedIndex: currentIndex,
        onSelected: (index) => _onTap(context, index),
        unselectedColor: (isAdmin || location.contains('preview=true')) 
          ? Theme.of(context).primaryColor 
          : null,
        items: const [
          ModernSubTabItem(
            icon: Icons.info_outline_rounded,
            activeIcon: Icons.info_rounded,
            label: 'Info',
          ),
          ModernSubTabItem(
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            label: 'Field',
          ),
          ModernSubTabItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            label: 'Live',
          ),
          ModernSubTabItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            label: 'Stats',
          ),
          ModernSubTabItem(
            icon: Icons.photo_library_outlined,
            activeIcon: Icons.photo_library_rounded,
            label: 'Photos',
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
    final id = segments[1];
    
    // Determine current index to detect if tapping same tab
    int currentIndex = 0;
    if (location.endsWith('/field')) {
      currentIndex = 1;
    } else if (location.endsWith('/live')) {
      currentIndex = 2;
    } else if (location.endsWith('/stats')) {
      currentIndex = 3;
    } else if (location.endsWith('/photos')) {
      currentIndex = 4;
    }

    // Preserve query parameters (e.g. preview=true)
    final query = uri.query;
    final suffix = query.isNotEmpty ? '?$query' : '';

    switch (index) {
      case 0:
        // If already on Event details tab, go back to events list
        if (currentIndex == 0) {
          context.go('/events');
        } else {
          context.go('/events/$id$suffix');
        }
        break;
      case 1:
        context.go('/events/$id/field$suffix');
        break;
      case 2:
        context.go('/events/$id/live$suffix');
        break;
      case 3:
        context.go('/events/$id/stats$suffix');
        break;
      case 4:
        context.go('/events/$id/photos$suffix');
        break;
    }
  }
}
