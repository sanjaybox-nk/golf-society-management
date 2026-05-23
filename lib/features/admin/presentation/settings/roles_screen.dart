import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacingTokens>();

    return HeadlessScaffold(
      title: 'System Roles',
      subtitle: 'Manage administrative permissions.',
      topPill: BoxyArtIndicator.committee(label: 'ADMIN'),
      showBack: true,
      actions: const [],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      slivers: [
        membersAsync.when(
          data: (members) {
            // Calculate counts for each MemberRole
            final Map<MemberRole, int> roleCounts = {};
            for (final role in MemberRole.values) {
              roleCounts[role] = members.where((m) => m.role == role).length;
            }

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, spacing?.cardToLabel ?? AppSpacing.cardToLabel, AppSpacing.xl, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...MemberRole.values.asMap().entries.map((entry) {
                    final isLast = entry.key == MemberRole.values.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : (spacing?.cardToCard ?? AppSpacing.standard),
                      ),
                      child: _buildRoleCard(context, entry.value, roleCounts[entry.value] ?? 0),
                    );
                  }),
                  const SizedBox(height: AppSpacing.pageBottom),
                ]),
              ),
            );
          },
          loading: () => const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtLoadingCard(title: 'Loading roles...'),
            ),
          ),
          error: (e, s) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: BoxyArtEmptyCard(
                title: 'Access Error',
                message: 'Could not load system roles: $e',
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(BuildContext context, MemberRole role, int count) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxyArtCard(
      onTap: () {
        context.pushNamed('admin-system-role-members', pathParameters: {'role': role.name});
      },
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          // Parity with Admin Hub and Competition Templates: Square 44px Badge
          BoxyArtIconBadge(
            icon: _getRoleIcon(role),
            size: 44,
            iconSize: 22,
            useCircle: false,
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      count > 0
                          ? '${_getRoleDisplayName(role).toUpperCase()}  ($count)'
                          : _getRoleDisplayName(role).toUpperCase(),
                      style: AppTypography.labelStrong.copyWith(
                        letterSpacing: AppTypography.lsLabel,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getRoleDescription(role),
                  style: AppTypography.micro.copyWith(
                    color: isDark ? AppColors.dark200 : AppColors.dark400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded, 
            color: isDark ? AppColors.dark400 : AppColors.dark200, 
            size: AppShapes.iconXs,
          ),
        ],
      ),
    );
  }

  // Helpers copied from Picker for consistency but expanded
  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Standard Admin';
      case MemberRole.restrictedAdmin: return 'Event Officer';
      case MemberRole.scorer: return 'Scorer';
      case MemberRole.viewer: return 'Observer (Read-Only)';
      case MemberRole.member: return 'Society Member';
      case MemberRole.socialMember: return 'Social Member';
    }
  }

  String _getRoleDescription(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'The highest level of authority. Super Admins manage the collective and its core configuration.';
      case MemberRole.admin: return 'Primary operators who manage the day-to-day running of events and the membership roster.';
      case MemberRole.restrictedAdmin: return 'Field-level support for managing specific event tasks and live scoring without full system access.';
      case MemberRole.scorer: return 'Assigned for event day scoring — can verify cards, resolve conflicts, and approve scorecards.';
      case MemberRole.viewer: return 'Standard member access. Read-only admin reporting is planned — assign Admin for full access in the meantime.';
      case MemberRole.member: return 'Standard app experience for all society members to participate in the season.';
      case MemberRole.socialMember: return 'Social-only access — can view events, scores and leaderboards but cannot register for golf or enter scores.';
    }
  }

  IconData _getRoleIcon(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Icons.admin_panel_settings_rounded;
      case MemberRole.admin: return Icons.security_rounded;
      case MemberRole.restrictedAdmin: return Icons.build_circle_outlined;
      case MemberRole.scorer: return Icons.edit_note_rounded;
      case MemberRole.viewer: return Icons.visibility_outlined;
      case MemberRole.member: return Icons.person_outline_rounded;
      case MemberRole.socialMember: return Icons.people_outline_rounded;
    }
  }
}
