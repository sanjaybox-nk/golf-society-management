import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/audit_activity.dart';
import 'package:golf_society/features/admin/data/audit_repository.dart';
import 'package:golf_society/features/admin/data/firestore_audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return FirestoreAuditRepository(FirebaseFirestore.instance);
});

final auditActivitiesProvider = StreamProvider.family<List<AuditActivity>, int>((ref, limit) {
  return ref.watch(auditRepositoryProvider).watchActivities(limit: limit);
});
