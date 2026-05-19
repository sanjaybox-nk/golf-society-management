import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/domain/models/platform_content.dart';
import 'package:golf_society/design_system/design_system.dart';
import 'package:golf_society/features/settings/data/platform_content_repository.dart';
import 'package:intl/intl.dart';
import '../../matchplay/domain/match_play_tournament.dart';

class NotificationBroadcastService {
  final Ref ref;

  NotificationBroadcastService(this.ref);

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Notifies all committee members (Admins/SuperAdmins) about a withdrawal.
  Future<void> notifyCommitteeOfWithdrawal({
    required GolfEvent event,
    required String playerName,
    required List<Member> allMembers,
  }) async {
    final committee = allMembers.where((m) => 
      m.role != MemberRole.member && 
      m.status != MemberStatus.suspended
    ).toList();

    for (var admin in committee) {
      // Bypassing model for direct Firestore write to include recipientId
      await _firestore.collection('notifications').add({
        'recipientId': admin.id,
        'title': 'Withdrawal Alert: ${event.title}',
        'message': '$playerName has withdrawn from the golf field. If the tournament was locked, a vacancy was automatically filled or noted.',
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'withdrawal',
        'isRead': false,
      });
    }
  }

  /// Notifies a player that they have been promoted to a tee time.
  Future<void> notifyPlayerOfPromotion({
    required GolfEvent event,
    required Member member,
    required int groupIndex,
  }) async {
    if (member.status == MemberStatus.suspended) return;

    final content = ref.read(platformContentProvider).value ?? const PlatformContent();
    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Tee Time Promotion!',
        'message': content.resolve(content.teeTimePromotion, {
          'groupNumber': '${groupIndex + 1}',
          'eventName': event.title,
        }),
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'promotion',
        'isRead': false,
    });
  }

  /// Notifies a member that their annual membership is due for renewal.
  Future<void> notifyMemberOfRenewal({
    required Member member,
  }) async {
    if (member.status == MemberStatus.suspended) return;

    final content = ref.read(platformContentProvider).value ?? const PlatformContent();
    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Membership Renewal Due',
        'message': content.resolve(content.membershipRenewalDue, {'firstName': member.firstName}),
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'Urgent',
        'isRead': false,
        'actionUrl': '/members/${member.id}',
    });
  }

  /// Notifies a member that their seasonal payment is due.
  Future<void> notifyMemberOfPaymentDue({
    required Member member,
  }) async {
    if (member.status == MemberStatus.suspended) return;

    final content = ref.read(platformContentProvider).value ?? const PlatformContent();
    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Payment Reminder',
        'message': content.resolve(content.membershipPaymentDue, {'firstName': member.firstName}),
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'Urgent',
        'isRead': false,
        'actionUrl': '/members/${member.id}',
    });
  }

  /// Sends a direct "Nudge" notification for renewal.
  Future<void> sendRenewalNudge({
    required Member member,
  }) async {
    final config = ref.read(themeControllerProvider);
    final deadline = config.renewalDeadline != null ? DateFormat('MMM d').format(config.renewalDeadline!) : 'soon';
    final content = ref.read(platformContentProvider).value ?? const PlatformContent();

    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Nudge: Membership Renewal',
        'message': content.resolve(content.membershipNudge, {'firstName': member.firstName, 'deadline': deadline}),
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'Nudge',
        'isRead': false,
        'actionUrl': '/members/${member.id}',
    });
  }

  /// Notifies all entrants of a Match Play tournament that the draw is published.
  Future<void> notifyMatchPlayPublished({
    required MatchPlayTournament tournament,
  }) async {
    final playerIds = <String>{};
    for (final entrant in tournament.entrants) {
      playerIds.addAll(entrant.playerIds);
    }

    for (final playerId in playerIds) {
      await _firestore.collection('notifications').add({
        'recipientId': playerId,
        'title': 'Match Play Draw Live!',
        'message': 'The draw for ${tournament.name} is now live! Check your opening match and deadline in the Match Play Hub.',
        'timestamp': FieldValue.serverTimestamp(),
        'category': 'match_play',
        'isRead': false,
        'actionUrl': '/matchplay',
      });
    }
  }
}

final renewalNudgeServiceProvider = Provider<NotificationBroadcastService>((ref) {
  return NotificationBroadcastService(ref);
});
