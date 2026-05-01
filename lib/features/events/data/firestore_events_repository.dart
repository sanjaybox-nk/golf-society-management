import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golf_society/domain/models/golf_event.dart';
import 'events_repository.dart';

class FirestoreEventsRepository implements EventsRepository {
  final FirebaseFirestore _firestore;

  FirestoreEventsRepository(this._firestore);

  CollectionReference<GolfEvent> get _eventsRef =>
      _firestore.collection('events').withConverter<GolfEvent>(
        fromFirestore: (snapshot, _) => _mapFirestoreToEvent(snapshot),
        toFirestore: (event, _) {
          final json = event.toJson();
          json.remove('id'); 
          return json;
        },
      );

  CollectionReference<EventExpense> get _globalExpensesRef =>
      _firestore.collection('global_expenses').withConverter<EventExpense>(
        fromFirestore: (snapshot, _) {
          final data = snapshot.data() ?? {};
          return EventExpense.fromJson({...data, 'id': snapshot.id});
        },
        toFirestore: (expense, _) {
          final json = expense.toJson();
          json.remove('id');
          return json;
        },
      );

  static GolfEvent _mapFirestoreToEvent(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data);
    mutableData['id'] = doc.id;

    // Hardened Sanitization for critical fields
    _sanitize(mutableData, [
      ('registrations', []),
      ('facilities', []),
      ('notes', []),
      ('galleryUrls', []),
      ('results', []),
      ('flashUpdates', []),
      ('grouping', {}),
      ('courseConfig', {}),
      ('finalizedStats', {}),
    ]);

    try {
      return GolfEvent.fromJson(mutableData);
    } catch (e) {
      return GolfEvent(
        id: doc.id,
        title: mutableData['title']?.toString() ?? 'Parse Error',
        seasonId: mutableData['seasonId']?.toString() ?? 'unknown',
        date: DateTime.now(),
        status: EventStatus.draft,
        description: 'Recovery mode: $e',
      );
    }
  }

  static void _sanitize(Map<String, dynamic> data, List<(String, dynamic)> fields) {
    for (final field in fields) {
      final key = field.$1;
      final defaultValue = field.$2;
      if (data[key] == null || (defaultValue is List && data[key] is! List) || (defaultValue is Map && data[key] is! Map)) {
        data[key] = defaultValue;
      }
    }
  }

  @override
  Stream<List<GolfEvent>> watchEvents({String? seasonId, EventStatus? status}) {
    Query<GolfEvent> query = _eventsRef;
    if (seasonId != null) query = query.where('seasonId', isEqualTo: seasonId);
    if (status != null) query = query.where('status', isEqualTo: status.name);
    
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<GolfEvent?> watchEvent(String id) => _eventsRef.doc(id).snapshots().map((s) => s.data());

  @override
  Future<List<GolfEvent>> getEvents({String? seasonId, EventStatus? status}) async {
    Query<GolfEvent> query = _eventsRef;
    if (seasonId != null) query = query.where('seasonId', isEqualTo: seasonId);
    if (status != null) query = query.where('status', isEqualTo: status.name);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<GolfEvent?> getEvent(String id) async => (await _eventsRef.doc(id).get()).data();

  @override
  Future<String> addEvent(GolfEvent event) async {
    if (event.id.isEmpty) {
      return (await _eventsRef.add(event)).id;
    } else {
      await _eventsRef.doc(event.id).set(event);
      return event.id;
    }
  }

  @override
  Future<void> updateEvent(GolfEvent event) => _eventsRef.doc(event.id).set(event, SetOptions(merge: true));

  @override
  Future<void> updateStatus(String eventId, EventStatus status) => 
      _firestore.collection('events').doc(eventId).update({'status': status.name});

  @override
  Future<void> deleteEvent(String eventId) => _eventsRef.doc(eventId).delete();

  @override
  Future<void> saveGlobalExpense(EventExpense expense) => _globalExpensesRef.doc(expense.id).set(expense);

  @override
  Future<List<EventExpense>> getGlobalExpenses() async {
    final snapshot = await _globalExpensesRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<EventExpense>> watchGlobalExpenses() {
    return _globalExpensesRef.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
