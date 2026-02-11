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
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: beigeBackground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      typeName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Choose a template or start blank',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Start Blank Card
                    _buildGalleryCard(
                      context,
                      title: 'Start Blank',
                      subtitle: 'Create a new $typeName from scratch',
                      icon: Icons.add_circle_outline_rounded,
                      isPrimary: true,
                      onTap: () async {
                        if (isPicker) {
                           final result = await context.push<LeaderboardConfig>('/admin/seasons/leaderboards/create/${type.name}/builder');
                           if (result != null && context.mounted) {
                             context.pop(result);
                           }
                        } else {
                          context.push('/admin/settings/leaderboards/create/${type.name}/builder');
                        }
                      },
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
                            const SizedBox(height: 32),
                            const BoxyArtSectionTitle(title: 'Saved Templates', padding: EdgeInsets.zero),
                            const SizedBox(height: 12),
                            ...filtered.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTemplateCard(context, t, ref),
                            )),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    const BoxyArtSectionTitle(title: 'System Presets', padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                     _buildGalleryCard(
                      context,
                      title: 'Standard $typeName',
                      subtitle: 'The traditional configuration',
                      icon: Icons.auto_awesome_rounded,
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
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          
          // Back Button sticky
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.dividerColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isPrimary ? theme.colorScheme.primary : Colors.grey,
                  size: 24,
                ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onChevronTap != null)
                IconButton(
                  onPressed: onChevronTap,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
            ],
          ),
          if (badges != null && badges.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 0, runSpacing: 8, children: badges),
          ],
        ],
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
