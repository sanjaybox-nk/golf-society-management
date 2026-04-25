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
    return child;
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
