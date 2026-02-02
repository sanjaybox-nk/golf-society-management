import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';

import '../../../../core/theme/contrast_helper.dart';

class GroupingStrategySelectionScreen extends ConsumerWidget {
  const GroupingStrategySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final current = societyConfig.groupingStrategy;
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);

    final strategies = [
      _GroupingStrategyOption(
        id: 'balanced',
        label: 'Balanced Teams',
        description: 'Balances total handicap across all groups. Best for team events or fair competition.',
        icon: Icons.balance,
      ),
      _GroupingStrategyOption(
        id: 'progressive',
        label: 'Progressive (Low HC First)',
        description: 'Orders groups by ability (Leaders out first). Great for pace of play.',
        icon: Icons.trending_up,
      ),
      _GroupingStrategyOption(
        id: 'similar',
        label: 'Similar Ability',
        description: 'Groups players of similar skill levels together. Good for peer competition.',
        icon: Icons.group_work,
      ),
      _GroupingStrategyOption(
        id: 'random',
        label: 'Random Draw',
        description: 'Randomly mixes players (respects pairings/buggies). Fun for social events.',
        icon: Icons.shuffle,
      ),
    ];

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Grouping Strategy',
        subtitle: 'Select default method',
        isLarge: true,
        leadingWidth: 70,
        leading: Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text('Back', style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: strategies.length,
        itemBuilder: (context, index) {
          final strategy = strategies[index];
          final isSelected = strategy.id == current;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BoxyArtFloatingCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              onTap: () {
                controller.setGroupingStrategy(strategy.id);
                // context.pop(); // Removed as per user request
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1) 
                          : Colors.grey.shade100,
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
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strategy.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
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
