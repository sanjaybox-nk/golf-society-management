import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/design_system/design_system.dart';
import '../../../members/presentation/members_provider.dart';



class CommitteeRolesScreen extends ConsumerStatefulWidget {
  const CommitteeRolesScreen({super.key});

  @override
  ConsumerState<CommitteeRolesScreen> createState() => _CommitteeRolesScreenState();
}

class _CommitteeRolesScreenState extends ConsumerState<CommitteeRolesScreen> {
  final List<String> _standardRoles = [
    'President',
    'Captain',
    'Vice Captain',
    'Secretary',
    'Treasurer',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(allMembersProvider);
    final beigeBackground = theme.scaffoldBackgroundColor;

    return HeadlessScaffold(
      title: 'Committee Roles',
      subtitle: 'Manage society specific titles',
      backgroundColor: beigeBackground,
      showBack: true,
      onBack: () => context.pop(),
      slivers: [
        membersAsync.when(
          data: (members) {
            final activeCustomRoles = members
                .map((m) => m.societyRole)
                .where((r) => r != null && r.isNotEmpty && !_standardRoles.contains(r))
                .cast<String>()
                .toSet()
                .toList();

            activeCustomRoles.sort();
            final allRoles = [..._standardRoles, ...activeCustomRoles];

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BoxyArtSectionTitle(title: 'SOCIETY TITLES'),
                  ...allRoles.map((role) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRoleCard(context, role),
                  )),
                  const SizedBox(height: 32),
                  _buildCreateButton(context),
                  const SizedBox(height: 100),
                ]),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
      ],
    );
  }

  Widget _buildRoleCard(BuildContext context, String role) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = _getRoleDescription(role);
    final icon = _getRoleIcon(role);
    const identityColor = Colors.cyan; 
    final bgColor = identityColor.withValues(alpha: 0.1);

    return BoxyArtCard(
      onTap: () {
        context.push('/admin/settings/committee-roles/members/${Uri.encodeComponent(role)}');
      },
      padding: const EdgeInsets.all(16),
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
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.pureWhite : AppColors.dark900,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.dark300 : AppColors.dark400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: isDark ? AppColors.dark400 : AppColors.dark200,
            onPressed: () => _showEditRoleDialog(role),
          ),
          Icon(
            Icons.chevron_right_rounded, 
            color: isDark ? AppColors.dark400 : AppColors.dark300, 
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return BoxyArtButton(
      title: 'Create Custom Role',
      icon: Icons.add_circle_outline_rounded,
      isPrimary: false,
      onTap: () => _showCreateRoleDialog(),
    );
  }

  // --- Dialogs ---

  void _showCreateRoleDialog() {
    final controller = TextEditingController();
    showBoxyArtDialog(
      context: context,
      title: 'New Role Title',
      content: BoxyArtFormField(
        label: 'Role Title',
        hintText: 'e.g. Tour Manager',
        controller: controller,
      ),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          final newRole = controller.text.trim();
          Navigator.of(context, rootNavigator: true).pop();
          context.push('/admin/settings/committee-roles/members/${Uri.encodeComponent(newRole)}');
        }
      },
      confirmText: 'Create Role',
    );
  }

  void _showEditRoleDialog(String oldName) {
    final controller = TextEditingController(text: oldName);
    showBoxyArtDialog(
      context: context,
      title: 'Edit Title: $oldName',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Renaming this role will update the title for ALL members who currently hold it.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          BoxyArtFormField(
            label: 'Role Title',
            controller: controller,
          ),
        ],
      ),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
      onConfirm: () {
        if (controller.text.trim().isNotEmpty && controller.text.trim() != oldName) {
          final newName = controller.text.trim();
          Navigator.of(context, rootNavigator: true).pop();
          _renameRole(oldName, newName);
        }
      },
      confirmText: 'Save',
    );
  }

  // --- Helpers ---

  Future<void> _renameRole(String oldName, String newName) async {
    // Batch update all members with this role
    final members = ref.read(allMembersProvider).asData?.value ?? [];
    final membersToUpdate = members.where((m) => m.societyRole == oldName).toList();

    if (membersToUpdate.isEmpty) {
      // Just a visual change if it was a standard role with no members?
      // Since we don't store roles separately, there's nothing to update if no members have it.
      // But for standard roles, we can't "rename" the hardcoded string in the list.
      // So this only effectively renames it for the people holding it.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No members held this role, so no updates were needed.')));
      return;
    }

    final repo = ref.read(membersRepositoryProvider);
    int count = 0;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Simple loop for now - optimal for < 500 members
      for (final member in membersToUpdate) {
        final updated = member.copyWith(societyRole: newName);
        await repo.updateMember(updated);
        count++;
      }
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated role for $count members.')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating roles: $e')));
      }
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'President': return Icons.gavel;
      case 'Captain': return Icons.sports_golf;
      case 'Vice Captain': return Icons.flag;
      case 'Secretary': return Icons.library_books; // changed from edit_document for compatibility
      case 'Treasurer': return Icons.account_balance;
      default: return Icons.stars; // Default badge
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'President': return 'Head of the society and committee chair.';
      case 'Captain': return 'Leads the team and manages golf events.';
      case 'Vice Captain': return 'Supports the Captain and deputizes when needed.';
      case 'Secretary': return 'Manages administration, minutes, and membership.';
      case 'Treasurer': return 'Manages finances, payments, and accounts.';
      default: return 'Custom Role';
    }
  }
}
