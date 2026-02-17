import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/golf_event.dart';
import 'events_repository.dart';

class FirestoreEventsRepository implements EventsRepository {
  final FirebaseFirestore _firestore;

  FirestoreEventsRepository(this._firestore);

  CollectionReference<GolfEvent> get _eventsRef =>
      _firestore.collection('events').withConverter<GolfEvent>(
        fromFirestore: (snapshot, _) => _mapFirestoreToEvent(snapshot),
        toFirestore: (event, _) {
          final json = event.toJson();
          json.remove('id'); // ID is the doc path
          return json;
        },
      );

  static GolfEvent _mapFirestoreToEvent(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    // Add ID to data for JSON parsing
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;

    // Apply minimal safety sanitization for critical List/Map fields 
    // to prevent Freezed/json_serializable from crashing on legacy/corrupt data.
    _sanitizeField(mutableData, 'registrations', []);
    _sanitizeField(mutableData, 'facilities', []);
    _sanitizeField(mutableData, 'notes', []);
    _sanitizeField(mutableData, 'galleryUrls', []);
    _sanitizeField(mutableData, 'results', []);
    _sanitizeField(mutableData, 'flashUpdates', []);
    _sanitizeField(mutableData, 'grouping', {});
    _sanitizeField(mutableData, 'courseConfig', {});
    _sanitizeField(mutableData, 'finalizedStats', {});

    try {
      return GolfEvent.fromJson(mutableData);
    } catch (e) {
      // Fallback for corrupted documents to prevent crashing lists
      return GolfEvent(
        id: doc.id,
        title: mutableData['title']?.toString() ?? 'Error: Invalid Data',
        seasonId: mutableData['seasonId']?.toString() ?? 'unknown',
        date: DateTime.now(),
        status: EventStatus.draft,
        description: 'Parsing error: $e',
      );
    }
  }

  static void _sanitizeField(Map<String, dynamic> data, String key, dynamic defaultValue) {
    if (data[key] == null) {
      data[key] = defaultValue;
    } else if (defaultValue is List && data[key] is! List) {
      data[key] = defaultValue;
    } else if (defaultValue is Map && data[key] is! Map) {
      data[key] = defaultValue;
    }
  }

  @override
  Stream<List<GolfEvent>> watchEvents({String? seasonId, EventStatus? status}) {
    Query<GolfEvent> query = _eventsRef;
    if (seasonId != null) {
      query = query.where('seasonId', isEqualTo: seasonId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Future<List<GolfEvent>> getEvents({String? seasonId, EventStatus? status}) async {
    Query<GolfEvent> query = _eventsRef;
    if (seasonId != null) {
      query = query.where('seasonId', isEqualTo: seasonId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<GolfEvent?> getEvent(String id) async {
    final doc = await _eventsRef.doc(id).get();
    return doc.data();
  }

  @override
  Future<String> addEvent(GolfEvent event) async {
    if (event.id.isEmpty) {
      final docRef = await _eventsRef.add(event);
      return docRef.id;
    } else {
      await _eventsRef.doc(event.id).set(event);
      return event.id;
    }
  }

  @override
  Future<void> updateEvent(GolfEvent event) async {
    await _eventsRef.doc(event.id).set(event, SetOptions(merge: true));
  }

  @override
  Future<void> updateStatus(String eventId, EventStatus status) async {
    // Note: Since we use withConverter, partial updates via .update() 
    // bypass the converter for the value passed, but we still use the typed Ref.
    await _firestore.collection('events').doc(eventId).update({'status': status.name});
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }
}
