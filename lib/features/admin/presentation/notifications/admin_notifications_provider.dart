import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/notification.dart';

final adminNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AppNotification(
        id: doc.id,
        title: data['title'] as String? ?? 'No Title',
        message: data['message'] as String? ?? '',
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: data['isRead'] as bool? ?? false,
        category: data['category'] as String? ?? 'General',
        actionUrl: data['actionUrl'] as String?,
      );
    }).toList().cast<AppNotification>();
  });
});
