import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/member.dart';
import 'members_provider.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(filteredMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search members...',
              leading: const Icon(Icons.search, color: Colors.grey),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              onChanged: (value) {
                ref.read(memberSearchQueryProvider.notifier).update(value);
              },
            ),
          ),
        ),
      ),
      body: members.isEmpty
          ? Center(
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
            )
          : ListView.separated(
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                return _MemberTile(member: members[index]);
              },
            ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          member.firstName[0] + member.lastName[0],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${member.firstName} ${member.lastName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'HCP: ${member.handicap.toStringAsFixed(1)}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            color: Colors.grey[600],
            onPressed: () {
              // TODO: Implement message action
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            color: Colors.grey[600],
            onPressed: () {
              // TODO: Implement call action
            },
          ),
        ],
      ),
      onTap: () {
        // TODO: Navigate to member profile details (read-only view)
      },
    );
  }
}
