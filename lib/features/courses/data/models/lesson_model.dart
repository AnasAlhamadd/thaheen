import '../../../../domain/entities/lesson.dart';

/// Data model representing a static lesson from course data.
///
/// Strictly immutable and contains no learner progress state.
class LessonModel extends Lesson {
  /// Creates a [LessonModel] instance.
  const LessonModel({
    required super.id,
    required super.title,
    super.titleEn,
    required super.durationSec,
    required super.video,
  });

  /// Creates a [LessonModel] from JSON with defensive fallbacks for missing/corrupted fields.
  factory LessonModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LessonModel(
        id: '',
        title: '',
        titleEn: '',
        durationSec: 0,
        video: '',
      );
    }

    return LessonModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? '',
      durationSec: (json['durationSec'] as num?)?.toInt() ?? 0,
      video: (json['video'] as String?) ?? '',
    );
  }

  /// Converts this [LessonModel] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'durationSec': durationSec,
      'video': video,
    };
  }
}
