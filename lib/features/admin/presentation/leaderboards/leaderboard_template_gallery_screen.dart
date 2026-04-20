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
    final typeName = _formatEnum(type.name);
    final templatesAsync = ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();

    return HeadlessScaffold(
      title: '$typeName Library',
      subtitle: isPicker ? 'Assign to current season' : 'Manage format blueprints',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
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
                    padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
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
                                size: 44,
                                iconSize: 22,
                                useCircle: false, 
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'START BLANK',
                                      style: AppTypography.labelStrong.copyWith(
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Create a new $typeName from scratch',
                                      style: AppTypography.caption.copyWith(
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
                                color: theme.brightness == Brightness.dark 
                                    ? AppColors.dark400 
                                    : AppColors.dark200, 
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
                            padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
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
             // Create a season-bound instance from the blueprint
             final newConfig = template.copyWith(
               id: const Uuid().v4(),
               scope: LeaderboardScope.seasonOnly,
             );
             context.pop(newConfig);
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

