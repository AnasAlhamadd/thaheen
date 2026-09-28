import '../../../../domain/entities/course.dart';
import 'section_model.dart';

/// Data model representing an entire course with sections and lessons.
///
/// Strictly immutable and contains only static course content.
class CourseModel extends Course {
  /// Creates a [CourseModel] instance.
  const CourseModel({
    required super.id,
    required super.title,
    super.titleEn,
    super.description,
    super.descriptionEn,
    required super.instructor,
    super.instructorEn,
    super.courseCode,
    super.semester,
    required super.thumbnail,
    required super.sections,
  });

  /// Creates a [CourseModel] from JSON with defensive fallbacks for missing/corrupted fields.
  factory CourseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CourseModel(
        id: '',
        title: '',
        titleEn: '',
        description: '',
        descriptionEn: '',
        instructor: '',
        instructorEn: '',
        courseCode: '',
        semester: '',
        thumbnail: '',
        sections: [],
      );
    }

    final rawSections = json['sections'];
    final List<SectionModel> parsedSections = [];

    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          parsedSections.add(SectionModel.fromJson(item));
        }
      }
    }

    return CourseModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      descriptionEn: (json['descriptionEn'] as String?) ?? '',
      instructor: (json['instructor'] as String?) ?? '',
      instructorEn: (json['instructorEn'] as String?) ?? '',
      courseCode: (json['courseCode'] as String?) ?? '',
      semester: (json['semester'] as String?) ?? '',
      thumbnail: (json['thumbnail'] as String?) ?? '',
      sections: parsedSections,
    );
  }

  /// Converts this [CourseModel] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'instructor': instructor,
      'instructorEn': instructorEn,
      'courseCode': courseCode,
      'semester': semester,
      'thumbnail': thumbnail,
      'sections': sections.map((s) => (s as SectionModel).toJson()).toList(),
    };
  }
}
