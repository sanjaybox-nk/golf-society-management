import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:intl/intl.dart';

class AdminGroupingHubCard extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback onGenerate;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const AdminGroupingHubCard({
    super.key,
    required this.event,
    required this.onGenerate,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(groupingStrategyProvider);
    final teeTime = ref.watch(groupingTeeTimeProvider) ?? event.teeOffTime ?? DateTime.now();
    final interval = ref.watch(groupingIntervalProvider) ?? event.teeOffInterval;
    final matchMode = ref.watch(groupingMatchPlayModeProvider);
    final isDirty = ref.watch(groupingDirtyProvider);
    final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BoxyArtSectionTitle(title: 'GROUPING & TEE TIMES'),
        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _HubRow(
                icon: Icons.auto_awesome_outlined,
                title: 'Generation Strategy',
                subtitle: toTitleCase(strategy),
                onTap: isLocked ? null : () => _showStrategyPicker(context, ref, strategy),
              ),
              const Divider(height: 1),
              _HubRow(
                icon: Icons.play_circle_outline_rounded,
                title: 'Tee-off Time (Seed)',
                subtitle: DateFormat('HH:mm').format(teeTime),
                onTap: isLocked ? null : () => _showTimePicker(context, ref, teeTime),
              ),
              const Divider(height: 1),
              _HubRow(
                icon: Icons.timer_outlined,
                title: 'Tee Interval',
                subtitle: 'Minutes between groups',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                      onPressed: isLocked ? null : () => ref.read(groupingIntervalProvider.notifier).set((interval - 1).clamp(5, 20)),
                    ),
                    Text(
                      '${interval}m',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: AppTypography.sizeBody,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      onPressed: isLocked ? null : () => ref.read(groupingIntervalProvider.notifier).set((interval + 1).clamp(5, 20)),
                    ),
                  ],
                ),
              ),
              if (!isLocked) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BoxyArtButton(
                    title: 'Generate Groups',
                    icon: Icons.auto_awesome_rounded,
                    onTap: onGenerate,
                    isPrimary: true,
                    fullWidth: true,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _HubRow(
                icon: Icons.grid_view_rounded,
                title: 'Manual Grouping',
                subtitle: 'Drag & drop players into tee times',
                onTap: () {
                  // This could navigate or just scroll down
                },
              ),
              const Divider(height: 1),
              ModernSwitchRow(
                label: 'Match Play Mode',
                subtitle: 'Enable match linkage for this event',
                icon: Icons.sports_kabaddi_outlined,
                value: matchMode,
                onChanged: isLocked ? null : (val) => ref.read(groupingMatchPlayModeProvider.notifier).set(val),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: BoxyArtButton(
                title: 'Reset',
                icon: Icons.refresh_rounded,
                onTap: isLocked ? null : onReset,
                isGhost: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: BoxyArtButton(
                title: isDirty ? 'Save Grouping' : 'Saved',
                icon: isDirty ? Icons.save_rounded : Icons.check_circle_outline_rounded,
                onTap: isDirty ? onSave : null,
                isPrimary: isDirty,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStrategyPicker(BuildContext context, WidgetRef ref, String current) {
    showBoxyArtDialog(
      context: context,
      title: 'Select Strategy',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StrategyOption(label: 'Random', value: 'random', current: current, onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v)),
          _StrategyOption(label: 'Balanced', value: 'balanced', current: current, onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v)),
          _StrategyOption(label: 'Progressive', value: 'progressive', current: current, onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v)),
          _StrategyOption(label: 'Similar Ability', value: 'similar', current: current, onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v)),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, WidgetRef ref, DateTime current) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time != null) {
      final now = DateTime.now();
      ref.read(groupingTeeTimeProvider.notifier).set(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    }
  }
}

class _HubRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _HubRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacitySubtle),
                borderRadius: AppShapes.md,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeBody)),
                  Text(subtitle, style: TextStyle(color: AppColors.dark600, fontSize: AppTypography.sizeLabel)),
                ],
              ),
            ),
            if (trailing != null) trailing! 
            else if (onTap != null) Icon(Icons.chevron_right_rounded, color: AppColors.dark300),
          ],
        ),
      ),
    );
  }
}

class _StrategyOption extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onSelect;

  const _StrategyOption({required this.label, required this.value, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        onSelect(value);
        Navigator.pop(context);
      },
    );
  }
}
