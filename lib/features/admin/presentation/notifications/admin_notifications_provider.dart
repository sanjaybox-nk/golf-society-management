import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/campaign.dart';

final adminNotificationsProvider = StreamProvider<List<Campaign>>((ref) {
  return FirebaseFirestore.instance
      .collection('campaigns')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Handle timestamp specifically since fromJson expects ISO string or DateTime usually,
      // but Firestore gives Timestamp
      final Map<String, dynamic> mappedData = Map.from(data);
      if (mappedData['timestamp'] is Timestamp) {
        mappedData['timestamp'] = (mappedData['timestamp'] as Timestamp).toDate().toIso8601String();
      }
      return Campaign.fromJson(mappedData..['id'] = doc.id);
    }).toList();
  });
});
