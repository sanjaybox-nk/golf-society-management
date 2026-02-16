import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';

import '../data/members_repository.dart';
import '../data/firestore_members_repository.dart';

// Repository Provider
final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return FirestoreMembersRepository();
});

// Search Query State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

final memberSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final adminMemberSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Filter State for Admin
enum AdminMemberFilter { current, committee, other }

class AdminMemberFilterNotifier extends Notifier<AdminMemberFilter> {
  @override
  AdminMemberFilter build() => AdminMemberFilter.current;
  
  void update(AdminMemberFilter filter) => state = filter;
}

final adminMemberFilterProvider = NotifierProvider<AdminMemberFilterNotifier, AdminMemberFilter>(AdminMemberFilterNotifier.new);
final userMemberFilterProvider = NotifierProvider<AdminMemberFilterNotifier, AdminMemberFilter>(AdminMemberFilterNotifier.new);

// All Members Data (Stream)
final allMembersProvider = StreamProvider<List<Member>>((ref) {
  final repo = ref.read(membersRepositoryProvider);
  return repo.watchMembers();
});

// Filtered List based on Search
final filteredMembersProvider = Provider<AsyncValue<List<Member>>>((ref) {
  final allMembersAsync = ref.watch(allMembersProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();

  return allMembersAsync.whenData((members) {
    if (searchQuery.isEmpty) {
      return members;
    }

    return members.where((member) {
      final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
      return fullName.contains(searchQuery);
    }).toList();
  });
});
