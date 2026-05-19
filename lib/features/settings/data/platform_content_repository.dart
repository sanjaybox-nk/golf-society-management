import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/platform_content.dart';
import 'package:golf_society/utils/firebase_providers.dart';

final platformContentRepositoryProvider = Provider(
  (ref) => PlatformContentRepository(ref.watch(firestoreProvider)),
);

final platformContentProvider = StreamProvider<PlatformContent>((ref) {
  return ref.watch(platformContentRepositoryProvider).getStream();
});

class PlatformContentRepository {
  final FirebaseFirestore _firestore;

  PlatformContentRepository(this._firestore);

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection('config').doc('platform_content');

  Stream<PlatformContent> getStream() {
    return _docRef.snapshots().map((doc) {
      if (!doc.exists) return const PlatformContent();
      return PlatformContent.fromJson(doc.data()!);
    });
  }

  Future<void> update(PlatformContent content) async {
    await _docRef.set(content.toJson(), SetOptions(merge: true));
  }
}
