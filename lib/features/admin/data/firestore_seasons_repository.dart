import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/season.dart';
import '../../../models/leaderboard_standing.dart';
import 'seasons_repository.dart';

class FirestoreSeasonsRepository implements SeasonsRepository {
  final FirebaseFirestore _firestore;

  FirestoreSeasonsRepository(this._firestore);

  CollectionReference<Season> get _seasonsRef =>
      _firestore.collection('seasons').withConverter<Season>(
        fromFirestore: (snapshot, _) => _mapFirestoreToSeason(snapshot),
        toFirestore: (season, _) {
          final json = season.toJson();
          json.remove('id');
          return json;
        },
      );

  static Season _mapFirestoreToSeason(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;

    // Standard Sanitization - Moving logic from old _mapSeason
    if (mutableData['name'] == null) {
      mutableData['name'] = 'Season ${mutableData['year'] ?? ''}';
    }
    
    final year = mutableData['year'] ?? DateTime.now().year;
    mutableData['year'] = year;

    if (mutableData['startDate'] == null) {
      mutableData['startDate'] = Timestamp.fromDate(DateTime(year as int, 1, 1));
    }
    if (mutableData['endDate'] == null) {
      mutableData['endDate'] = Timestamp.fromDate(DateTime(year as int, 12, 31));
    }
    if (mutableData['status'] == null) {
      mutableData['status'] = SeasonStatus.active.name;
    }
    if (mutableData['isCurrent'] == null) {
      mutableData['isCurrent'] = false;
    }

    try {
      return Season.fromJson(mutableData);
    } catch (e) {
      // Return a safe fallback to prevent breaking the entire list
      return Season(
        id: doc.id,
        name: mutableData['name']?.toString() ?? 'Error Loading Season',
        year: year is int ? year : DateTime.now().year,
        startDate: (mutableData['startDate'] as Timestamp).toDate(),
        endDate: (mutableData['endDate'] as Timestamp).toDate(),
        status: SeasonStatus.active,
      );
    }
  }

  @override
  Stream<List<Season>> watchSeasons() {
    return _seasonsRef
        .orderBy('year', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Future<List<Season>> getSeasons() async {
    final snapshot = await _seasonsRef.orderBy('year', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> addSeason(Season season) async {
    if (season.id.isEmpty) {
      await _seasonsRef.add(season);
    } else {
      await _seasonsRef.doc(season.id).set(season);
    }
  }

  @override
  Future<void> updateSeason(Season season) async {
    await _seasonsRef.doc(season.id).set(season, SetOptions(merge: true));
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
      'isCurrent': false,
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
    final collection = _firestore.collection('seasons')
        .doc(seasonId)
        .collection('leaderboards')
        .doc(leaderboardId)
        .collection('standings')
        .withConverter<LeaderboardStanding>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data() ?? {};
            return LeaderboardStanding.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (s, _) => s.toJson()..remove('id'),
        );

    for (var s in standings) {
      batch.set(collection.doc(s.memberId), s);
    }
    
    await batch.commit();
  }

  @override
  Stream<List<LeaderboardStanding>> watchLeaderboardStandings(String seasonId, String leaderboardId) {
    return _firestore.collection('seasons')
        .doc(seasonId)
        .collection('leaderboards')
        .doc(leaderboardId)
        .collection('standings')
        .withConverter<LeaderboardStanding>(
          fromFirestore: (snapshot, _) {
             final data = snapshot.data() ?? {};
             return LeaderboardStanding.fromJson({...data, 'id': snapshot.id});
          },
          toFirestore: (s, _) => s.toJson()..remove('id'),
        )
        .orderBy('points', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }
}
