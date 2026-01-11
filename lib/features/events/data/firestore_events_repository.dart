import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/golf_event.dart';
import 'events_repository.dart';

class FirestoreEventsRepository implements EventsRepository {
  final FirebaseFirestore _firestore;

  FirestoreEventsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  @override
  Stream<List<GolfEvent>> watchEvents() {
    return _eventsRef.orderBy('date', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // We ensure the ID from Firestore is used in the model
        final data = doc.data();
        // If 'id' is part of the data, fine, otherwise inject it?
        // Our GolfEvent freezed model has 'required String id'.
        // We should assume data contains it OR inject doc.id.
        // For robustness, let's inject doc.id if missing or mismatch.
        data['id'] = doc.id; 
        return GolfEvent.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<List<GolfEvent>> getEvents() async {
    final snapshot = await _eventsRef.orderBy('date', descending: false).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return GolfEvent.fromJson(data);
    }).toList();
  }

  @override
  Future<void> addEvent(GolfEvent event) async {
    // We let Firestore generate the ID, or use the one provided if valid?
    // Usually we add(), getting a ref, then update the ID inside? 
    // Or just set().
    // Let's use set() if ID is valid, or add() if empty.
    if (event.id.isEmpty) {
       await _eventsRef.add(event.toJson());
    } else {
       await _eventsRef.doc(event.id).set(event.toJson());
    }
  }

  @override
  Future<void> updateEvent(GolfEvent event) async {
    await _eventsRef.doc(event.id).update(event.toJson());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }
}
