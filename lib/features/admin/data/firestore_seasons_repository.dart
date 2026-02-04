import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/season.dart';
import '../../../models/leaderboard_standing.dart';
import 'seasons_repository.dart';

class FirestoreSeasonsRepository implements SeasonsRepository {
  final FirebaseFirestore _firestore;

  FirestoreSeasonsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _seasonsRef =>
      _firestore.collection('seasons');

  @override
  Stream<List<Season>> watchSeasons() {
    return _seasonsRef
        .orderBy('year', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapSeason(doc)).toList();
    });
  }

  @override
  Future<List<Season>> getSeasons() async {
    final snapshot = await _seasonsRef.orderBy('year', descending: true).get();
    return snapshot.docs.map((doc) => _mapSeason(doc)).toList();
  }

  Season _mapSeason(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['id'] = doc.id;

    // Robust Sanitization
    if (data['name'] == null) data['name'] = 'Season ${data['year'] ?? ''}';
    if (data['year'] == null) data['year'] = DateTime.now().year;
    
    // Core Dates - Fallback to current year boundaries if missing
    final year = data['year'] as int;
    if (data['startDate'] == null) {
      data['startDate'] = Timestamp.fromDate(DateTime(year, 1, 1));
    }
    if (data['endDate'] == null) {
      data['endDate'] = Timestamp.fromDate(DateTime(year, 12, 31));
    }

    // Default Enums and Flags
    if (data['status'] == null) data['status'] = SeasonStatus.active.name;
    if (data['isCurrent'] == null) data['isCurrent'] = false;


    try {
      return Season.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing season ${doc.id}: $e');
      // Return a safe fallback to prevent breaking the entire list
      return Season(
        id: doc.id,
        name: data['name']?.toString() ?? 'Error Loading Season',
        year: year,
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        status: SeasonStatus.active,
      );
    }
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
    final currentOnes =
        await _seasonsRef.where('isCurrent', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (var doc in currentOnes.docs) {
      batch.update(doc.reference, {'isCurrent': false});
    }

    // 2. Set new current
    batch.update(_seasonsRef.doc(seasonId), {'isCurrent': true});
    await batch.commit();
  }

  @override
  Future<void> updateLeaderboardStandings(String seasonId, String leaderboardId, List<LeaderboardStanding> standings) async {
    final batch = _firestore.batch();
    final collection = _seasonsRef.doc(seasonId)
        .collection('leaderboards')
        .doc(leaderboardId)
        .collection('standings');

    // Ideally, we might want to delete old standings first or use set efficiently.
    // simpler approach: Overwrite specific documents.
    // If we need to clear removed members, we might need a separate delete step.
    // For now, assume simple overwrite/update.
    
    for (var s in standings) {
      batch.set(collection.doc(s.memberId), s.toJson());
    }
    
    await batch.commit();
  }

  @override
  Stream<List<LeaderboardStanding>> watchLeaderboardStandings(String seasonId, String leaderboardId) {
    return _seasonsRef.doc(seasonId)
        .collection('leaderboards')
        .doc(leaderboardId)
        .collection('standings')
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => LeaderboardStanding.fromJson(doc.data())).toList();
        });
  }
}
