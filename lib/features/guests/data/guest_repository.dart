import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/guest_profile.dart';
import 'package:golf_society/utils/firebase_providers.dart';
import 'package:uuid/uuid.dart';

class GuestRepository {
  final FirebaseFirestore _firestore;
  GuestRepository(this._firestore);

  CollectionReference<GuestProfile> get _ref =>
      _firestore.collection('guests').withConverter<GuestProfile>(
        fromFirestore: (snap, _) => GuestProfile.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (guest, _) {
          final json = guest.toJson();
          json.remove('id');
          return json;
        },
      );

  Stream<List<GuestProfile>> watchAll() =>
      _ref.orderBy('lastPlayedAt', descending: true).snapshots().map(
            (s) => s.docs.map((d) => d.data()).toList(),
          );

  Future<GuestProfile?> findByEmail(String email) async {
    final snap = await _ref
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.data();
  }

  /// Looks up guest by email. Creates a new record if not found.
  /// Updates name/handicap and lastPlayedAt/eventCount on every play.
  Future<GuestProfile> findOrCreate({
    required String email,
    required String name,
    required double handicap,
  }) async {
    final normalisedEmail = email.toLowerCase().trim();
    final existing = await findByEmail(normalisedEmail);

    if (existing != null) {
      final updated = existing.copyWith(
        name: name,
        handicap: handicap,
        lastPlayedAt: DateTime.now(),
        eventCount: existing.eventCount + 1,
      );
      final json = updated.toJson()..remove('id');
      await _ref.doc(existing.id).update(json);
      return updated;
    }

    final id = const Uuid().v4();
    final now = DateTime.now();
    final guest = GuestProfile(
      id: id,
      name: name,
      email: normalisedEmail,
      handicap: handicap,
      firstPlayedAt: now,
      lastPlayedAt: now,
      eventCount: 1,
    );
    await _ref.doc(id).set(guest);
    return guest;
  }

  Future<void> update(GuestProfile guest) async {
    final json = guest.toJson()..remove('id');
    await _ref.doc(guest.id).update(json);
  }
}

final guestRepositoryProvider = Provider<GuestRepository>(
  (ref) => GuestRepository(ref.watch(firestoreProvider)),
);
