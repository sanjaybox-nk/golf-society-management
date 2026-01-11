import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/notification.dart';
import 'notifications_repository.dart';

class FirestoreNotificationsRepository implements NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure the ID is part of the model if needed, or just map fields
        // Since AppNotification has an 'id' field, we pass the doc.id
        data['id'] = doc.id;
        
        // Handle Timestamp to DateTime conversion if necessary, 
        // though Freezed/JsonSerializable usually handles it with the right converters.
        // If specific conversion needed:
        if (data['timestamp'] is Timestamp) {
            data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }

        return AppNotification.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
  
  @override
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}
