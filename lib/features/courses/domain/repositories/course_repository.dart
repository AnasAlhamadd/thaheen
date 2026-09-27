import '../../../../domain/entities/course.dart';

/// Contract for accessing course information.
abstract class CourseRepository {
  /// Retrieves all available courses.
  Future<List<Course>> getCourses();

  /// Retrieves a specific course by its unique [id].
  Future<Course?> getCourseById(String id);
}
