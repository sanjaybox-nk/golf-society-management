import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/member.dart';
import '../../../core/services/persistence_service.dart';
import 'dart:convert';

// Mock Provider for the current logged-in user
final currentUserProvider = Provider<Member>((ref) {
  return const Member(
    id: 'user_123',
    firstName: 'Sanjay',
    lastName: 'Patel',
    email: 'sanjay.patel@example.com',
    handicap: 14.2,
    handicapId: '1234567890',
    role: MemberRole.superAdmin,
    hasPaid: true,
    bio: 'Golf enthusiast looking to break 80 this season.',
  );
});

// Notifier to hold the member being impersonated (Peek Mode)
class ImpersonationNotifier extends Notifier<Member?> {
  static const _key = 'impersonated_member';

  @override
  Member? build() {
    final prefs = ref.watch(persistenceServiceProvider);
    final saved = prefs.getString(_key);
    if (saved != null) {
      try {
        return Member.fromJson(jsonDecode(saved));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  void set(Member? member) {
    state = member;
    final prefs = ref.read(persistenceServiceProvider);
    if (member != null) {
      prefs.setString(_key, jsonEncode(member.toJson()));
    } else {
      prefs.remove(_key);
    }
  }
  
  void clear() {
    state = null;
    ref.read(persistenceServiceProvider).remove(_key);
  }
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
