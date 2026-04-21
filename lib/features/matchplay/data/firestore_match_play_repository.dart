import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/match_play_tournament.dart';
import 'match_play_repository.dart';

class FirestoreMatchPlayRepository implements MatchPlayRepository {
  final FirebaseFirestore _firestore;

  FirestoreMatchPlayRepository(this._firestore);

  CollectionReference<MatchPlayTournament> get _tournamentsRef =>
      _firestore.collection('match_play_tournaments').withConverter<MatchPlayTournament>(
        fromFirestore: (snapshot, _) {
          final data = snapshot.data()!;
          return MatchPlayTournament.fromJson({...data, 'id': snapshot.id});
        },
        toFirestore: (tournament, _) {
          final json = tournament.toJson();
          json.remove('id');
          return json;
        },
      );

  @override
  Future<void> saveTournament(MatchPlayTournament tournament) async {
    await _tournamentsRef.doc(tournament.id).set(tournament, SetOptions(merge: true));
  }

  @override
  Future<MatchPlayTournament?> getTournament(String id) async {
    final doc = await _tournamentsRef.doc(id).get();
    return doc.data();
  }

  @override
  Future<List<MatchPlayTournament>> getAllTournaments() async {
    final snapshot = await _tournamentsRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> deleteTournament(String id) async {
    await _tournamentsRef.doc(id).delete();
  }

  @override
  Stream<List<MatchPlayTournament>> watchMatchPlayTournaments() {
    return _tournamentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
