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

    return HeadlessScaffold(
      title: 'System Roles',
      subtitle: 'Manage administrative permissions and site-wide access tiers.',
      showBack: true,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.x2l),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'ACCESS TIERS'),
                  ...MemberRole.values.where((r) => r != MemberRole.member).map((role) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _buildRoleCard(context, role, roleCounts[role] ?? 0),
                    );
                  }),
                  const SizedBox(height: AppSpacing.x2l),
                  const BoxyArtSectionTitle(title: 'STANDARD ACCESS'),
                  _buildRoleCard(context, MemberRole.member, roleCounts[MemberRole.member] ?? 0),
                  const SizedBox(height: 100),
                ]),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (e, s) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
        ),
      ],
    );
  }

  Widget _buildRoleCard(BuildContext context, MemberRole role, int count) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = _getRoleDescription(role);
    final icon = _getRoleIcon(role);
    const identityColor = Colors.cyan; // Consistent with Committee Roles overview
    final bgColor = identityColor.withOpacity(AppColors.opacityLow);

    return BoxyArtCard(
      onTap: () {
        context.pushNamed('admin-system-role-members', pathParameters: {'role': role.name});
      },
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          // Circular Icon Container (56x56)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon, 
                color: identityColor, 
                size: AppShapes.iconLg,
              ),
            ),
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
                      style: TextStyle(
                        fontSize: AppTypography.sizeButton,
                        fontWeight: AppTypography.weightExtraBold,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.pureWhite : AppColors.dark900,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      BoxyArtPill(
                        label: '$count',
                        color: AppColors.scoreEagle,
                        fontSize: AppTypography.sizeMicroSmall,
                        hasHorizontalMargin: false,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppTypography.sizeLabelStrong,
                    color: isDark ? AppColors.dark300 : AppColors.dark400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded, 
            color: AppColors.textSecondary, 
            size: AppShapes.iconMd,
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
