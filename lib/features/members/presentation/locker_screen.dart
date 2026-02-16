import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../core/shared_ui/headless_scaffold.dart';


import 'package:golf_society/models/member.dart';
import 'package:golf_society/models/handicap_system.dart';
import '../../../core/theme/theme_controller.dart';
import 'profile_provider.dart';

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
      backgroundColor: beigeBackground,
      showBack: false,
      onBack: () => context.go('/'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Profile Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary.withValues(alpha: 0.1), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: user.avatarUrl != null 
                            ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                            : Container(
                                color: Colors.white,
                                child: Center(
                                  child: Text(
                                    '${user.firstName[0]}${user.lastName[0]}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final society = ref.watch(themeControllerProvider);
                          final system = society.handicapSystem;
                          return Text(
                            '${system.shortName}: ${user.handicapId ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Handicap Section
              ModernCard(
                child: Column(
                  children: [
                    Text(
                      'CURRENT HANDICAP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.handicap.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Stats Section
              const Text(
                'SEASON HIGHLIGHTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['roundsPlayed'].toString(),
                      label: 'ROUNDS',
                      icon: Icons.golf_course_rounded,
                      color: Colors.blue,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['averageScore'].toString(),
                      label: 'AVG SCORE',
                      icon: Icons.analytics_rounded,
                      color: Colors.orange,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernMetricStat(
                      value: stats['wins'].toString(),
                      label: 'WINS',
                      icon: Icons.emoji_events_rounded,
                      color: Colors.amber,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BoxyArtButton(
                title: 'Season Standings',
                icon: Icons.leaderboard_rounded,
                onTap: () => GoRouter.of(context).push('/locker/standings'),
              ),
              const SizedBox(height: 40),

              // Settings Section
              const Text(
                'ACCOUNT SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              ModernCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildModernSettingsTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildModernSettingsTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildModernSettingsTile(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildModernSettingsTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    // Sign Out Logic
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}


