import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/handicap_system.dart';


class HandicapSystemSelectionScreen extends ConsumerWidget {
  const HandicapSystemSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final societyConfig = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);
    final beigeBackground = theme.scaffoldBackgroundColor;

    return HeadlessScaffold(
      title: 'Handicap System',
      subtitle: 'Select calculation provider',
      showBack: true,
      autoPrefix: false, // Fix header overlap
      onBack: () => context.pop(),
      backgroundColor: beigeBackground,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'CALCULATION PROVIDER'),
              ...HandicapSystem.values.map((system) {
                final isSelected = system == societyConfig.handicapSystem;
                final isDark = theme.brightness == Brightness.dark;
                const identityColor = Colors.blue;
                final iconColor = isSelected ? identityColor : (isDark ? AppColors.dark300 : AppColors.dark400);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      ref.read(themeControllerProvider.notifier).setHandicapSystem(system);
                      context.pop();
                    },
                    child: Row(
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
                              _getIcon(system), 
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
                                system.shortName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDescription(system),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: identityColor, size: 24)
                        else
                          Icon(
                            Icons.chevron_right_rounded, 
                            color: isDark ? AppColors.dark400 : AppColors.dark300,
                            size: 20,
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
