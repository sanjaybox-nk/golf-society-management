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
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          iconSize: 24,
          onPressed: () => context.push('/admin/settings/seasons/new'),
          tooltip: 'Add New Season',
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(
                title: 'All Seasons',
                isPeeking: true,
              ),
              seasonsAsync.when(
                data: (seasons) {
                  if (seasons.isEmpty) {
                    return const BoxyArtEmptyCard(
                      title: 'No Seasons Configured',
                      message: 'Active fixture calendars and historical archives will populate here once you initialize your first season.',
                      icon: Icons.calendar_month_rounded,
                    );
                  }
                  return Column(
                    children: seasons.map((season) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.standard),
                      child: _SeasonCard(season: season),
                    )).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
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
    const identityColor = AppColors.lime500;
    final iconColor = isActive ? identityColor : (isDark ? AppColors.dark400 : AppColors.dark300);
    final bgColor = isActive ? identityColor.withValues(alpha: AppColors.opacityLow) : (isDark ? AppColors.dark800 : AppColors.dark50);

    return Dismissible(
      key: Key(season.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: AppSpacing.x2l),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.coral500,
          borderRadius: AppShapes.xl,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.pureWhite, size: AppShapes.iconLg),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            BoxyArtIconBadge(
              icon: isActive ? Icons.calendar_today_rounded : Icons.archive_outlined,
              color: iconColor,
              isTinted: true,
              size: 44,
              iconSize: 22,
              useCircle: false,
            ),
            const SizedBox(width: AppSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    season.name.toUpperCase(),
                    style: AppTypography.labelStrong.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('MMM yyyy').format(season.startDate)} - ${DateFormat('MMM yyyy').format(season.endDate)}',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                  if (season.isCurrent) ...[
                    const SizedBox(height: AppSpacing.sm),
                    BoxyArtPill.status(
                      label: 'CURRENT SEASON',
                      icon: Icons.star_rounded,
                      color: AppColors.lime500,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
              BoxyArtGlassIconButton(
                icon: Icons.archive_outlined,
                iconSize: 20,
                onPressed: () => _showCloseSeasonDialog(context, ref),
                tooltip: 'Archive Season',
              ),
            Icon(
              Icons.arrow_forward_ios_rounded, 
              color: isDark ? AppColors.dark400 : AppColors.dark200, 
              size: AppShapes.iconXs,
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
