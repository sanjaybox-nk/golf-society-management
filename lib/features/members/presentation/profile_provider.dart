import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/services/persistence_service.dart';
import 'dart:convert';

// Mock Provider for the current logged-in user
final currentUserProvider = Provider<Member>((ref) {
  return const Member(
    id: 'demo_hero_sanjay',
    firstName: 'Sanjay',
    lastName: 'Patel',
    email: 'sanjay.patel@demo.com',
    handicap: 14.5,
    handicapId: 'WHS888888',
    role: MemberRole.superAdmin,
    hasPaid: true,
    bio: 'The Creator. Loves a tech-infused round of golf.',
    gender: 'Male',
    renewalStatus: MemberRenewalStatus.none,
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

// [NEW] Notifier to handle member-initiated renewal status updates
class MemberRenewalNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateStatus(String memberId, MemberRenewalStatus status) async {
    // In a real app, this would call membersRepository.updateMember
    // For this demo, we'll update the impersonation state if active, 
    // or just assume the backend update is successful.
    final impersonated = ref.read(impersonationProvider);
    if (impersonated != null && impersonated.id == memberId) {
      ref.read(impersonationProvider.notifier).set(impersonated.copyWith(renewalStatus: status));
    }
    
    // Log for verification
  }
}

final memberRenewalProvider = NotifierProvider<MemberRenewalNotifier, void>(MemberRenewalNotifier.new);
