import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/society_config.dart';

final societyConfigRepositoryProvider = Provider((ref) => SocietyConfigRepository());

final societyConfigStreamProvider = StreamProvider<SocietyConfig>((ref) {
  final repo = ref.watch(societyConfigRepositoryProvider);
  return repo.getConfigStream();
});

class SocietyConfigRepository {
  final _firestore = FirebaseFirestore.instance;
  final _docRef = FirebaseFirestore.instance.collection('config').doc('society');

  Stream<SocietyConfig> getConfigStream() {
    return _docRef.snapshots().map((doc) {
      if (!doc.exists) return const SocietyConfig();
      return SocietyConfig.fromJson(doc.data()!);
    });
  }

  Future<void> updateConfig(SocietyConfig config) async {
    await _docRef.set(config.toJson(), SetOptions(merge: true));
  }
}
