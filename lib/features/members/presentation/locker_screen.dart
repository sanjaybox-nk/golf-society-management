import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/features/members/presentation/profile_provider.dart';
import 'package:golf_society/features/members/presentation/member_stats_provider.dart';
import '../../home/presentation/home_providers.dart';

class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(effectiveUserProvider);
    final stats = ref.watch(userStatsProvider);
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
          padding: EdgeInsets.fromLTRB(AppTheme.pagePadding, 8, AppTheme.pagePadding, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: AppTheme.cardSpacing),

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
              SizedBox(height: AppTheme.cardSpacing),

              // Handicap Section
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
              ),
              SizedBox(height: AppTheme.cardSpacing),

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
                          backgroundColor: primary.withValues(alpha: AppColors.opacitySubtle),
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
                                    const Text(
                                      'SEASON STAKES',
                                      style: AppTypography.micro,
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
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
              ),

              // Stats Section
              const BoxyArtSectionTitle(title: 'Season Highlights'),
              Row(
                children: [
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['roundsPlayed'].toString(),
                      label: 'ROUNDS',
                      icon: Icons.golf_course_rounded,
                      color: AppColors.teamA,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['averageScore'].toString(),
                      label: 'AVG SCORE',
                      icon: Icons.analytics_rounded,
                      color: AppColors.amber500,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['wins'].toString(),
                      label: 'WINS',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.amber500,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              BoxyArtButton(
                title: 'Season Standings',
                icon: Icons.leaderboard_rounded,
                onTap: () => GoRouter.of(context).push('/locker/standings'),
              ),
              SizedBox(height: AppTheme.cardSpacing),

              // Settings Section
              const BoxyArtSectionTitle(title: 'Account Settings'),
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
                      iconColor: Colors.cyan,
                      onTap: () {},
                    ),
                    BoxyArtNavTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs and support chat',
                      iconColor: AppColors.teamB,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.cardSpacing),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    // Sign Out Logic
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l, vertical: AppSpacing.md),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: AppTypography.weightBold),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Extra space for nav bar
            ]),
          ),
        ),
      ],
    );
  }

  // Removed _buildModernSettingsTile as it is replaced by BoxyArtNavTile
}


