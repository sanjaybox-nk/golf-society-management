import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/leaderboard_config.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../features/events/presentation/events_provider.dart';
import 'package:uuid/uuid.dart';

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
    final typeName = _formatEnum(type.name).toUpperCase();
    final templatesAsync = ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: BoxyArtAppBar(
        title: typeName,
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
              subtitle: 'Create a new $typeName setup from scratch.',
              icon: Icons.add_circle_outline,
              isPrimary: true,
              onTap: () async {
                if (isPicker) {
                   // Navigate to builder in non-template mode (Season)
                   // We return the config result from the builder back to the picker flow
                   final result = await context.push<LeaderboardConfig>('/admin/seasons/leaderboards/create/${type.name}/builder');
                   if (result != null && context.mounted) {
                     context.pop(result);
                   }
                } else {
                  // Template Mode: Create NEW Template
                  context.push('/admin/settings/leaderboards/create/${type.name}/builder');
                }
              },
            ),

            const BoxyArtSectionTitle(
              title: 'SAVED TEMPLATES',
              padding: EdgeInsets.only(top: 32, bottom: 16),
            ),
            
            StreamBuilder<List<LeaderboardConfig>>(
              stream: templatesAsync,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final templates = snapshot.data!;
                
                // Filter templates by Type
                final filtered = templates.where((t) {
                   return _getTypeFromConfig(t) == type;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No saved $typeName templates found.',
                        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filtered.map((t) => _buildTemplateCard(context, t, ref)).toList(),
                );
              },
            ),

            const BoxyArtSectionTitle(
              title: 'SYSTEM PRESETS',
              padding: EdgeInsets.only(top: 32, bottom: 16),
            ),
            
            // Placeholder for System Presets
             _buildGalleryCard(
              context,
              title: 'Standard $typeName',
              subtitle: 'The traditional configuration.',
              icon: Icons.auto_awesome,
              onTap: () async {
                 if (isPicker) {
                   final result = await context.push<LeaderboardConfig>('/admin/seasons/leaderboards/create/${type.name}/builder');
                   if (result != null && context.mounted) context.pop(result);
                 } else {
                   context.push('/admin/settings/leaderboards/create/${type.name}/builder');
                 }
              },
              badges: [
                const _RuleBadge(label: 'STANDARD'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, LeaderboardConfig template, WidgetRef ref) {
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
        if (isPicker) return false; // Can't delete from picker mode usually, or maybe we allow? Let's disallow for safety.
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
        ref.read(leaderboardTemplatesRepositoryProvider).deleteTemplate(template.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Template deleted"), duration: Duration(seconds: 2)),
        );
      },
      child: _buildGalleryCard(
        context,
        title: template.name.toUpperCase(),
        subtitle: 'Custom Template', // Could add more details here based on config type
        icon: _getFormatIcon(type),
        onTap: () {
          if (isPicker) {
             // PICKER MODE: Use this template to create a NEW valid config
             // We pass a copy with a NEW ID so it doesn't conflict
             final newConfig = template.copyWith(id: const Uuid().v4());
             
             context.push<LeaderboardConfig>(
               '/admin/seasons/leaderboards/create/${type.name}/builder', 
               extra: newConfig 
             ).then((result) {
               if (result != null && context.mounted) context.pop(result);
             });
          } else {
            // TEMPLATE MODE: Edit the template itself
            context.push(
              '/admin/settings/leaderboards/edit/${template.id}',
              extra: template
            );
          }
        },
        onChevronTap: !isPicker ? () {
           context.push(
              '/admin/settings/leaderboards/edit/${template.id}',
              extra: template
            );
        } : null,
        badges: [
           // specific badges could go here
        ],
      ),
    );
  }
  
  IconData _getFormatIcon(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return Icons.format_list_numbered;
      case LeaderboardType.bestOfSeries: return Icons.emoji_events;
      case LeaderboardType.eclectic: return Icons.filter_hdr;
      case LeaderboardType.markerCounter: return Icons.flag;
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
                          color: Colors.black87
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
              Wrap(spacing: 0, runSpacing: 8, children: badges),
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
