import '../../../../domain/entities/section.dart';
import 'lesson_model.dart';

/// Data model representing a course section containing lessons.
///
/// Strictly immutable and contains only static course content.
class SectionModel extends Section {
  /// Creates a [SectionModel] instance.
  const SectionModel({
    required super.id,
    required super.title,
    super.titleEn,
    required super.lessons,
  });

  /// Creates a [SectionModel] from JSON with defensive fallbacks for missing/corrupted fields.
  factory SectionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SectionModel(
        id: '',
        title: '',
        titleEn: '',
        lessons: [],
      );
    }

    final rawLessons = json['lessons'];
    final List<LessonModel> parsedLessons = [];

    if (rawLessons is List) {
      for (final item in rawLessons) {
        if (item is Map<String, dynamic>) {
          parsedLessons.add(LessonModel.fromJson(item));
        }
      }
    }

    return SectionModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? '',
      lessons: parsedLessons,
    );
  }

  /// Converts this [SectionModel] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'lessons': lessons.map((l) => (l as LessonModel).toJson()).toList(),
    };
  }
}
