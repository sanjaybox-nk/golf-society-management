import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/features/members/presentation/members_provider.dart';
import 'package:golf_society/services/persistence_service.dart';
import 'package:golf_society/features/events/presentation/state/marker_selection_provider.dart';
import 'package:collection/collection.dart';

// Mock Provider for the current logged-in user
final currentUserProvider = Provider<Member>((ref) {
  return const Member(
    id: 'demo_hero_sanjay',
    firstName: 'Sanjay',
    lastName: 'Patel',
    email: 'sanjay.patel@demo.com',
    handicap: 0.0,
    handicapId: null,
    role: MemberRole.superAdmin,
    hasPaid: true,
    bio: 'The Creator. Loves a tech-infused round of golf.',
    gender: 'Male',
    allowSocialEventsOnly: false,
  );
});

// Notifier to hold the member being impersonated (Peek Mode)
class ImpersonationNotifier extends Notifier<Member?> {
  static const _key = 'impersonated_member';

  @override
  Member? build() {
    final prefs = ref.watch(persistenceServiceProvider);
    final savedId = prefs.getString(_key);
    if (savedId != null) {
      final members = ref.watch(allMembersProvider).value ?? [];
      return members.firstWhereOrNull((m) => m.id == savedId);
    }
    return null;
  }
  
  void set(Member? member) {
    state = member;
    final prefs = ref.read(persistenceServiceProvider);
    if (member != null) {
      prefs.setString(_key, member.id);
    } else {
      prefs.remove(_key);
    }
    // Hard-reset marker selection state when identity changes to prevent data bleed
    ref.invalidate(markerSelectionProvider);
  }
  
  void clear() {
    state = null;
    ref.read(persistenceServiceProvider).remove(_key);
    // Hard-reset marker selection state when identity changes to prevent data bleed
    ref.invalidate(markerSelectionProvider);
  }
}

final impersonationProvider = NotifierProvider<ImpersonationNotifier, Member?>(ImpersonationNotifier.new);

// The provider that all UI components should watch to get the current "identity"
final effectiveUserProvider = Provider<Member>((ref) {
  final fallback = ref.watch(currentUserProvider);
  final impersonatedMember = ref.watch(impersonationProvider);

  if (impersonatedMember != null) {
    return impersonatedMember.copyWith(role: MemberRole.member);
  }

  // Check if the "Hero" exists in the real member registry
  final membersAsync = ref.watch(allMembersProvider);
  return membersAsync.maybeWhen(
    data: (list) {
      final registered = list.firstWhereOrNull((m) => m.id == fallback.id || m.email == fallback.email);
      if (registered != null) {
        // Return registered data but keep the SuperAdmin role from fallback
        return registered.copyWith(role: fallback.role);
      }
      
      // If NOT registered, return fallback with cleared playing data
      return fallback.copyWith(
        handicap: 0.0,
        handicapId: null,
        firstName: fallback.firstName,
        lastName: fallback.lastName,
      );
    },
    orElse: () => fallback.copyWith(handicap: 0.0, handicapId: null), // Loading/Error/Wiped state = reset playing data
  );
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
