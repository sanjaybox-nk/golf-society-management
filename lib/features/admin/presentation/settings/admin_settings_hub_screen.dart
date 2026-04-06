import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/services/seeding_service.dart';

class AdminSettingsHubScreen extends ConsumerWidget {
  const AdminSettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);

    return HeadlessScaffold(
      title: 'Settings Hub',
      subtitle: 'System Configuration',
      showBack: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Society Configuration
              const BoxyArtSectionTitle(title: 'Society Config'),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.palette_outlined,
                      title: 'Branding & Theme',
                      subtitle: 'Colors, labels, and radius controls',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-branding'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.payments_outlined,
                      title: 'Currency & Treasury',
                      subtitle: 'Society currency and financial rules',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-treasury'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.groups_outlined,
                      title: 'Grouping Strategy',
                      subtitle: 'Default event grouping logic',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-grouping'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.calculate_outlined,
                      title: 'Handicap System',
                      subtitle: 'WHS, CONGU, or Custom rules',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-handicap'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.content_cut_rounded,
                      title: 'Society Cuts',
                      subtitle: 'Automated winner and podium cuts',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-cuts'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 2. Global Management (Seasons & Templates)
              const BoxyArtSectionTitle(title: 'Global Management'),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.calendar_today_rounded,
                      title: 'Season Management',
                      subtitle: 'Active seasons and rollover tools',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-seasons'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.dashboard_customize_rounded,
                      title: 'Competition Templates',
                      subtitle: 'Pre-configured event game rules',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-templates'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.leaderboard_outlined,
                      title: 'Season Leaderboards',
                      subtitle: 'Track Order of Merit & stat cycles',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-leaderboards'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 3. Access & Permissions
              const BoxyArtSectionTitle(title: 'Access & Permissions'),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'System Roles',
                      subtitle: 'Manage administrative access levels',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-roles'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.badge_outlined,
                      title: 'Committee Roles',
                      subtitle: 'Custom society titles and duties',
                      iconColor: theme.primaryColor,
                      onTap: () => context.pushNamed('admin-settings-committee-roles'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 4. Infrastructure (Wipe & Seed)
              const BoxyArtSectionTitle(title: 'Infrastructure'),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.auto_fix_high_rounded,
                      title: 'Initialize Demo Season',
                      subtitle: 'Wipe all and seed full 2025-26 data',
                      iconColor: AppColors.teamA, 
                      onTap: () => _showSeedConfirmation(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'System Reset',
                      subtitle: 'Factory reset (Wipe all society data)',
                      iconColor: Color(config.statusWaitlistColor), 
                      onTap: () => _showSystemResetDialog(context, ref),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 5. System Information
              const BoxyArtSectionTitle(title: 'System Information'),
              Row(
                children: [
                  Expanded(
                    child: BoxyArtCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Version', style: AppTypography.label.copyWith(color: AppColors.textTertiary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text('1.0.0+1', style: AppTypography.displayLocker),
                          Text('v3.3 Stable', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: BoxyArtCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Os', style: AppTypography.label.copyWith(color: AppColors.textTertiary)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(Platform.operatingSystem.toUpperCase(), style: AppTypography.displayLocker),
                          Text('Build Path: ARM64', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.x4l),
            ]),
          ),
        ),
      ],
    );
  }

  void _showSeedConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Initialize Demo?',
      message: 'This will WIPE all current data and seed a full professional 2025-26 season. Continue?',
      confirmText: 'INITIALIZE',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Initializing Demo Season...')));
      
      try {
        await ref.read(seedingServiceProvider).seedFullDemoData();
        messenger.showSnackBar(const SnackBar(content: Text('✅ Demo Season Initialized Successfully')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSystemResetDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Total System Wipe?',
      message: 'This will permanently delete all events, registrations, results, and member data. This cannot be undone.',
      confirmText: 'WIPE ALL',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Wiping system data...')));
      
      try {
        await ref.read(seedingServiceProvider).clearDemoData();
        messenger.showSnackBar(const SnackBar(content: Text('✅ System data wiped successfully')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
