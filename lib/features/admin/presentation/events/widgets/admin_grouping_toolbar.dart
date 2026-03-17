import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';

class AdminGroupingToolbar extends ConsumerWidget {
  final GolfEvent event;
  final List<GolfEvent> allEvents;
  final Map<String, double> handicapMap;
  final Competition? competition;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onAutoGenerate;

  const AdminGroupingToolbar({
    super.key,
    required this.event,
    required this.allEvents,
    required this.handicapMap,
    required this.competition,
    required this.onReset,
    required this.onSave,
    required this.onAutoGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);
    final isDirty = ref.watch(groupingDirtyProvider);
    final matchPlayMode = ref.watch(groupingMatchPlayModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppShapes.xl,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          // 1. Lock/Unlock Toggle
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => ref.read(groupingIsLockedProvider.notifier).setLocked(!isLocked),
                icon: Icon(
                  isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: isLocked ? AppColors.dark400 : AppColors.teamA,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(isLocked ? 'Locked' : 'Unlocked', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          const VerticalDivider(width: 1, indent: 4, endIndent: 4),
          const SizedBox(width: AppSpacing.md),
          
          // 2. Control Pill
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _ToolbarAction(
                    icon: Icons.rule_rounded,
                    label: 'Rules',
                    onTap: () {
                      // Navigate to rules or show modal
                    },
                  ),
                  _ToolbarAction(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Generate',
                    onTap: onAutoGenerate,
                  ),
                  _ToolbarAction(
                    icon: matchPlayMode ? Icons.sports_kabaddi_rounded : Icons.sports_kabaddi_outlined,
                    label: 'Matches',
                    isActive: matchPlayMode,
                    onTap: () => ref.read(groupingMatchPlayModeProvider.notifier).set(!matchPlayMode),
                  ),
                  _ToolbarAction(
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                    onTap: onReset,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),
          
          // 3. Save/Publish Button
          ElevatedButton(
            onPressed: isDirty ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teamA,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
            ),
            child: Text(
              isDirty ? 'Save Changes' : (event.isGroupingPublished ? 'Published' : 'Publish'),
              style: const TextStyle(fontSize: 12, fontWeight: AppTypography.weightExtraBold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = AppColors.teamA;
    final color = isActive ? activeColor : theme.iconTheme.color?.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? AppTypography.weightBlack : AppTypography.weightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
