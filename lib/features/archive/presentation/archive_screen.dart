import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/domain/models/season.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'archive_provider.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(archiveSeasonsProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

    return HeadlessScaffold(
      title: 'Archive',
      subtitle: 'Past society glory and seasons',
      showBack: false,
      onBack: () => context.go('/'),
      backgroundColor: beigeBackground,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BoxyArtSectionTitle(
                  title: 'Archived Seasons',),
                const SizedBox(height: AppSpacing.md),
                seasonsAsync.when(
                  data: (seasons) {
                    if (seasons.isEmpty) {
                      return const Center(
                        child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Text('No archived seasons yet.'),
                        ),
                      );
                    }
                    return Column(
                      children: seasons.map((season) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          title: Text(
            '${season.year} Season',
            style: const TextStyle(fontWeight: AppTypography.weightBold, fontSize: AppTypography.sizeLargeBody, letterSpacing: -0.5),
          ),
          subtitle: Text('Captain: $captain', style: TextStyle(color: AppColors.dark500, fontSize: AppTypography.sizeBodySmall)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: AppColors.opacityLow),
              borderRadius: AppShapes.md,
            ),
            child: Icon(
              Icons.history_edu_rounded,
              color: primary,
              size: AppShapes.iconMd,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow(context, 'Player of the Year', poty, Icons.emoji_events_rounded),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'MAJOR WINNERS',
              style: TextStyle(
                fontSize: AppTypography.sizeCaption,
                fontWeight: AppTypography.weightBold,
                letterSpacing: 1.1,
                color: AppColors.dark400,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...majors.map((winner) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, size: AppShapes.iconXs, color: primary.withValues(alpha: AppColors.opacityHalf)),
                  const SizedBox(width: AppSpacing.md),
                  Text(winner, style: const TextStyle(fontWeight: AppTypography.weightMedium, fontSize: AppTypography.sizeBodySmall)),
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
        Icon(icon, size: AppShapes.iconMd, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: AppTypography.weightSemibold, fontSize: AppTypography.sizeBody),
            ),
          ],
        ),
      ],
    );
  }
}
