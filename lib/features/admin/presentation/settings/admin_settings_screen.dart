import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/domain/models/handicap_system.dart';
import 'package:golf_society/services/seeding_service.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeControllerProvider);

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
              // 1. Localisation
              const BoxyArtSectionTitle(title: 'Localisation'),
              const SizedBox(height: 12),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Currency',
                      subtitle: '${config.currencyCode} (${config.currencySymbol})',
                      iconColor: Colors.green,
                      onTap: () => context.push('/admin/settings/currency'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.public_rounded,
                      title: 'Handicap Provider',
                      subtitle: config.handicapSystem.shortName,
                      iconColor: Colors.blue,
                      onTap: () => context.push('/admin/settings/handicap-system'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.auto_graph_rounded,
                      title: 'Society Cuts',
                      subtitle: (config.societyCutMode != SocietyCutMode.off) ? 'Active' : 'Disabled',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/settings/society-cuts'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),

              // 2. Competition Settings
              const BoxyArtSectionTitle(title: 'Competition Settings'),
              const SizedBox(height: 12),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.groups_3_rounded,
                      title: 'Grouping Strategy',
                      subtitle: _getStrategyLabel(config.groupingStrategy),
                      iconColor: Colors.indigo,
                      onTap: () => context.push('/admin/settings/grouping-strategy'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtSwitchTile(
                      icon: Icons.splitscreen_rounded,
                      label: 'Guest Leaderboards',
                      subtitle: 'Show guests in their own section.',
                      value: config.separateGuestLeaderboard,
                      iconColor: Colors.teal,
                      onChanged: (val) {
                        ref.read(themeControllerProvider.notifier).setSeparateGuestLeaderboard(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),

              // 3. Society Configurations
              const BoxyArtSectionTitle(title: 'Society Configurations'),
              const SizedBox(height: 12),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.badge_rounded,
                      title: 'Committee Roles',
                      subtitle: 'Manage society specific titles',
                      iconColor: const Color(0xFF1A237E),
                      onTap: () => context.push('/admin/settings/committee-roles'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.rule_folder_rounded,
                      title: 'Game Templates',
                      subtitle: 'Manage competition formats & rules',
                      iconColor: Colors.orange,
                      onTap: () => context.push('/admin/settings/templates'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.emoji_events_rounded,
                      title: 'Leaderboard Templates',
                      subtitle: 'Manage season point systems',
                      iconColor: Colors.amber,
                      onTap: () => context.push('/admin/settings/leaderboards'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.layers_rounded,
                      title: 'Manage Seasons',
                      subtitle: 'Archive and setup event seasons',
                      iconColor: Colors.teal,
                      onTap: () => context.push('/admin/settings/seasons'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      subtitle: 'Push notification preferences',
                      iconColor: Colors.indigo,
                      onTap: () => context.push('/admin/communications'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
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
                    BoxyArtNavTile(
                      icon: Icons.shield_rounded,
                      title: 'System Roles',
                      subtitle: 'View available administrative roles',
                      iconColor: Colors.purple,
                      onTap: () => context.push('/admin/settings/roles'),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              const BoxyArtSectionTitle(title: 'Danger Zone'),
              const SizedBox(height: AppSpacing.md),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.auto_awesome_motion_rounded,
                      title: 'Seed Full Demo Data',
                      subtitle: 'Generate members & events',
                      iconColor: Colors.pinkAccent,
                      onTap: () => _seedFullDemo(context, ref),
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Clear Database',
                      subtitle: 'Remove all society records',
                      iconColor: Colors.red,
                      onTap: () => _clearDatabase(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              const BoxyArtSectionTitle(title: 'App Info'),
              const SizedBox(height: AppSpacing.md),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0 (Build 61)',
                      iconColor: Colors.grey,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.05), indent: 76),
                    BoxyArtNavTile(
                      icon: Icons.devices_rounded,
                      title: 'Platform',
                      subtitle: theme.platform.name.toUpperCase(),
                      iconColor: Colors.blueGrey,
                      onTap: () {},
                    ),
                  ],
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
      message: 'This will seed 75 members (inc. Committee), 12 past events (2025/2026), and 3 upcoming events. All within the 25-26 season. Continue?',
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
        content: Text('✅ Lab Ready! Check "Events" to see all 15 matches in the 25-26 season.'),
        duration: Duration(seconds: 4),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _clearDatabase(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // High-risk confirmation with text validation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const BoxyArtDeleteConfirmationDialog(
        title: 'DANGER: Clear Database?',
        message: 'This will PERMANENTLY delete ALL society data (Members, Events, Scores, Standings). There is no undo. Continue?',
        requiredText: 'DELETE',
        confirmLabel: 'PURGE EVERYTHING',
      ),
    );

    if (confirm != true) return;

    if (!context.mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Starting full database purge... 🧹')));

    try {
      await ref.read(seedingServiceProvider).clearAllData();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Clean Slate Achieved! All collections wiped.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getStrategyLabel(String key) {
    switch (key) {
      case 'progressive': return 'Progressive (Low HC First)';
      case 'similar': return 'Similar Ability';
      case 'random': return 'Random Draw';
      case 'balanced': default: return 'Balanced Teams';
    }
  }
}
