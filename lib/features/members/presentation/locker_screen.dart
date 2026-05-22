import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/widgets/member_stats_row.dart';
import 'package:golf_society/features/members/presentation/member_stats_provider.dart';
import 'package:golf_society/features/members/presentation/widgets/member_cuts_card.dart';
import 'package:golf_society/features/members/presentation/widgets/handicap_trend_chart.dart';
import '../../home/presentation/home_providers.dart';
import '../../events/presentation/events_provider.dart';
import 'package:golf_society/domain/divisions/division_helper.dart';
import 'widgets/society_honors_modal.dart';

class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final user = ref.watch(effectiveUserProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;
    final primary = Theme.of(context).primaryColor;

    return HeadlessScaffold(
      title: 'Locker Room',
      subtitle: 'Private performance and settings',
      backgroundColor: beigeBackground,
      showBack: false,
      onBack: () => context.go('/'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 
            0, // Rely on HeadlessScaffold buffer
            AppTheme.pagePadding, 
            AppSpacing.cardToLabel
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // Profile Section
              Center(
                child: Column(
                  children: [
                    BoxyArtAvatar(
                      url: user.avatarUrl,
                      initials: '${user.firstName[0]}${user.lastName[0]}',
                      radius: 50,
                      isCircle: true,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: AppTypography.displayLocker,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                        borderRadius: BorderRadius.circular(AppShapes.rPill),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final society = ref.watch(themeControllerProvider);
                          final system = society.handicapSystem;
                          
                          if (user.handicapId == null) {
                            return Text(
                              'SYSTEM ADMINISTRATOR',
                              style: AppTypography.label.copyWith(
                                color: AppColors.lime500,
                                fontWeight: AppTypography.weightHeavy,
                                letterSpacing: 1.0,
                              ),
                            );
                          }

                          return Text(
                            '${system.shortName}: ${user.handicapId ?? "N/A"}',
                            style: AppTypography.label.copyWith(
                              color: AppColors.lime500,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Handicap Section OR Registration Call
              if (user.handicapId != null)
                Builder(builder: (context) {
                  final season = ref.watch(activeSeasonProvider).value;
                  final division = DivisionHelper.assignDivision(user, season?.divisionConfig);
                  return BoxyArtCard(
                    child: Column(
                      children: [
                        const BoxyArtSectionTitle(title: 'Current Handicap', isLevel2: true),
                        Text(
                          user.handicap.toStringAsFixed(1),
                          style: AppTypography.displayHero.copyWith(color: primary),
                        ),
                        if (division != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          BoxyArtPill.status(
                            label: DivisionHelper.label(division),
                            color: division == Division.div1 || division == Division.div1Ladies
                                ? AppColors.lime500
                                : AppColors.amber500,
                            isAction: false,
                          ),
                        ],
                        if (user.handicapHistory.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          BoxyArtHandicapTrend(history: user.handicapHistory),
                        ],
                      ],
                    ),
                  );
                })
              else
                BoxyArtCard(
                  backgroundColor: AppColors.lime500.withValues(alpha: AppColors.opacityLow),
                  child: Column(
                    children: [
                      Icon(Icons.sports_golf_rounded, color: AppColors.lime500, size: 40),
                      SizedBox(height: AppSpacing.md),
                        Text(
                          'NOT REGISTERED',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.lime500,
                            fontWeight: AppTypography.weightBold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'You are managing this society but are not currently listed as a playing member.',
                        style: AppTypography.micro.copyWith(color: AppColors.dark400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // Society Cuts Card (Transparency for members)
              Consumer(
                builder: (context, ref, _) {
                  final eventsAsync = ref.watch(eventsProvider);
                  final config = ref.watch(themeControllerProvider);
                  
                  return eventsAsync.when(
                    data: (events) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.standard),
                      child: MemberCutsCard(
                        memberId: user.id,
                        allEvents: events,
                        config: config,
                      ),
                    ),
                    loading: () => const BoxyArtLoadingCard(useCard: false, isCompact: true),
                    error: (e, s) => const SizedBox.shrink(), // Silent for cuts unless critical
                  );
                },
              ),

              // Financial Status Section
              Consumer(
                builder: (context, ref, _) {
                  final statusAsync = ref.watch(memberFinancialStatusProvider(user.id));
                  return statusAsync.when(
                    data: (status) {
                      if (status.totalDebt == 0 && status.accountCredit == 0) return const SizedBox.shrink();

                      final isCredit = status.netBalance > 0;
                      final isDebt = status.netBalance < 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                        child: BoxyArtCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'FINANCES', 
                                    style: AppTypography.micro.copyWith(
                                      fontWeight: AppTypography.weightBold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  if (isCredit)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.lime500, borderRadius: BorderRadius.circular(AppShapes.rSm)),
                                      child: Text('CREDIT: +£${status.netBalance.toStringAsFixed(0)}', style: AppTypography.micro.copyWith(color: AppColors.dark400, fontWeight: AppTypography.weightHeavy)),
                                    )
                                  else if (isDebt)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.coral500, borderRadius: BorderRadius.circular(AppShapes.rSm)),
                                      child: Text('OWES: £${status.netBalance.abs().toStringAsFixed(0)}', style: AppTypography.micro.copyWith(color: AppColors.pureWhite, fontWeight: AppTypography.weightHeavy)),
                                    )
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (status.accountCredit > 0) ...[
                                Text(
                                  'AVAILABLE VOUCHER CREDIT: £${status.accountCredit.toStringAsFixed(0)}',
                                  style: AppTypography.micro.copyWith(
                                    color: AppColors.lime500,
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (status.totalEventFeesOwed > 0) ...[
                                Text(
                                  'EVENT ENTRY FEES OWED: £${status.totalEventFeesOwed.toStringAsFixed(0)}',
                                  style: AppTypography.micro.copyWith(
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                              if (status.totalFinesOwed > 0) ...[
                                Text(
                                  'ACCUMULATED FINES OWED: £${status.totalFinesOwed.toStringAsFixed(0)}',
                                  style: AppTypography.micro.copyWith(
                                    color: AppColors.coral500,
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const BoxyArtLoadingCard(useCard: false, isCompact: true),
                    error: (e, s) => const SizedBox.shrink(), // Silent for finances header
                  );
                },
              ),
              // Season Stakes section
              Consumer(
                builder: (context, ref, _) {
                  final stakesAsync = ref.watch(homeSeasonStakesProvider);
                  return stakesAsync.when(
                    data: (stakes) {
                      if (stakes == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                        child: BoxyArtCard(
                          backgroundColor: primary.withValues(alpha: AppColors.opacityLow),
                          border: Border.all(color: primary.withValues(alpha: AppColors.opacityLow)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: AppColors.opacityLow),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.auto_awesome_rounded, color: primary, size: AppShapes.iconMd),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SEASON STAKES',
                                      style: AppTypography.micro.copyWith(
                                        fontWeight: AppTypography.weightBold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      stakes,
                                      style: AppTypography.labelStrong,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const BoxyArtLoadingCard(useCard: false, isCompact: true),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
              ),

              // Founding Member Recognition
              if (user.isFoundingMember)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
                  child: GestureDetector(
                    onTap: () => _showHonors(context, user),
                    child: BoxyArtCard(
                      backgroundColor: AppColors.lime500.withValues(alpha: 0.05),
                      border: Border.all(color: AppColors.lime500.withValues(alpha: 0.2)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.lime500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.dark400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'HONORARY STATUS',
                                        style: AppTypography.micro.copyWith(
                                          color: AppColors.lime500,
                                          fontWeight: AppTypography.weightHeavy,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.lime500.withValues(alpha: 0.5)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'FOUNDING MEMBER',
                                  style: AppTypography.labelStrong.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Recognized for establishing the foundations of the society.',
                                  style: AppTypography.micro.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Stats Section (Only if registered)
              if (user.handicapId != null) ...[
                const BoxyArtSectionTitle(
                  title: 'Season Highlights',
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final performanceAsync = ref.watch(memberPerformanceProvider(user.id));
                    return performanceAsync.when(
                      data: (stats) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            MemberStatsRow(
                              starts: stats.starts,
                              wins: stats.wins,
                              top5: stats.top5,
                              avgPts: stats.avgPts,
                              bestPts: stats.bestPts,
                              rank: stats.rank,
                            ),
                            const BoxyArtSectionTitle(
                              title: 'Season Standing',
                            ),
                          BoxyArtCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.emoji_events_rounded,
                                  color: AppColors.amber500,
                                  label: 'Order of Merit',
                                  value: stats.rank != null ? 'Rank #${stats.rank}' : 'Unranked',
                                ),
                                const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.grid_view_rounded,
                                  color: AppColors.teamA,
                                  label: 'Starts',
                                  value: '${stats.starts} Matches',
                                ),
                                const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.park_rounded,
                                  color: AppColors.lime500,
                                  label: 'Best Score',
                                  value: stats.bestPts > 0 ? '${stats.bestPts} Pts' : '-',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      loading: () => const BoxyArtLoadingCard(
                        title: 'Preparing locker...',
                        message: 'Fetching highlights',
                        isCompact: true,
                      ),
                      error: (e, s) => BoxyArtEmptyState(title: 'Stats Error', message: 'Unable to load performance highlights', icon: Icons.error_outline_rounded, isCompact: true),
                    );
                  },
                ),
                BoxyArtButton(
                  title: 'Season Standings',
                  icon: Icons.leaderboard_rounded,
                  isTinted: true,
                  fullWidth: true,
                  onTap: () => GoRouter.of(context).push('/locker/standings'),
                ),
                const BoxyArtSectionTitle(title: 'Round Story'),
                Consumer(
                  builder: (context, ref, _) {
                    final stats = ref.watch(memberRoundStoryStatsProvider(user.id));
                    if (stats.isEmpty) return const SizedBox.shrink();
                    final hasTags = stats.values.any((v) => v > 0);
                    if (!hasTags) return const SizedBox.shrink();
                    return BoxyArtCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildHighlightRow(context,
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.lime500,
                            label: 'Gimmes',
                            value: '${stats['gimmes'] ?? 0} total',
                          ),
                          const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                          _buildHighlightRow(context,
                            icon: Icons.upload_rounded,
                            color: AppColors.coral500,
                            label: 'Pick Ups',
                            value: '${stats['pickUps'] ?? 0} total',
                          ),
                          const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                          _buildHighlightRow(context,
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.amber500,
                            label: '+1 Stroke Penalties',
                            value: '${stats['penalty1'] ?? 0} total',
                          ),
                          const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                          _buildHighlightRow(context,
                            icon: Icons.warning_rounded,
                            color: AppColors.amber500,
                            label: '+2 Stroke Penalties',
                            value: '${stats['penalty2'] ?? 0} total',
                          ),
                          const BoxyArtDivider(verticalPadding: AppSpacing.sm),
                          _buildHighlightRow(context,
                            icon: Icons.add_circle_outline_rounded,
                            color: AppColors.dark400,
                            label: 'Total Penalty Strokes',
                            value: '${stats['totalPenaltyStrokes'] ?? 0}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const BoxyArtSectionTitle(title: 'My Season Activity'),
                Consumer(
                  builder: (context, ref, _) {
                    final historyAsync = ref.watch(memberEventHistoryProvider(user.id));
                    return historyAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const BoxyArtCard(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Text('No event activity recorded yet for this season.'),
                            ),
                          );
                        }
                        return BoxyArtCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0; i < items.length; i++) ...[
                                _buildActivityRow(context, items[i]),
                                if (i < items.length - 1) const BoxyArtDivider(verticalPadding: 0),
                              ],
                            ],
                          ),
                        );
                      },
                      loading: () => const BoxyArtLoadingCard(isCompact: true),
                      error: (e, s) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
              const BoxyArtSectionTitle(
                title: 'Account Settings',
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Society Hall of Fame',
                      subtitle: 'Our legacy and founding members',
                      iconColor: AppColors.lime500,
                      onTap: () => _showHonors(context, user),
                    ),
                    BoxyArtNavTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Edit your profile and data',
                      iconColor: AppColors.textTertiary,
                      onTap: () {},
                    ),
                    BoxyArtNavTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Set your alert preferences',
                      iconColor: AppColors.amber500,
                      onTap: () {},
                    ),
                    BoxyArtNavTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your security settings',
                      iconColor: AppColors.teamB, // Standardized from Colors.cyan
                      onTap: () {},
                    ),
                    BoxyArtNavTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs and support chat',
                      iconColor: AppColors.textTertiary, // Standardized from AppColors.teamB
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.standard),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    // Sign Out Logic
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.coral500, // Standardized from Colors.redAccent
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l, vertical: AppSpacing.md),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: AppTypography.weightBold),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(BuildContext context, MemberEventHistoryItem item) {
    final statusColor = switch (item.status) {
      ParticipationStatus.confirmed => AppColors.lime500,
      ParticipationStatus.participated => AppColors.lime600,
      ParticipationStatus.dns => AppColors.coral500,
      ParticipationStatus.withdrawn => AppColors.dark300,
    };
    
    final statusLabel = switch (item.status) {
      ParticipationStatus.confirmed => 'CONFIRMED',
      ParticipationStatus.participated => 'PARTICIPATED',
      ParticipationStatus.dns => 'DNS',
      ParticipationStatus.withdrawn => 'WITHDRAWN',
    };

    return InkWell(
      onTap: () => context.go('/events/${item.eventId}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Date Mini-badge
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: AppShapes.sm,
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(item.date).toUpperCase(),
                    style: AppTypography.micro.copyWith(color: AppColors.pureWhite, fontSize: 9, fontWeight: AppTypography.weightHeavy),
                  ),
                  Text(
                    DateFormat('dd').format(item.date),
                    style: AppTypography.label.copyWith(color: AppColors.pureWhite, fontWeight: AppTypography.weightBold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.eventTitle, style: AppTypography.labelStrong),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: AppTypography.micro.copyWith(
                      color: statusColor,
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (item.score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.score} pts',
                    style: AppTypography.labelStrong.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  if (item.position != null)
                    Text(
                      'Rank #${item.position}',
                      style: AppTypography.micro.copyWith(color: AppColors.dark400),
                    ),
                ],
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.dark300, size: 16),
          ],
        ),
      ),
    );
  }

  void _showHonors(BuildContext context, Member user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocietyHonorsModal(currentUser: user),
    );
  }

  Widget _buildHighlightRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppColors.opacityLow),
            borderRadius: AppShapes.sm,
          ),
          child: Icon(icon, size: AppShapes.iconSm, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: AppTypography.weightSemibold, fontSize: AppTypography.sizeBody),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: AppTypography.weightBlack,
            fontSize: AppTypography.sizeBody,
            color: color == AppColors.amber500 ? Theme.of(context).primaryColor : color,
          ),
        ),
      ],
    );
  }
}


