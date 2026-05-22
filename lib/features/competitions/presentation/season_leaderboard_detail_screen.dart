import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../events/presentation/events_provider.dart';
import 'standings/standings_providers.dart';
import 'package:golf_society/domain/models/leaderboard_standing.dart';
import '../../members/presentation/profile_provider.dart';
import '../../members/presentation/members_provider.dart';
import 'package:golf_society/domain/models/leaderboard_config.dart';
import 'package:golf_society/domain/divisions/division_helper.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../admin/utils/leaderboard_rule_translator.dart';

class SeasonLeaderboardDetailScreen extends ConsumerWidget {
  final String leaderboardId;
  final String? seasonId;

  const SeasonLeaderboardDetailScreen({
    super.key, 
    required this.leaderboardId, 
    this.seasonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = seasonId != null 
        ? ref.watch(seasonByIdProvider(seasonId!))
        : ref.watch(activeSeasonProvider);
    final currentUser = ref.watch(effectiveUserProvider);
    final currentUserId = currentUser.id;

    // Use provided seasonId or fall back to active season ID
    final actualSeasonId = seasonId ?? seasonAsync.value?.id;

    if (actualSeasonId == null) {
      return const HeadlessScaffold(
        title: 'Standings',
        showBack: true,
        slivers: [
          SliverFillRemaining(
            child: BoxyArtLoadingCard(useCard: false),
          ),
        ],
      );
    }

    final standingsAsync = ref.watch(leaderboardStandingsProvider((seasonId: actualSeasonId, leaderboardId: leaderboardId)));

    return seasonAsync.when(
      data: (season) {
        final config = season?.leaderboards.firstWhereOrNull((l) => l.id == leaderboardId);
        final title = config?.name ?? 'Standings';
        final subtitle = season?.name.toUpperCase() ?? 'SEASON STANDINGS';

        return HeadlessScaffold(
          title: title,
          subtitle: subtitle,
          showBack: true,
          slivers: [
            standingsAsync.when(
              data: (standings) {
                final positions = _calculatePositions(standings);
                final podiumStandings = standings.where((s) => s.points > 0).toList();
                final podiumPositions = [
                  for (int i = 0; i < positions.length; i++)
                    if (standings[i].points > 0) positions[i],
                ];
                return SliverMainAxisGroup(
                  slivers: [
                    if (podiumStandings.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _PodiumHeader(
                          standings: podiumStandings.take(3).toList(),
                          positions: podiumPositions.take(3).toList(),
                          config: config,
                          currentUserId: currentUserId,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.cardToCard)),
                    ],

                    if (standings.isEmpty)
                      const SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        sliver: SliverToBoxAdapter(
                          child: BoxyArtEmptyCard(
                            title: 'No Data Available',
                            message: 'Standings will appear here once events in this season are published and calculated.',
                            icon: Icons.leaderboard_outlined,
                          ),
                        ),
                      )
                    else ...[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final standing = standings[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                              child: _StandingRow(
                                standing: standing,
                                position: positions[index],
                                isShared: _isSharedPosition(positions, index),
                                isMe: standing.memberId == currentUserId,
                                config: config,
                                divisionConfig: season?.divisionConfig,
                              ),
                            );
                          },
                          childCount: standings.length,
                        ),
                      ),
                      if (config != null)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.pageBottom),
                          sliver: SliverToBoxAdapter(
                            child: _RulesCard(
                              config: config!,
                              onTap: () => _showRulesSheet(context, config!),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
              loading: () => const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: BoxyArtLoadingCard(useCard: false),
                ),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: BoxyArtEmptyState(
                  title: 'Standings Error',
                  message: e.toString(),
                  icon: Icons.error_outline_rounded,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const HeadlessScaffold(title: 'Standings', showBack: true, slivers: [SliverToBoxAdapter(child: BoxyArtLoadingCard())]),
      error: (e, s) => HeadlessScaffold(title: 'Error', showBack: true, slivers: [SliverToBoxAdapter(child: Text(e.toString()))]),
    );
  }

}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

List<int> _calculatePositions(List<LeaderboardStanding> standings) {
  final positions = <int>[];
  for (int i = 0; i < standings.length; i++) {
    if (i == 0) {
      positions.add(1);
    } else if (standings[i].points == standings[i - 1].points) {
      positions.add(positions[i - 1]);
    } else {
      positions.add(i + 1);
    }
  }
  return positions;
}

bool _isSharedPosition(List<int> positions, int index) {
  final pos = positions[index];
  return (index > 0 && positions[index - 1] == pos) ||
      (index < positions.length - 1 && positions[index + 1] == pos);
}

void _showRulesSheet(BuildContext context, LeaderboardConfig config) {
  BoxyArtBottomSheet.show(
    context: context,
    title: 'Scoring Rules',
    child: config.map(
      orderOfMerit: (oom) => _OomRulesContent(config: oom),
      bestOfSeries: (bos) => _BosRulesContent(config: bos),
      eclectic: (e) => _EclecticRulesContent(config: e),
      markerCounter: (m) => _MarkerRulesContent(config: m),
    ),
  );
}

String _unitLabel(LeaderboardConfig? config) {
  if (config == null) return 'PTS';
  return config.map(
    orderOfMerit: (_) => 'PTS',
    bestOfSeries: (bos) => bos.metric == BestOfMetric.stableford ? 'PTS' : 'STR',
    eclectic: (e) => e.metric == EclecticMetric.stableford ? 'PTS' : 'STR',
    markerCounter: (m) {
      if (m.rankingMethod == MarkerRankingMethod.points) return 'PTS';
      if (m.targetTypes.length == 1) {
        return switch (m.targetTypes.first) {
          MarkerType.birdie => 'BIRDIES',
          MarkerType.eagle => 'EAGLES',
          MarkerType.albatross => 'ALBATROSS',
          MarkerType.holeInOne => 'ACES',
          MarkerType.two => '2s',
          MarkerType.par => 'PARS',
        };
      }
      return 'MARKERS';
    },
  );
}

class _RulesCard extends StatelessWidget {
  final LeaderboardConfig config;
  final VoidCallback onTap;

  const _RulesCard({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final description = LeaderboardRuleTranslator.translate(config);

    return BoxyArtCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          BoxyArtIconBadge(
            icon: Icons.info_outline_rounded,
            color: AppColors.dark300,
            isTinted: true,
            size: AppShapes.iconMd,
            iconSize: AppShapes.iconSm,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How this works', style: AppTypography.labelStrong),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.chevron_right_rounded, color: AppColors.dark400, size: AppShapes.iconSm),
        ],
      ),
    );
  }
}

class _PodiumHeader extends ConsumerWidget {
  final List<LeaderboardStanding> standings;
  final List<int> positions;
  final LeaderboardConfig? config;
  final String currentUserId;

  const _PodiumHeader({required this.standings, required this.positions, this.config, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String unit = _unitLabel(config);
    final members = ref.watch(allMembersProvider).value ?? [];
    String? avatarUrl(String memberId) =>
        members.firstWhereOrNull((m) => m.id == memberId)?.avatarUrl;
    bool isShared(int i) => _isSharedPosition(positions, i);

    final count = standings.length;

    Widget spot(int i, {bool isWinner = false}) => Expanded(
          child: _PodiumSpot(
            standing: standings[i],
            rank: positions[i],
            isShared: isShared(i),
            isWinner: isWinner,
            unit: unit,
            isMe: standings[i].memberId == currentUserId,
            avatarUrl: avatarUrl(standings[i].memberId),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (count == 1) ...[
            spot(0, isWinner: true),
          ] else if (count == 2) ...[
            spot(1),
            spot(0, isWinner: true),
          ] else ...[
            spot(1),
            spot(0, isWinner: true),
            spot(2),
          ],
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final LeaderboardStanding standing;
  final int rank;
  final bool isShared;
  final bool isWinner;
  final String unit;
  final bool isMe;
  final String? avatarUrl;

  const _PodiumSpot({
    required this.standing,
    required this.rank,
    this.isShared = false,
    this.isWinner = false,
    required this.unit,
    this.isMe = false,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    
    final Color rankColor = rank == 1 
        ? AppColors.amber500 
        : (rank == 2 
            ? (isDark ? AppColors.dark150 : AppColors.dark400) 
            : (isDark ? AppColors.dark300 : AppColors.dark600));

    final double avatarSize = isWinner ? 92.0 : 76.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomCenter, 
          clipBehavior: Clip.none, 
          children: [
            // High-Fidelity Avatar with Rank Branding
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: avatarSize, 
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: isDark ? AppColors.dark600 : AppColors.pureWhite,
                  border: Border.all(
                    color: isMe ? primary : rankColor.withValues(alpha: isWinner ? 1 : AppColors.opacitySubtle),
                    width: isWinner ? AppShapes.borderThick : AppShapes.borderMedium,
                  ),
                  boxShadow: isWinner
                      ? theme.extension<AppShadows>()?.primaryButtonGlow ?? []
                      : theme.extension<AppShadows>()?.softScale ?? [],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? BoxyArtImage(url: avatarUrl!, fit: BoxFit.cover)
                      : Container(
                          color: rankColor.withValues(alpha: 0.12),
                          child: Center(
                            child: Text(
                              _initials(standing.memberName),
                              style: AppTypography.displayHero.copyWith(
                                fontSize: isWinner ? AppTypography.sizeDisplay : AppTypography.sizeHeadline,
                                fontWeight: AppTypography.weightHeavy,
                                color: isMe ? primary : rankColor,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            
            // Standardized Rank Badge
            Positioned(
              bottom: 2,
              child: BoxyArtNumberBadge(
                number: rank,
                prefix: isShared ? '=' : null,
                size: 28,
                isRanking: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Name & Points with High-Contrast Typography
        Text(
          standing.memberName, 
          textAlign: TextAlign.center, 
          style: AppTypography.labelStrong.copyWith(
            fontSize: isWinner ? AppTypography.sizeLabel : AppTypography.sizeMicro,
            color: isMe ? primary : null,
          ),
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${standing.points.toStringAsFixed(0)} $unit',
          style: AppTypography.micro.copyWith(
            color: primary,
            fontWeight: AppTypography.weightBold,
            letterSpacing: AppTypography.lsStandard,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Branded Podium Section
        Container(
          width: double.infinity, 
          height: isWinner ? 68 : 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.dark800 : AppColors.pureWhite, 
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(theme.extension<AppShapeTokens>()?.card.topLeft.x ?? AppShapes.rLg),
            ),
            boxShadow: theme.extension<AppShadows>()?.softScale ?? [],
            border: Border.all(
              color: isDark ? AppColors.dark600.withValues(alpha: 0.3) : AppColors.dark100,
              width: 1,
            ),
          ),
          child: isWinner ? Center(
            child: Icon(
              Icons.star_rounded, 
              color: AppColors.amber500.withValues(alpha: 0.6), 
              size: 18,
            ),
          ) : null,
        ),
      ],
    );
  }
}

class _StandingRow extends ConsumerWidget {
  final LeaderboardStanding standing;
  final int position;
  final bool isShared;
  final bool isMe;
  final LeaderboardConfig? config;
  final DivisionConfig? divisionConfig;

  const _StandingRow({
    required this.standing,
    required this.position,
    required this.isShared,
    required this.isMe,
    this.config,
    this.divisionConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final members = ref.watch(allMembersProvider).value ?? [];
    final member = members.firstWhereOrNull((m) => m.id == standing.memberId);

    // Show division pill when leaderboard is not already filtered to one division
    final configDivisionFilter = config?.map(
      orderOfMerit: (c) => c.divisionFilter,
      bestOfSeries: (c) => c.divisionFilter,
      eclectic: (c) => c.divisionFilter,
      markerCounter: (c) => c.divisionFilter,
    );
    final memberDivision = divisionConfig != null && member != null
        ? DivisionHelper.assignDivision(member, divisionConfig)
        : null;
    final showDivisionPill = memberDivision != null && configDivisionFilter == null;

    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      border: isMe ? Border.all(color: AppColors.amber500, width: 1.5) : null,
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          BoxyArtNumberBadge(
            number: position,
            prefix: isShared ? '=' : null,
            size: 32,
            isRanking: true,
          ),
          const SizedBox(width: AppSpacing.md),
          BoxyArtAvatar(
            url: member?.avatarUrl,
            initials: _initials(standing.memberName),
            radius: 16,
            isCircle: true,
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standing.memberName, 
                  style: AppTypography.labelStrong.copyWith(
                    color: isMe ? primary : null,
                  ), 
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMe)
                  Text(
                    'PERSONAL BEST',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.amber500,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: AppTypography.lsLabel,
                    ),
                  ),
                if (showDivisionPill)
                  BoxyArtPill.status(
                    label: DivisionHelper.shortLabel(memberDivision!),
                    color: memberDivision == Division.div1 || memberDivision == Division.div1Ladies
                        ? AppColors.lime500
                        : AppColors.amber500,
                    hasHorizontalMargin: false,
                  ),
              ],
            ),
          ),
          
          // Points Display
          Text(
            standing.points.toStringAsFixed(0), 
            style: AppTypography.body.copyWith(
              fontWeight: AppTypography.weightBlack, 
              color: isMe ? primary : null,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _unitLabel(config),
            style: AppTypography.micro.copyWith(
              fontWeight: AppTypography.weightBold,
              color: AppColors.dark400,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    BoxyArtBottomSheet.show(
      context: context,
      title: standing.memberName,
      child: _StandingDetailContent(standing: standing, config: config),
    );
  }
}

class _StandingDetailContent extends StatelessWidget {
  final LeaderboardStanding standing;
  final LeaderboardConfig? config;

  const _StandingDetailContent({required this.standing, this.config});

  @override
  Widget build(BuildContext context) {
    if (config == null) return const SizedBox.shrink();
    return config!.map(
      orderOfMerit: (c) => _OomDetail(standing: standing, config: c),
      bestOfSeries: (c) => _BosDetail(standing: standing, config: c),
      eclectic: (c) => _EclecticDetail(standing: standing, config: c),
      markerCounter: (c) => _MarkerDetail(standing: standing, config: c),
    );
  }
}

// ── Shared stat tile ──────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxyArtCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: isDark ? AppColors.dark200 : AppColors.dark400,
              letterSpacing: AppTypography.lsLabel,
              fontWeight: AppTypography.weightBold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: AppTypography.label.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: AppTypography.weightHeavy,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statGrid(List<_StatTile> tiles) => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.8,
      children: tiles,
    );

// ── OoM detail ────────────────────────────────────────────────────────────────

class _OomDetail extends StatelessWidget {
  final LeaderboardStanding standing;
  final OrderOfMeritConfig config;

  const _OomDetail({required this.standing, required this.config});

  @override
  Widget build(BuildContext context) {
    final best = standing.history.isNotEmpty
        ? standing.history.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)
        : '—';
    final unit = config.source == OOMSource.position ? 'PTS' : (config.rankingBasis == OOMRankingBasis.stableford ? 'PTS' : 'STR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Season totals'),
        _statGrid([
          _StatTile(label: 'TOTAL $unit', value: standing.points.toStringAsFixed(0)),
          _StatTile(label: 'ROUNDS PLAYED', value: standing.roundsPlayed.toString()),
          _StatTile(label: 'BEST ROUND', value: best),
          if (config.bestN > 0)
            _StatTile(label: 'ROUNDS COUNTED', value: standing.roundsCounted.toString()),
        ]),
        if (standing.history.isNotEmpty) ...[
          const _RuleSectionTitle('Round history'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int i = 0; i < standing.history.length; i++) ...[
                  _RuleRow(
                    label: 'Round ${i + 1}',
                    value: '${standing.history[i].toStringAsFixed(0)} $unit',
                    isHighlighted: standing.history[i] == standing.history.reduce((a, b) => a > b ? a : b),
                  ),
                  if (i < standing.history.length - 1) const BoxyArtDivider(verticalPadding: 0),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

// ── Best of Series detail ─────────────────────────────────────────────────────

class _BosDetail extends StatelessWidget {
  final LeaderboardStanding standing;
  final BestOfSeriesConfig config;

  const _BosDetail({required this.standing, required this.config});

  @override
  Widget build(BuildContext context) {
    final unit = config.metric == BestOfMetric.stableford ? 'PTS' : 'STR';
    final sortedHistory = [...standing.history]..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Season totals'),
        _statGrid([
          _StatTile(label: 'TOTAL $unit', value: standing.points.toStringAsFixed(0)),
          _StatTile(label: 'ROUNDS PLAYED', value: standing.roundsPlayed.toString()),
          _StatTile(label: 'ROUNDS COUNTED', value: '${standing.roundsCounted} of ${config.bestN}'),
          if (sortedHistory.isNotEmpty)
            _StatTile(label: 'BEST ROUND', value: sortedHistory.first.toStringAsFixed(0)),
        ]),
        if (standing.history.isNotEmpty) ...[
          const _RuleSectionTitle('All rounds'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int i = 0; i < standing.history.length; i++) ...[
                  _RuleRow(
                    label: 'Round ${i + 1}',
                    value: '${standing.history[i].toStringAsFixed(0)} $unit',
                    isHighlighted: i < standing.roundsCounted,
                  ),
                  if (i < standing.history.length - 1) const BoxyArtDivider(verticalPadding: 0),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

// ── Eclectic detail ───────────────────────────────────────────────────────────

class _EclecticDetail extends StatelessWidget {
  final LeaderboardStanding standing;
  final EclecticConfig config;

  const _EclecticDetail({required this.standing, required this.config});

  @override
  Widget build(BuildContext context) {
    final unit = config.metric == EclecticMetric.stableford ? 'PTS' : 'STR';
    final holes = standing.holeScores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Dream round'),
        _statGrid([
          _StatTile(label: 'TOTAL $unit', value: standing.points.toStringAsFixed(0)),
          _StatTile(label: 'HOLES RECORDED', value: holes.length.toString()),
        ]),
        if (holes.isNotEmpty) ...[
          const _RuleSectionTitle('Best score per hole'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int h = 1; h <= 18; h++) ...[
                  if (holes.containsKey(h.toString())) ...[
                    _RuleRow(
                      label: 'Hole $h',
                      value: '${holes[h.toString()]} $unit',
                    ),
                    if (h < 18 && holes.containsKey((h + 1).toString()))
                      const BoxyArtDivider(verticalPadding: 0),
                  ],
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

// ── Marker Counter detail ─────────────────────────────────────────────────────

class _MarkerDetail extends StatelessWidget {
  final LeaderboardStanding standing;
  final MarkerCounterConfig config;

  const _MarkerDetail({required this.standing, required this.config});

  @override
  Widget build(BuildContext context) {
    final unit = _unitLabel(config);
    final isSingleType = config.targetTypes.length == 1;
    final holes = standing.holeScores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Season totals'),
        _statGrid([
          _StatTile(label: 'TOTAL $unit', value: standing.points.toStringAsFixed(0)),
          _StatTile(label: 'ROUNDS PLAYED', value: standing.roundsPlayed.toString()),
        ]),
        if (standing.history.isNotEmpty) ...[
          const _RuleSectionTitle('Per round'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int i = 0; i < standing.history.length; i++) ...[
                  _RuleRow(
                    label: 'Round ${i + 1}',
                    value: standing.history[i] > 0
                        ? '${standing.history[i].toStringAsFixed(0)} $unit'
                        : 'None',
                    isHighlighted: standing.history[i] > 0,
                  ),
                  if (i < standing.history.length - 1) const BoxyArtDivider(verticalPadding: 0),
                ],
              ],
            ),
          ),
        ],
        if (isSingleType && holes.isNotEmpty) ...[
          const _RuleSectionTitle('Holes scored'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.standard, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int i = 0; i < holes.entries.length; i++) ...[
                  _RuleRow(
                    label: 'Hole ${holes.keys.elementAt(i)}',
                    value: '× ${holes.values.elementAt(i)}',
                    isHighlighted: true,
                  ),
                  if (i < holes.length - 1) const BoxyArtDivider(verticalPadding: 0),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rules sheet content widgets
// ---------------------------------------------------------------------------

class _RuleRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _RuleRow({required this.label, required this.value, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.dark200 : AppColors.dark400,
                fontWeight: AppTypography.weightRegular,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelStrong.copyWith(
              color: isHighlighted ? primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleSectionTitle extends StatelessWidget {
  final String title;
  const _RuleSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.cardToLabel, bottom: AppSpacing.labelToCard),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.micro.copyWith(
          color: isDark ? AppColors.dark200 : AppColors.dark400,
          fontWeight: AppTypography.weightBold,
          letterSpacing: AppTypography.lsLabel,
        ),
      ),
    );
  }
}

class _OomRulesContent extends StatelessWidget {
  final OrderOfMeritConfig config;
  const _OomRulesContent({required this.config});

  @override
  Widget build(BuildContext context) {
    final sortedPositions = config.positionPointsMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sortedPositions.isNotEmpty) ...[
          const _RuleSectionTitle('Points per position'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                for (int i = 0; i < sortedPositions.length; i++) ...[
                  _RuleRow(
                    label: _ordinal(sortedPositions[i].key),
                    value: '${sortedPositions[i].value} pts',
                    isHighlighted: sortedPositions[i].key == 1,
                  ),
                  if (i < sortedPositions.length - 1) const BoxyArtDivider(verticalPadding: 0),
                ],
              ],
            ),
          ),
        ] else ...[
          const _RuleSectionTitle('Scoring basis'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                _RuleRow(
                  label: 'Metric',
                  value: config.rankingBasis == OOMRankingBasis.stableford ? 'Stableford' : 'Gross strokes',
                ),
                const BoxyArtDivider(verticalPadding: 0),
                _RuleRow(
                  label: 'Rounds',
                  value: config.bestN > 0 ? 'Best ${config.bestN} only' : 'All rounds counted',
                ),
                const BoxyArtDivider(verticalPadding: 0),
                _RuleRow(
                  label: 'Scope',
                  value: switch (config.scope) {
                    LeaderboardScope.seasonOnly => 'Season events only',
                    LeaderboardScope.invitationalsOnly => 'Non-season events only',
                    LeaderboardScope.global => 'All events',
                  },
                ),
              ],
            ),
          ),
        ],
        if (config.appearancePoints > 0) ...[
          const _RuleSectionTitle('Participation bonus'),
          BoxyArtCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.xs,
            ),
            child: _RuleRow(
              label: 'Per event',
              value: '+${config.appearancePoints} pts for every finisher',
            ),
          ),
        ],
        const _RuleSectionTitle('Ties'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: _RuleRow(
            label: config.source == OOMSource.position ? 'Tied positions' : 'Equal points',
            value: config.source == OOMSource.position ? 'Points shared equally' : 'Shared position',
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }

  String _ordinal(int n) {
    if (n == 1) return '1st Place';
    if (n == 2) return '2nd Place';
    if (n == 3) return '3rd Place';
    return '${n}th Place';
  }
}

class _BosRulesContent extends StatelessWidget {
  final BestOfSeriesConfig config;
  const _BosRulesContent({required this.config});

  @override
  Widget build(BuildContext context) {
    final metric = config.metric == BestOfMetric.stableford ? 'Stableford points' : 'Stroke play';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Format'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              _RuleRow(label: 'Rounds counted', value: 'Best ${config.bestN}', isHighlighted: true),
              const BoxyArtDivider(verticalPadding: 0),
              _RuleRow(label: 'Scoring method', value: metric),
            ],
          ),
        ),
        const _RuleSectionTitle('Ties'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: const _RuleRow(
            label: 'Equal totals',
            value: 'Shared position, alphabetical',
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

class _EclecticRulesContent extends StatelessWidget {
  final EclecticConfig config;
  const _EclecticRulesContent({required this.config});

  @override
  Widget build(BuildContext context) {
    final method = config.metric == EclecticMetric.stableford ? 'Stableford points' : 'Gross strokes';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RuleSectionTitle('Format'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              const _RuleRow(label: 'Score used', value: 'Best per hole'),
              const BoxyArtDivider(verticalPadding: 0),
              _RuleRow(label: 'Method', value: method),
            ],
          ),
        ),
        const _RuleSectionTitle('Ties'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: const _RuleRow(
            label: 'Equal totals',
            value: 'Countback: last 9, 6, 3, 1 holes',
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}

class _MarkerRulesContent extends StatelessWidget {
  final MarkerCounterConfig config;
  const _MarkerRulesContent({required this.config});

  String _fmt(String val) {
    final exp = RegExp(r'(?<=[a-z])[A-Z]');
    final s = val.replaceAllMapped(exp, (m) => ' ${m.group(0)}');
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final shapes = Theme.of(context).extension<AppShapeTokens>();
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final chipGap = spacing?.cardToCard ?? AppSpacing.atomic;

    final holeText = config.holeFilter == HoleFilter.all
        ? 'All holes'
        : '${_fmt(config.holeFilter.name)}s only';
    final roundsText = config.bestN > 0 ? 'Best ${config.bestN} rounds' : 'All rounds';
    final basisText = config.rankingMethod == MarkerRankingMethod.points
        ? 'Total Stableford points'
        : 'Count occurrences';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.rankingMethod == MarkerRankingMethod.count) ...[
        const _RuleSectionTitle('Target markers'),
        Wrap(
          spacing: chipGap,
          runSpacing: chipGap,
          children: config.targetTypes.map((t) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.standard,
              vertical: AppSpacing.atomic,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: AppColors.opacityLow),
              borderRadius: shapes?.pill ?? BorderRadius.circular(20),
              border: Border.all(
                color: primary.withValues(alpha: AppColors.opacityBorder),
                width: AppShapes.borderThin,
              ),
            ),
            child: Text(
              _fmt(t.name),
              style: AppTypography.label.copyWith(
                fontWeight: AppTypography.weightBold,
                color: primary,
              ),
            ),
          )).toList(),
        ),
        ], // end count-only target markers section
        const _RuleSectionTitle('Rules'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              _RuleRow(label: 'Holes', value: holeText),
              const BoxyArtDivider(verticalPadding: 0),
              _RuleRow(label: 'Basis', value: basisText),
              const BoxyArtDivider(verticalPadding: 0),
              _RuleRow(label: 'Rounds', value: roundsText),
            ],
          ),
        ),
        const _RuleSectionTitle('Ties'),
        BoxyArtCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.xs,
          ),
          child: const _RuleRow(
            label: 'Equal count',
            value: 'Shared position, alphabetical',
          ),
        ),
        const SizedBox(height: AppSpacing.standard),
      ],
    );
  }
}
