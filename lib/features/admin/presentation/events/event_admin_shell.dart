import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // NOTE: Do NOT use Scaffold here. GlobalAppShell already provides the root
    // Scaffold. A nested Scaffold creates a FocusScope/_FocusMarker
    // (InheritedNotifier<FocusNode>) during its first mount. When this happens
    // inside go_router's StatefulNavigationShell LayoutBuilder, the FocusNode
    // notification propagates to dependents OUTSIDE the LayoutBuilder's
    // buildScope, which calls markNeedsBuild() during layout → assertion crash.
    // A plain Material avoids all Focus system initialization at the shell level.
    // We add a dedicated FocusScope to isolate focus shifts within the hub content,
    // preventing focus notifications from triggering parent layout passes during builds.
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FocusScope(
        debugLabel: 'EventAdminShell:$id',
        child: child,
      ),
    );
  }
}


