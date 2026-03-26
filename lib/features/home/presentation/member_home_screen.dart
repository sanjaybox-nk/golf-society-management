import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';

import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/member.dart';
import 'home_providers.dart';
import 'widgets/home_notification_card.dart';
import '../../members/presentation/profile_provider.dart';
import '../../surveys/presentation/surveys_provider.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import 'package:golf_society/domain/models/survey.dart';
import '../../events/presentation/events_provider.dart';

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
    final isImpersonating = ref.watch(impersonationProvider) != null;
    
    // Top 2 unread notifications
    final notificationsAsync = ref.watch(homeNotificationsProvider);
    
    final nextMatch = ref.watch(homeNextMatchProvider);
    final topPlayers = ref.watch(homeSeasonLeaderboardProvider);
    final personalStanding = ref.watch(homeMemberStandingProvider);
    final societyConfig = ref.watch(themeControllerProvider);
    final surveysAsync = ref.watch(activeSurveysProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return HeadlessScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: effectiveUser.firstName,
      subtitleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getGreeting(),
                style: AppTypography.labelStrong.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.waving_hand_rounded, size: 14, color: AppColors.lime500),
            ],
          ),
          if (societyConfig.logoUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Image.network(
                societyConfig.logoUrl!,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
      showMenu: true,
      showAdminShortcut: true,
      slivers: [
        if (isImpersonating)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
            sliver: SliverToBoxAdapter(
              child: BoxyArtCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.actionMidnight.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded, color: AppColors.actionMidnight, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VIEWING AS MEMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: AppTypography.weightExtraBold,
                              letterSpacing: 1.2,
                              color: AppColors.actionMidnight,
                            ),
                          ),
                          Text(
                            '${effectiveUser.firstName} ${effectiveUser.lastName}',
                            style: AppTypography.labelStrong,
                          ),
                        ],
                      ),
                    ),
                    BoxyArtButton(
                      title: 'EXIT',
                      isSecondary: true,
                      isSmall: true,
                      onTap: () => ref.read(impersonationProvider.notifier).clear(),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Membership Status Banner (Society-wide Renewal Model)
        if (societyConfig.globalMembershipEndDate != null) ...[
          (() {
            final now = DateTime.now();
            final expiry = societyConfig.globalMembershipEndDate!;
            final window = societyConfig.renewalWindowDays;
            final difference = expiry.difference(now).inDays;
            
            final isExcludedStatus = effectiveUser.status == MemberStatus.archived || 
                                   effectiveUser.status == MemberStatus.left;
            
            if (isExcludedStatus) return const SliverToBoxAdapter(child: SizedBox.shrink());

            final isExpired = difference < 0;
            final isWithinWindow = difference <= window && difference >= 0;

            if (isExpired || isWithinWindow) {
              final color = isExpired ? AppColors.coral500 : AppColors.amber500;
              final hasSubmittedPreference = effectiveUser.renewalStatus != MemberRenewalStatus.none;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    backgroundColor: color.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        BoxyArtIconBadge(
                          icon: isExpired ? Icons.error_rounded : Icons.calendar_today_rounded,
                          color: color,
                          size: 42,
                          iconSize: 22,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isExpired ? 'MEMBERSHIP EXPIRED' : 'RENEWAL PERIOD',
                                style: AppTypography.micro.copyWith(
                                  color: color,
                                  fontWeight: AppTypography.weightHeavy,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasSubmittedPreference 
                                  ? 'Your selection: ${effectiveUser.renewalStatus.name.toUpperCase()}'
                                  : (isExpired 
                                      ? 'The season ended on ${DateFormat('MMM d').format(expiry)}'
                                      : 'Season ends in $difference days (${DateFormat('MMM d').format(expiry)})'),
                                style: AppTypography.labelStrong.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (societyConfig.isRenewalActive && !hasSubmittedPreference) ...[
                          const SizedBox(width: AppSpacing.md),
                          BoxyArtButton(
                            title: 'RENEW NOW',
                            isPrimary: true,
                            isSmall: true,
                            onTap: () => _showRenewalSelection(context, ref),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          })(),
        ],
        // Notifications & Content
        notificationsAsync.when(
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          data: (allNotifications) {
            final spacing = Theme.of(context).extension<AppSpacingTokens>();
            final unreadNotifications = allNotifications
                .where((n) => !n.isRead)
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            final homeNotifications = unreadNotifications.take(2).toList();
            
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, 
                vertical: spacing?.labelToCard ?? AppSpacing.labelToCard
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Notifications Section (Dynamic)
                  if (homeNotifications.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BoxyArtSectionTitle(
                          title: 'Notifications',
                          isPeeking: true, // Tight to top
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
                    ...homeNotifications.asMap().entries.map((entry) {
                      final isLast = entry.key == homeNotifications.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard)),
                        child: StaggeredEntrance(
                          index: entry.key,
                          child: HomeNotificationCard(notification: entry.value),
                        ),
                      );
                    }),
                  ],
                ]),
              ),
            );
          },
        ),

        // Upcoming Event Section (Next Match / Live Now)
        nextMatch.when(
          data: (event) {
            if (event == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
            final isLive = event.status == EventStatus.inPlay;
                
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoxyArtSectionTitle(
                      title: isLive ? 'LIVE NOW' : 'NEXT FIXTURE', 
                      isPeeking: true,
                    ),
                    const SizedBox(height: AppSpacing.labelToCard),
                    _NextMatchCard(event: event),
                  ],
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Society Polls
        eventsAsync.when(
          data: (events) {
            final activePolls = events.expand((e) => e.feedItems.where((i) => i.type == FeedItemType.poll && i.isPublished).map((item) => (e, item))).toList();
            if (activePolls.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = activePolls[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0) ...[
                            const BoxyArtSectionTitle(title: 'SOCIETY POLLS'),
                            const SizedBox(height: AppSpacing.labelToCard),
                          ],
                          _GlobalPollCard(event: item.$1, item: item.$2),
                        ],
                      ),
                    );
                  },
                  childCount: activePolls.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Active Surveys
        surveysAsync.when(
          data: (surveys) {
            final dismissed = ref.watch(dismissedSurveyIdsProvider);
            final active = surveys
                .where((s) => !dismissed.contains(s.id))
                .toList();

            if (active.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final survey = active[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: BoxyArtCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            const Icon(Icons.poll_rounded, color: AppColors.lime500),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    survey.title,
                                    style: AppTypography.displaySection.copyWith(fontSize: 16),
                                  ),
                                  Text(
                                    'Your feedback is requested',
                                    style: AppTypography.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                            ),
                            BoxyArtGlassIconButton(
                              icon: Icons.chevron_right_rounded,
                              onPressed: () => context.push('/surveys/${survey.id}'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: active.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Leaderboard Snippet
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'ORDER OF MERIT'),
          ),
        ),

        topPlayers.when(
          data: (players) {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: _LeaderboardSnippet(
                  topPlayers: players,
                  personalStanding: personalStanding.value?['standing'] as LeaderboardStanding?,
                  personalRank: personalStanding.value?['rank'] as int?,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        
        // Final spacing
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  void _showRenewalSelection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    BoxyArtBottomSheet.show(
      context: context,
      title: 'MEMBERSHIP RENEWAL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Please select your status for the upcoming season. Your choice will be sent to the admin for final processing.',
              style: AppTypography.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                height: 1.4,
                fontWeight: AppTypography.weightStrong,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          StaggeredEntrance(
            index: 0,
            child: _RenewalOptionTile(
              title: 'Renew Membership',
              subtitle: 'I want to continue playing for the next season.',
              icon: Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                final user = ref.read(effectiveUserProvider);
                _updateRenewal(context, ref, user.id, MemberRenewalStatus.renew);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StaggeredEntrance(
            index: 1,
            child: _RenewalOptionTile(
              title: 'Suspend Membership',
              subtitle: 'I want to take a break but keep my account.',
              icon: Icons.pause_circle_outline_rounded,
              color: AppColors.amber500,
              onTap: () {
                final user = ref.read(effectiveUserProvider);
                _updateRenewal(context, ref, user.id, MemberRenewalStatus.suspend);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StaggeredEntrance(
            index: 2,
            child: _RenewalOptionTile(
              title: 'Leave Society',
              subtitle: 'I want to withdraw from the society.',
              icon: Icons.exit_to_app_rounded,
              color: AppColors.coral500,
              onTap: () {
                final user = ref.read(effectiveUserProvider);
                _updateRenewal(context, ref, user.id, MemberRenewalStatus.leave);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRenewal(BuildContext context, WidgetRef ref, String memberId, MemberRenewalStatus status) async {
    await ref.read(memberRenewalProvider.notifier).updateStatus(memberId, status);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your selection has been submitted.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}

class _RenewalOptionTile extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RenewalOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: color.withValues(alpha: isDark ? 0.12 : 0.08),
      border: Border.all(
        color: color.withValues(alpha: 0.24),
        width: 1.5,
      ),
      child: Row(
        children: [
          BoxyArtIconBadge(
            icon: icon,
            color: color,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.displaySection.copyWith(
                    fontSize: 15,
                    letterSpacing: 0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                    height: 1.2,
                    fontWeight: AppTypography.weightStrong,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: color.withValues(alpha: AppColors.opacityHigh),
            size: 20,
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
                    if (isLive && isPlaying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacityLow),
                          borderRadius: AppShapes.md,
                        ),
                        child: Text(
                          'Playing',
                          style: AppTypography.micro.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                    isSmall: true,
                    onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}/live'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtButton(
                    title: 'View Event Hub',
                    isSecondary: true,
                    isSmall: true,
                    onTap: () => context.push('/events/${Uri.encodeComponent(event.id)}'),
                  ),
                ] else
                  BoxyArtButton(
                    title: 'View Details',
                    isPrimary: true,
                    isSmall: true,
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
                const BoxyArtDivider(),
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
            const BoxyArtDivider(verticalPadding: AppSpacing.xs),
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

  const _SurveyInteractiveCard({required this.survey});

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
                    isSmall: true,
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
                        isSmall: true,
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
class _GlobalPollCard extends ConsumerWidget {
  final GolfEvent event;
  final EventFeedItem item;

  const _GlobalPollCard({required this.event, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = (item.pollData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final votes = (item.pollData['votes'] as Map?)?.cast<String, String>() ?? {};
    final user = ref.watch(effectiveUserProvider);
    final userVote = votes[user.id];
    final hasVoted = userVote != null;
    
    // Calculate percentages
    final totalVotes = votes.length;
    final Map<String, int> counts = {};
    for (var opt in options) {
      counts[opt] = votes.values.where((v) => v == opt).length;
    }

    return BoxyArtCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll_rounded, color: AppColors.lime500, size: AppShapes.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE POLL',
                      style: AppTypography.label.copyWith(
                        color: AppColors.lime500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title ?? 'Quick Question',
                      style: AppTypography.displayHeading.copyWith(fontSize: AppTypography.sizeLargeBody),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isLast = index == options.length - 1;
            final count = counts[option] ?? 0;
            final percent = totalVotes == 0 ? 0.0 : count / totalVotes;
            final isSelected = userVote == option;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: GestureDetector(
                onTap: hasVoted ? null : () => _vote(ref, option),
                child: Stack(
                  children: [
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.pureWhite.withValues(alpha: AppColors.opacitySubtle) 
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: AppShapes.md,
                        border: Border.all(
                          color: isSelected ? AppColors.lime500 : Colors.transparent,
                        ),
                      ),
                    ),
                    if (hasVoted)
                      AnimatedContainer(
                        duration: AppAnimations.slow,
                        height: 48,
                        width: MediaQuery.of(context).size.width * percent,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lime500.withValues(alpha: AppColors.opacityMedium) : AppColors.lime500.withValues(alpha: AppColors.opacitySubtle),
                          borderRadius: AppShapes.md,
                        ),
                      ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightMedium,
                                fontSize: AppTypography.sizeButton,
                              ),
                            ),
                            if (hasVoted)
                              Text('${(percent * 100).round()}%'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (hasVoted)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                '$totalVotes vote${totalVotes == 1 ? '' : 's'} • From ${event.title}',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _vote(WidgetRef ref, String option) async {
    final user = ref.read(effectiveUserProvider);
    final votes = Map<String, String>.from(item.pollData['votes'] ?? {});
    votes[user.id] = option;

    final updatedItem = item.copyWith(
      pollData: {
        ...item.pollData,
        'votes': votes,
      },
    );

    final List<EventFeedItem> updatedItems = List.from(event.feedItems);
    final index = updatedItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      updatedItems[index] = updatedItem;
      final updatedEvent = event.copyWith(feedItems: updatedItems);
      await ref.read(eventsRepositoryProvider).updateEvent(updatedEvent);
    }
  }
}
