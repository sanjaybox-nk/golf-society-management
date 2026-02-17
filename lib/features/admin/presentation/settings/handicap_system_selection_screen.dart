import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../models/handicap_system.dart';


class HandicapSystemSelectionScreen extends ConsumerWidget {
  const HandicapSystemSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;
    final primary = Theme.of(context).primaryColor;

    return HeadlessScaffold(
      title: 'Handicap System',
      subtitle: 'Select calculation provider',
      showBack: true,
      onBack: () => context.pop(),
      backgroundColor: beigeBackground,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 32),
              
              ...HandicapSystem.values.map((system) {
                final isSelected = system == societyConfig.handicapSystem;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ModernCard(
                    onTap: () {
                      controller.setHandicapSystem(system);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primary.withValues(alpha: 0.1) 
                                  : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _getIcon(system),
                              color: isSelected ? primary : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  system.shortName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getDescription(system),
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIcon(HandicapSystem system) {
    switch (system) {
      case HandicapSystem.igolf: return Icons.flag_rounded;
      case HandicapSystem.ghin: return Icons.public_rounded;
      case HandicapSystem.golfIreland: return Icons.landscape_rounded;
      case HandicapSystem.golfLink: return Icons.link_rounded;
      case HandicapSystem.whs: return Icons.numbers_rounded;
    }
  }

  String _getDescription(HandicapSystem system) {
    switch (system) {
      case HandicapSystem.igolf: return 'England Golf / iGolf subscribers';
      case HandicapSystem.ghin: return 'USGA / GHIN (North America)';
      case HandicapSystem.golfIreland: return 'Golf Ireland Members';
      case HandicapSystem.golfLink: return 'Golf Australia Members';
      case HandicapSystem.whs: return 'Generic World Handicap System';
    }
  }
}
