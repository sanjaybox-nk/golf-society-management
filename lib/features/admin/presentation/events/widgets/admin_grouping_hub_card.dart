import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/features/admin/providers/admin_ui_providers.dart';
import 'package:golf_society/utils/string_utils.dart';
import 'package:intl/intl.dart';

class AdminGroupingHubCard extends ConsumerWidget {
  final GolfEvent event;
  final VoidCallback onGenerate;

  const AdminGroupingHubCard({

    super.key,
    required this.event,
    required this.onGenerate,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(groupingStrategyProvider);
    final teeTime = event.teeOffTime ?? DateTime.now();
    final interval = event.teeOffInterval;
    final isLocked = ref.watch(groupingIsLockedProvider) ?? (event.grouping['locked'] ?? false);

    final localGroups = ref.watch(groupingLocalGroupsProvider);

    final bool hasGroups = localGroups != null && localGroups.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _HubRow(
                icon: Icons.auto_awesome_outlined,
                title: 'Generation strategy',
                subtitle: toSentenceCase(strategy),
                onTap: isLocked ? null : () => _showStrategyPicker(context, ref, strategy),
              ),
              const BoxyArtDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.dark400),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Using fixed course settings: Starting at ${DateFormat('HH:mm').format(teeTime)} with ${interval}m intervals.',
                        style: TextStyle(
                          fontSize: AppTypography.sizeLabel,
                          color: AppColors.dark500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked) ...[
                const BoxyArtDivider(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BoxyArtButton(
                    title: hasGroups ? 'Regenerate Groups' : 'Generate Groups',
                    icon: hasGroups ? Icons.refresh_rounded : Icons.auto_awesome_rounded,
                    onTap: onGenerate,
                    isPrimary: true,
                    fullWidth: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }


  void _showStrategyPicker(BuildContext context, WidgetRef ref, String current) {
    showBoxyArtDialog(
      context: context,
      title: 'Select strategy',
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
}



class _HubRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _HubRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
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
            if (onTap != null) Icon(Icons.chevron_right_rounded, color: AppColors.dark300),
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
