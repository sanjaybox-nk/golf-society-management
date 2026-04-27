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
      subtitle: 'Manage administrative permissions and site-wide access tiers.',
      topPill: BoxyArtPill.committee(label: 'ADMIN'),
      showBack: true,
      actions: const [],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: BoxyArtSectionTitle(title: 'Access tiers', isPeeking: true),
          ),
        ),
        membersAsync.when(
          data: (members) {
            // Calculate counts for each MemberRole
            final Map<MemberRole, int> roleCounts = {};
            for (final role in MemberRole.values) {
              roleCounts[role] = members.where((m) => m.role == role).length;
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...MemberRole.values.where((r) => r != MemberRole.member).map((role) {
                    final isLastInGroup = role == MemberRole.viewer;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLastInGroup ? 0 : (spacing?.cardToCard ?? AppSpacing.atomic),
                      ),
                      child: _buildRoleCard(context, role, roleCounts[role] ?? 0),
                    );
                  }),
                  const BoxyArtSectionTitle(title: 'Standard access', isPeeking: false),
                  _buildRoleCard(context, MemberRole.member, roleCounts[MemberRole.member] ?? 0),
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
                      _getRoleDisplayName(role).toUpperCase(),
                      style: AppTypography.labelStrong.copyWith(
                        letterSpacing: 1.0,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      BoxyArtPill(
                        label: '$count',
                        // Design 4.x: Primary-tinted count pills
                        color: theme.primaryColor,
                        fontSize: AppTypography.sizeMicroSmall,
                        hasHorizontalMargin: false,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getRoleDescription(role),
                  style: AppTypography.caption.copyWith(
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
      case MemberRole.viewer: return 'Observer (Read-Only)';
      case MemberRole.member: return 'Society Member';
    }
  }

  String _getRoleDescription(MemberRole role) {
     switch (role) {
      case MemberRole.superAdmin: return 'The highest level of authority. Super Admins manage the collective and its core configuration.';
      case MemberRole.admin: return 'Primary operators who manage the day-to-day running of events and the membership roster.';
      case MemberRole.restrictedAdmin: return 'Field-level support for managing specific event tasks and live scoring without full system access.';
      case MemberRole.viewer: return 'Internal auditors or committee members who need to monitor stats without editing rights.';
      case MemberRole.member: return 'Standard app experience for all society members to participate in the season.';
    }
  }

  IconData _getRoleIcon(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Icons.admin_panel_settings_rounded;
      case MemberRole.admin: return Icons.security_rounded;
      case MemberRole.restrictedAdmin: return Icons.build_circle_outlined;
      case MemberRole.viewer: return Icons.visibility_outlined;
      case MemberRole.member: return Icons.person_outline_rounded;
    }
  }
}
