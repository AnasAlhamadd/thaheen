import 'dart:convert';
import '../../../../domain/entities/lesson_progress.dart';

/// Data model representing a user's progress for a single lesson.
///
/// Implements defensive parsing to handle missing or corrupt stored values safely.
class LessonProgressModel extends LessonProgress {
  /// Creates a [LessonProgressModel] instance.
  const LessonProgressModel({
    required super.lessonId,
    required super.position,
    required super.completed,
  });

  /// Creates a [LessonProgressModel] from JSON map with defensive fallbacks.
  factory LessonProgressModel.fromJson(Map<String, dynamic> json, {String? defaultLessonId}) {
    final lessonId = (json['lessonId'] as String?) ?? defaultLessonId ?? '';
    final positionSeconds = (json['position'] as num?)?.toInt() ?? 0;
    final completed = (json['completed'] as bool?) ?? false;

    return LessonProgressModel(
      lessonId: lessonId,
      position: Duration(seconds: positionSeconds < 0 ? 0 : positionSeconds),
      completed: completed,
    );
  }

  /// Converts this [LessonProgressModel] to a JSON-encodable map.
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'position': position.inSeconds,
      'completed': completed,
    };
  }

  /// Encodes this model to a JSON string.
  String toJsonString() => json.encode(toJson());

  /// Decodes a JSON string into a [LessonProgressModel] safely.
  factory LessonProgressModel.fromJsonString(String source, {String? defaultLessonId}) {
    try {
      final decoded = json.decode(source);
      if (decoded is Map<String, dynamic>) {
        return LessonProgressModel.fromJson(decoded, defaultLessonId: defaultLessonId);
      }
    } catch (_) {
      // In case of parsing error, return a clean default progress.
    }
    return LessonProgressModel(
      lessonId: defaultLessonId ?? '',
      position: Duration.zero,
      completed: false,
    );
  }
}
