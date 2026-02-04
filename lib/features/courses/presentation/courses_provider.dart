import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/course_repository.dart';
import '../data/firestore_course_repository.dart';
import '../../../models/course.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return FirestoreCourseRepository(FirebaseFirestore.instance);
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return ref.watch(courseRepositoryProvider).watchCourses();
});

final courseSearchProvider = FutureProvider.family<List<Course>, String>((ref, query) {
  return ref.watch(courseRepositoryProvider).searchCourses(query);
});

final courseDetailProvider = FutureProvider.family<Course?, String>((ref, id) {
  return ref.watch(courseRepositoryProvider).getCourse(id);
});
