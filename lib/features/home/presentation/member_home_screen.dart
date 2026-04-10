import 'dart:convert';
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
import 'package:golf_society/domain/models/society_config.dart';
import '../../events/presentation/events_provider.dart';
import 'package:golf_society/utils/string_utils.dart';

import 'widgets/home_welcome_hero.dart';

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
    final spacing = theme.extension<AppSpacingTokens>();

    // Empty State Detection for "Fresh Start"
    final hasNotifications = notificationsAsync.value?.any((n) => !n.isRead) ?? false;
    final hasNextMatch = nextMatch.value != null;
    final hasLeaderboard = topPlayers.value?.isNotEmpty ?? false;
    final hasSurveys = surveysAsync.value?.isNotEmpty ?? false;
    final isFreshStart = !hasNotifications && !hasNextMatch && !hasLeaderboard && !hasSurveys;

    return HeadlessScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: effectiveUser.firstName,
      titleSuffix: societyConfig.logoUrl != null ? BoxyArtImage(
        url: societyConfig.logoUrl!,
        height: 40,
        fit: BoxFit.contain,
        errorWidget: const SizedBox.shrink(),
      ) : null,
      subtitleWidget: Text(
        _getGreeting(),
        style: AppTypography.labelStrong.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      showMenu: true,
      showAdminShortcut: true,
      slivers: [
        if (isFreshStart)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
            sliver: SliverToBoxAdapter(
              child: StaggeredEntrance(
                index: 0,
                child: HomeWelcomeHero(
                  config: societyConfig,
                  member: effectiveUser,
                ),
              ),
            ),
          ),

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
                            'Viewing as Member',
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

        // Notifications & Content - Conditional on having unread updates
        notificationsAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (allNotifications) {
            final unreadNotifications = allNotifications
                .where((n) => !n.isRead)
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            final homeNotifications = unreadNotifications.take(2).toList();
            
            // Hide section entirely if no unread notifications exist for a clean slate
            if (homeNotifications.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, 
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Notifications Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BoxyArtSectionTitle(
                        title: 'Notifications',
                      ),
                      TextButton(
                        onPressed: () => context.push('/home/notifications'),
                        child: Text(
                          'View All', 
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isDark ? AppColors.lime400 : AppColors.lime700,
                            fontWeight: AppTypography.weightBold,
                            inherit: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...homeNotifications.asMap().entries.map((entry) {
                    return StaggeredEntrance(
                      index: entry.key,
                      child: HomeNotificationCard(notification: entry.value),
                    );
                  }),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BoxyArtSectionTitle(
                      title: isLive ? 'Live Now' : 'Next Fixture', 
                    ),
                    // Removed redundant SizedBox - handled by BoxyArtSectionTitle
                    _NextMatchCard(event: event),
                  ],
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Society Polls
        eventsAsync.when(
          data: (events) {
            final activePolls = events.expand((e) => e.feedItems.where((i) => i.type == FeedItemType.poll && i.isPublished).map((item) => (e, item))).toList();
            if (activePolls.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = activePolls[index];
                    return StaggeredEntrance(
                      index: index,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0) ...[
                            const BoxyArtSectionTitle(title: 'Society Polls'),
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
                    error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Active Surveys
        surveysAsync.when(
          data: (active) {
            if (active.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final survey = active[index];
                    return StaggeredEntrance(
                      index: index,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0) ...[
                            const BoxyArtSectionTitle(title: 'Member Surveys'),
                          ],
                          Dismissible(
                            key: ValueKey('survey_dismiss_${survey.id}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              ref.read(surveysRepositoryProvider).dismissSurvey(survey.id, effectiveUser.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: StatusColors.negative,
                                borderRadius: BorderRadius.circular(AppShapes.rXl),
                              ),
                              child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                            ),
                            child: BoxyArtCard(
                              onTap: () => context.push('/surveys/${survey.id}'),
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Row(
                                children: [
                                  // 1. Identity Icon
                                  const BoxyArtSquareBadge(
                                    size: 44,
                                    isTinted: true,
                                    child: Icon(
                                      Icons.quiz_rounded,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),

                                  // 2. Main Content Area
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toTitleCase(survey.title),
                                          style: AppTypography.cardTitle.copyWith(
                                            color: isDark ? AppColors.pureWhite : AppColors.dark900,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          survey.deadline != null 
                                            ? 'Ends: ${DateFormat('d MMM').format(survey.deadline!)}' 
                                            : 'Your feedback is requested',
                                          style: AppTypography.subtext.copyWith(
                                            color: isDark ? AppColors.dark150 : AppColors.dark700,
                                            fontSize: 13,
                                            fontWeight: AppTypography.weightSemibold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 3. Action / Status Column
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      BoxyArtPill.status(
                                        label: 'POLL',
                                        color: Color(societyConfig.primaryColor),
                                        isAction: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.dark400.withValues(alpha: AppColors.opacityMuted),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Spacing between cards
                          if (index < active.length - 1)
                            SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                        ],
                      ),
                    );
                  },
                  childCount: active.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Leaderboard Snippet - Conditional on having data
        topPlayers.when(
          data: (players) {
            if (players.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverMainAxisGroup(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: BoxyArtSectionTitle(
                      title: 'Order of Merit',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverToBoxAdapter(
                    child: _LeaderboardSnippet(
                      topPlayers: players,
                      personalStanding: personalStanding.value?['standing'] as LeaderboardStanding?,
                      personalRank: personalStanding.value?['rank'] as int?,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        
        // Season Sponsors (Consolidated Tiered View)
        (() {
          // 1. Managed Sponsors: Show all registry sponsors (removing strict scope filter to find the missing 8)
          final managedSponsors = societyConfig.sponsors.toList();
          
          // 2. Unmanaged Sponsors: Sponsors in ledger but NOT in registry
          final unmanagedSponsors = societyConfig.ledgerEntries
              .where((e) => e.type == 'Sponsorship' && 
                e.scope?.toLowerCase() != 'event' && 
                !societyConfig.sponsors.any((s) => s.id == e.sponsorId)
              )
              .map((e) => Sponsor(
                id: e.id,
                name: e.source,
                tier: SponsorTier.standard,
                description: e.description,
                logoUrl: e.logoUrl,
              ))
              .toList();
          
          // 3. Combine and merge by ID to be super safe
          final Map<String, Sponsor> uniqueSponsors = {};
          for (var s in managedSponsors) { uniqueSponsors[s.id] = s; }
          for (var s in unmanagedSponsors) {
            if (!uniqueSponsors.containsKey(s.id)) uniqueSponsors[s.id] = s;
          }
          
          final sponsors = uniqueSponsors.values.toList()
            ..sort((a, b) => a.tier.index.compareTo(b.tier.index));
          
          if (sponsors.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, 
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxyArtSectionTitle(
                    title: 'Official Season Sponsors',
                  ),
                  BoxyArtCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (() {
                        final List<Widget> children = [];
                        
                        // Group by tier
                        final Map<SponsorTier, List<Sponsor>> grouped = {};
                        for (final s in sponsors) {
                          grouped.putIfAbsent(s.tier, () => []).add(s);
                        }

                        final sortedTiers = grouped.keys.toList()
                          ..sort((a, b) => a.index.compareTo(b.index));

                        for (int i = 0; i < sortedTiers.length; i++) {
                          final tier = sortedTiers[i];
                          final group = grouped[tier]!;
                          
                          // Subheader
                          children.add(
                            Padding(
                              padding: EdgeInsets.only(
                                top: i == 0 ? 0 : AppSpacing.xl,
                                bottom: AppSpacing.md,
                              ),
                              child: Text(
                                '${toTitleCase(tier.name)} Partners',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.dark300,
                                  fontWeight: AppTypography.weightHeavy,
                                  letterSpacing: 0.5,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );

                          // Partner Rows
                          for (int j = 0; j < group.length; j++) {
                            final s = group[j];
                            final isLastInGroup = j == group.length - 1;
                            
                            children.add(
                              Padding(
                                padding: EdgeInsets.only(bottom: isLastInGroup ? 0 : AppSpacing.lg),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (s.logoUrl != null && s.logoUrl!.isNotEmpty)
                                      BoxyArtImage(
                                        url: s.logoUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.contain,
                                        borderRadius: BorderRadius.circular(8),
                                        errorWidget: const BoxyArtIconBadge(
                                          icon: Icons.handshake_rounded,
                                          color: AppColors.lime500,
                                          isTinted: true,
                                          size: 56,
                                        ),
                                      )
                                    else
                                      const BoxyArtIconBadge(
                                        icon: Icons.handshake_rounded,
                                        color: AppColors.lime500,
                                        isTinted: true,
                                        size: 56,
                                      ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          (() {
                                            // Find best entry for label (prioritizing season)
                                            String labelStr = toTitleCase(s.name);
                                            
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  labelStr,
                                                  style: AppTypography.body.copyWith(
                                                    fontWeight: AppTypography.weightBold,
                                                    fontSize: 16,
                                                    letterSpacing: -0.4,
                                                  ),
                                                ),
                                              ],
                                            );
                                          })(),
                                          if (s.description != null && s.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                _extractPlainText(s.description),
                                                style: AppTypography.label.copyWith(
                                                  color: AppColors.dark300,
                                                  height: 1.4,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return children;
                      })(),
                    ),
                  ),
                ],
              ),
            ),
          );
        })(),

        // Final spacing
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 140),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }



  String _extractPlainText(String? content) {
    if (content == null) return '';
    if (content.startsWith('[{"insert"')) {
      try {
        final List<dynamic> delta = jsonDecode(content);
        return delta
            .where((op) => op['insert'] is String)
            .map((op) => op['insert'] as String)
            .join('')
            .trim();
      } catch (_) {
        return content.trim();
      }
    }
    return content.trim();
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
    
    // Apply Brand Gradient to the card background
    final backgroundGradient = AppGradients.brandPrimary(context);

    return BoxyArtCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/events/${event.id}'),
      gradient: backgroundGradient,
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
                        style: AppTypography.displayLocker.copyWith(color: AppColors.pureWhite),
                      ),
                    ),
                    if (isLive && isPlaying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withValues(alpha: 0.2),
                          borderRadius: AppShapes.md,
                        ),
                        child: Text(
                          'Playing',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.pureWhite,
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
                  iconColor: AppColors.pureWhite,
                  labelColor: AppColors.pureWhite.withValues(alpha: 0.7),
                  valueColor: AppColors.pureWhite,
                ),
                const SizedBox(height: AppSpacing.md),
                ModernInfoRow(
                  label: 'Tee Off',
                  value: DateFormat('h:mm a').format(event.teeOffTime ?? event.date),
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.pureWhite,
                  labelColor: AppColors.pureWhite.withValues(alpha: 0.7),
                  valueColor: AppColors.pureWhite,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isLive && isPlaying) ...[
                  BoxyArtButton(
                    title: 'ENTER SCORE',
                    isPrimary: true,
                    isSmall: true,
                    onTap: () => context.go('/events/${Uri.encodeComponent(event.id)}/live'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BoxyArtButton(
                    title: 'View Event Hub',
                    isSecondary: true,
                    isSmall: true,
                    onTap: () => context.go('/events/${Uri.encodeComponent(event.id)}'),
                  ),
                ] else
                  BoxyArtButton(
                    title: 'View Details',
                    isPrimary: true,
                    isSmall: true,
                    onTap: () => context.go('/events/${Uri.encodeComponent(event.id)}'),
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
              const BoxyArtIconBadge(
                icon: Icons.poll_rounded,
                color: AppColors.lime500,
                isTinted: true,
                size: AppShapes.iconLg,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dark600,
                        borderRadius: AppShapes.sm,
                        border: Border.all(color: AppColors.dark500),
                      ),
                      child: Text(
                        'POLL QUESTION',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.lime500,
                          fontWeight: AppTypography.weightHeavy,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title ?? 'Quick Question',
                      style: AppTypography.displayHeading.copyWith(
                        fontSize: 18,
                        fontWeight: AppTypography.weightExtraBold,
                      ),
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
                    // Design 4.x Standardized Option Container
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.dark600,
                        borderRadius: AppShapes.md,
                        border: Border.all(
                          color: isSelected ? AppColors.lime500 : AppColors.dark500,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                    // Glassmorphic Percentage Fill (v4.0)
                    if (hasVoted)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: AppAnimations.medium,
                            curve: Curves.easeOutQuart,
                            height: 56,
                            width: constraints.maxWidth * percent,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.lime500.withValues(alpha: 0.12) 
                                  : AppColors.pureWhite.withValues(alpha: 0.06),
                              borderRadius: AppShapes.md,
                            ),
                          );
                        },
                      ),
                    // Label Content with Standardized Toggles
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              isSelected 
                                  ? Icons.radio_button_checked_rounded 
                                  : (hasVoted ? Icons.radio_button_off_rounded : Icons.radio_button_off_rounded),
                              color: isSelected ? AppColors.lime500 : AppColors.dark400,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                option,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? AppColors.lime500 : AppColors.pureWhite,
                                  fontWeight: isSelected ? AppTypography.weightBold : AppTypography.weightRegular,
                                ),
                              ),
                            ),
                            if (hasVoted) ...[
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                '${(percent * 100).round()}%',
                                style: AppTypography.labelStrong.copyWith(
                                  color: isSelected ? AppColors.lime500 : AppColors.dark300,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                style: AppTypography.micro.copyWith(color: AppColors.dark300, letterSpacing: 0.5),
              ),
              if (hasVoted)
                Text(
                  'VOTE CAST',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.lime500,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: 1.0,
                  ),
                )
              else
                Text(
                  'NOT VOTED',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.dark400,
                    fontWeight: AppTypography.weightHeavy,
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
          const BoxyArtDivider(verticalPadding: AppSpacing.lg),
          Text(
            'From ${event.title}',
            style: AppTypography.micro.copyWith(color: AppColors.dark300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
