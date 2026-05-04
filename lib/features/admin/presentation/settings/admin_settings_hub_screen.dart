import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/services/seeding_service.dart';
import 'package:golf_society/features/settings/data/society_config_repository.dart';


class AdminSettingsHubScreen extends ConsumerWidget {
  const AdminSettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);

    return HeadlessScaffold(
      title: 'Settings Hub',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      subtitle: 'System Configuration',
      showBack: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                      icon: Icons.account_balance_rounded,
                      title: 'Starting Balance',
                      subtitle: 'Society opening bank balance',
                      onTap: () => context.pushNamed('admin-settings-treasury'),
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
                      icon: Icons.dashboard_customize_rounded,
                      title: 'Competition Templates',
                      subtitle: 'Pre-configured event game rules',
                      onTap: () => context.pushNamed('admin-settings-templates'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.palette_outlined,
                      title: 'App Appearance',
                      subtitle: 'Light, dark, and system themes',
                      onTap: () => context.pushNamed('admin-settings-appearance'),
                    ),
                    const BoxyArtDivider(),
                    _buildConfigToggle(
                      context, 
                      ref,
                      icon: Icons.layers_outlined,
                      title: 'Match Play Overlay',
                      subtitle: 'Show/Hide match brackets in events',
                      value: config.showMatchPlayOverlay,
                      onChanged: (val) async {
                        final newConfig = config.copyWith(showMatchPlayOverlay: val);
                        await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(newConfig);
                        ref.invalidate(themeControllerProvider);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 2. Access & Permissions
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

              // 3. Infrastructure (Wipe & Seed)
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
                      subtitle: 'Master Seed (Stableford + Match Play Progression)',
                      onTap: () => _showSeedConfirmation(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.handshake_outlined,
                      title: 'Handshake & Rhythm UAT',
                      subtitle: 'Consolidated: Medal + Stableford + Conflicts',
                      onTap: () => _showUATSeedConfirmation(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'System Factory Reset',
                      subtitle: 'Deep wipe (Everything including branding)',
                      onTap: () => _showSystemResetDialog(context, ref),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.section),

              // 4. Testing & Hardening Lab
              const BoxyArtSectionTitle(
                title: 'Testing & Hardening Lab',
                isPeeking: true,
              ),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Harden Members Only',
                      subtitle: 'Re-seed roster with full profiles',
                      onTap: () => _showMemberSeedConfirmation(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.history_rounded,
                      title: 'Harden History',
                      subtitle: 'Seed complex lifecycle events (Draft)',
                      iconColor: AppColors.dark300,
                      onTap: () {},
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
                          Text('VERSION', style: AppTypography.labelStrong.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: AppTypography.weightBold,
                            fontSize: AppTypography.sizeLabel,
                            letterSpacing: 1.0,
                          )),
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
                          Text('OS', style: AppTypography.labelStrong.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: AppTypography.weightBold,
                            fontSize: AppTypography.sizeLabel,
                            letterSpacing: 1.0,
                          )),
                          const SizedBox(height: AppSpacing.xs),
                          Text(Platform.operatingSystem.toUpperCase(), style: AppTypography.displayLocker),
                          Text('Build Path: ARM64', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.x4l),
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
      confirmText: 'CLEAR',
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

  void _showMemberSeedConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Harden Members?',
      message: 'This will REFRESH the entire member roster with high-quality hardened data. Current member records will be replaced. Continue?',
      confirmText: 'HARDEN',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Hardening Member Roster...')));
      
      try {
        await ref.read(seedingServiceProvider).seedMembersOnly();
        messenger.showSnackBar(const SnackBar(content: Text('✅ Member Roster Hardened Successfully')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }


  void _showUATSeedConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await showBoxyArtDialog<bool>(
      context: context,
      title: 'Initialize UAT?',
      message: 'This will perform a safe wipe and seed two distinct events (Medal & Stableford) with specific conflict states for full Handshake and Vertical Rhythm UAT. Continue?',
      confirmText: 'INITIALIZE',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Initializing Master UAT Scenario...')));
      
      try {
        await ref.read(seedingServiceProvider).seedHandshakeAndRhythmUAT();
        messenger.showSnackBar(const SnackBar(content: Text('✅ UAT Environment Ready')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildConfigToggle(
    BuildContext context, 
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Standardized 4.x Icon Badge
          BoxyArtIconBadge(
            icon: icon,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelStrong.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.weightBold,
                    fontSize: AppTypography.sizeLabel,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                    fontWeight: AppTypography.weightMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Branded Switch
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.lime500,
            activeTrackColor: AppColors.lime500.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}
