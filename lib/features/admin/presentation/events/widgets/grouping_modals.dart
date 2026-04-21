import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/utils/string_utils.dart';
import '../../../providers/admin_ui_providers.dart';

class GroupingModals {
  static void showGroupingRules(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentStrategy = ref.watch(groupingStrategyProvider);

    final List<({String id, String label, String description, IconData icon, IconData selectedIcon})> strategies = [
      (
        id: 'balanced',
        label: 'Balanced Teams',
        description: 'Balances total handicap across all groups. Best for team events or fair competition.',
        icon: Icons.balance_outlined,
        selectedIcon: Icons.balance_rounded,
      ),
      (
        id: 'progressive',
        label: 'Progressive (Low HC First)',
        description: 'Orders groups by ability (Leaders out first). Great for pace of play.',
        icon: Icons.trending_up_rounded,
        selectedIcon: Icons.trending_up_rounded,
      ),
      (
        id: 'similar',
        label: 'Similar Ability',
        description: 'Groups players of similar skill levels together. Good for peer competition.',
        icon: Icons.group_work_outlined,
        selectedIcon: Icons.group_work_rounded,
      ),
      (
        id: 'random',
        label: 'Random Draw',
        description: 'Randomly mixes players (respects pairings/buggies). Fun for social events.',
        icon: Icons.shuffle_rounded,
        selectedIcon: Icons.shuffle_rounded,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Use branch navigator so the global bottom nav bar stays visible behind the sheet.
      useRootNavigator: false,
      builder: (context) => Material(
        color: theme.cardColor,
        borderRadius: AppShapes.sheet,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branded Grabber Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.dark400.withValues(alpha: 0.15),
                    borderRadius: AppShapes.xs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              Text('Grouping Strategy', style: AppTypography.displayPage),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how players should be assigned to groups for this event.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.dark400),
              ),
              const SizedBox(height: AppSpacing.x3l),
              
              ...strategies.map((strategy) {
                final isSelected = currentStrategy == strategy.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StrategyOption(
                    id: strategy.id,
                    label: strategy.label,
                    description: strategy.description,
                    icon: isSelected ? strategy.selectedIcon : strategy.icon,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(groupingStrategyProvider.notifier).set(strategy.id);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
              
              // Extra space to clear the floating navigation bar
              const SizedBox(height: AppSpacing.x5l),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrategyOption extends StatelessWidget {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StrategyOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.lg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) 
              : (isDark ? AppColors.dark800 : AppColors.dark50),
          borderRadius: AppShapes.lg,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.dark400,
              size: 44,
              iconSize: 22,
              isTinted: true,
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.micro.copyWith(
                    fontWeight: AppTypography.weightExtraBold,
                    color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.dark600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
