import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../events/presentation/events_provider.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:collection/collection.dart';
import '../../providers/admin_ui_providers.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import './event_admin_grouping_screen.dart'; // For GroupingExitAction

class EventAdminShell extends ConsumerWidget {
  final Widget child;

  const EventAdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segments = GoRouterState.of(context).uri.pathSegments;
    // Extract ID from path parameters: /admin/events/manage/:id/...
    String? id = GoRouterState.of(context).pathParameters['id'];
    if (id == null) {
      final manageIndex = segments.indexOf('manage');
      if (manageIndex != -1 && manageIndex < segments.length - 1) {
        id = segments[manageIndex + 1];
      }
    }

    final eventsAsync = ref.watch(adminEventsProvider);
    final event = eventsAsync.value?.firstWhereOrNull((e) => e.id == id);
    final isGolfEvent = event == null || event.eventType == EventType.golf;

    final List<_AdminTab> tabs = [
      const _AdminTab(
        path: 'home',
        icon: Icons.home_filled,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      const _AdminTab(
        path: 'event',
        icon: Icons.info_outline_rounded,
        activeIcon: Icons.info_rounded,
        label: 'Details',
      ),
      const _AdminTab(
        path: 'registrations',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Registration',
      ),
      if (isGolfEvent) ...[
        const _AdminTab(
          path: 'grouping',
          icon: Icons.grid_view_rounded,
          activeIcon: Icons.grid_view_sharp,
          label: 'Groups',
        ),
        const _AdminTab(
          path: 'scores',
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events,
          label: 'Scores',
        ),
      ],
      const _AdminTab(
        path: 'reporting',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Reports',
      ),
    ];

    int currentIndex = tabs.indexWhere((t) => segments.contains(t.path));
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: BoxyArtBottomNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (index) => _onTap(context, ref, index, currentIndex, tabs, id),
        activeColor: AppColors.lime500,
        borderColor: AppColors.lime500,
        items: tabs.map((t) => BoxyArtBottomNavItem(
          icon: t.icon,
          activeIcon: t.activeIcon,
          label: t.label,
        )).toList(),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, int index, int currentIndex, List<_AdminTab> tabs, String? id) async {
    if (index == currentIndex || id == null) return;
    
    final currentTab = tabs[currentIndex];
    final nextTab = tabs[index];

    // Check if grouping is dirty before leaving it
    if (currentTab.path == 'grouping') {
      final isDirty = ref.read(groupingDirtyProvider);
      if (isDirty) {
        final action = await _showExitConfirmation(context);
        if (action == GroupingExitAction.stay) return;
        
        if (action == GroupingExitAction.save) {
          final groups = ref.read(groupingLocalGroupsProvider);
          final isLocked = ref.read(groupingIsLockedProvider);
          
          if (groups != null) {
            try {
              final events = await ref.read(adminEventsProvider.future);
              final event = events.firstWhere((e) => e.id == id);
              final updatedEvent = event.copyWith(
                grouping: {
                  'groups': groups.map((g) => g.toJson()).toList(),
                  'updatedAt': DateTime.now().toIso8601String(),
                  'locked': isLocked ?? false,
                },
              );
              await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
            } catch (e) {
              // Error handled by resetting below or could show snackbar
            }
          }
        }
        
        // Reset dirty state if discarding or saving
        ref.read(groupingDirtyProvider.notifier).setDirty(false);
      }
    }

    if (!context.mounted) return;

    final encodedId = Uri.encodeComponent(id);
    context.go('/admin/events/manage/$encodedId/${nextTab.path}');
  }

  Future<GroupingExitAction> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<GroupingExitAction>(
      context: context,
      builder: (dialogContext) => BoxyArtDialog(
        title: 'Unsaved Changes',
        message: 'You have unsaved groupings. Do you want to save them before exiting?',
        confirmText: 'Save',
        cancelText: 'Discard',
        onConfirm: () => Navigator.of(dialogContext).pop(GroupingExitAction.save),
        onCancel: () => Navigator.of(dialogContext).pop(GroupingExitAction.discard),
        actions: [
          BoxyArtButton(
            title: 'Discard',
            onTap: () => Navigator.of(dialogContext).pop(GroupingExitAction.discard),
            isGhost: true,
          ),
          BoxyArtButton(
            title: 'Save',
            onTap: () => Navigator.of(dialogContext).pop(GroupingExitAction.save),
            isPrimary: true,
          ),
        ],
      ),
    );
    return result ?? GroupingExitAction.stay;
  }
}

class _AdminTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _AdminTab({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
