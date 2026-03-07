import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';

class ScoringReviewQueueScreen extends ConsumerWidget {
  const ScoringReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingReviewsProvider);

    return HeadlessScaffold(
      title: 'Review Queue',
      subtitle: 'Pending scorecards awaiting approval',
      slivers: [
        pendingAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: BoxyArtCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        onTap: () => context.push('/admin/competitions/manage/${review.id}/reviews'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.amber500.withValues(alpha: AppColors.opacityLow),
                                  borderRadius: AppShapes.md,
                                ),
                                child: const Icon(Icons.rate_review_outlined, color: AppColors.amber500),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.name.toUpperCase(),
                                      style: const TextStyle(fontWeight: AppTypography.weightBold),
                                    ),
                                    Text(
                                      '${review.pendingCount} scorecards awaiting review',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeLabel),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: reviews.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => SliverFillRemaining(
            child: Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.coral500))),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: AppShapes.iconMassive, color: AppColors.lime500.withValues(alpha: AppColors.opacityMuted)),
          const SizedBox(height: AppSpacing.lg),
          const Text('All caught up!', style: TextStyle(color: AppColors.pureWhite, fontWeight: AppTypography.weightBold)),
          const Text('No scorecards pending review.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// Model for review queue items (until backend is fully linked)
class CompetitionReviewSummary {
  final String id;
  final String name;
  final int pendingCount;

  CompetitionReviewSummary({required this.id, required this.name, required this.pendingCount});
}

final pendingReviewsProvider = FutureProvider<List<CompetitionReviewSummary>>((ref) async {
  // Placeholder logic
  return [
    CompetitionReviewSummary(id: 'comp1', name: 'Winter Stableford', pendingCount: 12),
    CompetitionReviewSummary(id: 'comp2', name: 'Captain\'s Prize', pendingCount: 4),
  ];
});
