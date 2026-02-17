import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/course.dart';
import 'course_repository.dart';

class FirestoreCourseRepository implements CourseRepository {
  final FirebaseFirestore _firestore;

  FirestoreCourseRepository(this._firestore);

  CollectionReference<Course> get _coursesRef =>
      _firestore.collection('courses').withConverter<Course>(
        fromFirestore: (snapshot, _) => _mapFirestoreToCourse(snapshot),
        toFirestore: (course, _) {
          final json = course.toMap();
          json.remove('id');
          return json;
        },
      );

  static Course _mapFirestoreToCourse(DocumentSnapshot<Map<String, dynamic>> doc) {
    // Note: Course model uses fromFirestore which already takes a DocumentSnapshot
    // To stay consistent with my withConverter refactor pattern:
    return Course.fromFirestore(doc);
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    if (query.isEmpty) return [];
    
    // Simple prefix search using Firestore query
    final snapshot = await _coursesRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Course?> getCourse(String id) async {
    final doc = await _coursesRef.doc(id).get();
    return doc.data();
  }

  @override
  Future<String> saveCourse(Course course) async {
    if (course.id.isEmpty) {
      final ref = await _coursesRef.add(course);
      return ref.id;
    } else {
      await _coursesRef.doc(course.id).set(course, SetOptions(merge: true));
      return course.id;
    }
  }

  @override
  Stream<List<Course>> watchCourses() {
    return _coursesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
