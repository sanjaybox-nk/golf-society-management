import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/competition.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../competitions/presentation/competitions_provider.dart';
import '../../../competitions/presentation/widgets/competition_shared_widgets.dart';

class CompetitionTemplateGalleryScreen extends ConsumerWidget {
  final String typeStr;
  final bool isTemplate;
  final bool isPicker;
  final String? eventId;

  const CompetitionTemplateGalleryScreen({
    super.key,
    required this.typeStr,
    this.isTemplate = false,
    this.isPicker = false,
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
      title: 'Create $gameName Game',
      subtitle: 'Templates and blank formats',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      actions: const [],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Start Blank Card
              BoxyArtCard(
                onTap: () async {
                  if (isPicker) {
                    final result = await context.push<String>('/admin/events/competitions/new/create/$typeStr');
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

              templatesAsync.when(
                data: (templates) {
                    final filtered = templates.where((t) {
                    final rules = t.rules;
                    
                    // 1. If we are in a subtype-specific gallery (e.g. Fourball), show ONLY that subtype.
                    if (subtype != null && subtype != CompetitionSubtype.none) {
                      return rules.subtype == subtype;
                    }

                    // 2. For general format galleries (e.g. Match Play, Stableford, Scramble), 
                    // show all subtypes EXCEPT those that have their own dedicated categories in the picker (Pairs).
                    final isDedicatedSubtype = rules.subtype == CompetitionSubtype.fourball || 
                                              rules.subtype == CompetitionSubtype.foursomes;

                    // Match by format (e.g. matchPlay, stableford)
                    if (rules.format == format) {
                      return !isDedicatedSubtype;
                    }

                    return false;
                  }).toList();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: BoxyArtEmptyState(
                          title: 'No Templates Found',
                          message: 'No saved templates for ${CompetitionRules(format: format, subtype: subtype ?? CompetitionSubtype.none).gameName.toUpperCase()}',
                          icon: Icons.search_off_rounded,
                          isCompact: true,
                        ),
                      );
                    }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BoxyArtSectionTitle(
                        title: 'SAVED TEMPLATES',
                      ),
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
          ref.read(competitionsRepositoryProvider).deleteTemplate(template.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Template deleted"), duration: Duration(seconds: 2)),
          );
        },
        child: CompetitionRulesCard(
          eventId: template.id,
          competition: template,
          title: '', 
          showChevron: true,
          onTap: () {
            if (isPicker) {
               context.pop(template.id);
            } else {
              context.push('/admin/settings/templates/edit/${template.id}');
            }
          },
        ),
      ),
    );
  }
}
