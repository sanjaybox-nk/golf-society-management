import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
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
                  SizedBox(height: spacing?.cardToCard ?? AppSpacing.x2l), // [4.x Rhythm]
                  ...survey.questions.map((q) => Padding(
                    padding: EdgeInsets.only(bottom: spacing?.cardToCard ?? AppSpacing.x2l),
                    child: _buildQuestionResult(context, q, survey.responses, membersAsync, spacing),
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
          Container(height: 40, width: 1, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityLow)),
          _buildHeroMetric(context, 'PARTICIPATION', '$rate%', Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.pureWhite.withValues(alpha: AppColors.opacityHigh), size: AppShapes.iconLg),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value, 
          style: AppTypography.displaySection.copyWith(
            color: AppColors.pureWhite,
            fontWeight: AppTypography.weightBlack,
            letterSpacing: AppTypography.lsTight,
          ),
        ),
        Text(
          label.toUpperCase(), 
          style: AppTypography.micro.copyWith(
            fontWeight: AppTypography.weightHeavy,
            color: AppColors.pureWhite.withValues(alpha: AppColors.opacityStrong),
            letterSpacing: AppTypography.lsMicro,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResult(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<dynamic>> membersAsync, AppSpacingTokens? spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxyArtSectionTitle(
          title: _getQuestionPlainText(q.question), // Extracts plain text from potential JSON
          isPeeking: true,
        ),
        BoxyArtCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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

  Widget _buildTextResults(BuildContext context, SurveyQuestion q, Map<String, dynamic> responses, AsyncValue<List<dynamic>> membersAsync) {
    final textResponses = responses.entries
        .where((e) => e.value[q.id] != null && e.value[q.id].toString().trim().isNotEmpty)
        .toList();

    if (textResponses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          'No responses yet.'.toUpperCase(), 
          style: AppTypography.micro.copyWith(
            fontWeight: AppTypography.weightHeavy,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.dark400 : AppColors.dark300,
            letterSpacing: AppTypography.lsMicro,
          ),
        ),
      );
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
              Text(
                name.toUpperCase(), 
                style: AppTypography.micro.copyWith(
                  fontWeight: AppTypography.weightHeavy,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: AppTypography.lsMicro,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
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
