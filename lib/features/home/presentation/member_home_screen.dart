import 'dart:convert';
import 'dart:io';
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
                    _EventSponsorCard(event: event, societyConfig: societyConfig),
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
        
        // Season Sponsors — Official Sponsors card (Gold / Silver / Bronze)
        (() {
          bool hasSeasonEntry(Sponsor s) {
            final entries = societyConfig.ledgerEntries
                .where((e) => e.sponsorId == s.id && e.type == 'Sponsorship')
                .toList();
            return entries.isEmpty || entries.any((e) => e.scope?.toLowerCase() != 'event');
          }

          final managedSponsors = societyConfig.sponsors.where(hasSeasonEntry).toList();
          final unmanagedSponsors = societyConfig.ledgerEntries
              .where((e) => e.type == 'Sponsorship' &&
                e.scope?.toLowerCase() != 'event' &&
                !societyConfig.sponsors.any((s) => s.id == e.sponsorId))
              .map((e) => Sponsor(
                id: e.id,
                name: e.source,
                tier: SponsorTier.partner,
                description: e.description,
                logoUrl: e.logoUrl,
              ))
              .toList();

          final Map<String, Sponsor> uniqueMap = {};
          for (var s in managedSponsors) { uniqueMap[s.id] = s; }
          for (var s in unmanagedSponsors) { uniqueMap.putIfAbsent(s.id, () => s); }

          final tieredSponsors = uniqueMap.values
              .where((s) => s.tier != SponsorTier.partner)
              .toList()
              ..sort((a, b) => a.tier.index.compareTo(b.tier.index));

          if (tieredSponsors.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

          final Map<SponsorTier, List<Sponsor>> grouped = {};
          for (final s in tieredSponsors) {
            grouped.putIfAbsent(s.tier, () => []).add(s);
          }
          final sortedTiers = grouped.keys.toList()
            ..sort((a, b) => a.index.compareTo(b.index));

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxyArtSectionTitle(title: 'Official Season Sponsors'),
                  BoxyArtCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < sortedTiers.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.xl),
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Text(
                              '${sortedTiers[i].name.toUpperCase()} PARTNERS',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.dark300,
                                fontWeight: AppTypography.weightHeavy,
                                letterSpacing: 1.0,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          for (int j = 0; j < grouped[sortedTiers[i]]!.length; j++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: j < grouped[sortedTiers[i]]!.length - 1 ? AppSpacing.lg : 0,
                              ),
                              child: _SponsorRow(
                                sponsor: grouped[sortedTiers[i]]![j],
                                extractText: _extractPlainText,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        })(),

        // Partners card (Partner tier — always after the sponsors card)
        (() {
          bool hasSeasonEntry(Sponsor s) {
            final entries = societyConfig.ledgerEntries
                .where((e) => e.sponsorId == s.id && e.type == 'Sponsorship')
                .toList();
            return entries.isEmpty || entries.any((e) => e.scope?.toLowerCase() != 'event');
          }

          final managedSponsors = societyConfig.sponsors
              .where((s) => s.tier == SponsorTier.partner && hasSeasonEntry(s))
              .toList();
          final unmanagedSponsors = societyConfig.ledgerEntries
              .where((e) => e.type == 'Sponsorship' &&
                e.scope?.toLowerCase() != 'event' &&
                !societyConfig.sponsors.any((s) => s.id == e.sponsorId))
              .map((e) => Sponsor(
                id: e.id,
                name: e.source,
                tier: SponsorTier.partner,
                description: e.description,
                logoUrl: e.logoUrl,
              ))
              .toList();

          final Map<String, Sponsor> uniqueMap = {};
          for (var s in managedSponsors) { uniqueMap[s.id] = s; }
          for (var s in unmanagedSponsors) { uniqueMap.putIfAbsent(s.id, () => s); }

          final partners = uniqueMap.values.toList();
          if (partners.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoxyArtSectionTitle(title: 'Partners'),
                  BoxyArtCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int j = 0; j < partners.length; j++)
                          Padding(
                            padding: EdgeInsets.only(bottom: j < partners.length - 1 ? AppSpacing.lg : 0),
                            child: _SponsorRow(
                              sponsor: partners[j],
                              extractText: _extractPlainText,
                            ),
                          ),
                      ],
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

class _SponsorRow extends StatelessWidget {
  final Sponsor sponsor;
  final String Function(String?) extractText;

  const _SponsorRow({required this.sponsor, required this.extractText});

  Widget _sponsorLogo(String? url) {
    const fallback = BoxyArtIconBadge(
      icon: Icons.handshake_rounded,
      color: AppColors.lime500,
      isTinted: true,
      size: 56,
    );
    if (url == null || url.isEmpty) return fallback;
    final isLocal = url.startsWith('/') || url.contains('cache');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: isLocal
            ? Image.file(File(url), fit: BoxFit.contain, errorBuilder: (ctx, err, st) => fallback)
            : BoxyArtImage(url: url, fit: BoxFit.contain, errorWidget: fallback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sponsorLogo(sponsor.logoUrl),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toTitleCase(sponsor.name),
                style: AppTypography.headline.copyWith(
                  fontWeight: AppTypography.weightBold,
                  letterSpacing: AppTypography.lsHero,
                ),
              ),
              if (sponsor.description != null && sponsor.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    extractText(sponsor.description),
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
    );
  }
}

class _EventSponsorCard extends StatelessWidget {
  final GolfEvent event;
  final SocietyConfig societyConfig;

  const _EventSponsorCard({required this.event, required this.societyConfig});

  @override
  Widget build(BuildContext context) {
    final sponsors = event.isClosed
        ? <FinancialEntry>[]
        : societyConfig.ledgerEntries.where((e) =>
            e.type == 'Sponsorship' &&
            e.scope?.toLowerCase() == 'event' &&
            e.eventId == event.id).toList();

    if (sponsors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.atomic),
      child: BoxyArtCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EVENT SPONSOR',
              style: AppTypography.micro.copyWith(
                color: AppColors.dark300,
                fontWeight: AppTypography.weightHeavy,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (int i = 0; i < sponsors.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.lg),
              _SponsorRow(
                sponsor: Sponsor(
                  id: sponsors[i].id,
                  name: sponsors[i].source,
                  tier: SponsorTier.partner,
                  description: sponsors[i].description,
                  logoUrl: sponsors[i].logoUrl,
                ),
                extractText: (s) {
                  if (s == null) return '';
                  if (s.startsWith('[{"insert"')) {
                    try {
                      final List<dynamic> delta = jsonDecode(s);
                      return delta
                          .where((op) => op['insert'] is String)
                          .map((op) => op['insert'] as String)
                          .join('')
                          .trim();
                    } catch (_) {}
                  }
                  return s.trim();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
