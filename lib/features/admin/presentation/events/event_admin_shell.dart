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
    // NOTE: Do NOT use Scaffold or FocusScope here. GlobalAppShell already provides 
    // the root Scaffold and manages the focus environment.
    // 
    // Nested Scaffolds or explicit FocusScopes inside go_router's 
    // StatefulNavigationShell LayoutBuilder can trigger focus notifications 
    // to parent listeners (like GlobalAppShell's Scaffold) during a layout pass,
    // causing an illegal markNeedsBuild() call → assertion crash.
    // 
    // A plain Material maintains the zero-baseline coordinate system and 
    // correct background color for hub content without affecting the focus tree.
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}


