import '../../../models/course.dart';

abstract class CourseRepository {
  Future<List<Course>> searchCourses(String query);
  Future<Course?> getCourse(String id);
  Future<String> saveCourse(Course course);
  Stream<List<Course>> watchCourses();
}
