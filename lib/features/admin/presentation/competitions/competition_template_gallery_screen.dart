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

  const CompetitionTemplateGalleryScreen({
    super.key,
    required this.typeStr,
    this.isTemplate = false,
    this.isPicker = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtype = CompetitionSubtype.values.where((e) => e.name == typeStr).firstOrNull;
    final format = CompetitionFormat.values.where((e) => e.name == typeStr).firstOrNull ?? CompetitionFormat.stableford;

    final gameName = CompetitionRules(
      format: format,
      subtype: subtype ?? CompetitionSubtype.none,
    ).gameName;

    final templatesAsync = ref.watch(templatesListProvider);

    return HeadlessScaffold(
      title: 'Create $gameName Game',
      autoPrefix: false,
      subtitle: 'Choose a saved template or start blank',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: AppSpacing.x2l, left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.x2l),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Start Blank Card
              _BlankTemplateCard(
                title: 'Start Blank',
                subtitle: 'Create a new $gameName from scratch',
                icon: CompetitionRules(
                  format: format,
                  subtype: subtype ?? CompetitionSubtype.none,
                ).gameIcon,
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
              ),

              templatesAsync.when(
                data: (templates) {
                  final filtered = templates.where((t) {
                      final rules = t.rules;
                      if (subtype != null && subtype != CompetitionSubtype.none) {
                        return rules.subtype == subtype;
                      }
                      // Scramble always has a non-none subtype (texas/florida),
                      // so match on format alone for formats that use subtypes internally.
                      if (format == CompetitionFormat.scramble) {
                        return rules.format == format;
                      }
                      return rules.format == format && rules.subtype == CompetitionSubtype.none;
                  }).toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.x3l),
                      const BoxyArtSectionTitle(title: 'Saved Templates', ),
                      const SizedBox(height: AppSpacing.md),
                      ...filtered.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: _buildTemplateCard(context, t, ref),
                      )),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Text('Error loading templates: $e'),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }


  Widget _buildTemplateCard(BuildContext context, Competition template, WidgetRef ref) {
    return Dismissible(
      key: Key(template.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: AppShapes.x2l,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.x2l),
        child: const Icon(Icons.delete_outline, color: AppColors.pureWhite, size: AppShapes.iconLg),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Template?"),
            content: const Text("Are you sure you want to delete this template?"),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text("Cancel")),
              TextButton(
                onPressed: () => context.pop(true), 
                child: const Text("Delete", style: TextStyle(color: AppColors.coral500)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(competitionsRepositoryProvider).deleteTemplate(template.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template deleted"), duration: Duration(seconds: 2)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: CompetitionRulesCard(
          eventId: template.id,
          competition: template, // Pass the object directly!
          title: '', // No section title needed for gallery items
          showChevron: true,
          onTap: () {
            if (isPicker) {
               context.pop(template.id);
            } else {
              context.push('/admin/settings/templates/edit/${template.id}');
            }
          },
          onChevronTap: () {
            context.push('/admin/settings/templates/edit/${template.id}');
          },
        ),
      ),
    );
  }
}

class _BlankTemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BlankTemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityLow),
              borderRadius: AppShapes.md,
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: AppColors.opacityMedium)),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: AppShapes.iconLg),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppTypography.sizeBody,
                    fontWeight: AppTypography.weightBlack,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.sizeLabel,
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: AppTypography.weightSemibold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: AppShapes.iconMd),
        ],
      ),
    );
  }
}
