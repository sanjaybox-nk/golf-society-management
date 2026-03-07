


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/members/presentation/profile_provider.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/design_system/design_system.dart';

/// A reusable action icon that provides a shortcut to the Admin Console.
/// 
/// Visible ONLY to:
/// 1. Users with [MemberRole.admin] or [MemberRole.superAdmin].
/// 2. Users NOT currently in "Peek Mode".
class AdminShortcutAction extends ConsumerWidget {
  const AdminShortcutAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isPeeking = ref.watch(impersonationProvider) != null;

    // Visibility logic: Must be admin/superAdmin, NOT peeking, and NOT already in/previewing admin console
    final bool isAdmin = (currentUser.role == MemberRole.admin || 
                          currentUser.role == MemberRole.superAdmin);
    
    bool canSeeAdmin = false;
    try {
      final state = GoRouterState.of(context);
      final String currentPath = state.uri.path;
      final bool isPreview = state.uri.queryParameters['preview'] == 'true';
      final bool isAlreadyInAdmin = currentPath.startsWith('/admin');
      final bool isCommsPreview = currentPath.contains('/preview'); // Extra safety for other preview paths
      
      // Also hide in "Event Hub" tabs which are administrative/themed preview areas
      final bool isEventHub = currentPath.contains('/info') || 
                              currentPath.contains('/field') || 
                              currentPath.contains('/live') || 
                              currentPath.contains('/stats') || 
                              currentPath.contains('/photos');

      canSeeAdmin = isAdmin && !isPeeking && !isAlreadyInAdmin && !isPreview && !isCommsPreview && !isEventHub;
    } catch (_) {
      // In contexts without GoRouterState (like some dialogs), default to hiding the shortcut
      canSeeAdmin = false;
    }

    if (!canSeeAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Container(
        width: AppSpacing.x4l,
        height: AppSpacing.x4l,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: AppColors.opacityLow)),
        ),
        child: IconButton(
          icon: Icon(
            Icons.admin_panel_settings_rounded,
            color: Theme.of(context).iconTheme.color,
            size: AppShapes.iconMd,
          ),
          tooltip: 'Admin Console',
          onPressed: () => context.go('/admin'),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
