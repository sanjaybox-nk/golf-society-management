import 'package:golf_society/domain/models/audit_activity.dart';

abstract class AuditRepository {
  Stream<List<AuditActivity>> watchActivities({int limit = 20});
  Future<void> logActivity(AuditActivity activity);
}
