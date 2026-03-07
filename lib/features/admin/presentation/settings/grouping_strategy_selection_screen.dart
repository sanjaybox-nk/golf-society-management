import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';



class GroupingStrategySelectionScreen extends ConsumerWidget {
  const GroupingStrategySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeControllerProvider).groupingStrategy;
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    final strategies = [
      _GroupingStrategyOption(
        id: 'balanced',
        label: 'Balanced Teams',
        description: 'Balances total handicap across all groups. Best for team events or fair competition.',
        icon: Icons.balance_rounded,
      ),
      _GroupingStrategyOption(
        id: 'progressive',
        label: 'Progressive (Low HC First)',
        description: 'Orders groups by ability (Leaders out first). Great for pace of play.',
        icon: Icons.trending_up_rounded,
      ),
      _GroupingStrategyOption(
        id: 'similar',
        label: 'Similar Ability',
        description: 'Groups players of similar skill levels together. Good for peer competition.',
        icon: Icons.group_work_rounded,
      ),
      _GroupingStrategyOption(
        id: 'random',
        label: 'Random Draw',
        description: 'Randomly mixes players (respects pairings/buggies). Fun for social events.',
        icon: Icons.shuffle_rounded,
      ),
    ];

    return HeadlessScaffold(
      title: 'Grouping Strategy',
      subtitle: 'Select automatic pairing logic',
      showBack: true,
      autoPrefix: false, // Fix header overlap
      onBack: () => context.pop(),
      backgroundColor: beigeBackground,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'PAIRING LOGIC'),
              ...strategies.map((strategy) {
                final isSelected = strategy.id == current;
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                const identityColor = AppColors.teamA;
                final iconColor = isSelected ? identityColor : (isDark ? AppColors.dark300 : AppColors.dark400);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    onTap: () {
                      ref.read(themeControllerProvider.notifier).setGroupingStrategy(strategy.id);
                      context.pop();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular Icon Container (56x56)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: identityColor.withValues(alpha: AppColors.opacityLow),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              strategy.icon, 
                              color: iconColor, 
                              size: AppShapes.iconLg,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strategy.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: AppTypography.sizeButton,
                                  fontWeight: AppTypography.weightExtraBold,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strategy.description,
                                style: TextStyle(
                                  fontSize: AppTypography.sizeLabelStrong,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: AppSpacing.sm, top: 2),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: identityColor,
                              size: AppShapes.iconLg,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm, top: 2),
                            child: Icon(
                              Icons.chevron_right_rounded, 
                              color: isDark ? AppColors.dark400 : AppColors.dark300,
                              size: AppShapes.iconMd,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _GroupingStrategyOption {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  _GroupingStrategyOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}
