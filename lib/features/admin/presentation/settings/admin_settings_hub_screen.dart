import 'dart:io';
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
      titleSuffix: BoxyArtPill.committee(label: 'ADMIN'),
      subtitle: 'System Configuration',
      showBack: true,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: spacing?.cardToLabel ?? AppSpacing.cardToLabel),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Society Configuration
              const BoxyArtSectionTitle(
                title: 'Society Config',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.business_rounded,
                      title: 'Society Identity',
                      subtitle: 'Update society name and logo',
                      onTap: () => context.pushNamed('admin-settings-identity'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.palette_outlined,
                      title: 'App Appearance',
                      subtitle: 'Light, dark, and system themes',
                      onTap: () => context.pushNamed('admin-settings-appearance'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.payments_outlined,
                      title: 'Currency & Treasury',
                      subtitle: 'Society currency and financial rules',
                      onTap: () => context.pushNamed('admin-settings-treasury'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.groups_outlined,
                      title: 'Grouping Strategy',
                      subtitle: 'Default event grouping logic',
                      onTap: () => context.pushNamed('admin-settings-grouping'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.calculate_outlined,
                      title: 'Handicap System',
                      subtitle: 'WHS, CONGU, or Custom rules',
                      onTap: () => context.pushNamed('admin-settings-handicap'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.content_cut_rounded,
                      title: 'Society Cuts',
                      subtitle: 'Automated winner and podium cuts',
                      onTap: () => context.pushNamed('admin-settings-cuts'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 2. Global Management (Seasons & Templates)
              const BoxyArtSectionTitle(
                title: 'Global Management',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.calendar_today_rounded,
                      title: 'Season Management',
                      subtitle: 'Active seasons and rollover tools',
                      onTap: () => context.pushNamed('admin-settings-seasons'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.dashboard_customize_rounded,
                      title: 'Competition Templates',
                      subtitle: 'Pre-configured event game rules',
                      onTap: () => context.pushNamed('admin-settings-templates'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.leaderboard_outlined,
                      title: 'Season Leaderboards',
                      subtitle: 'Track Order of Merit & stat cycles',
                      onTap: () => context.pushNamed('admin-settings-leaderboards'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 3. Access & Permissions
              const BoxyArtSectionTitle(
                title: 'Access & Permissions',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'System Roles',
                      subtitle: 'Manage administrative access levels',
                      onTap: () => context.pushNamed('admin-settings-roles'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.badge_outlined,
                      title: 'Committee Roles',
                      subtitle: 'Custom society titles and duties',
                      onTap: () => context.pushNamed('admin-settings-committee-roles'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 4. Infrastructure (Wipe & Seed)
              const BoxyArtSectionTitle(
                title: 'Infrastructure',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Clear Activity Data',
                      subtitle: 'Wipe events & members (Keeps branding/templates)',
                      onTap: () => _showClearActivityDialog(context, ref),
                    ),
                    const BoxyArtDivider(),
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
                      title: 'System Factory Reset',
                      subtitle: 'Deep wipe (Everything including branding)',
                      iconColor: Color(config.statusWaitlistColor), 
                      onTap: () => _showSystemResetDialog(context, ref),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 5. Advanced Management (Dev Lab)
              const BoxyArtSectionTitle(
                title: 'Advanced Management',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.terminal_rounded,
                      title: 'Design Token Lab',
                      subtitle: 'Granular radii, shadows, and spacing',
                      onTap: () => context.pushNamed('admin-settings-branding'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 6. System Information
              const BoxyArtSectionTitle(
                title: 'System Information',
                isPeeking: true,
              ),
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

  void _showClearActivityDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Clear Events & Members?',
      message: 'This will wipe all events, results, and member data, but PRESERVE your branding, competition templates, and courses. Continue?',
      confirmText: 'CLEAR ACTIVITY',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Purging activity data...')));
      
      try {
        await ref.read(seedingServiceProvider).clearActivityData();
        messenger.showSnackBar(const SnackBar(content: Text('✅ Activity cleared (Scaffolding Preserved)')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
