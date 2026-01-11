import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../models/member.dart';
import 'members_provider.dart';
import 'member_details_modal.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider); // Use allMembers to apply custom filter logic here
    final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(userMemberFilterProvider);

    return Scaffold(
      appBar: BoxyArtAppBar(
        title: 'Members',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(82),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: BoxyArtSearchBar(
              hintText: 'Search members...',
              onChanged: (value) {
                ref.read(memberSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
        ),
      ),
      body: membersAsync.when(
        data: (members) {
          final confirmedList = members.where((m) {
            final name = '${m.firstName} ${m.lastName} ${m.nickname ?? ''}'.toLowerCase();
            final matchesSearch = name.contains(searchQuery);
            if (!matchesSearch) return false;

            if (currentFilter == AdminMemberFilter.current) {
              return m.status == MemberStatus.member || 
                     m.status == MemberStatus.active ||
                     m.status == MemberStatus.suspended;
            } else {
              return m.status == MemberStatus.archived || 
                     m.status == MemberStatus.left ||
                     m.status == MemberStatus.inactive;
            }
          }).toList();

          if (confirmedList.isEmpty) {
             return Stack(
               children: [
                 const _EmptyMembers(),
                 Positioned(
                   left: 0,
                   right: 0,
                   bottom: 0,
                   child: FloatingFilterBar<AdminMemberFilter>(
                    selectedValue: currentFilter,
                    options: [
                      FloatingFilterOption(label: 'Current', value: AdminMemberFilter.current),
                      FloatingFilterOption(label: 'Past', value: AdminMemberFilter.past),
                    ],
                    onChanged: (filter) {
                      ref.read(userMemberFilterProvider.notifier).update(filter);
                    },
                  ),
                ),
              ],
             );
          }

          final sortedList = [...confirmedList]..sort((a, b) => a.lastName.compareTo(b.lastName));

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24).copyWith(bottom: 110),
                itemCount: sortedList.length,
                itemBuilder: (context, index) {
                  final m = sortedList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       if (index == 0) ...[
                          _SectionHeader(
                            title: currentFilter == AdminMemberFilter.current
                              ? 'Current Members'
                              : 'Past Members'
                          ),
                          const SizedBox(height: 16),
                       ],
                       Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MemberTile(member: m),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingFilterBar<AdminMemberFilter>(
                  selectedValue: currentFilter,
                  options: [
                    FloatingFilterOption(label: 'Current', value: AdminMemberFilter.current),
                    FloatingFilterOption(label: 'Past', value: AdminMemberFilter.past),
                  ],
                  onChanged: (filter) {
                    ref.read(userMemberFilterProvider.notifier).update(filter);
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

class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MemberDetailsModal.show(context, member),
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
                member.firstName[0] + member.lastName[0],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
                    'HCP: ${member.handicap.toStringAsFixed(1)} | ${member.whsNumber?.isNotEmpty == true ? member.whsNumber : 'No WHS'}',
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
                  // Row 4: Status | Fee Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(member.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(member.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
 Color _getStatusColor(MemberStatus status) {
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No members found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
