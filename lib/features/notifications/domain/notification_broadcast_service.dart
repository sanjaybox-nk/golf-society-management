import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/member.dart';
import 'package:golf_society/domain/models/golf_event.dart';

class NotificationBroadcastService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationBroadcastService();

  /// Notifies all committee members (Admins/SuperAdmins) about a withdrawal.
  Future<void> notifyCommitteeOfWithdrawal({
    required GolfEvent event,
    required String playerName,
    required List<Member> allMembers,
  }) async {
    final committee = allMembers.where((m) => m.role != MemberRole.member).toList();

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
    required String memberId,
    required int groupIndex,
  }) async {
    await _firestore.collection('notifications').add({
        'recipientId': memberId,
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
}

final notificationBroadcastServiceProvider = Provider<NotificationBroadcastService>((ref) {
  return NotificationBroadcastService();
});
