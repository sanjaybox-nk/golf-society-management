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
import '../../matchplay/domain/match_definition.dart';

part 'widgets/home_next_match_card.dart';
part 'widgets/home_leaderboard_snippet.dart';
part 'widgets/home_poll_card.dart';
part 'widgets/home_matchplay_card.dart';

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
                backgroundColor: AppColors.actionMidnight.withValues(alpha: AppColors.opacityLow),
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
                              letterSpacing: 1.0,
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
          loading: () => const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: false),
            ),
          ),
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
                          style: AppTypography.label.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: AppTypography.weightBold,
                            letterSpacing: AppTypography.lsLabel,
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
        ref.watch(userLiveMatchesProvider).when(
          data: (matches) {
            if (matches.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final (event, match) = matches[index];
                    return StaggeredEntrance(
                      index: index,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BoxyArtSectionTitle(title: 'Active Tournaments'),
                          _MatchPlayMatchupCard(event: event, match: match),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    );
                  },
                  childCount: matches.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // Upcoming Event Section (Next Match / Live Now)
        nextMatch.when(
          data: (event) {
            if (event == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
            // Filter out if it's already shown in Match Play above? 
            // Better to show both if one is a general event and the other is a tournament specific match.
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
                    _NextMatchCard(event: event),
                  ],
                ),
              ),
            );
          },
          loading: () => const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: true),
            ),
          ),
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
          loading: () => const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(useCard: false),
            ),
          ),
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
                              child: const Icon(Icons.delete_sweep_rounded, color: AppColors.pureWhite),
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
          loading: () => const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), sliver: SliverToBoxAdapter(child: BoxyArtLoadingCard(useCard: false))),
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
          loading: () => const SliverPadding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), sliver: SliverToBoxAdapter(child: BoxyArtLoadingCard(useCard: false))),
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
                                '${tier.name.toUpperCase()} PARTNERS',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.dark300,
                                  fontWeight: AppTypography.weightHeavy,
                                  letterSpacing: 1.0,
                                  fontSize: 10,
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
        SliverPadding(
          padding: const EdgeInsets.only(bottom: AppSpacing.x5l),
          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
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


