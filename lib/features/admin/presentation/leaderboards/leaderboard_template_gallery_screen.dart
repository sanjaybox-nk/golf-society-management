import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/design_system/design_system.dart';
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
    final typeName = _formatEnum(type.name);
    final templatesAsync = ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();

    return HeadlessScaffold(
      title: typeName,
      subtitle: isPicker ? 'Choose a template to add to your season' : 'Choose a template or start blank',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Start Blank Card (Only available when editing templates in settings)
              if (!isPicker)
                _buildGalleryCard(
                  context,
                  title: 'Start Blank',
                  subtitle: 'Create a new $typeName from scratch',
                  icon: Icons.add_circle_outline_rounded,
                  isPrimary: true,
                  onTap: () {
                    context.push('/admin/settings/leaderboards/create/${type.name}');
                  },
                ),

              if (!isPicker)
                const SizedBox(height: 16),

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
                      const BoxyArtSectionTitle(title: 'Saved Templates', ),
                      const SizedBox(height: 12),
                      ...filtered.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTemplateCard(context, t, ref),
                      )),
                    ],
                  );
                },
              ),

              const SizedBox(height: 100),
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
        iconColor: _getFormatColor(type),
        onTap: () {
          if (isPicker) {
             // PICKER MODE: Instantly return this template to be added to the season.
             // We pass a copy with a NEW ID so it doesn't conflict with the master template.
             final newConfig = template.copyWith(id: const Uuid().v4());
             context.pop(newConfig);
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
      case LeaderboardType.orderOfMerit: return Icons.emoji_events_rounded;
      case LeaderboardType.bestOfSeries: return Icons.list_alt_rounded;
      case LeaderboardType.eclectic: return Icons.grid_on_rounded;
      case LeaderboardType.markerCounter: return Icons.park_rounded;
    }
  }

  Color _getFormatColor(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.orderOfMerit: return Colors.amber;
      case LeaderboardType.bestOfSeries: return Colors.blue;
      case LeaderboardType.eclectic: return Colors.purple;
      case LeaderboardType.markerCounter: return Colors.green;
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
    Color? iconColor,
    List<Widget>? badges,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor = iconColor ?? (isPrimary ? AppColors.lime500 : (isDark ? AppColors.dark300 : AppColors.dark400));
    final effectiveBg = iconColor?.withValues(alpha: 0.1) ?? (isPrimary ? AppColors.lime500.withValues(alpha: 0.1) : (isDark ? AppColors.dark600 : AppColors.lightHeader));
    
    return BoxyArtCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: effectiveBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: effectiveColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.label.copyWith(
                        fontSize: 12,
                        color: isDark ? AppColors.dark300 : AppColors.dark400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, 
                color: isDark ? AppColors.dark400 : AppColors.dark300, 
                size: 20,
              ),
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

