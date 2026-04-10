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
    final spacing = Theme.of(context).extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Society Surveys',
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      subtitle: 'Gather feedback & insights',
      showBack: true, // [NEW] Enable back navigation
      actions: [
        BoxyArtGlassIconButton(
          icon: Icons.add_rounded,
          onPressed: () => context.push('/admin/surveys/new'),
          tooltip: 'Create Survey',
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        ),
        surveysAsync.when(
          data: (surveys) {
            if (surveys.isEmpty) {
              return const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtEmptyCard(
                    title: 'No Surveys Created',
                    message: 'Draft polls and society insights will appear here once you create your first survey.',
                    icon: Icons.quiz_outlined,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final survey = surveys[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.standard),
                      child: _SurveyListCard(survey: survey, spacing: spacing),
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
  final AppSpacingTokens? spacing;

  const _SurveyListCard({required this.survey, this.spacing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final responseCount = survey.responses.length;
    final isExpired = survey.deadline != null && survey.deadline!.isBefore(DateTime.now());

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
                ),
              ),
              BoxyArtStatusPill(
                isPaid: survey.isPublished && !isExpired,
                paidLabel: isExpired ? 'Expired' : 'Live',
                dueLabel: 'Draft',
                color: isExpired 
                  ? StatusColors.negative 
                  : (survey.isPublished ? AppColors.teamA : AppColors.amber500),
                onToggle: isExpired ? null : () {
                  ref.read(surveysRepositoryProvider).updateSurvey(
                    survey.copyWith(isPublished: !survey.isPublished),
                  );
                },
              ),
            ],
          ),
          if (survey.description != null && survey.description!.isNotEmpty) ...[
            SizedBox(height: spacing?.labelToCard ?? AppSpacing.md),
            Text(
              survey.description!,
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
          Row(
            children: [
              _buildInfoItem(
                context,
                Icons.question_answer_outlined,
                '${survey.questions.length} Questions',
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildInfoItem(
                context,
                Icons.people_outline_rounded,
                '$responseCount Responses',
              ),
            ],
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created ${DateFormat('MMM d, yyyy').format(survey.createdAt)}',
                    style: AppTypography.caption.copyWith(color: AppColors.dark300),
                  ),
                  if (survey.deadline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expires ${DateFormat('MMM d, yyyy').format(survey.deadline!)}',
                      style: AppTypography.caption.copyWith(
                        color: isExpired ? StatusColors.negative : AppColors.dark300,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BoxyArtButton(
                title: 'View Results',
                icon: Icons.bar_chart_rounded,
                onTap: () => context.push('/admin/surveys/results/${survey.id}'),
              ),
              BoxyArtGlassIconButton(
                icon: Icons.edit_rounded,
                onPressed: () => context.push('/admin/surveys/edit/${survey.id}'),
                tooltip: 'Edit Survey',
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: AppShapes.iconXs, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.label.copyWith(fontSize: AppTypography.sizeLabel),
        ),
      ],
    );
  }
}
