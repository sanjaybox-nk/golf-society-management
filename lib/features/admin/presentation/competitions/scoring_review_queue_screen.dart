import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/shared_ui/headless_scaffold.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BoxyArtFloatingCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        onTap: () => context.push('/admin/competitions/manage/${review.id}/reviews'),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.rate_review_outlined, color: Colors.orange),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.name.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${review.pendingCount} scorecards awaiting review',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
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
            child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
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
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('All caught up!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('No scorecards pending review.', style: TextStyle(color: Colors.grey)),
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
