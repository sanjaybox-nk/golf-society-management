import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/course.dart';
import 'course_repository.dart';

class FirestoreCourseRepository implements CourseRepository {
  final FirebaseFirestore _firestore;

  FirestoreCourseRepository(this._firestore);

  CollectionReference get _courses => _firestore.collection('courses');

  @override
  Future<List<Course>> searchCourses(String query) async {
    if (query.isEmpty) return [];
    
    // Simple prefix search using Firestore query
    final snapshot = await _courses
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
  }

  @override
  Future<Course?> getCourse(String id) async {
    final doc = await _courses.doc(id).get();
    if (!doc.exists) return null;
    return Course.fromFirestore(doc);
  }

  @override
  Future<String> saveCourse(Course course) async {
    final data = course.toMap();
    if (course.id.isEmpty) {
      final ref = await _courses.add(data);
      return ref.id;
    } else {
      await _courses.doc(course.id).set(data);
      return course.id;
    }
  }

  @override
  Stream<List<Course>> watchCourses() {
    return _courses.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    });
  }
}
