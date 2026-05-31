import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/settings/data/society_config_repository.dart';
import 'package:golf_society/features/events/presentation/events_provider.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/competitions/services/leaderboard_invoker_service.dart';
import 'package:golf_society/services/seeding_service.dart';
import 'package:golf_society/services/seeding/match_play_event_seeder.dart' show MatchPlayEventStage;
import 'package:golf_society/domain/models/season.dart' show SeasonStatus;

class AdminOperationsScreen extends ConsumerWidget {
  const AdminOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<AppSpacingTokens>();
    final config = ref.watch(themeControllerProvider);

    return HeadlessScaffold(
      title: 'Operations',
      subtitle: 'Admin Console',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: spacing?.cardToLabel ?? AppSpacing.cardToLabel,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.lg,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // 1. Season & Competition
              const BoxyArtSectionTitle(title: 'Season & Competition', isPeeking: true),
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
                      icon: Icons.account_tree_outlined,
                      title: 'Season Match Play',
                      subtitle: 'Generate draws, seedings & brackets',
                      onTap: () => context.pushNamed('admin-matchplay-draw'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.leaderboard_outlined,
                      title: 'Season Leaderboards',
                      subtitle: 'Track Order of Merit & stat cycles',
                      onTap: () => context.pushNamed('admin-settings-leaderboards'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.sync_rounded,
                      title: 'Sync Standings',
                      subtitle: 'Recalculate all leaderboard standings',
                      onTap: () => _syncStandings(context, ref),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.workspaces_rounded,
                      title: 'Division Templates',
                      subtitle: 'Create and manage handicap division setups',
                      onTap: () => context.pushNamed('admin-division-templates'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // 2. Members & Community
              const BoxyArtSectionTitle(title: 'Members & Community', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.autorenew_rounded,
                      title: 'Member Renewals',
                      subtitle: 'Track season rollover & payments',
                      onTap: () => context.pushNamed('admin-member-renewal'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Add New Member',
                      subtitle: 'Onboard and assign credentials',
                      onTap: () => context.pushNamed('admin-member-new'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Audience Manager',
                      subtitle: 'Configure mailing lists & templates',
                      onTap: () => context.pushNamed('admin-audience'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.quiz_outlined,
                      title: 'Society Surveys',
                      subtitle: 'Draft and publish polls',
                      onTap: () => context.pushNamed('admin-surveys'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // 3. Finance & Analytics
              const BoxyArtSectionTitle(title: 'Finance & Analytics', isPeeking: true),
              BoxyArtCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    BoxyArtNavTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Debt Ledger',
                      subtitle: 'Outstanding fees and member balances',
                      onTap: () => context.pushNamed('admin-debt-ledger'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Season Financials',
                      subtitle: 'Rolling P&L across all season events',
                      onTap: () => context.pushNamed('admin-season-financials'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.handshake_outlined,
                      title: 'Sponsorships & Donations',
                      subtitle: 'Manage partners, supporters & revenue',
                      onTap: () => context.pushNamed('admin-sponsorship-hub'),
                    ),
                    const BoxyArtDivider(),
                    BoxyArtNavTile(
                      icon: Icons.analytics_outlined,
                      title: 'Reports & Insights',
                      subtitle: 'Financials, engagement & trends',
                      onTap: () => context.pushNamed('admin-reports'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // 4. Society Configuration
              const BoxyArtSectionTitle(title: 'Society Configuration', isPeeking: true),
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
                      icon: Icons.currency_pound_rounded,
                      title: 'Currency',
                      subtitle: 'Symbol and currency code',
                      onTap: () => context.pushNamed('admin-settings-currency'),
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
                      icon: Icons.people_alt_outlined,
                      title: 'Grouping Strategy',
                      subtitle: 'Default tee-time pairing method for all events',
                      onTap: () => context.pushNamed('admin-settings-grouping'),
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
                      icon: Icons.content_cut_rounded,
                      title: 'Society Cuts',
                      subtitle: 'Global handicap adjustment rules',
                      onTap: () => context.pushNamed('admin-settings-cuts'),
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
                      context, ref,
                      icon: Icons.leaderboard_outlined,
                      title: 'Separate Guest Leaderboard',
                      subtitle: 'Guests ranked independently from members',
                      value: config.separateGuestLeaderboard,
                      onChanged: (val) async {
                        final newConfig = config.copyWith(separateGuestLeaderboard: val);
                        await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(newConfig);
                        ref.invalidate(themeControllerProvider);
                      },
                    ),
                    const BoxyArtDivider(),
                    _buildConfigToggle(
                      context, ref,
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
                    const BoxyArtDivider(),
                    _buildConfigToggle(
                      context, ref,
                      icon: Icons.people_outline_rounded,
                      title: 'Social Membership',
                      subtitle: 'Enable social-only tier — attends social events, no golf',
                      value: config.enableSocialMembership,
                      onChanged: (val) async {
                        final newConfig = config.copyWith(enableSocialMembership: val);
                        await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(newConfig);
                        ref.invalidate(themeControllerProvider);
                      },
                    ),
                    if (config.enableSocialMembership) ...[
                      const BoxyArtDivider(),
                      _buildConfigToggle(
                        context, ref,
                        icon: Icons.low_priority_rounded,
                        title: 'Social Members Golf Waitlist',
                        subtitle: 'Social members join golf events on waitlist — full members get priority',
                        value: config.socialMembersGolfWaitlistPriority,
                        onChanged: (val) async {
                          final newConfig = config.copyWith(socialMembersGolfWaitlistPriority: val);
                          await ref.read(societyConfigRepositoryProvider).forceReplaceConfig(newConfig);
                          ref.invalidate(themeControllerProvider);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),

              // 5. Access & Permissions
              const BoxyArtSectionTitle(title: 'Access & Permissions', isPeeking: true),
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

              // 6. Dev Tools — debug builds only
              if (kDebugMode) ...[
                SizedBox(height: spacing?.cardToCard ?? AppSpacing.standard),
                const BoxyArtSectionTitle(title: 'Dev Tools', isPeeking: true),
                BoxyArtCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      BoxyArtNavTile(
                        icon: Icons.science_rounded,
                        title: 'Design Lab',
                        subtitle: 'Colors, shapes, spacing, navigation, and typography',
                        onTap: () => context.pushNamed('admin-settings-branding'),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.message_outlined,
                        title: 'Platform Content',
                        subtitle: 'Default notification messages and system strings',
                        onTap: () => context.pushNamed('admin-settings-platform-content'),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.palette_rounded,
                        title: 'Component Preview',
                        subtitle: 'Compare navigation component variants',
                        onTap: () => context.pushNamed('admin-settings-design-preview'),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.person_add_alt_1_rounded,
                        title: 'Harden Members Only',
                        subtitle: 'Re-seed roster with full profiles',
                        onTap: () => _showMemberSeedConfirmation(context, ref),
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
                        icon: Icons.fact_check_rounded,
                        title: 'Final Verification UAT',
                        subtitle: 'Medal: all submitted, GIMMEs, pick-ups, conflicts',
                        onTap: () => _showFinalVerificationSeedConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.group_add_outlined,
                        title: 'Registration Scaffold',
                        subtitle: '16 confirmed members, registration closed, no game type — attach any format to test',
                        onTap: () => _showRegistrationScaffoldConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.style_rounded,
                        title: 'Singles Scorecard Showcase',
                        subtitle: '16 members in-play — switch game template to test each scorecard format',
                        onTap: () => _showSinglesShowcaseConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.people_outline_rounded,
                        title: 'Fourball Scorecard Showcase',
                        subtitle: '8 members in-play as 4 pairs — Team View, bestball calc, counting-hole dots',
                        onTap: () => _showFourballShowcaseConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.group_work_rounded,
                        title: 'Scramble Scorecard Showcase',
                        subtitle: '12 members as 3 teams of 4 — shared team scores, shotAttributions, drive-rule banner',
                        onTap: () => _showScrambleShowcaseConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.account_tree_outlined,
                        title: 'Match Play Draw UAT',
                        subtitle: 'R16 draw auto-generated — ready to score and view bracket',
                        onTap: () => _showMatchPlayEventUATConfirmation(context, ref, MatchPlayEventStage.draw),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.sports_score_rounded,
                        title: 'Match Play Scores UAT',
                        subtitle: 'Pure match play — draw + submitted scorecards, ready to verify calculator',
                        onTap: () => _showMatchPlayEventUATConfirmation(context, ref, MatchPlayEventStage.scores),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.layers_rounded,
                        title: 'Stableford + Match Play Overlay UAT',
                        subtitle: 'Dual scoring — check Stableford pts and match play result from same scorecards',
                        onTap: () => _showMatchPlayEventUATConfirmation(context, ref, MatchPlayEventStage.stablefordOverlay),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.layers_outlined,
                        title: 'Medal + Match Play Overlay UAT',
                        subtitle: 'Dual scoring — check stroke total and match play result from same scorecards',
                        onTap: () => _showMatchPlayEventUATConfirmation(context, ref, MatchPlayEventStage.medalOverlay),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.leaderboard_rounded,
                        title: 'Stableford Leaderboard UAT',
                        subtitle: 'Round 1 complete, Round 2 in-play with last group ready to verify',
                        onTap: () => _showStablefordLeaderboardUATConfirmation(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.cleaning_services_rounded,
                        title: 'Clear Activity Data',
                        subtitle: 'Wipe events & members (keeps branding/templates)',
                        onTap: () => _showClearActivityDialog(context, ref),
                      ),
                      const BoxyArtDivider(),
                      BoxyArtNavTile(
                        icon: Icons.delete_forever_rounded,
                        title: 'System Factory Reset',
                        subtitle: 'Deep wipe — everything including branding',
                        iconColor: AppColors.coral500,
                        onTap: () => _showSystemResetDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: spacing?.cardToLabel ?? AppSpacing.x4l),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Config toggle helper
// ---------------------------------------------------------------------------

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
        BoxyArtIconBadge(icon: icon),
        const SizedBox(width: AppSpacing.lg),
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
                  letterSpacing: AppTypography.lsLabel,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.micro.copyWith(
                  color: isDark ? AppColors.dark200 : AppColors.dark400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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



// ---------------------------------------------------------------------------
// Standings sync
// ---------------------------------------------------------------------------

void _syncStandings(BuildContext context, WidgetRef ref) async {
  final seasonAsync = ref.read(activeSeasonProvider);
  final season = seasonAsync.asData?.value;
  if (season == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No active season found')),
    );
    return;
  }
  if (season.status == SeasonStatus.closed) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Season is closed — standings are frozen')),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Syncing standings...')),
  );
  try {
    await ref.read(leaderboardInvokerServiceProvider).recalculateAll(season.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Standings synchronised')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Dev seeding dialogs
// ---------------------------------------------------------------------------

void _showClearActivityDialog(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Clear Events & Members?',
    message: 'Wipes all events, results, and member data. Preserves branding, templates, and courses.',
    confirmText: 'CLEAR',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Purging activity data...')));
    try {
      await ref.read(seedingServiceProvider).clearActivityData();
      ref.invalidate(allMembersProvider);
      ref.invalidate(eventsProvider);
      ref.invalidate(activeSeasonProvider);
      messenger.showSnackBar(const SnackBar(content: Text('✅ Activity cleared')));
      if (context.mounted) context.go('/home');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showSystemResetDialog(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Total System Wipe?',
    message: 'Permanently deletes all events, registrations, results, and member data. Cannot be undone.',
    confirmText: 'WIPE ALL',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Wiping system data...')));
    try {
      await ref.read(seedingServiceProvider).clearDemoData();

      // Invalidate after wipe so providers restart their streams against cleared Firestore
      ref.invalidate(allMembersProvider);
      ref.invalidate(eventsProvider);
      ref.invalidate(activeSeasonProvider);

      messenger.showSnackBar(const SnackBar(content: Text('✅ System data wiped')));
      if (context.mounted) context.go('/home');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showMemberSeedConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Harden Members?',
    message: 'Refreshes the entire member roster with hardened data. Current records will be replaced.',
    confirmText: 'HARDEN',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Hardening Member Roster...')));
    try {
      await ref.read(seedingServiceProvider).seedMembersOnly();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Member Roster Hardened')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showUATSeedConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Initialize UAT?',
    message: 'Safe wipe + two events (Medal & Stableford) with conflict states for Handshake & Rhythm UAT.',
    confirmText: 'INITIALIZE',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Initializing UAT...')));
    try {
      await ref.read(seedingServiceProvider).seedHandshakeAndRhythmUAT();
      messenger.showSnackBar(const SnackBar(content: Text('✅ UAT Environment Ready')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showFinalVerificationSeedConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Verification UAT?',
    message: 'Adds a full Medal event with all cards submitted, GIMMEs, pick-ups, penalties, and score conflicts.',
    confirmText: 'SEED EVENT',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding Verification UAT...')));
    try {
      await ref.read(seedingServiceProvider).seedFinalVerificationUAT();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Verification UAT Ready')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showRegistrationScaffoldConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Registration Scaffold?',
    message: '16 members confirmed, registration closed. No game type attached — go to the event editor and add any format to test the full flow: grouping → scoring → verify → publish.',
    confirmText: 'SEED',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Creating registration scaffold...')));
    try {
      await ref.read(seedingServiceProvider).seedRegistrationScaffold();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Scaffold ready — attach a game type in the event editor')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showSinglesShowcaseConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Singles Showcase?',
    message: 'Clears all activity data, hardens the member roster, then creates one in-play singles event (16 members, 4 groups). Groups 1–3 are fully scored; Group 4 is mid-round. Switch the competition template in the event editor to test Stableford, Medal, and Bogey scorecards.',
    confirmText: 'SEED',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding Singles Showcase...')));
    try {
      await ref.read(seedingServiceProvider).seedSinglesShowcase();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Singles Showcase ready — open the event and try each template')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showScrambleShowcaseConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Scramble Showcase?',
    message: 'Clears all activity data, hardens the member roster, then creates one in-play Texas Scramble event. 12 members across 3 teams of 4 — all team members share the same hole scores. Group 1 has deliberate drive violations (one player took 6/9 drives) to test the amber drive-warning banner.',
    confirmText: 'SEED',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding Scramble Showcase...')));
    try {
      await ref.read(seedingServiceProvider).seedScrambleShowcase();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Scramble Showcase ready — check Team View and drive-rule banner')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showFourballShowcaseConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Fourball Showcase?',
    message: 'Clears all activity data, hardens the member roster, then creates one in-play Fourball (Betterball) event. 8 members across 2 groups — players [0,1] and [2,3] in each group form pairs. Group 1 is fully scored; Group 2 is mid-round. Check the Team View pill, counting-hole dots, and pair leaderboard.',
    confirmText: 'SEED',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding Fourball Showcase...')));
    try {
      await ref.read(seedingServiceProvider).seedFourballShowcase();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Fourball Showcase ready — check Team View and counting-hole dots')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showMatchPlayEventUATConfirmation(BuildContext context, WidgetRef ref, MatchPlayEventStage stage) async {
  final (title, message, label) = switch (stage) {
    MatchPlayEventStage.registration => (
        'Seed Match Play Stage 1?',
        'Creates a Singles Match Play knockout event with 16 confirmed registrations. No draw yet.',
        'Stage 1',
      ),
    MatchPlayEventStage.draw => (
        'Seed Match Play Draw UAT?',
        'Creates a Singles Match Play event with the R16 draw auto-generated — ready to score hole-by-hole.',
        'Draw',
      ),
    MatchPlayEventStage.scores => (
        'Seed Match Play Scores UAT?',
        'Creates a pure Match Play event with draw + submitted scorecards for all 8 matches. Check debug log for handicap divergence points on Match 1.',
        'Scores',
      ),
    MatchPlayEventStage.stablefordOverlay => (
        'Seed Stableford + Match Play Overlay?',
        'Creates a Stableford event with match play overlay — same scorecards drive both calculations. Check debug log for stroke divergence verification points.',
        'Stableford Overlay',
      ),
    MatchPlayEventStage.medalOverlay => (
        'Seed Medal + Match Play Overlay?',
        'Creates a Medal event with match play overlay — same scorecards drive both calculations. Check debug log for stroke divergence verification points.',
        'Medal Overlay',
      ),
  };

  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: title,
    message: message,
    confirmText: 'SEED',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text('Seeding Match Play $label...')));
    try {
      await ref.read(seedingServiceProvider).seedMatchPlayEventUAT(stage);
      messenger.showSnackBar(SnackBar(content: Text('✅ Match Play $label Ready')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

void _showStablefordLeaderboardUATConfirmation(BuildContext context, WidgetRef ref) async {
  final confirm = await showBoxyArtDialog<bool>(
    context: context,
    title: 'Seed Stableford Leaderboard UAT?',
    message: 'Creates two Stableford events. Round 1 is fully approved — tap Recalculate Stats to populate leaderboards. Round 2 is in-play with the last group ready for you to verify and close.',
    confirmText: 'SEED EVENTS',
    onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
    onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
  );
  if (confirm == true && context.mounted) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Seeding Stableford UAT...')));
    try {
      await ref.read(seedingServiceProvider).seedStablefordLeaderboardUAT();
      messenger.showSnackBar(const SnackBar(content: Text('✅ Stableford Leaderboard UAT Ready')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
