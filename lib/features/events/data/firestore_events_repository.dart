import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/golf_event.dart';
import 'events_repository.dart';

class FirestoreEventsRepository implements EventsRepository {
  final FirebaseFirestore _firestore;

  FirestoreEventsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  @override
  Stream<List<GolfEvent>> watchEvents({String? seasonId, EventStatus? status}) {
    Query<Map<String, dynamic>> query = _eventsRef;
    if (seasonId != null) {
      query = query.where('seasonId', isEqualTo: seasonId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _mapEvent(doc)).toList();
    });
  }

  @override
  Future<List<GolfEvent>> getEvents({String? seasonId, EventStatus? status}) async {
    Query<Map<String, dynamic>> query = _eventsRef;
    if (seasonId != null) {
      query = query.where('seasonId', isEqualTo: seasonId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _mapEvent(doc)).toList();
  }

  @override
  Future<GolfEvent?> getEvent(String id) async {
    try {
      final doc = await _eventsRef.doc(id).get();
      if (!doc.exists) return null;
      return _mapEvent(doc);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting event $id: $e');
      return null;
    }
  }

  GolfEvent _mapEvent(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    data['id'] = doc.id;

    // Sanitize data (robust list reading)
    // Firestore sometimes initializes empty arrays as maps or we might have legacy data
    const listFields = [
      'registrations',
      'facilities',
      'notes',
      'galleryUrls',
      'results',
      'flashUpdates'
    ];
    for (final field in listFields) {
      final val = data[field];
      if (val != null && val is! List) {
        // Force to empty list if not a list (handles Maps, legacy data, etc.)
        data[field] = [];
      }
    }

    // 1. Sanitize Top-level required strings
    if (data['title'] == null) data['title'] = 'Untitled Event';
    if (data['seasonId'] == null) data['seasonId'] = 'unknown_season';

    // 2. Sanitize Simple String Lists (remove nulls)
    for (final field in ['facilities', 'galleryUrls', 'flashUpdates']) {
      if (data[field] is List) {
        data[field] = (data[field] as List).whereType<String>().toList();
      }
    }

    // 3. Sanitize Boolean Flags (default values)
    if (data['hasBreakfast'] == null) data['hasBreakfast'] = false;
    if (data['hasLunch'] == null) data['hasLunch'] = false;
    if (data['hasDinner'] == null) data['hasDinner'] = true;
    if (data['showRegistrationButton'] == null) data['showRegistrationButton'] = true;
    if (data['isGroupingPublished'] == null) data['isGroupingPublished'] = false;

    // 3. Deep sanitize registrations
    if (data['registrations'] != null && data['registrations'] is List) {
      final List rawRegs = data['registrations'];
      final List<Map<String, dynamic>> safeRegs = [];
      
      for (var item in rawRegs) {
        if (item is Map) {
          final Map<String, dynamic> regMap = Map<String, dynamic>.from(item);
          
          // Strings
          if (regMap['memberId'] == null) regMap['memberId'] = 'unknown_id';
          if (regMap['memberName'] == null) regMap['memberName'] = 'Unknown Member';
          
          // Bools (default to false/true based on model defaults)
          if (regMap['isGuest'] == null) regMap['isGuest'] = false;
          if (regMap['attendingGolf'] == null) regMap['attendingGolf'] = true;
          if (regMap['attendingDinner'] == null) regMap['attendingDinner'] = false;
          if (regMap['hasPaid'] == null) regMap['hasPaid'] = false;
          if (regMap['needsBuggy'] == null) regMap['needsBuggy'] = false;
          if (regMap['guestAttendingDinner'] == null) regMap['guestAttendingDinner'] = false;
          
          // Doubles
          if (regMap['cost'] == null) regMap['cost'] = 0.0;

          safeRegs.add(regMap);
        }
      }
      data['registrations'] = safeRegs;
    }

    // 4. Final Safety Net for List Fields
    // Explicitly force all list fields to be Lists, no matter what
    if (data['registrations'] is! List) data['registrations'] = [];
    if (data['facilities'] is! List) data['facilities'] = [];
    if (data['notes'] is! List) data['notes'] = [];
    if (data['galleryUrls'] is! List) data['galleryUrls'] = [];
    if (data['results'] is! List) data['results'] = [];
    if (data['flashUpdates'] is! List) data['flashUpdates'] = [];

    try {
      return GolfEvent.fromJson(data);
    } catch (e) {
      // Log the error for debugging
      // ignore: avoid_print
      print('Error parsing event ${doc.id}: $e');
      // Return a safe "Error" event instead of crashing the app
      // This allows the list to load even if one event is corrupted
      return GolfEvent(
        id: doc.id,
        title: data['title']?.toString() ?? 'Error Loading Event',
        seasonId: data['seasonId']?.toString() ?? '',
        date: DateTime.now(),
        // Pass empty lists to ensure it doesn't crash further up
        registrations: [],
        facilities: [],
        notes: [],
        galleryUrls: [],
        results: [],
        flashUpdates: [],
        status: EventStatus.draft,
        description: 'Data Error: $e',
      );
    }
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
