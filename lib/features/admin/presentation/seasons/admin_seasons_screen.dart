import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/season.dart';
import '../../../events/presentation/events_provider.dart';



class AdminSeasonsScreen extends ConsumerWidget {
  const AdminSeasonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsProvider);

    return HeadlessScaffold(
      title: 'Seasons',
      subtitle: 'Archive and setup event seasons',
      showBack: true,
      onBack: () => context.pop(),
      titleSuffix: BoxyArtGlassIconButton(
        icon: Icons.add_rounded,
        iconSize: 24,
        onPressed: () => context.push('/admin/settings/seasons/new'),
        tooltip: 'Add New Season',
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'All Seasons', ),
              const SizedBox(height: 12),
              seasonsAsync.when(
                data: (seasons) {
                  if (seasons.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Text(
                          'No seasons created yet',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: seasons.map((season) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SeasonCard(season: season),
                    )).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SeasonCard extends ConsumerWidget {
  final Season season;
  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = season.status == SeasonStatus.active;
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(season.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog(
          context: context,
          title: 'Delete Season?',
          message: 'This will permanently delete "${season.name}" and ALL its events. This action cannot be undone.',
          confirmText: 'Delete Permanently',
          onConfirm: () {
            ref.read(seasonsRepositoryProvider).deleteSeason(season.id);
            Navigator.of(context, rootNavigator: true).pop(true);
          },
        );
      },
      child: BoxyArtCard(
        onTap: () => context.push('/admin/settings/seasons/edit/${season.id}', extra: season),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
        child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.name,
                      style: AppTypography.label.copyWith(fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${DateFormat('MMM yyyy').format(season.startDate)} - ${DateFormat('MMM yyyy').format(season.endDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (season.isCurrent)
                      BoxyArtPill.status(
                        label: 'Current Season',
                        color: theme.primaryColor,
                        icon: Icons.star_rounded,
                      )
                    else if (isActive)
                      BoxyArtButton(
                        title: 'Make Current',
                        onTap: () => ref.read(seasonsRepositoryProvider).setCurrentSeason(season.id),
                        fullWidth: false,
                      )
                    else
                      BoxyArtPill.status(
                        label: 'Archived',
                        color: theme.disabledColor,
                        icon: Icons.archive_outlined,
                      ),
                  ],
                ),
              ),
              if (isActive)
                BoxyArtGlassIconButton(
                  icon: Icons.archive_outlined,
                  onPressed: () => _showCloseSeasonDialog(context, ref),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: theme.dividerColor.withValues(alpha: 0.3), 
                  size: 14,
                ),
            ],
          ),
        ),
      );
  }

  void _showCloseSeasonDialog(BuildContext context, WidgetRef ref) {
    // In a real app, we'd prompt for AGM results here.
    // For this prototype, we'll just close it.
    showBoxyArtDialog(
      context: context,
      title: 'Close Season?',
      message: 'This will move the season and all its events to the Archive. This cannot be undone.',
      onConfirm: () async {
        await ref.read(seasonsRepositoryProvider).closeSeason(season.id, {
          'captain': 'TBD',
          'playerOfTheYear': 'TBD',
          'majorWinners': [],
        });
        if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      },
      confirmText: 'Close & Archive',
    );
  }
}
