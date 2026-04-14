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
    );
  }
}


