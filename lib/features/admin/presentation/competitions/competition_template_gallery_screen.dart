import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/competition.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../competitions/presentation/competitions_provider.dart';

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
    // Determine the type from string
    final subtype = CompetitionSubtype.values.where((e) => e.name == typeStr).firstOrNull;
    final format = CompetitionFormat.values.where((e) => e.name == typeStr).firstOrNull ?? CompetitionFormat.stableford;
    
    final gameName = (subtype != null && subtype != CompetitionSubtype.none)
        ? subtype.name.toUpperCase()
        : format.name.toUpperCase();

    final templatesAsync = ref.watch(templatesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: BoxyArtAppBar(
        title: '$gameName GALLERY',
        showBack: true,
        isLarge: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Blank Card
            _buildGalleryCard(
              context,
              title: 'Start Blank',
              subtitle: 'Create a new $gameName setup from scratch.',
              icon: Icons.add_circle_outline,
              isPrimary: true,
              onTap: () async {
                if (isPicker) {
                   // Navigate to builder in non-template mode
                   final result = await context.push<String>('/admin/competitions/new/create/$typeStr');
                   if (result != null && context.mounted) {
                     context.pop(result);
                   }
                } else {
                  final path = isTemplate 
                      ? '/admin/settings/templates/create/$typeStr'
                      : '/admin/settings/templates/create/$typeStr'; // Both lead to template builder
                  context.push(path);
                }
              },
            ),

            const BoxyArtSectionTitle(
              title: 'SAVED TEMPLATES',
              padding: EdgeInsets.only(top: 32, bottom: 16),
            ),
            
            templatesAsync.when(
              data: (templates) {
                // Filter templates by subtype or format
                final filtered = templates.where((t) {
                  if (subtype != null && subtype != CompetitionSubtype.none) {
                    return t.rules.subtype == subtype;
                  }
                  // For generic formats (Stableford, Scramble, etc) match the format.
                  // This allows internal subtypes like Texas Scramble to show up.
                  return t.rules.format == format;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No saved $gameName templates found.',
                        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filtered.map((t) => _buildTemplateCard(context, t, ref)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error loading templates: $e'),
            ),

            const BoxyArtSectionTitle(
              title: 'SYSTEM PRESETS',
              padding: EdgeInsets.only(top: 32, bottom: 16),
            ),
            
            _buildGalleryCard(
              context,
              title: 'Standard $gameName',
              subtitle: 'The traditional configuration used by most societies.',
              icon: Icons.auto_awesome,
              onTap: () async {
                if (isPicker) {
                   final result = await context.push<String>('/admin/events/competitions/new/create/$typeStr');
                   if (result != null && context.mounted) {
                     context.pop(result);
                   }
                } else {
                  final path = isTemplate 
                      ? '/admin/settings/templates/create/$typeStr'
                      : '/admin/settings/templates/create/$typeStr';
                  context.push(path);
                }
              },
              badges: [
                _RuleBadge(label: _getDefaultAllowance(format, subtype)),
                const _RuleBadge(label: '1 ROUND'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultAllowance(CompetitionFormat format, CompetitionSubtype? subtype) {
    if (subtype == CompetitionSubtype.fourball) return '90% HCP';
    if (subtype == CompetitionSubtype.foursomes) return '50% HCP';
    if (format == CompetitionFormat.stableford) return '95% HCP';
    if (format == CompetitionFormat.matchPlay) return '100% DIFF';
    return '100% HCP';
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
      child: _buildGalleryCard(
        context,
        title: (template.name != null && template.name!.isNotEmpty) 
            ? template.name!.toUpperCase() 
            : template.rules.format.name.toUpperCase(),
        subtitle: '${template.rules.mode.name} • ${template.rules.roundsCount} ROUND',
        icon: _getFormatIcon(template.rules.format),
        onTap: () {
          if (isPicker) {
             // RETURN TO EVENT FORM WITH TEMPLATE ID
             context.pop(template.id);
          } else {
            context.push('/admin/settings/templates/edit/${template.id}');
          }
        },
        onChevronTap: () {
          context.push('/admin/settings/templates/edit/${template.id}');
        },
        badges: [
          _RuleBadge(label: '${(template.rules.handicapAllowance * 100).toInt()}% HCP'),
          _RuleBadge(label: template.rules.tieBreak.name.toUpperCase()),
        ],
      ),
    );
  }

  IconData _getFormatIcon(CompetitionFormat format) {
    switch (format) {
      case CompetitionFormat.stableford: return Icons.format_list_numbered;
      case CompetitionFormat.stroke: return Icons.golf_course;
      case CompetitionFormat.maxScore: return Icons.vertical_align_top;
      case CompetitionFormat.matchPlay: return Icons.compare_arrows;
      case CompetitionFormat.scramble: return Icons.group_work;
    }
  }

  Widget _buildGalleryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onChevronTap,
    bool isPrimary = false,
    List<Widget>? badges,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isPrimary 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(icon, color: isPrimary ? theme.colorScheme.primary : Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onChevronTap != null)
                  IconButton(
                    onPressed: onChevronTap,
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )
                else
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            if (badges != null && badges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(children: badges),
            ],
          ],
        ),
      ),
    );
  }
}

class _RuleBadge extends StatelessWidget {
  final String label;
  const _RuleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
