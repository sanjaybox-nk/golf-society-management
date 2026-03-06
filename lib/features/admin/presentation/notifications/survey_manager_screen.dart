import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'surveys_provider.dart';
import 'survey_form_screen.dart';

class SurveyManagerScreen extends ConsumerWidget {
  const SurveyManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveysProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BoxyArtSectionTitle(title: 'Society Surveys'),
            BoxyArtGlassIconButton(
              icon: Icons.add_rounded,
              onPressed: () => _openSurveyForm(context),
              tooltip: 'Create New Survey',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (surveys.isEmpty)
          _buildEmptyState()
        else
          ...surveys.map((survey) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BoxyArtCard(
                onTap: () => _openSurveyForm(context, survey: survey),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lime500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_rounded, color: AppColors.lime500),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.title,
                            style: AppTypography.displayHeading.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${survey.questions.length} Questions • ${survey.responses.length} Responses',
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (survey.isPublished)
                      BoxyArtPill.status(label: 'LIVE', color: Colors.green)
                    else
                      BoxyArtPill.status(label: 'DRAFT', color: Colors.orange),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.dark150),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 130),
      ],
    );
  }

  void _openSurveyForm(BuildContext context, {Survey? survey}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurveyFormScreen(existingSurvey: survey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.assignment_outlined,
          size: 64,
          color: AppColors.dark400,
        ),
        SizedBox(height: 16),
        Text(
          'No Surveys Yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.dark200,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Gather insights from your members by creating your first survey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.dark300,
            ),
          ),
        ),
      ],
    );
  }
}
