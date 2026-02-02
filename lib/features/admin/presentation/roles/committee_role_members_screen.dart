import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/boxy_art_widgets.dart';
import '../../../../models/member.dart';
import '../../../members/presentation/members_provider.dart';

import '../../../../core/theme/contrast_helper.dart';

class CommitteeRoleMembersScreen extends ConsumerStatefulWidget {
  final String role; // e.g. "Captain"

  const CommitteeRoleMembersScreen({
    super.key,
    required this.role,
  });

  @override
  ConsumerState<CommitteeRoleMembersScreen> createState() => _CommitteeRoleMembersScreenState();
}

class _CommitteeRoleMembersScreenState extends ConsumerState<CommitteeRoleMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Color get _roleColor => Theme.of(context).primaryColor;
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
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimary = ContrastHelper.getContrastingText(primaryColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: BoxyArtAppBar(
        title: widget.role,
        isLarge: true,
        leadingWidth: 70,
        leading: Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text('Back', style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header / Search
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                  'Manage members currently serving as ${widget.role}.',
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

          // Member List
          Expanded(
            child: membersAsync.when(
              data: (members) {
                List<Member> displayList;
                final isSearching = _searchQuery.isNotEmpty;

                if (isSearching) {
                  // Candidates + Holders matching search
                  displayList = members.where((m) {
                    final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                } else {
                  // Holders Only
                  displayList = members.where((m) => m.societyRole == widget.role).toList();
                }

                // Sort: Role holders first, then alpha
                displayList.sort((a, b) {
                  final aHasRole = a.societyRole == widget.role;
                  final bHasRole = b.societyRole == widget.role;
                  if (aHasRole && !bHasRole) return -1;
                  if (!aHasRole && bHasRole) return 1;
                  return a.lastName.compareTo(b.lastName);
                });

                if (displayList.isEmpty) {
                  return Center(
                    child: Text(
                      isSearching ? 'No members found.' : 'No members have this position.',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: displayList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = displayList[index];
                    final hasRole = member.societyRole == widget.role;

                    if (!hasRole) {
                      return _buildCandidateTile(member);
                    } else {
                      return _buildActiveRoleTile(member);
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  // Tile for someone who CAN be added
  Widget _buildCandidateTile(Member member) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        // existing societyRole info could go here as subtitle if they hold another role
        subtitle: member.societyRole != null && member.societyRole!.isNotEmpty 
            ? Text(member.societyRole!, style: TextStyle(fontSize: 12, color: _roleColor)) 
            : null,
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: _roleColor, size: 32),
          onPressed: () {
            _updateRole(member, widget.role);
            _searchController.clear();
          },
        ),
      ),
    );
  }

  // Tile for someone who HAS the role
  Widget _buildActiveRoleTile(Member member) {
    return Dismissible(
      key: Key(member.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _updateRole(member, null); // Remove role
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _roleColor, width: 2),
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
                        color: _roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _roleColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: true,
              activeTrackColor: _roleColor,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              onChanged: (val) {
                 if (!val) _updateRole(member, null);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(Member member, String? newRole) async {
    final repo = ref.read(membersRepositoryProvider);
    // Note: This replaces any existing role. A member can only have ONE society role at a time currently.
    final updatedMember = member.copyWith(societyRole: newRole);
    try {
      await repo.updateMember(updatedMember);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
