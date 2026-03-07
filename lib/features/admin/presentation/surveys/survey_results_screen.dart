import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/features/surveys/presentation/surveys_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';

class SurveyResultsScreen extends ConsumerWidget {
  final String surveyId;

  const SurveyResultsScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveyAsync = ref.watch(surveyProvider(surveyId));
    final membersAsync = ref.watch(allMembersProvider);

    return surveyAsync.when(
      data: (survey) {
        if (survey == null) {
          return const Scaffold(body: Center(child: Text('Survey not found')));
        }

        return HeadlessScaffold(
          title: 'Survey Results',
          subtitle: survey.title,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildParticipationCard(context, survey, membersAsync),
                  const SizedBox(height: AppSpacing.x3l),
                  ...survey.questions.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                    child: _buildQuestionResult(context, q, survey.responses, membersAsync),
                  )),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildParticipationCard(BuildContext context, Survey survey, AsyncValue<List<dynamic>> membersAsync) {
    final totalResponses = survey.responses.length;
    final totalMembers = membersAsync.asData?.value.length ?? 0;
    final rate = totalMembers == 0 ? 0 : (totalResponses / totalMembers * 100).toInt();

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Row(
        children: [
          _buildMetric('RESPONSES', totalResponses.toString(), Icons.people_rounded, AppColors.lime500),
          const Spacer(),
          const VerticalDivider(),
          const Spacer(),
          _buildMetric('PARTICIPATION', '$rate%', Icons.analytics_rounded, AppColors.teamA),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppShapes.iconLg),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: const TextStyle(fontSize: AppTypography.sizeDisplayLocker, fontWeight: AppTypography.weightBlack)),
        Text(label, style: const TextStyle(fontSize: AppTypography.sizeCaption, fontWeight: AppTypography.weightBold, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildQuestionResult(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<dynamic>> membersAsync) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.question.toUpperCase(),
            style: const TextStyle(fontWeight: AppTypography.weightBlack, fontSize: AppTypography.sizeLabelStrong, letterSpacing: 1.2, color: AppColors.lime500),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (q.type == SurveyQuestionType.text)
            _buildTextResults(context, q, responses, membersAsync)
          else
            _buildChoiceResults(context, q, responses),
        ],
      ),
    );
  }

  Widget _buildChoiceResults(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses) {
    final Map<String, int> counts = {for (var opt in q.options) opt: 0};
    int total = 0;

    for (final userResponse in responses.values) {
      final answer = userResponse[q.id];
      if (answer == null) continue;

      if (q.type == SurveyQuestionType.singleChoice) {
        if (counts.containsKey(answer)) {
          counts[answer] = counts[answer]! + 1;
          total++;
        }
      } else {
        final List<dynamic> selected = listify(answer);
        for (final opt in selected) {
          if (counts.containsKey(opt.toString())) {
            counts[opt.toString()] = counts[opt.toString()]! + 1;
            total++;
          }
        }
      }
    }

    return Column(
      children: q.options.map((opt) {
        final count = counts[opt] ?? 0;
        final percent = total == 0 ? 0.0 : count / responses.length; // Per respondent, not per total selection

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(opt, style: const TextStyle(fontWeight: AppTypography.weightSemibold, fontSize: AppTypography.sizeBodySmall))),
                  Text('$count (${(percent * 100).toInt()}%)', style: const TextStyle(fontSize: AppTypography.sizeLabel, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppShapes.xs,
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: AppColors.dark400,
                  color: AppColors.lime500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextResults(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<dynamic>> membersAsync) {
    final textResponses = responses.entries
        .where((e) => e.value[q.id] != null && e.value[q.id].toString().trim().isNotEmpty)
        .toList();

    if (textResponses.isEmpty) {
      return const Text('No responses yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: AppTypography.sizeLabelStrong));
    }

    return Column(
      children: textResponses.map((e) {
        final userId = e.key;
        final answer = e.value[q.id].toString();
        final member = membersAsync.asData?.value.firstWhere((m) => m.id == userId, orElse: () => null);
        final name = member != null ? '${member.firstName} ${member.lastName}' : 'Unknown Member';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.dark600,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: AppTypography.weightBlack, color: AppColors.lime500, fontSize: AppTypography.sizeCaptionStrong)),
              const SizedBox(height: AppSpacing.sm),
              Text(answer, style: const TextStyle(fontSize: AppTypography.sizeBodySmall, height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<dynamic> listify(dynamic val) {
    if (val is List) return val;
    return val == null ? [] : [val];
  }
}
