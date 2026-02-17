import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';
import '../../../members/presentation/members_provider.dart';



class RoleMembersScreen extends ConsumerStatefulWidget {
  final MemberRole role;

  const RoleMembersScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<RoleMembersScreen> createState() => _RoleMembersScreenState();
}

class _RoleMembersScreenState extends ConsumerState<RoleMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);

    return HeadlessScaffold(
      title: _getRoleDisplayName(widget.role),
      showBack: true,
      backgroundColor: const Color(0xFFF0F2F5),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRoleDescription(widget.role),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Search Bar
                BoxyArtFormField(
                  label: 'Search Members',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                ),
              ],
            ),
          ),
        ),

        // Member List
        membersAsync.when(
          data: (members) {
            // Separation of concerns:
            // 1. Current Role Holders (Default List)
            // 2. Search Candidates (Search List)
            
            List<Member> displayList;
            final isSearching = _searchQuery.isNotEmpty;

            if (isSearching) {
              // Show matching members who DO NOT have the role (Candidates)
              // AND members who DO have the role (so you can see they are already added)
              displayList = members.where((m) {
                final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                return name.contains(_searchQuery);
              }).toList();
            } else {
              // Show only current holders
              displayList = members.where((m) => m.role == widget.role).toList();
            }

            displayList.sort((a, b) {
              // Sort: Role holders first, then alpha
              final aHasRole = a.role == widget.role;
              final bHasRole = b.role == widget.role;
              if (aHasRole && !bHasRole) return -1;
              if (!aHasRole && bHasRole) return 1;
              return a.lastName.compareTo(b.lastName);
            });

            if (displayList.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    isSearching ? 'No members found.' : 'No members have this role.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = displayList[index];
                    final hasRole = member.role == widget.role;

                    // If searching and they don't have role, show Add button.
                    // If they have role, show Switch + Dismissible.
                    
                    if (!hasRole) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCandidateTile(member),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActiveRoleTile(member),
                      );
                    }
                  },
                  childCount: displayList.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
        ),
      ],
    );
  }

  // Tile for someone who CAN be added (Search Result)
  Widget _buildCandidateTile(Member member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
          child: member.avatarUrl == null
              ? Text(
                  member.firstName.isNotEmpty ? member.firstName[0] : '',
                  style: const TextStyle(color: Colors.black54),
                )
              : null,
        ),
        title: Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF1A237E), size: 32),
          onPressed: () {
            _updateRole(member, widget.role);
            _searchController.clear();
          },
        ),
      ),
    );
  }

  // Tile for someone who HAS the role (Default List)
  // Supports Dismiss (Swipe) and Switch
  Widget _buildActiveRoleTile(Member member) {
    final roleColor = _getRoleColor(widget.role);
    
    return Dismissible(
      key: Key(member.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // Remove role (Demote to standard member)
        _updateRole(member, MemberRole.member);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: roleColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.firstName.isNotEmpty ? member.firstName[0] : '',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.firstName} ${member.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getRoleDisplayName(widget.role),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: true, // Always true if in this list
              activeTrackColor: roleColor,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              onChanged: (val) {
                 // Toggling off removes the role
                 if (!val) _updateRole(member, MemberRole.member);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(Member member, MemberRole newRole) async {
    final repo = ref.read(membersRepositoryProvider);
    final updatedMember = member.copyWith(role: newRole);
    try {
      await repo.updateMember(updatedMember);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _getRoleDisplayName(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Super Admin';
      case MemberRole.admin: return 'Admin';
      case MemberRole.restrictedAdmin: return 'Restricted Admin';
      case MemberRole.viewer: return 'Viewer';
      case MemberRole.member: return 'Standard Member';
    }
  }

  String _getRoleDescription(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return 'Manage members designated as Super Admins.';
      case MemberRole.admin: return 'Manage members designated as Admins.';
      case MemberRole.restrictedAdmin: return 'Manage members designated as Restricted Admins.';
      case MemberRole.viewer: return 'Manage members with Viewer access.';
      case MemberRole.member: return '';
    }
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.superAdmin: return Colors.deepPurple;
      case MemberRole.admin: return Colors.blue;
      case MemberRole.restrictedAdmin: return Colors.orange;
      case MemberRole.viewer: return Colors.teal;
      case MemberRole.member: return Colors.grey;
    }
  }
}
