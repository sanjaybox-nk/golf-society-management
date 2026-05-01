import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/society_config.dart';
import 'package:golf_society/utils/firebase_providers.dart';

final societyConfigRepositoryProvider = Provider((ref) => SocietyConfigRepository(ref.watch(firestoreProvider)));

final societyConfigStreamProvider = StreamProvider<SocietyConfig>((ref) {
  final repo = ref.watch(societyConfigRepositoryProvider);
  return repo.getConfigStream();
});

class SocietyConfigRepository {
  final FirebaseFirestore _firestore;

  SocietyConfigRepository(this._firestore);

  DocumentReference<Map<String, dynamic>> get _docRef => _firestore.collection('config').doc('society');

  Stream<SocietyConfig> getConfigStream() {
    return _docRef.snapshots().map((doc) {
      if (!doc.exists) return const SocietyConfig();
      return SocietyConfig.fromJson(doc.data()!);
    });
  }

  Future<void> updateConfig(SocietyConfig config) async {
    await _docRef.set(config.toJson(), SetOptions(merge: true));
  }

  Future<void> forceReplaceConfig(SocietyConfig config) async {
    await _docRef.set(config.toJson(), SetOptions(merge: false));
  }

  Future<void> deleteConfig() async {
    await _docRef.delete();
  }
}
