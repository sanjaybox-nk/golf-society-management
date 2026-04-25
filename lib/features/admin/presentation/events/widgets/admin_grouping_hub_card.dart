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

    return BoxyArtFormColumn(
      children: [
        BoxyArtCard(
          padding: EdgeInsets.zero,
          child: BoxyArtFormColumn(
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
              if (!event.isRegistrationClosed && !event.occursToday) ...[
                const BoxyArtDivider(),
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text(
                      'Registration not completed',
                      style: TextStyle(
                        color: AppColors.dark400,
                        fontStyle: FontStyle.italic,
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                  ),
                ),
              ] else if (!event.isGroupingPublished && !isLocked) ...[
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
      title: 'Grouping Strategy',
      content: SingleChildScrollView(
        child: BoxyArtFormColumn(
          children: [
            _StrategyOption(
              label: 'Random', 
              description: 'Socially varied pairings with no influence from ability.',
              icon: Icons.shuffle_rounded,
              value: 'random', 
              current: current, 
              onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v),
            ),
            _StrategyOption(
              label: 'Balanced', 
              description: 'Aims to normalize total handicap across all groups.',
              icon: Icons.balance_rounded,
              value: 'balanced', 
              current: current, 
              onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v),
            ),
            _StrategyOption(
              label: 'Progressive', 
              description: 'Ordered by handicap - lower handicaps at the front.',
              icon: Icons.trending_up_rounded,
              value: 'progressive', 
              current: current, 
              onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v),
            ),
            _StrategyOption(
              label: 'Similar Ability', 
              description: 'Groups players with similar handicaps together.',
              icon: Icons.people_outline_rounded,
              value: 'similar', 
              current: current, 
              onSelect: (v) => ref.read(groupingStrategyProvider.notifier).set(v),
            ),
          ],
        ),
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
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.micro.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 1.0,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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


class _StrategyOption extends ConsumerWidget {
  final String label;
  final String description;
  final IconData icon;
  final String value;
  final String current;
  final ValueChanged<String> onSelect;

  const _StrategyOption({
    required this.label, 
    required this.description,
    required this.icon,
    required this.value, 
    required this.current, 
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final isSelected = value == current;
    
    final primaryColor = Color(config.primaryColor);
    final bgColor = isDark ? Color(config.backgroundColor) : AppColors.dark50;
    final cardRadius = config.cardRadius;
    
    return InkWell(
      onTap: () {
        onSelect(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: isSelected 
                ? primaryColor.withValues(alpha: 0.5) 
                : (isDark ? AppColors.dark500 : AppColors.dark200).withValues(alpha: 0.2),
            width: isSelected ? AppShapes.borderLight : AppShapes.borderThin,
          ),
          color: isSelected 
              ? primaryColor.withValues(alpha: 0.08) 
              : bgColor.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: icon,
              color: isSelected ? primaryColor : Colors.transparent,
              iconColor: isSelected ? primaryColor : null,
              size: 42,
              iconSize: 20,
              fillOpacity: isSelected ? 0.12 : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label, 
                    style: AppTypography.body.copyWith(
                      fontWeight: AppTypography.weightStrong,
                      color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description, 
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark200 : AppColors.dark400,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded, 
                color: primaryColor, 
                size: AppShapes.iconSm,
              ),
          ],
        ),
      ),
    );
  }
}
