import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../../features/events/presentation/events_provider.dart';
import 'package:uuid/uuid.dart';
import 'widgets/leaderboard_shared_widgets.dart';

class LeaderboardTemplateGalleryScreen extends ConsumerWidget {
  final LeaderboardType type;
  final bool isTemplate;
  final bool isPicker;

  const LeaderboardTemplateGalleryScreen({
    super.key,
    required this.type,
    this.isTemplate = false,
    this.isPicker = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final shapes = theme.extension<AppShapeTokens>();
    final typeName = _getDisplayName(type);
    final templatesAsync = ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();

    return HeadlessScaffold(
      title: '$typeName Templates',
      subtitle: isPicker ? 'Assign to current season' : 'Create leaderboard templates',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.x4l,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Start Blank Card (Only available when editing templates in settings)
              if (!isPicker)
                StaggeredEntrance(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.cardToCard),
                    child: BoxyArtCard(
                      onTap: () {
                        context.push('/admin/settings/leaderboards/create/${type.name}');
                      },
                      child: Row(
                        children: [
                          BoxyArtIconBadge(
                            icon: _getFormatIcon(type),
                            color: _getFormatColor(type),
                            isTinted: true,
                            size: shapes?.iconBadgeSize ?? AppShapes.iconHero,
                            iconSize: shapes?.iconBadgeIconSize ?? AppShapes.iconLg,
                          ),
                          const SizedBox(width: AppSpacing.standard),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START BLANK',
                                  style: AppTypography.labelStrong.copyWith(
                                    letterSpacing: AppTypography.lsLabel,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Create a new $typeName from scratch',
                                  style: AppTypography.micro.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? AppColors.dark200
                                        : AppColors.dark400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.add_rounded,
                            color: AppColors.dark400,
                            size: AppShapes.iconMd,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              StreamBuilder<List<LeaderboardConfig>>(
                stream: templatesAsync,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final templates = snapshot.data!;
                  final filtered = templates.where((t) {
                    return _getTypeFromConfig(t) == type;
                  }).toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BoxyArtSectionTitle(
                        title: 'Saved Templates',
                      ),
                      ...filtered.asMap().entries.map((entry) {
                        final idx = entry.key + (isPicker ? 0 : 1);
                        final t = entry.value;
                        return StaggeredEntrance(
                          index: idx,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.cardToCard),
                            child: _buildTemplateCard(context, t, ref),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(BuildContext context, LeaderboardConfig template, WidgetRef ref) {
    return Dismissible(
      key: Key(template.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: AppShapes.xl,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.x2l),
        child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
      ),
      confirmDismiss: (direction) async {
        if (isPicker) return false;
        // Block deletion if any season (active or archived) references this template.
        final allSeasons = await ref.read(seasonsRepositoryProvider).getSeasons();
        final usedInSeasons = allSeasons.where((s) => s.leaderboardIds.contains(template.id)).toList();
        if (usedInSeasons.isNotEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Cannot delete — used in: ${usedInSeasons.map((s) => s.name).join(', ')}',
                ),
              ),
            );
          }
          return false;
        }
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Template?',
          message: 'This will permanently remove "${template.name}" from your saved templates.',
          confirmText: 'Delete',
          isDangerous: true,
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
          onConfirm: () async {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(leaderboardTemplatesRepositoryProvider).deleteTemplate(template.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template deleted"), duration: Duration(seconds: 2)),
        );
      },
      child: LeaderboardRulesCard(
        config: template,
        showChevron: true,
        onTap: () {
          if (isPicker) {
             context.pop(template);
          } else {
            context.push(
              '/admin/settings/leaderboards/edit/${template.id}',
              extra: template
            );
          }
        },
      ),
    );
  }
  
  String _getDisplayName(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return 'Order of Merit';
      case LeaderboardType.bestOfSeries: return 'Best of Series';
      case LeaderboardType.eclectic: return 'Eclectic';
      case LeaderboardType.markerCounter: return 'Birdie Tree';
    }
  }

  IconData _getFormatIcon(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return Icons.emoji_events_rounded;
      case LeaderboardType.bestOfSeries: return Icons.list_alt_rounded;
      case LeaderboardType.eclectic: return Icons.grid_on_rounded;
      case LeaderboardType.markerCounter: return Icons.park_rounded;
    }
  }

  Color _getFormatColor(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return AppColors.amber500;
      case LeaderboardType.bestOfSeries: return AppColors.teamA;
      case LeaderboardType.eclectic: return AppColors.teamB;
      case LeaderboardType.markerCounter: return AppColors.lime500;
    }
  }

  String _formatEnum(String val) {
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }
  
  LeaderboardType _getTypeFromConfig(LeaderboardConfig config) {
    return config.map(
      orderOfMerit: (_) => LeaderboardType.orderOfMerit,
      bestOfSeries: (_) => LeaderboardType.bestOfSeries,
      eclectic: (_) => LeaderboardType.eclectic,
      markerCounter: (_) => LeaderboardType.markerCounter,
    );
  }

}

