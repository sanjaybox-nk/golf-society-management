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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.amber.shade700,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peeking as ${effectiveUser.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(impersonationProvider.notifier).clear(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'EXIT PEEK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
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
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
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
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            if (societyConfig.logoUrl != null) ...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    societyConfig.logoUrl!,
                                    height: 48,
                                    width: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.golf_course, size: 42),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    effectiveUser.firstName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        SizedBox(width: 8),
                      ],
                    ),
          
                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                                        fontWeight: FontWeight.bold,
                                        inherit: true, // Fix for TextStyle interpolation crash
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...homeNotifications.asMap().entries.map((entry) => StaggeredEntrance(
                              index: entry.key,
                              child: HomeNotificationCard(notification: entry.value),
                            )),
                            const SizedBox(height: 24),
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
                                const SizedBox(height: 12),
                                ...visibleSurveys.map((survey) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
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
                          const SizedBox(height: 12),
                          StaggeredEntrance(
                            index: homeNotifications.length, // Stagger after notifications
                            child: nextMatch.when(
                              data: (event) {
                                if (event == null) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
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
                      const SizedBox(height: 24),

                      // Leaderboard Snippet
                      BoxyArtSectionTitle(
                        title: 'Order of Merit',
                        isPeeking: isPeeking,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 40),
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

class _NextMatchCard extends StatelessWidget {
  final GolfEvent event;

  const _NextMatchCard({required this.event});

  @override
  Widget build(BuildContext context) {

    
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM').format(event.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (event.registrations.any((r) => r.memberId == 'current-user-id'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Playing',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernInfoRow(
                  label: 'Course',
                  value: event.courseName ?? 'TBA',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 12),
                ModernInfoRow(
                  label: 'Tee Off',
                  value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: 20),
                BoxyArtButton(
                  title: 'View Details',
                  isPrimary: true,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topPlayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                   Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade400),
                   const SizedBox(width: 8),
                   Text(
                     'No standings recorded yet.',
                     style: TextStyle(
                       fontSize: 13,
                       color: Colors.grey.shade500,
                       fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  BoxyArtNumberBadge(
                    number: position,
                    size: 28,
                    textColor: isMe ? Colors.blue : null,
                  ),
                  const SizedBox(width: 12),
                  // Standard Avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.dark600,
                      border: Border.all(color: AppColors.dark900, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTypography.displayHeading.copyWith(
                          color: AppColors.dark300,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: 15,
                        color: isMe ? Colors.blue : AppColors.pureWhite,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${player['points']}',
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: 18,
                      color: isMe ? Colors.blue : (isFirst ? AppColors.lime500 : AppColors.pureWhite),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (!isPersonalInSnippet && personalStanding != null) ...[
            const Divider(height: 24, color: AppColors.dark600),
            Row(
              children: [
                BoxyArtNumberBadge(
                  number: personalRank ?? 0,
                  size: 28,
                  textColor: Colors.blue,
                  color: Colors.blue.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dark600,
                    border: Border.all(color: AppColors.dark900, width: 2.0),
                  ),
                  child: Center(
                    child: Text(
                      (personalStanding!.memberName.isNotEmpty) ? personalStanding!.memberName[0].toUpperCase() : '?',
                      style: AppTypography.displayHeading.copyWith(
                        color: AppColors.dark300,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your Standing',
                    style: AppTypography.displayHeading.copyWith(
                      fontSize: 15, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  '${personalStanding?.points.toInt()}',
                  style: AppTypography.displayHeading.copyWith(
                    fontWeight: FontWeight.w900, 
                    fontSize: 18, 
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],

          if (topPlayers.isNotEmpty || personalStanding != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.dark600),
            const SizedBox(height: 4),
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
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.lime500),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Toggle
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(Icons.poll_rounded, color: AppColors.lime500, size: 20),
                const SizedBox(width: 8),
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
                      const SizedBox(height: 4),
                      Text(
                        widget.survey.title,
                        style: AppTypography.displayHeading.copyWith(fontSize: 18),
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
                  const SizedBox(width: 12),
                ],
                Icon(
                  _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),

          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: _isExpanded ? null : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.survey.description != null && widget.survey.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.survey.description!,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: widget.survey.questions.map((q) => _buildQuestion(q, userResponse?[q.id], hasVoted)).toList(),
                      ),
                    ),
                    
                    if (!hasVoted) ...[
                      const SizedBox(height: 12),
                      BoxyArtButton(
                        title: _isSubmitting ? 'Submitting...' : 'Submit Response',
                        isPrimary: true,
                        fullWidth: true,
                        onTap: _isSubmitting ? null : _submitAll,
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                        child: Text(
                          'Thank you for your feedback!',
                          style: AppTypography.label.copyWith(color: AppColors.lime500, fontSize: 12),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.question.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: AppColors.pureWhite,
              fontSize: 13,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (q.type == SurveyQuestionType.text)
            Container(
              decoration: BoxDecoration(
                color: AppColors.dark600,
                borderRadius: BorderRadius.circular(12),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                child: TextField(
                  controller: _getTextController(q.id, currentAnswer?.toString()),
                  readOnly: hasVoted,
                  onChanged: hasVoted ? null : (v) => setState(() => _localAnswers[q.id] = v),
                  style: TextStyle(
                    color: hasVoted && currentAnswer != null ? AppColors.lime500 : Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your response...',
                    hintStyle: TextStyle(color: AppColors.dark300, fontSize: 14),
                    suffixIcon: (hasVoted && currentAnswer != null) 
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.lime500, size: 20)
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
                padding: const EdgeInsets.only(bottom: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lime500.withValues(alpha: 0.1) : AppColors.dark600,
                      borderRadius: BorderRadius.circular(12),
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
                              color: isSelected ? AppColors.lime500 : Colors.white.withValues(alpha: 0.9),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                          size: 20
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
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
