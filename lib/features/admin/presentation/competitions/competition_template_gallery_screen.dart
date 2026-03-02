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
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 24),
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
                      const SizedBox(height: 32),
                      const BoxyArtSectionTitle(title: 'Saved Templates', ),
                      const SizedBox(height: 12),
                      ...filtered.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTemplateCard(context, t, ref),
                      )),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
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
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
        padding: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
