import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/leaderboard_config.dart';
import '../../../../features/events/presentation/events_provider.dart';

import 'controls/oom_control.dart';
import 'controls/best_of_control.dart';
import 'controls/eclectic_control.dart';
import 'controls/marker_counter_control.dart';

class LeaderboardBuilderScreen extends ConsumerWidget {
  final LeaderboardType type;
  final LeaderboardConfig? existingConfig; // If editing
  final bool isTemplate; // If saving to Templates repo instead of returning

  const LeaderboardBuilderScreen({
    super.key,
    required this.type,
    this.existingConfig,
    this.isTemplate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BoxyArtAppBar(
        title: _formatEnum(type.name).toUpperCase(),
        centerTitle: true,
        isLarge: true,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildControl(context, ref),
      ),
    );
  }

  Widget _buildControl(BuildContext context, WidgetRef ref) {
    Future<void> handleSave(LeaderboardConfig config) async {
      if (isTemplate) {
        // Save to Repo
        try {
          final repo = ref.read(leaderboardTemplatesRepositoryProvider);
          if (existingConfig != null) {
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

    switch (type) {
      case LeaderboardType.orderOfMerit:
        return OrderOfMeritControl(existingConfig: existingConfig, onSave: handleSave);
      case LeaderboardType.bestOfSeries:
        return BestOfSeriesControl(existingConfig: existingConfig, onSave: handleSave);
      case LeaderboardType.eclectic:
        return EclecticControl(existingConfig: existingConfig, onSave: handleSave);
      case LeaderboardType.markerCounter:
        return MarkerCounterControl(existingConfig: existingConfig, onSave: handleSave);
    }
  }

  String _formatEnum(String val) {
    final RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = val.replaceAllMapped(exp, (Match m) => ' ${m.group(0)}');
    return result[0].toUpperCase() + result.substring(1);
  }
}
