import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';

// Mock Provider for the current logged-in user
final currentUserProvider = Provider<Member>((ref) {
  return const Member(
    id: 'user_123',
    firstName: 'Sanjay',
    lastName: 'Patel',
    email: 'sanjay.patel@example.com',
    handicap: 14.2,
    whsNumber: '1234567890',
    role: MemberRole.superAdmin,
    hasPaid: true,
    bio: 'Golf enthusiast looking to break 80 this season.',
  );
});

// Notifier to hold the member being impersonated (Peek Mode)
class ImpersonationNotifier extends Notifier<Member?> {
  @override
  Member? build() => null;
  
  void set(Member? member) => state = member;
  void clear() => state = null;
}

final impersonationProvider = NotifierProvider<ImpersonationNotifier, Member?>(ImpersonationNotifier.new);

// The provider that all UI components should watch to get the current "identity"
final effectiveUserProvider = Provider<Member>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final impersonatedMember = ref.watch(impersonationProvider);

  if (impersonatedMember != null) {
    // Return the impersonated member, but force the role to 'member' 
    // to hide admin UI even if impersonating another admin.
    return impersonatedMember.copyWith(role: MemberRole.member);
  }

  return currentUser;
});

// Mock Provider for user statistics
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'roundsPlayed': 12,
    'averageScore': 88.5,
    'wins': 2,
    'bestScore': 82,
  };
});
