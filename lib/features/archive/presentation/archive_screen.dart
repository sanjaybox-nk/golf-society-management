import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/season.dart';
import 'archive_provider.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(archiveSeasonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: seasonsAsync.when(
        data: (seasons) {
          if (seasons.isEmpty) {
            return const Center(child: Text('No archived seasons yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              return _SeasonCard(season: seasons[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          '${season.year} Season',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Captain: $captain'),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.history_edu,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          _buildDetailRow(context, 'Player of the Year', poty, Icons.emoji_events),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Major Winners',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          ...majors.map((winner) => Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 8),
                Text(winner),
              ],
            ),
          )),
        ],
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
