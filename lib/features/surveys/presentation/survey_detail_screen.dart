import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/survey.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'surveys_provider.dart';

class SurveyDetailScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const SurveyDetailScreen({super.key, required this.surveyId});

  @override
  ConsumerState<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  final Map<String, dynamic> _localAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) debugPrint('DEBUG: Building SurveyDetailScreen for id: ${widget.surveyId}');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    final surveyAsync = ref.watch(surveyProvider(widget.surveyId));
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'Society Survey',
      showBack: true,
      slivers: [
        surveyAsync.when(
          loading: () => const SliverFillRemaining(
            child: BoxyArtLoadingCard(useCard: true),
          ),
          error: (err, stack) => SliverFillRemaining(
            child: Center(child: Text('Error: $err')),
          ),
          data: (survey) {
            if (survey == null) {
              return const SliverFillRemaining(
                child: Center(child: Text('Survey not found')),
              );
            }

            final user = ref.watch(effectiveUserProvider);
            final isExpired = survey.deadline != null && survey.deadline!.isBefore(DateTime.now());
            final userResponse = survey.responses[user.id] as Map<String, dynamic>?;
            final hasVoted = userResponse != null;

            return SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BoxyArtCard(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing?.cardHorizontalPadding ?? AppSpacing.md,
                        vertical: spacing?.cardVerticalPadding ?? AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 72,
                                child: Center(
                                  child: const BoxyArtSquareBadge(
                                    size: 56,
                                    isTinted: true,
                                    child: Icon(
                                      Icons.quiz_rounded,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      survey.title,
                                      style: AppTypography.displayHeading.copyWith(
                                        fontSize: 20,
                                        fontWeight: AppTypography.weightExtraBold,
                                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        survey.deadline != null 
                                          ? (isExpired ? 'Closed: ${DateFormat('d MMM').format(survey.deadline!)}' : 'Closes: ${DateFormat('d MMM').format(survey.deadline!)}') 
                                          : 'Open',
                                        style: AppTypography.micro.copyWith(
                                          color: isExpired ? StatusColors.negative : (isDark ? AppColors.dark150 : AppColors.dark700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (survey.description != null && survey.description!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                survey.description!,
                                style: AppTypography.body.copyWith(
                                  color: isDark ? AppColors.dark150 : AppColors.dark700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (isExpired) ...[
                    const SizedBox(height: AppSpacing.lg),
                    BoxyArtCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      backgroundColor: StatusColors.negative.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_clock_rounded, color: StatusColors.negative, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'This survey is now closed. Your feedback is appreciated, but new responses can no longer be submitted.',
                              style: AppTypography.micro.copyWith(
                                color: StatusColors.negative,
                                fontWeight: AppTypography.weightSemibold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x3l),
                  IgnorePointer(
                    ignoring: isExpired,
                    child: Opacity(
                      opacity: isExpired ? 0.6 : 1.0,
                      child: Column(
                        children: survey.questions.asMap().entries.map((entry) => _buildQuestion(entry.value, entry.key, userResponse?[entry.value.id], hasVoted)).toList(),
                      ),
                    ),
                  ),
                  if (!hasVoted && !isExpired) ...[
                    const SizedBox(height: AppSpacing.x2l),
                    BoxyArtButton(
                      title: _isSubmitting ? 'SUBMITTING...' : 'SUBMIT RESPONSE',
                      isPrimary: true,
                      fullWidth: true,
                      onTap: _isSubmitting ? null : () => _submitAll(survey),
                    ),
                  ] else if (hasVoted)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(config.primaryColor), size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Thank you! Your feedback has been recorded.',
                            style: AppTypography.labelStrong.copyWith(color: Color(config.primaryColor)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestion(SurveyQuestion q, int index, dynamic answer, bool hasVoted) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = ref.watch(themeControllerProvider);
    var currentAnswer = hasVoted ? answer : _localAnswers[q.id];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4l),
      child: BoxyArtCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: AppTypography.labelStrong.copyWith(
                color: isDark ? AppColors.dark400 : AppColors.dark400,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              q.question,
              style: AppTypography.displaySection.copyWith(
                fontSize: 18,
                height: 1.3,
                fontWeight: AppTypography.weightSemibold,
                color: isDark ? AppColors.pureWhite : AppColors.dark900,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          if (q.type == SurveyQuestionType.text)
            BoxyArtCard(
              padding: EdgeInsets.zero,
              showShadow: false,
              border: Border.all(
                color: hasVoted && currentAnswer != null ? Color(config.primaryColor) : (isDark ? AppColors.dark500 : AppColors.lightBorder),
              ),
              child: TextField(
                controller: _getTextController(q.id, currentAnswer?.toString()),
                readOnly: hasVoted,
                onChanged: hasVoted ? null : (v) => setState(() => _localAnswers[q.id] = v),
                maxLines: 4,
                style: AppTypography.body.copyWith(
                  color: hasVoted && currentAnswer != null ? Color(config.primaryColor) : (isDark ? AppColors.pureWhite : AppColors.dark900),
                ),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(color: isDark ? AppColors.dark400 : AppColors.dark300),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  border: InputBorder.none,
                ),
              ),
            ),
          if (q.type != SurveyQuestionType.text)
            ...q.options.map((option) {
              bool isSelected;
              if (q.type == SurveyQuestionType.multipleChoice) {
                final list = (currentAnswer as List<dynamic>?)?.cast<String>() ?? [];
                isSelected = list.contains(option);
              } else {
                isSelected = currentAnswer == option;
              }

              final Color primaryColor = Color(config.primaryColor);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BoxyArtCard(
                  onTap: hasVoted ? null : () => _handleSelection(q, option),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  showShadow: false,
                  backgroundColor: isSelected ? primaryColor.withValues(alpha: 0.08) : null,
                  border: Border.all(
                    color: isSelected ? primaryColor : (isDark ? AppColors.dark500 : AppColors.lightBorder),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: AppTypography.body.copyWith(
                            color: isSelected ? primaryColor : (isDark ? AppColors.pureWhite : AppColors.dark900),
                            fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        isSelected 
                          ? (q.type == SurveyQuestionType.multipleChoice ? Icons.check_box_rounded : Icons.check_circle_rounded)
                          : (q.type == SurveyQuestionType.multipleChoice ? Icons.check_box_outline_blank_rounded : Icons.radio_button_off_rounded),
                        color: isSelected ? primaryColor : (isDark ? AppColors.dark400 : AppColors.dark300),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleSelection(SurveyQuestion q, String option) {
    setState(() {
      if (q.type == SurveyQuestionType.multipleChoice) {
        final list = List<String>.from((_localAnswers[q.id] as List<dynamic>?)?.cast<String>() ?? []);
        if (list.contains(option)) {
          list.remove(option);
        } else {
          list.add(option);
        }
        _localAnswers[q.id] = list;
      } else {
        _localAnswers[q.id] = option;
      }
    });
  }

  TextEditingController _getTextController(String questionId, String? initialValue) {
    if (!_textControllers.containsKey(questionId)) {
      _textControllers[questionId] = TextEditingController(text: initialValue);
    }
    return _textControllers[questionId]!;
  }

  Future<void> _submitAll(Survey survey) async {
    if (_localAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your feedback before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(effectiveUserProvider);
      await ref.read(surveysRepositoryProvider).submitResponse(survey.id, user.id, _localAnswers);
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted. Thank you!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
