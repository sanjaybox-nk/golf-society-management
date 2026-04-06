import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/domain/models/member.dart';
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
        final spacing = Theme.of(context).extension<AppSpacingTokens>();

        return HeadlessScaffold(
          title: 'Survey Results',
          subtitle: survey.title,
          showBack: true, // [NEW] Enable back navigation
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildParticipationCard(context, survey, membersAsync),
                  const SizedBox(height: AppSpacing.x2l), // Standard card separation
                  ...survey.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                      child: _buildQuestionResult(context, index, q, survey.responses, membersAsync),
                    );
                  }),
                  const SizedBox(height: AppSpacing.pageBottom),
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

  Widget _buildParticipationCard(BuildContext context, Survey survey, AsyncValue<List<Member>> membersAsync) {
    final totalResponses = survey.responses.length;
    final totalMembers = membersAsync.asData?.value.length ?? 0;
    final rate = totalMembers == 0 ? 0 : (totalResponses / totalMembers * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        gradient: AppGradients.brandPrimary(context),
        borderRadius: AppShapes.hero,
        boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeroMetric(context, 'RESPONSES', totalResponses.toString(), Icons.people_rounded),
          Container(height: 40, width: 1, color: AppColors.pureWhite.withOpacity(AppColors.opacityLow)),
          _buildHeroMetric(context, 'PARTICIPATION', '$rate%', Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.pureWhite.withOpacity(AppColors.opacityHigh), size: 28),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value, 
          style: AppTypography.displayHeading.copyWith(
            fontSize: 24,
            color: AppColors.pureWhite,
            fontWeight: AppTypography.weightHeavy,
            letterSpacing: AppTypography.lsTight,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label, 
          style: AppTypography.micro.copyWith(
            fontWeight: AppTypography.weightHeavy,
            color: AppColors.pureWhite.withOpacity(AppColors.opacityStrong),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResult(BuildContext context, int index, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<Member>> membersAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.labelToCard),
          child: Text(
            'QUESTION ${index + 1}', 
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: isDark ? AppColors.dark300 : AppColors.dark400,
              letterSpacing: 1.2,
            ),
          ),
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getQuestionPlainText(q.question),
                style: AppTypography.body.copyWith(
                  fontWeight: AppTypography.weightStrong,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (q.type == SurveyQuestionType.text)
                _buildTextResults(context, q, responses, membersAsync)
              else
                _buildChoiceResults(context, q, responses),
            ],
          ),
        ),
      ],
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

    final maxVotes = counts.values.isEmpty ? 0 : counts.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: q.options.map((opt) {
        final count = counts[opt] ?? 0;
        final percent = total == 0 ? 0.0 : count / responses.length;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isWinner = maxVotes > 0 && count == maxVotes;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      opt, 
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: isWinner ? AppTypography.weightExtraBold : AppTypography.weightSemibold,
                        color: isWinner ? (isDark ? AppColors.pureWhite : AppColors.dark950) : (isDark ? AppColors.dark100 : AppColors.dark800),
                      ),
                    ),
                  ),
                  Text(
                    '$count (${(percent * 100).toInt()}%)'.toUpperCase(), 
                    style: AppTypography.micro.copyWith(
                      fontWeight: AppTypography.weightHeavy,
                      color: isWinner ? Theme.of(context).colorScheme.primary : (isDark ? AppColors.dark300 : AppColors.dark400),
                      letterSpacing: AppTypography.lsMicro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // [NEW] Analytical Chart Rail & Bar
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dark500 : AppColors.dark100,
                      borderRadius: AppShapes.pill,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: isWinner ? AppGradients.brandPrimary(context) : null,
                        color: isWinner ? null : (isDark ? AppColors.dark300 : AppColors.dark400),
                        borderRadius: AppShapes.pill,
                        boxShadow: isWinner ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextResults(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<Member>> membersAsync) {
    final textResponses = responses.entries
        .where((e) => e.value is Map && e.value[q.id] != null && e.value[q.id].toString().trim().isNotEmpty)
        .toList();

    if (textResponses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          'NO RESPONSES YET', 
          style: AppTypography.micro.copyWith(
            fontWeight: AppTypography.weightBold,
            color: AppColors.dark400,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: textResponses.map((e) {
        final userId = e.key;
        final answer = e.value[q.id].toString();
        final member = membersAsync.asData?.value.firstWhereOrNull((m) => m.id == userId);
        final name = member != null ? member.displayName : 'Unknown Member';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark600 : AppColors.dark50,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: isDark ? AppColors.dark500 : AppColors.dark100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toUpperCase(), 
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                answer, 
                style: AppTypography.label.copyWith(
                  fontWeight: AppTypography.weightRegular,
                  height: 1.4,
                )
              ),
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

  String _getQuestionPlainText(String content) {
    if (content.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(content));
      return doc.toPlainText().trim();
    } catch (e) {
      return content;
    }
  }
}
