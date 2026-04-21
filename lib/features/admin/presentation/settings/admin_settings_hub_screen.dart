import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/services/seeding_service.dart';
import 'package:golf_society/services/seeding/match_play_seeder.dart';

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
                      onTap: () => _showSeedConfirmation(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.biotech_rounded,
                      title: 'Match Play Test Lab',
                      subtitle: 'Stage-by-stage tournament seeding',
                      onTap: () => _showMatchPlayLabDialog(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'System Factory Reset',
                      subtitle: 'Deep wipe (Everything including branding)',
                      onTap: () => _showSystemResetDialog(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.palette_outlined,
                      title: 'App Appearance',
                      subtitle: 'Light, dark, and system themes',
                      onTap: () => context.pushNamed('admin-settings-appearance'),
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

  Future<void> _showMatchPlayLabDialog(BuildContext context, WidgetRef ref) async {
    final stage = await showBoxyArtDialog<MatchPlayStage>(
      context: context,
      title: 'Match Play Test Lab',
      message: 'Select which tournament stage you would like to seed for testing.',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          BoxyArtButton(
            title: 'STAGE 1: REGISTRATION',
            onTap: () => Navigator.of(context, rootNavigator: true).pop(MatchPlayStage.registration),
          ),
          const SizedBox(height: AppSpacing.sm),
          BoxyArtButton(
            title: 'STAGE 2: DRAW PUBLISHED',
            onTap: () => Navigator.of(context, rootNavigator: true).pop(MatchPlayStage.drawPublished),
          ),
          const SizedBox(height: AppSpacing.sm),
          BoxyArtButton(
            title: 'STAGE 3: MID-ROUND RESULTS',
            onTap: () => Navigator.of(context, rootNavigator: true).pop(MatchPlayStage.midRoundResults),
          ),
        ],
      ),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(null),
    );

    if (stage != null && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Seeding Match Play Stage: ${stage.name}...')));
      
      try {
        await ref.read(seedingServiceProvider).seedMatchPlayTestLab(stage);
        messenger.showSnackBar(const SnackBar(content: Text('✅ Laboratory Seeding Successful')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSanjayTestSeedConfirmation(BuildContext context, WidgetRef ref) async {
    await _showMatchPlayLabDialog(context, ref);
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
