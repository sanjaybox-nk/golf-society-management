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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'PAIRING LOGIC'),
              ...strategies.map((strategy) {
                final isSelected = strategy.id == current;
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                const identityColor = Colors.indigo;
                final iconColor = isSelected ? identityColor : (isDark ? AppColors.dark300 : AppColors.dark400);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(16),
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
                            color: identityColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              strategy.icon, 
                              color: iconColor, 
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strategy.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strategy.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8, top: 2),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: identityColor,
                              size: 24,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Icon(
                              Icons.chevron_right_rounded, 
                              color: isDark ? AppColors.dark400 : AppColors.dark300,
                              size: 20,
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
