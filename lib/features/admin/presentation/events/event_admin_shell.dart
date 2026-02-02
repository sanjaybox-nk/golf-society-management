import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../../core/shared_ui/shared_ui.dart';
import '../../providers/admin_ui_providers.dart';
import './event_admin_grouping_screen.dart'; // For GroupingExitAction

class EventAdminShell extends ConsumerWidget {
  final Widget child;

  const EventAdminShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    
    if (location.endsWith('/registrations')) {
      currentIndex = 1;
    } else if (location.endsWith('/grouping')) {
      currentIndex = 2;
    } else if (location.endsWith('/scores')) {
      currentIndex = 3;
    } else if (location.endsWith('/reports')) {
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
              onTap: (index) => _onTap(context, ref, index, currentIndex),
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
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Reports',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, int index, int currentIndex) async {
    if (index == currentIndex) return;

    // Extract ID from current location: /admin/events/manage/:id/...
    // Capture this BEFORE any async gaps
    final currentLocation = GoRouterState.of(context).uri.toString();
    final parts = currentLocation.split('/');
    if (parts.length < 5) return;
    final id = parts[4];

    // Check if grouping is dirty before leaving it
    if (currentIndex == 2) {
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

    switch (index) {
      case 0:
        context.go('/admin/events/manage/$id/event');
        break;
      case 1:
        context.go('/admin/events/manage/$id/registrations');
        break;
      case 2:
        context.go('/admin/events/manage/$id/grouping');
        break;
      case 3:
        context.go('/admin/events/manage/$id/scores');
        break;
      case 4:
        context.go('/admin/events/manage/$id/reports');
        break;
    }
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
