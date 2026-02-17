import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
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
    final membersAsync = ref.watch(allMembersProvider);
    final beigeBackground = Theme.of(context).scaffoldBackgroundColor;

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
                  ...allRoles.map((role) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRoleCard(context, role),
                  )),
                  const SizedBox(height: 16),
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
    final description = _getRoleDescription(role);
    final icon = _getRoleIcon(role);

    return ModernCard(
      onTap: () {
        context.push('/admin/settings/committee-roles/members/${Uri.encodeComponent(role)}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  onPressed: () => _showEditRoleDialog(role),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return BoxyArtButton(
      title: 'Create Custom Role',
      icon: Icons.add_circle_outline,
      isSecondary: true,
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
