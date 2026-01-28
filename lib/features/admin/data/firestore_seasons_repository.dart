import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/season.dart';
import 'seasons_repository.dart';

class FirestoreSeasonsRepository implements SeasonsRepository {
  final FirebaseFirestore _firestore;

  FirestoreSeasonsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _seasonsRef =>
      _firestore.collection('seasons');

  @override
  Stream<List<Season>> watchSeasons() {
    return _seasonsRef.orderBy('year', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Season.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<List<Season>> getSeasons() async {
    final snapshot = await _seasonsRef.orderBy('year', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Season.fromJson(data);
    }).toList();
  }

  @override
  Future<void> addSeason(Season season) async {
    if (season.id.isEmpty) {
      await _seasonsRef.add(season.toJson());
    } else {
      await _seasonsRef.doc(season.id).set(season.toJson());
    }
  }

  @override
  Future<void> updateSeason(Season season) async {
    await _seasonsRef.doc(season.id).update(season.toJson());
  }

  @override
  Future<void> deleteSeason(String seasonId) async {
    await _seasonsRef.doc(seasonId).delete();
  }

  @override
  Future<void> closeSeason(String seasonId, Map<String, dynamic> agmData) async {
    await _seasonsRef.doc(seasonId).update({
      'status': SeasonStatus.closed.name,
      'agmData': agmData,
      'isCurrent': false, // Ensure archived season is not current
    });
  }
  @override
  Future<void> setCurrentSeason(String seasonId) async {
    // 1. Unset current from all
    final currentOnes = await _seasonsRef.where('isCurrent', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (var doc in currentOnes.docs) {
      batch.update(doc.reference, {'isCurrent': false});
    }
    
    // 2. Set new current
    batch.update(_seasonsRef.doc(seasonId), {'isCurrent': true});
    await batch.commit();
  }
}
