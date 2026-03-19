import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';

class AdminGroupingToolbar extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onAutoGenerate;

  const AdminGroupingToolbar({
    super.key,
    required this.event,
    required this.onReset,
    required this.onSave,
    required this.onAutoGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);
    final isDirty = ref.watch(groupingDirtyProvider);
    final matchPlayMode = ref.watch(groupingMatchPlayModeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarAction(
          icon: Icons.auto_awesome_outlined,
          label: 'Generate',
          onTap: isLocked ? null : onAutoGenerate,
        ),
        _ToolbarAction(
          icon: matchPlayMode ? Icons.sports_kabaddi_rounded : Icons.sports_kabaddi_outlined,
          label: 'Matches',
          isActive: matchPlayMode,
          onTap: isLocked ? null : () => ref.read(groupingMatchPlayModeProvider.notifier).set(!matchPlayMode),
        ),
        _ToolbarAction(
          icon: Icons.refresh_rounded,
          label: 'Reset',
          onTap: isLocked ? null : onReset,
        ),
        _ToolbarAction(
          icon: isDirty ? Icons.save_rounded : Icons.check_circle_outline_rounded,
          label: isDirty ? 'Save' : 'Saved',
          isActive: isDirty,
          onTap: isDirty ? onSave : null,
        ),
      ],
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onTap != null;
    
    final Color effectiveColor = isEnabled 
        ? (isActive ? AppColors.actionGreen : (isDark ? AppColors.dark150 : AppColors.dark900))
        : AppColors.dark400.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: AppAnimations.medium,
            scale: isActive ? 1.1 : 1.0,
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              color: effectiveColor,
              size: 22, // Matched to nav bar icon system
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: AppTypography.sizeCaption, // Standardized to 10px
              fontWeight: isActive ? AppTypography.weightExtraBold : AppTypography.weightMedium,
              color: effectiveColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
