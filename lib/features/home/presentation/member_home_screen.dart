import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';

import 'package:golf_society/domain/models/golf_event.dart';
import 'home_providers.dart';
import 'widgets/home_notification_card.dart';
import '../../members/presentation/profile_provider.dart';
import '../../surveys/presentation/surveys_provider.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/survey.dart';

/// Track dismissed survey IDs for the current session to keep the home screen clean.
class DismissedSurveysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void dismiss(String surveyId) {
    state = {...state, surveyId};
  }
}

final dismissedSurveyIdsProvider = NotifierProvider<DismissedSurveysNotifier, Set<String>>(DismissedSurveysNotifier.new);

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveUser = ref.watch(effectiveUserProvider);
    final isPeeking = ref.watch(impersonationProvider) != null;
    
    // Top 2 unread notifications
    final notificationsAsync = ref.watch(homeNotificationsProvider);
    
    final nextMatch = ref.watch(homeNextMatchProvider);
    final topPlayers = ref.watch(homeSeasonLeaderboardProvider);
    final personalStanding = ref.watch(homeMemberStandingProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final surveysAsync = ref.watch(activeSurveysProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match provided aesthetic
      body: Column(
        children: [
          if (isPeeking)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
              color: AppColors.amber500,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: AppColors.pureWhite, size: AppShapes.iconSm),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Peeking as ${effectiveUser.displayName}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(impersonationProvider.notifier).clear(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: AppColors.opacityMedium),
                          borderRadius: AppShapes.xs,
                        ),
                        child: Text(
                          'EXIT PEEK',
                          style: AppTypography.microSmall.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allNotifications) {
                final unreadNotifications = allNotifications
                    .where((n) => !n.isRead)
                    .toList()
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                
                final homeNotifications = unreadNotifications.take(2).toList();
                
                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      pinned: true, // Keep it pinned for a premium feel
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: AppColors.opacityStrong),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: false,
                      toolbarHeight: 80, // Taller app bar
                      flexibleSpace: ClipRect(
                        child:  BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Row(
                          children: [
                            if (societyConfig.logoUrl != null) ...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: AppShapes.md,
                                  boxShadow: Theme.of(context).extension<AppShadows>()?.softScale ?? [],
                                ),
                                child: ClipRRect(
                                  borderRadius: AppShapes.md,
                                  child: Image.network(
                                    societyConfig.logoUrl!,
                                    height: 48,
                                    width: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.golf_course, size: 42),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: AppTypography.labelStrong.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                  Text(
                                    effectiveUser.firstName,
                                    style: AppTypography.displaySubPage,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: const [
                        AdminShortcutAction(),
                        SizedBox(width: AppSpacing.sm),
                      ],
                    ),
          
                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Notifications Section (Dynamic)
                          if (homeNotifications.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BoxyArtSectionTitle(
                                  title: 'Notifications',
                                  isPeeking: isPeeking,
                                ),
                                  TextButton(
                                    onPressed: () => context.push('/home/notifications'),
                                    child: Text(
                                      'View All', 
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: isDark ? AppColors.lime400 : AppColors.lime700,
                                        fontWeight: AppTypography.weightBold,
                                        inherit: true, // Fix for TextStyle interpolation crash
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...homeNotifications.asMap().entries.map((entry) => StaggeredEntrance(
                              index: entry.key,
                              child: HomeNotificationCard(notification: entry.value),
                            )),
                            const SizedBox(height: AppSpacing.x2l),
                          ],

                          // Society Surveys
                          ...surveysAsync.when(
                            data: (surveys) {
                              final dismissedIds = ref.watch(dismissedSurveyIdsProvider);
                              final now = DateTime.now();
                              
                              final visibleSurveys = surveys.where((s) {
                                // 1. Filter by dismissal
                                if (dismissedIds.contains(s.id)) return false;
                                
                                // 2. Filter by deadline
                                if (s.deadline != null && now.isAfter(s.deadline!)) return false;
                                
                                return true;
                              }).toList();
                              
                              if (visibleSurveys.isEmpty) return [const SizedBox.shrink()];
                              return [
                                BoxyArtSectionTitle(
                                  title: 'Society Surveys',
                                  isPeeking: isPeeking,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ...visibleSurveys.map((survey) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                                  child: _SurveyInteractiveCard(
                                    key: ValueKey('survey_${survey.id}'),
                                    survey: survey,
                                  ),
                                )),
                              ];
                            },
                            loading: () => [const SizedBox.shrink()],
                            error: (_, _) => [const SizedBox.shrink()],
                          ),
          
                          // Next Match Hero Card
                          BoxyArtSectionTitle(
                            title: 'Next Match',
                            isPeeking: isPeeking,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          StaggeredEntrance(
                            index: homeNotifications.length, // Stagger after notifications
                            child: nextMatch.when(
                              data: (event) {
                                if (event == null) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(AppSpacing.lg),
                                      child: Text('No upcoming matches scheduled.'),
                                    ),
                                  );
                                }
                                return _NextMatchCard(event: event);
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (err, stack) => Text('Error: $err'),
                            ),
                          ),
                      const SizedBox(height: AppSpacing.x2l),

                      // Leaderboard Snippet
                      BoxyArtSectionTitle(
                        title: 'Order of Merit',
                        isPeeking: isPeeking,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      StaggeredEntrance(
                        index: homeNotifications.length + 1, // Stagger after match card
                        child: topPlayers.when(
                          data: (players) => _LeaderboardSnippet(
                            topPlayers: players,
                            personalStanding: personalStanding.value?['standing'] as LeaderboardStanding?,
                            personalRank: personalStanding.value?['rank'] as int?,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error loading standings: $err'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                    ]),
                  ),
                ),
              ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class _NextMatchCard extends ConsumerWidget {
  final GolfEvent event;

  const _NextMatchCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveUser = ref.watch(effectiveUserProvider);
    final isLive = event.status == EventStatus.inPlay;
    final isPlaying = event.registrations.any((r) => r.memberId == effectiveUser.id);

    
    return BoxyArtCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/events/${event.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
                  child: Image.network(
                    event.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppShapes.rXl)),
                    gradient: AppGradients.scrim(),
                  ),
                ),
                Positioned(
                  top: AppSpacing.lg,
                  left: AppSpacing.lg,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: AppColors.opacityHalf),
                      borderRadius: AppShapes.sm,
                      border: Border.all(color: AppColors.pureWhite.withValues(alpha: 0.24)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.pureWhite, size: AppShapes.iconXs),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM').format(event.date),
                          style: AppTypography.micro.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTypography.displayLocker,
                      ),
                    ),
                    if (isPlaying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: AppColors.opacityLow),
                          borderRadius: AppShapes.md,
                        ),
                        child: Text(
                          'Playing',
                          style: AppTypography.micro.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ModernInfoRow(
                  label: 'Course',
                  value: event.courseName ?? 'TBA',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                ModernInfoRow(
                  label: 'Tee Off',
                  value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isLive && isPlaying) ...[
                  BoxyArtButton(
                    title: 'ENTER SCORE',
                    isPrimary: true,
                    fullWidth: true,
                    onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}/live'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtButton(
                    title: 'View Event Hub',
                    isSecondary: true,
                    fullWidth: true,
                    onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
                  ),
                ] else
                  BoxyArtButton(
                    title: 'View Details',
                    isPrimary: true,
                    fullWidth: true,
                    onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSnippet extends StatelessWidget {
  final List<Map<String, dynamic>> topPlayers;
  final LeaderboardStanding? personalStanding;
  final int? personalRank;

  const _LeaderboardSnippet({required this.topPlayers, this.personalStanding, this.personalRank});

  @override
  Widget build(BuildContext context) {
    final isPersonalInSnippet = topPlayers.any((p) => p['name'] == personalStanding?.memberName);

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topPlayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                   Icon(Icons.info_outline_rounded, size: AppShapes.iconSm, color: AppColors.dark400),
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     'No standings recorded yet.',
                     style: AppTypography.labelStrong.copyWith(
                       color: AppColors.dark500,
                     ),
                   ),
                ],
              ),
            ),

          ...topPlayers.map((player) {
            final position = player['position'] as int;
            final isFirst = position == 1;
            final isMe = player['name'] == personalStanding?.memberName;
            final name = player['name'] as String;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  BoxyArtNumberBadge(
                    number: position,
                    size: AppShapes.iconLg,
                    textColor: isMe ? AppColors.teamA : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Standard Avatar
                  Container(
                    width: AppSpacing.x3l,
                    height: AppSpacing.x3l,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.dark600,
                      border: Border.all(color: AppColors.dark900, width: AppShapes.borderMedium),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.dark300,
                          fontWeight: AppTypography.weightExtraBold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.button.copyWith(
                        color: isMe ? AppColors.teamA : AppColors.pureWhite,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                  ),
                  Text(
                    '${player['points']}',
                    style: AppTypography.displayLargeBody.copyWith(
                      color: isMe ? AppColors.teamA : (isFirst ? AppColors.lime500 : AppColors.pureWhite),
                      fontWeight: AppTypography.weightExtraBold,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (!isPersonalInSnippet && personalStanding != null) ...[
            const Divider(height: AppSpacing.x2l, color: AppColors.dark600),
            Row(
              children: [
                BoxyArtNumberBadge(
                  number: personalRank ?? 0,
                  size: AppShapes.iconLg,
                  textColor: AppColors.teamA,
                  color: AppColors.teamA.withValues(alpha: AppColors.opacityLow),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: AppSpacing.x3l,
                  height: AppSpacing.x3l,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dark600,
                    border: Border.all(color: AppColors.dark900, width: AppShapes.borderMedium),
                  ),
                  child: Center(
                    child: Text(
                      (personalStanding!.memberName.isNotEmpty) ? personalStanding!.memberName[0].toUpperCase() : '?',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.dark300,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Your Standing',
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: AppTypography.sizeButton, 
                      fontWeight: AppTypography.weightExtraBold, 
                      color: AppColors.teamA,
                    ),
                  ),
                ),
                Text(
                  '${personalStanding?.points.toInt()}',
                  style: AppTypography.displayLargeBody.copyWith(
                    fontWeight: AppTypography.weightExtraBold, 
                    color: AppColors.teamA,
                  ),
                ),
              ],
            ),
          ],

          if (topPlayers.isNotEmpty || personalStanding != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.dark600),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => context.push('/locker/standings'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Full Season Standings',
                    style: AppTypography.label.copyWith(
                      color: AppColors.lime500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: AppShapes.iconSm, color: AppColors.lime500),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Ready for the green,';
  if (hour < 17) return 'Perfect day for a round,';
  return 'Fore! Welcome back,';
}

class _SurveyInteractiveCard extends ConsumerStatefulWidget {
  final Survey survey;

  const _SurveyInteractiveCard({super.key, required this.survey});

  @override
  ConsumerState<_SurveyInteractiveCard> createState() => _SurveyInteractiveCardState();
}

class _SurveyInteractiveCardState extends ConsumerState<_SurveyInteractiveCard> {
  final Map<String, dynamic> _localAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};
  bool _isSubmitting = false;
  bool _isExpanded = false; // Collapsed by default to reduce clutter

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(effectiveUserProvider);
    final userResponse = widget.survey.responses[user.id] as Map<String, dynamic>?;
    final hasVoted = userResponse != null;

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Toggle
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(Icons.poll_rounded, color: AppColors.lime500, size: AppShapes.iconMd),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOCIETY SURVEY',
                        style: AppTypography.label.copyWith(
                          color: AppColors.lime500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.survey.title,
                        style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
                      ),
                    ],
                  ),
                ),
                if (hasVoted) ...[
                  BoxyArtButton(
                    title: 'Dismiss',
                    isSecondary: true,
                    onTap: () {
                      ref.read(dismissedSurveyIdsProvider.notifier).dismiss(widget.survey.id);
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  size: AppShapes.iconMd,
                ),
              ],
            ),
          ),

          ClipRect(
            child: AnimatedSize(
              duration: AppAnimations.medium,
              curve: Curves.easeInOut,
              child: SizedBox(
                height: _isExpanded ? null : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.survey.description != null && widget.survey.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        widget.survey.description!,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Column(
                        children: widget.survey.questions.map((q) => _buildQuestion(q, userResponse?[q.id], hasVoted)).toList(),
                      ),
                    ),
                    
                    if (!hasVoted) ...[
                      const SizedBox(height: AppSpacing.md),
                      BoxyArtButton(
                        title: _isSubmitting ? 'Submitting...' : 'Submit Response',
                        isPrimary: true,
                        fullWidth: true,
                        onTap: _isSubmitting ? null : _submitAll,
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm, left: AppSpacing.xs),
                        child: Text(
                          'Thank you for your feedback!',
                          style: AppTypography.label.copyWith(color: AppColors.lime500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(SurveyQuestion q, dynamic answer, bool hasVoted) {
    var currentAnswer = hasVoted ? answer : _localAnswers[q.id];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.question.toUpperCase(),
            style: AppTypography.labelStrong.copyWith(
              color: AppColors.pureWhite,
              fontWeight: AppTypography.weightExtraBold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (q.type == SurveyQuestionType.text)
            Container(
              decoration: BoxDecoration(
                color: AppColors.dark600,
                borderRadius: AppShapes.md,
                border: Border.all(
                  color: hasVoted && currentAnswer != null ? AppColors.lime500 : AppColors.dark500,
                  width: hasVoted && currentAnswer != null ? 1.5 : 1.0,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
                child: TextField(
                  controller: _getTextController(q.id, currentAnswer?.toString()),
                  readOnly: hasVoted,
                  onChanged: hasVoted ? null : (v) => setState(() => _localAnswers[q.id] = v),
                  style: TextStyle(
                    color: hasVoted && currentAnswer != null ? AppColors.lime500 : AppColors.pureWhite,
                    fontSize: AppTypography.sizeBodySmall,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your response...',
                    hintStyle: TextStyle(color: AppColors.dark300, fontSize: AppTypography.sizeBodySmall),
                    suffixIcon: (hasVoted && currentAnswer != null) 
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.lime500, size: AppShapes.iconMd)
                        : null,
                  ),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasVoted ? null : () {
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lime500.withValues(alpha: AppColors.opacityLow) : AppColors.dark600,
                      borderRadius: AppShapes.md,
                      border: Border.all(
                        color: isSelected ? AppColors.lime500 : AppColors.dark500,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? AppColors.lime500 : AppColors.pureWhite.withValues(alpha: AppColors.opacityStrong),
                              fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected 
                            ? (q.type == SurveyQuestionType.multipleChoice 
                                ? Icons.check_box_rounded 
                                : Icons.check_circle_rounded)
                            : (q.type == SurveyQuestionType.multipleChoice 
                                ? Icons.check_box_outline_blank_rounded 
                                : Icons.radio_button_off_rounded), 
                          color: isSelected ? AppColors.lime500 : AppColors.dark400, 
                          size: AppShapes.iconMd
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  TextEditingController _getTextController(String questionId, String? initialValue) {
    if (!_textControllers.containsKey(questionId)) {
      _textControllers[questionId] = TextEditingController(text: initialValue);
    }
    return _textControllers[questionId]!;
  }

  Future<void> _submitAll() async {
    if (_localAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer at least one question.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(effectiveUserProvider);
      await ref.read(surveysRepositoryProvider).submitResponse(widget.survey.id, user.id, _localAnswers);
      if (mounted) {
        setState(() {
          _isExpanded = false;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response submitted. Thank you!')),
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
