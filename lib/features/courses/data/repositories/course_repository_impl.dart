import '../../../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/local_course_data_source.dart';

/// Implementation of [CourseRepository] fetching data via [LocalCourseDataSource].
class CourseRepositoryImpl implements CourseRepository {
  final LocalCourseDataSource localDataSource;

  /// Creates a [CourseRepositoryImpl] with required [localDataSource].
  const CourseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Course>> getCourses() async {
    return await localDataSource.getCourses();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    final courses = await localDataSource.getCourses();
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }
}
