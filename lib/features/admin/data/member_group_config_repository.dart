import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/member_group_config.dart';
import 'package:golf_society/utils/firebase_providers.dart';

final memberGroupConfigRepositoryProvider = Provider<MemberGroupConfigRepository>((ref) {
  return FirestoreMemberGroupConfigRepository(ref.watch(firestoreProvider));
});

abstract class MemberGroupConfigRepository {
  Stream<List<MemberGroupConfig>> watchConfigs();
  Future<List<MemberGroupConfig>> getConfigs();
  Future<MemberGroupConfig?> getConfig(String id);
  Future<String> addConfig(MemberGroupConfig config);
  Future<void> updateConfig(MemberGroupConfig config);
  Future<void> deleteConfig(String id);
}

class FirestoreMemberGroupConfigRepository implements MemberGroupConfigRepository {
  final FirebaseFirestore _firestore;

  FirestoreMemberGroupConfigRepository(this._firestore);

  CollectionReference<MemberGroupConfig> get _ref =>
      _firestore.collection('member_group_configs').withConverter(
        fromFirestore: (snap, _) {
          final data = Map<String, dynamic>.from(snap.data() ?? {});
          data['id'] = snap.id;
          return MemberGroupConfig.fromJson(data);
        },
        toFirestore: (c, _) {
          final json = c.toJson();
          json.remove('id');
          return json;
        },
      );

  @override
  Stream<List<MemberGroupConfig>> watchConfigs() =>
      _ref.snapshots().map((s) => s.docs.map((d) => d.data()).toList());

  @override
  Future<List<MemberGroupConfig>> getConfigs() async {
    final snap = await _ref.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  @override
  Future<MemberGroupConfig?> getConfig(String id) async {
    final doc = await _ref.doc(id).get();
    return doc.data();
  }

  @override
  Future<String> addConfig(MemberGroupConfig config) async {
    if (config.id.isEmpty) {
      final doc = await _ref.add(config);
      return doc.id;
    }
    await _ref.doc(config.id).set(config);
    return config.id;
  }

  @override
  Future<void> updateConfig(MemberGroupConfig config) =>
      _ref.doc(config.id).set(config);

  @override
  Future<void> deleteConfig(String id) => _ref.doc(id).delete();
}
