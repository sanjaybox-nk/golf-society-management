import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/shared_ui/headless_scaffold.dart';
import '../../../../core/theme/theme_controller.dart';



class GroupingStrategySelectionScreen extends ConsumerWidget {
  const GroupingStrategySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final current = societyConfig.groupingStrategy;
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
      onBack: () => context.pop(),
      backgroundColor: beigeBackground,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...strategies.map((strategy) {
                final isSelected = strategy.id == current;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ModernCard(
                    onTap: () => controller.setGroupingStrategy(strategy.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
                                  : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              strategy.icon,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strategy.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strategy.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
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
