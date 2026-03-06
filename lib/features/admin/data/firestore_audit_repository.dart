import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/audit_activity.dart';
import 'audit_repository.dart';

class FirestoreAuditRepository implements AuditRepository {
  final FirebaseFirestore _firestore;

  FirestoreAuditRepository(this._firestore);

  @override
  Stream<List<AuditActivity>> watchActivities({int limit = 20}) {
    return _firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditActivity.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  @override
  Future<void> logActivity(AuditActivity activity) async {
    await _firestore.collection('activities').add(activity.toJson());
  }
}
