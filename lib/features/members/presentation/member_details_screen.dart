import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/features/members/presentation/member_details_modal.dart';

class MemberDetailsScreen extends ConsumerWidget {
  final String id;
  final bool isAdminContext;

  const MemberDetailsScreen({
    super.key,
    required this.id,
    this.isAdminContext = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == 'new') {
      return MemberDetailsModal(
        isNewMember: true,
        isAdminContext: isAdminContext,
        isModal: false,
      );
    }

    final memberAsync = ref.watch(memberByIdProvider(id));

    return memberAsync.when(
      data: (member) {
        if (member == null) {
          return const Scaffold(
            body: Center(child: Text('Member not found')),
          );
        }
        return MemberDetailsModal(
          member: member,
          isAdminContext: isAdminContext,
          isModal: false,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}
