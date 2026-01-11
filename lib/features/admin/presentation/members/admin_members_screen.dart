import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golf_society/core/theme/app_theme.dart';
import 'package:golf_society/core/theme/app_shadows.dart';

import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/models/member.dart';
import 'package:golf_society/core/widgets/boxy_art_widgets.dart';
import 'package:golf_society/features/members/presentation/member_details_modal.dart';

class AdminMembersScreen extends ConsumerWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);
    final searchQuery = ref.watch(adminMemberSearchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(adminMemberFilterProvider);

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Manage Members',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                mini: true,
                onPressed: () => context.push('/admin/members/new'),
                child: const Icon(Icons.person_add, size: 20),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(82),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: BoxyArtSearchBar(
              hintText: 'Search admin members...',
              onChanged: (value) {
                ref.read(adminMemberSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
        ),
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          
          final filtered = members.where((m) {
            final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
            final matchesSearch = name.contains(searchQuery);
            
            if (!matchesSearch) return false;

            if (currentFilter == AdminMemberFilter.current) {
              return m.status != MemberStatus.archived && 
                     m.status != MemberStatus.left &&
                     m.status != MemberStatus.inactive &&
                     !m.isArchived;
            } else {
              return m.status == MemberStatus.archived || 
                     m.status == MemberStatus.left ||
                     m.status == MemberStatus.inactive ||
                     m.isArchived;
            }
          }).toList();

          final sortedMembers = [...filtered]..sort((a, b) => a.lastName.compareTo(b.lastName));

          // Calculate counts for badges
          final currentCount = members.where((m) => 
            m.status != MemberStatus.archived && 
            m.status != MemberStatus.left &&
            m.status != MemberStatus.inactive &&
            !m.isArchived
          ).length;

          final pastCount = members.where((m) => 
            m.status == MemberStatus.archived || 
            m.status == MemberStatus.left ||
            m.status == MemberStatus.inactive ||
            m.isArchived
          ).length;

          return Stack(
            children: [
              Column(
                children: [
              // List
              Expanded(
                child: sortedMembers.isEmpty 
                  ? Center(
                      child: Text(
                        currentFilter == AdminMemberFilter.current 
                          ? 'No current members found.' 
                          : 'No past members found.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 100),
                      itemCount: sortedMembers.length,
                      itemBuilder: (context, index) {
                        final m = sortedMembers[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDismissibleMember(context, ref, m),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
          
          // Floating Filter Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingFilterBar<AdminMemberFilter>(
              selectedValue: currentFilter,
              options: [
                FloatingFilterOption(label: 'Current ($currentCount)', value: AdminMemberFilter.current),
                FloatingFilterOption(label: 'Past ($pastCount)', value: AdminMemberFilter.past),
              ],
              onChanged: (filter) {
                ref.read(adminMemberFilterProvider.notifier).update(filter);
              },
            ),
          ),
        ],
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error: $err')),
  ),
);
}
}

class _SimpleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _SimpleBadge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
 Widget _buildDismissibleMember(BuildContext context, WidgetRef ref, Member member) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Dismissible(
      key: Key(member.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showBoxyArtDialog<bool>(
          context: context,
          title: 'Delete Member?',
          message: 'Delete ${member.firstName} ${member.lastName}?',
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
          confirmText: 'Delete',
        );
      },
      onDismissed: (direction) {
        ref.read(membersRepositoryProvider).deleteMember(member.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${member.firstName}')),
        );
      },
      child: GestureDetector(
        onTap: () => context.push('/admin/members/edit/${member.id}', extra: member),
        onLongPress: () => MemberDetailsModal.show(context, member),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8E1), Color(0xFFF7D354)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.surfaceGrey,
                child: Text(
                  member.firstName.isNotEmpty ? member.firstName[0] : '', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name
                    Text(
                      '${member.firstName} ${member.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    if (member.societyRole != null && member.societyRole!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          member.societyRole!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    if (member.nickname != null && member.nickname!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          member.nickname!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Row 2: HCP | iGolf Membership
                    Text(
                      'HC: ${member.handicap.toStringAsFixed(1)} | iGolf: ${member.whsNumber?.isNotEmpty == true ? member.whsNumber : '-'}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Row 3: Email
                    Text(
                      member.email,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Row 4: Status | Fee Status | Since Pill
                    Row(
                      children: [
                        _SimpleBadge(
                          label: member.status.displayName,
                          color: _getAdminStatusColor(member.status).withValues(alpha: 0.15),
                          textColor: _getAdminStatusColor(member.status),
                        ),
                        const SizedBox(width: 8),
                        if (member.hasPaid)
                          const _SimpleBadge(
                            label: 'Fee Paid',
                            color: Color(0xFFE8F5E9),
                            textColor: Color(0xFF2E7D32),
                          )
                        else
                          const _SimpleBadge(
                            label: 'Fee Due',
                            color: Color(0xFFFFF3E0),
                            textColor: Color(0xFFE65100),
                          ),
                        const Spacer(),
                        if (member.joinedDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Since ${member.joinedDate!.year}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    ),
  );
}

Color _getAdminStatusColor(MemberStatus status) {
  switch (status) {
    case MemberStatus.member:
    case MemberStatus.active:
      return Colors.green.shade700;
    case MemberStatus.pending:
      return Colors.blue.shade700;
    case MemberStatus.suspended:
      return Colors.orange.shade800;
    case MemberStatus.archived:
    case MemberStatus.inactive:
      return Colors.grey.shade600;
    case MemberStatus.left:
      return Colors.red.shade700;
  }
}

class _AdminSectionHeader extends StatelessWidget {
  final String title;
  const _AdminSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}
