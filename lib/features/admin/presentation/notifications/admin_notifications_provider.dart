import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/campaign.dart';

final adminNotificationsProvider = StreamProvider<List<Campaign>>((ref) {
  return FirebaseFirestore.instance
      .collection('campaigns')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Campaign(
        id: doc.id,
        title: data['title'] as String? ?? 'No Title',
        message: data['message'] as String? ?? '',
        category: data['category'] as String? ?? 'General',
        targetType: data['targetType'] as String? ?? 'Unknown',
        recipientCount: data['recipientCount'] as int? ?? 0,
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        sentByUserId: data['sentByUserId'] as String?,
        actionUrl: data['actionUrl'] as String?,
        targetDescription: data['targetDescription'] as String?,
      );
    }).toList();
  });
});
