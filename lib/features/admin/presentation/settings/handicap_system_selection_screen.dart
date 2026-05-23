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
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);

    return HeadlessScaffold(
      title: 'Handicap System',
      subtitle: 'Select calculation provider',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      onBack: () => context.pop(),
      actions: const [],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'CALCULATION PROVIDER',
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: HandicapSystem.values.asMap().entries.map((item) {
                    final index = item.key;
                    final system = item.value;
                    final isSelected = system == societyConfig.handicapSystem;
                    final isLast = index == HandicapSystem.values.length - 1;

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(themeControllerProvider.notifier).setHandicapSystem(system);
                          },
                          borderRadius: BorderRadius.only(
                            topLeft: index == 0 ? Radius.circular(config.cardRadius) : Radius.zero,
                            topRight: index == 0 ? Radius.circular(config.cardRadius) : Radius.zero,
                            bottomLeft: isLast ? Radius.circular(config.cardRadius) : Radius.zero,
                            bottomRight: isLast ? Radius.circular(config.cardRadius) : Radius.zero,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0 ? Radius.circular(config.cardRadius) : Radius.zero,
                                topRight: index == 0 ? Radius.circular(config.cardRadius) : Radius.zero,
                                bottomLeft: isLast ? Radius.circular(config.cardRadius) : Radius.zero,
                                bottomRight: isLast ? Radius.circular(config.cardRadius) : Radius.zero,
                              ),
                            ),
                            child: Row(
                              children: [
                                BoxyArtIconBadge(
                                  icon: _getIcon(system),
                                  size: 44,
                                  iconSize: 22,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        system.shortName.toUpperCase(),
                                        style: AppTypography.labelStrong.copyWith(
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getDescription(system),
                                        style: AppTypography.micro.copyWith(
                                          color: isDark ? AppColors.dark300 : AppColors.dark400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded, 
                                    color: theme.primaryColor, 
                                    size: AppShapes.iconLg,
                                  )
                                else
                                  Icon(
                                    Icons.chevron_right_rounded, 
                                    color: isDark ? AppColors.dark400 : AppColors.dark300,
                                    size: AppShapes.iconMd,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) const BoxyArtDivider(verticalPadding: 0),
                      ],
                    );
                  }).toList(),
                ),
              ),
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
