import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'package:golf_society/design_system/design_system.dart';
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

    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Tee Time Promotion!',
        'message': 'You have been promoted from the waitlist to Group ${groupIndex + 1} for ${event.title}.',
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

    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Membership Renewal Due',
        'message': 'Hi ${member.firstName}, your annual membership is due for renewal. Please visit your profile to confirm and update details.',
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

    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Payment Reminder',
        'message': 'Hi ${member.firstName}, your annual membership renewal is confirmed! Please finalize your payment via your profile to secure your spot for the new season.',
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

    await _firestore.collection('notifications').add({
        'recipientId': member.id,
        'title': 'Nudge: Membership Renewal',
        'message': 'Hi ${member.firstName}, we haven\'t heard from you yet regarding the new season! Please submit your preference by $deadline to stay in the game.',
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
