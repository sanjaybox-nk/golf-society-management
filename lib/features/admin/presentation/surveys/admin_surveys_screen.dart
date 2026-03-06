import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/features/surveys/presentation/surveys_provider.dart';

class AdminSurveysScreen extends ConsumerWidget {
  const AdminSurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(surveysProvider);

    return HeadlessScaffold(
      title: 'Society Surveys',
      subtitle: 'Gather feedback & insights',
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          onPressed: () => context.push('/admin/surveys/new'),
          tooltip: 'Create Survey',
        ),
        const SizedBox(width: 8),
      ],
      slivers: [
        surveysAsync.when(
          data: (surveys) {
            if (surveys.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text('No surveys created yet.'),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final survey = surveys[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SurveyListCard(survey: survey),
                    );
                  },
                  childCount: surveys.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
      ],
    );
  }
}

class _SurveyListCard extends ConsumerWidget {
  final Survey survey;

  const _SurveyListCard({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final responseCount = survey.responses.length;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: AppTypography.displayHeading.copyWith(fontSize: 18),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          if (survey.description != null && survey.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              survey.description!,
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                context,
                Icons.question_answer_outlined,
                '${survey.questions.length} Questions',
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                context,
                Icons.people_outline_rounded,
                '$responseCount Responses',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created ${DateFormat('MMM d, yyyy').format(survey.createdAt)}',
                style: AppTypography.caption.copyWith(color: Colors.grey),
              ),
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                onPressed: () => context.push('/admin/surveys/edit/${survey.id}'),
                tooltip: 'Edit Survey',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BoxyArtButton(
                title: 'View Results',
                icon: Icons.bar_chart_rounded,
                onTap: () => context.push('/admin/surveys/results/${survey.id}'),
              ),
              Row(
                children: [
                  const Text('Published', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: survey.isPublished,
                    activeThumbColor: AppColors.lime500,
                    onChanged: (val) {
                      ref.read(surveysRepositoryProvider).updateSurvey(
                        survey.copyWith(isPublished: val),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final now = DateTime.now();
    final isExpired = survey.deadline != null && survey.deadline!.isBefore(now);

    if (isExpired) {
      return BoxyArtPill.status(label: 'EXPIRED', color: Colors.grey);
    }
    if (!survey.isPublished) {
      return BoxyArtPill.status(label: 'DRAFT', color: Colors.orange);
    }
    return BoxyArtPill.status(label: 'ACTIVE', color: Colors.blue);
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.label.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
