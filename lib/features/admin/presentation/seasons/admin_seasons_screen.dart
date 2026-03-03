import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/season.dart';
import '../../../events/presentation/events_provider.dart';
import '../../../competitions/services/leaderboard_invoker_service.dart';



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
    final isDark = theme.brightness == Brightness.dark;
    const identityColor = Colors.teal;
    final iconColor = isActive ? identityColor : (isDark ? AppColors.dark400 : AppColors.dark300);
    final bgColor = isActive ? identityColor.withValues(alpha: 0.1) : (isDark ? AppColors.dark800 : AppColors.dark50);

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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circular Icon Container (56x56)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isActive ? Icons.calendar_today_rounded : Icons.archive_outlined, 
                  color: iconColor, 
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    season.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.pureWhite : AppColors.dark900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('MMM yyyy').format(season.startDate)} - ${DateFormat('MMM yyyy').format(season.endDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                  if (season.isCurrent) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: identityColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'CURRENT SEASON',
                          style: TextStyle(
                            color: identityColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            if (isActive && !season.isCurrent)
              BoxyArtGlassIconButton(
                icon: Icons.star_outline_rounded,
                iconSize: 20,
                onPressed: () => ref.read(seasonsRepositoryProvider).setCurrentSeason(season.id),
              ),
            if (isActive)
              BoxyArtGlassIconButton(
                icon: Icons.refresh_rounded,
                iconSize: 20,
                onPressed: () async {
                  final result = await showBoxyArtDialog(
                    context: context,
                    title: 'Recalculate Standings?',
                    message: 'This will re-calculate all standings for this season across all leaderboards. This might take a few seconds.',
                    confirmText: 'Recalculate',
                  );
                  if (result == true) {
                    await ref.read(leaderboardInvokerServiceProvider).recalculateAll(season.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Standings recalculated successfully')),
                      );
                    }
                  }
                },
              ),
            if (isActive)
              IconButton(
                icon: Icon(
                  Icons.archive_outlined, 
                  size: 20, 
                  color: isDark ? AppColors.dark400 : AppColors.dark200,
                ),
                onPressed: () => _showCloseSeasonDialog(context, ref),
              ),
            Icon(
              Icons.chevron_right_rounded, 
              color: isDark ? AppColors.dark400 : AppColors.dark300, 
              size: 20,
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
