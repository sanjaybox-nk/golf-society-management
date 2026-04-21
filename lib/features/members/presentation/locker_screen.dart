import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/widgets/member_stats_row.dart';
import 'package:golf_society/features/members/presentation/widgets/member_cuts_card.dart';
import '../../home/presentation/home_providers.dart';
import '../../events/presentation/events_provider.dart';

class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
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
                                letterSpacing: 1.2,
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
                BoxyArtCard(
                  child: Column(
                    children: [
                      const BoxyArtSectionTitle(title: 'Current Handicap', isLevel2: true),
                      Text(
                        user.handicap.toStringAsFixed(1),
                        style: AppTypography.displayHero.copyWith(
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                )
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
                            letterSpacing: 1.2,
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
                                      letterSpacing: 1.2,
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
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (status.totalEventFeesOwed > 0) ...[
                                Text(
                                  'EVENT ENTRY FEES OWED: £${status.totalEventFeesOwed.toStringAsFixed(0)}',
                                  style: AppTypography.micro.copyWith(
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                              if (status.totalFinesOwed > 0) ...[
                                Text(
                                  'ACCUMULATED FINES OWED: £${status.totalFinesOwed.toStringAsFixed(0)}',
                                  style: AppTypography.micro.copyWith(
                                    color: AppColors.coral500,
                                    fontWeight: AppTypography.weightBold,
                                    letterSpacing: 1.2,
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
                                        letterSpacing: 1.2,
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
                SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                BoxyArtButton(
                  title: 'Season Standings',
                  icon: Icons.leaderboard_rounded,
                  onTap: () => GoRouter.of(context).push('/locker/standings'),
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
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Edit your profile and data',
                      iconColor: AppColors.lime500,
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


