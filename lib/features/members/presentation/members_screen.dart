import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/boxy_art_widgets.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/contrast_helper.dart';
import '../../../models/member.dart';
import 'members_provider.dart';
import 'member_details_modal.dart';

import '../../../../core/theme/status_colors.dart';

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
        showLeading: false,
        isLarge: true,
        actions: const [],
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
                itemCount: sortedList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoxyArtSectionTitle(title: 'Member Directory', padding: EdgeInsets.only(bottom: 16)),
                      ],
                    );
                  }
                  final m = sortedList[index - 1];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

class _MemberTile extends ConsumerWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeControllerProvider);
    final cardTintIntensity = config.cardTintIntensity;
    final useGradient = config.useCardGradient;
    
    // Calculate effective background color for contrast
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final effectiveBackgroundColor = useGradient
        ? Color.alphaBlend(primaryColor.withValues(alpha: cardTintIntensity * 0.75), cardColor)
        : Color.alphaBlend(primaryColor.withValues(alpha: cardTintIntensity), cardColor);
    
    // Get contrasting text color
    final textColor = ContrastHelper.getContrastingText(effectiveBackgroundColor);
    final subTextColor = textColor.withValues(alpha: 0.7);
    
    return GestureDetector(
      onTap: () => MemberDetailsModal.show(context, member),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: useGradient ? Theme.of(context).cardColor : Color.alphaBlend(Theme.of(context).primaryColor.withValues(alpha: cardTintIntensity), Theme.of(context).cardColor),
          gradient: useGradient ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: cardTintIntensity * 0.5),
              Theme.of(context).primaryColor.withValues(alpha: cardTintIntensity),
            ],
          ) : null,
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
              backgroundColor: Colors.white,
              backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
              child: member.avatarUrl == null
                  ? Text(
                      (member.firstName.isNotEmpty ? member.firstName[0] : '') +
                          (member.lastName.isNotEmpty ? member.lastName[0] : ''),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name
                  Text(
                    '${member.firstName} ${member.lastName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  if (member.societyRole != null && member.societyRole!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        member.societyRole!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  if (member.nickname != null && member.nickname!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        member.nickname!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Row 2: HCP | iGolf Membership
                  Text(
                    'HC: ${member.handicap.toStringAsFixed(1)} | iGolf: ${member.whsNumber?.isNotEmpty == true ? member.whsNumber : '-'}',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      BoxyArtStatusPill(
                        text: member.status.displayName,
                        baseColor: member.status.color,
                      ),
                      if (member.hasPaid) ...[
                        const SizedBox(width: 8),
                        BoxyArtStatusPill(
                          text: 'Fee Paid',
                          baseColor: StatusColors.positive,
                        ),
                      ] else ...[
                        const SizedBox(width: 8),
                        BoxyArtStatusPill(
                          text: 'Fee Due',
                          baseColor: StatusColors.warning,
                        ),
                      ],
                    ],
                  ),
                  if (member.joinedDate != null) ...[
                    const SizedBox(height: 6),
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
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subTextColor),
          ],
        ),
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
