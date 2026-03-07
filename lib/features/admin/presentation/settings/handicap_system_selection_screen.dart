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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'CALCULATION PROVIDER'),
              ...HandicapSystem.values.map((system) {
                final isSelected = system == societyConfig.handicapSystem;
                final isDark = theme.brightness == Brightness.dark;
                const identityColor = AppColors.teamA;
                final iconColor = isSelected ? identityColor : (isDark ? AppColors.dark300 : AppColors.dark400);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                            color: identityColor.withValues(alpha: AppColors.opacityLow),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _getIcon(system), 
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
                                system.shortName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: AppTypography.sizeButton,
                                  fontWeight: AppTypography.weightExtraBold,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDescription(system),
                                style: TextStyle(
                                  fontSize: AppTypography.sizeLabelStrong,
                                  color: isDark ? AppColors.dark300 : AppColors.dark400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: identityColor, size: AppShapes.iconLg)
                        else
                          Icon(
                            Icons.chevron_right_rounded, 
                            color: isDark ? AppColors.dark400 : AppColors.dark300,
                            size: AppShapes.iconMd,
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
