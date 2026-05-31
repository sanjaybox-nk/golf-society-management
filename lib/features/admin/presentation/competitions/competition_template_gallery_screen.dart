import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:uuid/uuid.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../competitions/presentation/widgets/competition_shared_widgets.dart';

class CompetitionTemplateGalleryScreen extends ConsumerWidget {
  final String typeStr;
  final bool isTemplate;
  final bool isPicker;
  final bool isOverlay;
  final String? eventId;

  const CompetitionTemplateGalleryScreen({
    super.key,
    required this.typeStr,
    this.isTemplate = false,
    this.isPicker = false,
    this.isOverlay = false,
    this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subtype = CompetitionSubtype.values.where((e) => e.name.toLowerCase() == typeStr.toLowerCase()).firstOrNull;
    final format = CompetitionFormat.values.where((e) => e.name.toLowerCase() == typeStr.toLowerCase()).firstOrNull ?? CompetitionFormat.stableford;

    final rules = CompetitionRules(
      format: format,
      subtype: subtype ?? CompetitionSubtype.none,
    );
    final gameName = rules.gameName;

    final templatesAsync = ref.watch(templatesListProvider);

    return HeadlessScaffold(
      title: 'Create $gameName',
      subtitle: 'Templates and blank formats',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              BoxyArtCard(
                onTap: () async {
                  if (isPicker) {
                    final overlay = isOverlay ? '?overlay=true' : '';
                    final result = await context.push<String>('/admin/events/manage/$eventId/game-setup/create/$typeStr$overlay');
                    if (result != null && context.mounted) {
                      context.pop(result);
                    }
                  } else {
                    context.push('/admin/settings/templates/create/$typeStr');
                  }
                },
                child: Row(
                  children: [
                    BoxyArtIconBadge(
                      icon: rules.gameIcon,
                      size: 44,
                      iconSize: 22,
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
                            'Create a new $gameName from scratch',
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
                      color: theme.brightness == Brightness.dark
                          ? AppColors.dark400
                          : AppColors.dark200,
                      size: AppShapes.iconMd,
                    ),
                  ],
                ),
              ),

              templatesAsync.when(
                data: (templates) {
                  final filtered = templates.where((t) {
                    final rules = t.rules;
                    if (subtype != null && subtype != CompetitionSubtype.none) {
                      return rules.subtype == subtype;
                    }
                    final isDedicatedSubtype =
                      rules.subtype == CompetitionSubtype.fourball ||
                      rules.subtype == CompetitionSubtype.foursomes ||
                      rules.subtype == CompetitionSubtype.matchPlaySeason;

                    if (rules.format == format) {
                      return !isDedicatedSubtype;
                    }
                    return false;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: BoxyArtEmptyCard(
                        title: 'No Templates Found',
                        message: 'No saved templates for ${CompetitionRules(format: format, subtype: subtype ?? CompetitionSubtype.none).gameName.toUpperCase()}',
                        icon: Icons.search_off_rounded,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BoxyArtSectionTitle(title: 'SAVED TEMPLATES'),
                      ...filtered.map((t) => _buildTemplateCard(context, t, ref)),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Text('Error loading templates: $e'),
              ),

              const SizedBox(height: AppSpacing.x4l),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(BuildContext context, Competition template, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(template.id),
        direction: DismissDirection.horizontal,
        // Swipe right → Duplicate (lime)
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.lime500,
            borderRadius: AppShapes.xl,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: AppSpacing.x2l),
          child: const Icon(Icons.copy_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
        ),
        // Swipe left → Delete (coral)
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: AppColors.coral500,
            borderRadius: AppShapes.xl,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.x2l),
          child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _handleDuplicate(context, template, ref);
            return false;
          }
          // Delete confirmation
          return await showBoxyArtDialog<bool>(
            context: context,
            title: 'Delete Template?',
            message: 'Are you sure you want to delete this template?',
            confirmText: 'Delete',
            isDangerous: true,
            onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
            onConfirm: () async {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
          ) ?? false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            ref.read(competitionsRepositoryProvider).deleteTemplate(template.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template deleted'), duration: Duration(seconds: 2)),
            );
          }
        },
        child: CompetitionRulesCard(
          eventId: template.id,
          competition: template,
          title: '',
          showChevron: true,
          onTap: () async {
            if (isPicker) {
              if (isOverlay && template.rules.effectiveMode == CompetitionMode.teams) {
                await _showOverlayTeamGuard(context, template, ref);
              } else {
                context.pop(template.id);
              }
            } else {
              context.push('/admin/settings/templates/edit/${template.id}');
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleDuplicate(BuildContext context, Competition template, WidgetRef ref) async {
    final copy = template.copyWith(
      id: const Uuid().v4(),
      name: 'Copy of ${template.name ?? template.rules.gameName}',
      type: CompetitionType.game,
    );
    await ref.read(competitionsRepositoryProvider).addTemplate(copy);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template duplicated'),
          backgroundColor: AppColors.teamA,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showOverlayTeamGuard(BuildContext context, Competition template, WidgetRef ref) async {
    final nameController = TextEditingController(
      text: 'Copy of ${template.name ?? template.rules.gameName}',
    );

    await BoxyArtBottomSheet.show<void>(
      context: context,
      title: 'Team Play Not Supported as Overlay',
      child: BoxyArtFormColumn(
        children: [
          BoxyArtCard(
            child: BoxyArtFormColumn(
              children: [
                Text(
                  'This template uses team play, which isn\'t supported as a match play overlay. '
                  'Create a singles version to use as an overlay — your original template is unchanged.',
                  style: AppTypography.label.copyWith(color: AppColors.dark400),
                ),
                const BoxyArtDivider(),
                BoxyArtInputField(
                  label: 'New template name',
                  controller: nameController,
                ),
              ],
            ),
          ),
          BoxyArtButton(
            title: 'Copy & Use as Overlay',
            fullWidth: true,
            onTap: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final singlesRules = template.rules.copyWith(
                subtype: CompetitionSubtype.none,
                mode: CompetitionMode.singles,
              );
              final copy = template.copyWith(
                id: const Uuid().v4(),
                name: name,
                rules: singlesRules,
                type: CompetitionType.game,
              );
              final newId = await ref.read(competitionsRepositoryProvider).addTemplate(copy);
              if (context.mounted) {
                Navigator.of(context).pop();
                context.pop(newId);
              }
            },
          ),
          BoxyArtButton(
            title: 'Start Fresh',
            fullWidth: true,
            isTinted: true,
            onTap: () async {
              Navigator.of(context).pop();
              if (context.mounted) {
                final result = await context.push<String>(
                  '/admin/events/manage/$eventId/game-setup/create/matchPlay?overlay=true',
                );
                if (result != null && context.mounted) {
                  context.pop(result);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
