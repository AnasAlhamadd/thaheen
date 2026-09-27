import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course_model.dart';

/// Data source interface for fetching bundled local course data.
abstract class LocalCourseDataSource {
  /// Loads courses from the bundled JSON asset.
  Future<List<CourseModel>> getCourses();
}

/// Implementation of [LocalCourseDataSource] that loads courses from rootBundle.
class LocalCourseDataSourceImpl implements LocalCourseDataSource {
  static const String _coursesAssetPath = 'assets/data/courses.json';

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final String jsonString = await rootBundle.loadString(_coursesAssetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final rawCourses = decoded['courses'];
      if (rawCourses is! List) {
        return [];
      }

      final List<CourseModel> courses = [];
      for (final item in rawCourses) {
        if (item is Map<String, dynamic>) {
          courses.add(CourseModel.fromJson(item));
        }
      }
      return courses;
    } on FormatException {
      // Malformed JSON handled defensively
      return [];
    } catch (_) {
      // Missing file or any bundle read error handled defensively
      return [];
    }
  }
}
