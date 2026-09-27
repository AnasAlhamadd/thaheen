import '../../../../domain/entities/lesson_progress.dart';

/// Contract for accessing and updating learner progress.
abstract class ProgressRepository {
  /// Retrieves progress for a specific lesson by [lessonId].
  Future<LessonProgress?> getLessonProgress(String lessonId);

  /// Retrieves all recorded lesson progress keyed by lesson ID.
  Future<Map<String, LessonProgress>> getAllProgress();

  /// Saves the playback [position] for a lesson.
  Future<void> savePosition(String lessonId, Duration position);

  /// Marks a lesson as completed.
  Future<void> markCompleted(String lessonId);

  /// Retrieves the ID of the last watched lesson, if any.
  Future<String?> getLastWatchedLessonId();

  /// Updates the last watched lesson ID.
  Future<void> setLastWatchedLessonId(String lessonId);
}
