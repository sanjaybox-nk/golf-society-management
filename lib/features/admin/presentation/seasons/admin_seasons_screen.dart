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
      topPill: BoxyArtPill.committee(label: 'ADMIN'),

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
                    return Column(
                      children: [
                        const BoxyArtEmptyCard(
                          title: 'No Seasons Configured',
                          message: 'Active fixture calendars and historical archives will populate here once you initialize your first season.',
                          icon: Icons.calendar_month_rounded,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        SizedBox(
                          width: double.infinity,
                          child: BoxyArtButton(
                            title: 'Create New Season',
                            icon: Icons.add_rounded,
                            isTinted: true,
                            fullWidth: true,
                            onTap: () => context.push('/admin/settings/seasons/new'),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      ...seasons.map((season) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.standard),
                        child: _SeasonCard(season: season),
                      )),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: BoxyArtButton(
                          title: 'Create New Season',
                          icon: Icons.add_rounded,
                          isTinted: true,
                          fullWidth: true,
                          onTap: () => context.push('/admin/settings/seasons/new'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.x3l),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: AppSpacing.pageBottom),
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
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${DateFormat('MMM yyyy').format(season.startDate)} - ${DateFormat('MMM yyyy').format(season.endDate)}',
                    style: AppTypography.micro.copyWith(
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                  if (season.isCurrent) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const BoxyArtIndicator(
                      label: 'CURRENT SEASON',
                      dotColor: AppColors.lime500,
                      hasHorizontalMargin: false,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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

}
