import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/season.dart';
import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../core/shared_ui/headless_scaffold.dart';
import 'archive_provider.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(archiveSeasonsProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return HeadlessScaffold(
      title: 'Archive',
      showBack: true,
      onBack: () => context.go('/'),
      backgroundColor: beigeBackground,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BoxyArtSectionTitle(
                  title: 'Archived Seasons',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                seasonsAsync.when(
                  data: (seasons) {
                    if (seasons.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text('No archived seasons yet.'),
                        ),
                      );
                    }
                    return Column(
                      children: seasons.map((season) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SeasonCard(season: season),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final Season season;

  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context) {
    final captain = season.agmData['captain'] as String? ?? 'Unknown';
    final poty = season.agmData['playerOfTheYear'] as String? ?? 'Unknown';
    final majors = (season.agmData['majorWinners'] as List<dynamic>?)?.cast<String>() ?? [];
    final primary = Theme.of(context).primaryColor;

    return ModernCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          title: Text(
            '${season.year} Season',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
          ),
          subtitle: Text('Captain: $captain', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history_edu_rounded,
              color: primary,
              size: 20,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Player of the Year', poty, Icons.emoji_events_rounded),
            const SizedBox(height: 16),
            Text(
              'MAJOR WINNERS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            ...majors.map((winner) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: primary.withValues(alpha: 0.6)),
                  const SizedBox(width: 12),
                  Text(winner, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
