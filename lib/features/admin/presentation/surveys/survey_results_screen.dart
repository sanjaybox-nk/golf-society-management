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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildParticipationCard(context, survey, membersAsync),
                  const SizedBox(height: 32),
                  ...survey.questions.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
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
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildMetric('RESPONSES', totalResponses.toString(), Icons.people_rounded, AppColors.lime500),
          const Spacer(),
          const VerticalDivider(),
          const Spacer(),
          _buildMetric('PARTICIPATION', '$rate%', Icons.analytics_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuestionResult(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<dynamic>> membersAsync) {
    return BoxyArtCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.question.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2, color: AppColors.lime500),
          ),
          const SizedBox(height: 20),
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
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(opt, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  Text('$count (${(percent * 100).toInt()}%)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
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
      return const Text('No responses yet.', style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    return Column(
      children: textResponses.map((e) {
        final userId = e.key;
        final answer = e.value[q.id].toString();
        final member = membersAsync.asData?.value.firstWhere((m) => m.id == userId, orElse: () => null);
        final name = member != null ? '${member.firstName} ${member.lastName}' : 'Unknown Member';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.dark600,
            borderRadius: AppShapes.md,
            border: Border.all(color: AppColors.dark500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.lime500, fontSize: 11)),
              const SizedBox(height: 8),
              Text(answer, style: const TextStyle(fontSize: 14, height: 1.4)),
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
