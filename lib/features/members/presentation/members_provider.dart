import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';

// Search Query State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void update(String query) => state = query;
}

final memberSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// All Members Data
final allMembersProvider = Provider<List<Member>>((ref) {
  return [
    const Member(
      id: '1',
      firstName: 'Sanjay',
      lastName: 'Patel',
      email: 'sanjay@example.com',
      handicap: 14.2,
      whsNumber: '1234567890',
      role: MemberRole.member,
    ),
    const Member(
      id: '2',
      firstName: 'David',
      lastName: 'Miller',
      email: 'david@example.com',
      handicap: 8.5,
      whsNumber: '0987654321',
      role: MemberRole.admin,
    ),
    const Member(
      id: '3',
      firstName: 'James',
      lastName: 'Wilson',
      email: 'james@example.com',
      handicap: 18.0,
      whsNumber: '1122334455',
      role: MemberRole.member,
    ),
    const Member(
      id: '4',
      firstName: 'Robert',
      lastName: 'Brown',
      email: 'robert@example.com',
      handicap: 22.4,
      whsNumber: '5544332211',
      role: MemberRole.member,
    ),
    const Member(
      id: '5',
      firstName: 'Michael',
      lastName: 'Taylor',
      email: 'michael@example.com',
      handicap: 5.2,
      whsNumber: '6677889900',
      role: MemberRole.member,
    ),
  ];
});

// Filtered List based on Search
final filteredMembersProvider = Provider<List<Member>>((ref) {
  final allMembers = ref.watch(allMembersProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return allMembers;
  }

  return allMembers.where((member) {
    final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
    return fullName.contains(searchQuery);
  }).toList();
});
