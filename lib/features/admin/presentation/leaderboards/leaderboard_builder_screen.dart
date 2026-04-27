import 'package:golf_society/design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:collection/collection.dart';
import '../../../../features/events/presentation/events_provider.dart';

import 'controls/oom_control.dart';
import 'controls/best_of_control.dart';
import 'controls/eclectic_control.dart';
import 'controls/marker_counter_control.dart';

class LeaderboardBuilderScreen extends ConsumerWidget {
  final LeaderboardType? type;
  final String? configId;
  final LeaderboardConfig? existingConfig; // If passed as extra
  final bool isTemplate; // If saving to Templates repo instead of returning

  const LeaderboardBuilderScreen({
    super.key,
    this.type,
    this.configId,
    this.existingConfig,
    this.isTemplate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we have an ID but no config, we need to load it. 
    // In this app's pattern, we usually pass extra, but if we don't, we can look it up in the repository's watch stream.
    LeaderboardConfig? effectiveConfig = existingConfig;
    
    if (configId != null && effectiveConfig == null) {
      final templatesStream = ref.watch(leaderboardTemplatesRepositoryProvider).watchTemplates();
      return StreamBuilder<List<LeaderboardConfig>>(
        stream: templatesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final list = snapshot.data ?? [];
          effectiveConfig = list.firstWhereOrNull((c) => c.id == configId);
          if (effectiveConfig == null) return const Center(child: Text('Template not found'));
          return _buildScaffold(context, ref, effectiveConfig);
        },
      );
    }

    return _buildScaffold(context, ref, effectiveConfig);
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, LeaderboardConfig? effectiveConfig) {
    final effectiveType = type ?? (effectiveConfig != null ? _getTypeFromConfig(effectiveConfig) : LeaderboardType.orderOfMerit);

    return HeadlessScaffold(
      title: _formatEnum(effectiveType.name),
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      subtitle: effectiveConfig != null ? 'Edit configuration' : 'New configuration',
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.x2l,
            bottom: AppSpacing.x4l,
          ),
          sliver: SliverToBoxAdapter(
            child: StaggeredEntrance(
              index: 0,
              child: _buildControl(context, ref, effectiveType, effectiveConfig),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControl(BuildContext context, WidgetRef ref, LeaderboardType effectiveType, LeaderboardConfig? effectiveConfig) {
    Future<void> handleSave(LeaderboardConfig config) async {
      if (isTemplate) {
        // Save to Repo
        try {
          final repo = ref.read(leaderboardTemplatesRepositoryProvider);
          if (effectiveConfig != null) {
            await repo.updateTemplate(config);
          } else {
            await repo.addTemplate(config);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template Saved!')));
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      } else {
        // Return Config for memory/season
        context.pop(config);
      }
    }

    switch (effectiveType) {
      case LeaderboardType.orderOfMerit:
        return OrderOfMeritControl(existingConfig: effectiveConfig is OrderOfMeritConfig ? effectiveConfig : null, onSave: handleSave);
      case LeaderboardType.bestOfSeries:
        return BestOfSeriesControl(existingConfig: effectiveConfig is BestOfSeriesConfig ? effectiveConfig : null, onSave: handleSave);
      case LeaderboardType.eclectic:
        return EclecticControl(existingConfig: effectiveConfig is EclecticConfig ? effectiveConfig : null, onSave: handleSave);
      case LeaderboardType.markerCounter:
        return MarkerCounterControl(existingConfig: effectiveConfig is MarkerCounterConfig ? effectiveConfig : null, onSave: handleSave);
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
