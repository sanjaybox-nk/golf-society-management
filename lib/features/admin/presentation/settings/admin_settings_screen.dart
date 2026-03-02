import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/services/seeding_service.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return HeadlessScaffold(
      title: 'Settings',
      subtitle: 'App-wide configuration',
      showBack: true,
      onBack: () => context.go('/admin'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const BoxyArtSectionTitle(title: 'Society Configurations', ),
              const SizedBox(height: 12),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.badge_rounded,
                      title: 'Committee Roles',
                      subtitle: 'Manage society specific titles',
                      iconColor: const Color(0xFF1A237E),
                      onTap: () => context.push('/admin/settings/committee-roles'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.rule_folder_rounded,
                      title: 'Game Templates',
                      subtitle: 'Manage competition formats & rules',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/settings/templates'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.emoji_events_rounded,
                      title: 'Leaderboard Templates',
                      subtitle: 'Manage season point systems',
                      iconColor: Colors.amber,
                      onTap: () => context.push('/admin/settings/leaderboards'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.tune_rounded,
                      title: 'General',
                      subtitle: 'App basics and display settings',
                      iconColor: Colors.blueGrey,
                      onTap: () => context.push('/admin/settings/general'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.layers_rounded,
                      title: 'Manage Seasons',
                      subtitle: 'Archive and setup event seasons',
                      iconColor: Colors.teal,
                      onTap: () => context.push('/admin/settings/seasons'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      subtitle: 'Push notification preferences',
                      iconColor: Colors.indigo,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.palette_rounded,
                      title: 'Society Branding',
                      subtitle: 'Customize colors and theme',
                      iconColor: Colors.pink,
                      onTap: () => context.push('/admin/settings/branding'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              const BoxyArtSectionTitle(title: 'Access & Permissions'),
              const SizedBox(height: AppSpacing.md),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.shield_rounded,
                      title: 'System Roles',
                      subtitle: 'View available administrative roles',
                      iconColor: Colors.purple,
                      onTap: () => context.push('/admin/settings/roles'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.history_rounded,
                      title: 'Audit Logs',
                      subtitle: 'View recent administrative changes',
                      iconColor: Colors.blueGrey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audit Logs are coming soon!'))
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    _SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Clear Database',
                      subtitle: 'Remove all members and registrations',
                      iconColor: Colors.red,
                      onTap: () => _clearDatabase(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              const BoxyArtSectionTitle(title: 'Initialization Tools'),
              const SizedBox(height: AppSpacing.md),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: _SettingsTile(
                  icon: Icons.auto_awesome_motion_rounded,
                  title: 'Seed Full Demo Data',
                  subtitle: 'Populate members, events, and results',
                  iconColor: Colors.pinkAccent,
                  onTap: () => _seedFullDemo(context, ref),
                ),
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _seedFullDemo(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'Initialize Lab?',
      message: 'This will seed 60 members (inc. Committee), 3 past events (Jan/Feb 2026), and 1 upcoming event (The Lab Open). All within the current 2026 season. Continue?',
      confirmText: 'Initialize',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Building Lab foundation... (Members & Events)')));

    try {
      await ref.read(seedingServiceProvider).seedFullDemoData();
      messenger.showSnackBar(const SnackBar(
        content: Text('✅ Lab Ready! Check "Events" to see all 4 matches in the 2026 season.'),
        duration: Duration(seconds: 4),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }




  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    // High-risk confirmation
    final confirm = await showBoxyArtDialog<bool>(
      context: context, 
      title: 'DANGER: Clear Database?',
      message: 'This will PERMANENTLY delete ALL society data (Members, Events, Scores, Standings). There is no undo. Continue?',
      confirmText: 'PURGE EVERYTHING',
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    );
    
    if (confirm != true) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Starting full database purge... 🧹')));

    try {
      await ref.read(seedingServiceProvider).clearAllData();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Clean Slate Achieved! All collections wiped.')));
    } catch (e) {
      debugPrint('❌ Error clearing database: $e');
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}


class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded, 
                color: theme.dividerColor.withValues(alpha: 0.3), 
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
