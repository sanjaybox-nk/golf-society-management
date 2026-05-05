import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';

/// Icon-button action bar rendered in the grouping screen's subtitle slot.
/// All actions are surfaced as callbacks — no direct state access.
class GroupingToolbar extends StatelessWidget {
  const GroupingToolbar({
    super.key,
    required this.event,
    required this.isLocked,
    required this.isDirty,
    required this.hasGroups,
    required this.matchPlayMode,
    required this.onGenerate,
    required this.onRecalculate,
    required this.onToggleLock,
    required this.onToggleMatchMode,
    required this.onSave,
    required this.onPublish,
  });

  final GolfEvent event;
  final bool isLocked;
  final bool isDirty;
  final bool hasGroups;
  final bool matchPlayMode;
  final VoidCallback onGenerate;
  final VoidCallback onRecalculate;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleMatchMode;
  final VoidCallback onSave;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 1. Generate / Regenerate
          Opacity(
            opacity: event.isRegistrationClosed ? 1.0 : 0.4,
            child: BoxyArtGlassIconButton(
              icon: Icons.refresh_rounded,
              tooltip: hasGroups ? 'Regenerate' : 'Generate',
              onPressed: event.isRegistrationClosed
                  ? () {
                      if (isLocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Groupings locked. Unlock to regenerate.')),
                        );
                        return;
                      }
                      onGenerate();
                    }
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 2. Recalculate PHCs
          BoxyArtGlassIconButton(
            icon: Icons.calculate_outlined,
            tooltip: 'Recalculate PHCs',
            onPressed: onRecalculate,
          ),
          const SizedBox(width: AppSpacing.sm),

          // 3. Lock / Unlock
          Opacity(
            opacity: event.isRegistrationClosed ? 1.0 : 0.4,
            child: BoxyArtGlassIconButton(
              icon: isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              tooltip: isLocked ? 'Unlock' : 'Lock',
              iconColor: isLocked ? primary : null,
              onPressed: event.isRegistrationClosed
                  ? () {
                      if (!hasGroups) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generate groups first!')),
                        );
                        return;
                      }
                      onToggleLock();
                    }
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 4. Match Mode (only for match play events)
          if (event.secondaryTemplateId != null) ...[
            BoxyArtGlassIconButton(
              icon: matchPlayMode ? Icons.check_circle_rounded : Icons.circle_outlined,
              tooltip: 'Match Mode',
              iconColor: matchPlayMode ? primary : null,
              onPressed: onToggleMatchMode,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // 5. Save
          Opacity(
            opacity: event.isRegistrationClosed ? 1.0 : 0.4,
            child: BoxyArtGlassIconButton(
              icon: Icons.save_rounded,
              tooltip: 'Save',
              iconColor: isDirty ? primary : null,
              onPressed: event.isRegistrationClosed ? onSave : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 6. Publish / Unpublish
          BoxyArtGlassIconButton(
            icon: event.isGroupingPublished ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            tooltip: event.isGroupingPublished ? 'Unpublish' : 'Publish',
            iconColor: event.isGroupingPublished ? primary : null,
            onPressed: onPublish,
          ),
        ],
      ),
    );
  }
}
