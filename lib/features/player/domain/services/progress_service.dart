import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../domain/entities/lesson_status.dart';

/// Pure Dart domain service managing business logic for lesson unlocking and progress.
///
/// Contains zero Flutter UI dependencies.
class ProgressService {
  /// Completion threshold required by Section 3.3 and 14.1 of the specification (90%).
  static const double completionThreshold = 0.90;

  /// Checks if a lesson should be marked as completed based on playback [position] and total [duration].
  ///
  /// Rule: completed if `position >= duration * 0.90`.
  /// Always returns false if [duration] is zero or negative.
  bool shouldCompleteLesson(Duration position, Duration duration) {
    if (duration <= Duration.zero) return false;
    return position >= duration * completionThreshold;
  }

  /// Backward-compatible alias for existing call-sites.
  bool isCompleted({
    required Duration position,
    required Duration duration,
  }) {
    return shouldCompleteLesson(position, duration);
  }

  /// Checks if a lesson is unlocked within a [course].
  ///
  /// Sequential unlock rule:
  /// - Flattens the course sections into a sequential lesson list.
  /// - First lesson is always unlocked.
  /// - Lesson N is unlocked only if Lesson N-1 is completed.
  /// - Returns false if [lessonId] is not in the course.
  bool isLessonUnlocked(
    Course course,
    String lessonId,
    List<LessonProgress> progressList,
  ) {
    final lessons = course.sections.expand((s) => s.lessons).toList();
    final index = lessons.indexWhere((l) => l.id == lessonId);
    if (index == -1) return false;
    if (index == 0) return true;

    final completedLessonIds = progressList
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toSet();

    return completedLessonIds.contains(lessons[index - 1].id);
  }

  /// Index-based unlock checker for convenience.
  bool isUnlocked({
    required List<Lesson> lessons,
    required int index,
    required Set<String> completedLessonIds,
  }) {
    if (index == 0) return true;
    if (index < 0 || index >= lessons.length) return false;
    return completedLessonIds.contains(lessons[index - 1].id);
  }

  /// Calculates the progress of a course (0.0 to 1.0).
  ///
  /// Rule: `completedLessons / totalLessons`.
  /// Returns 0.0 if the course has 0 lessons (guards against division by zero).
  double calculateCourseProgress(
    Course course,
    List<LessonProgress> progressList,
  ) {
    final lessons = course.sections.expand((s) => s.lessons).toList();
    if (lessons.isEmpty) return 0.0;

    final completedLessonIds = progressList
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toSet();

    final completedCount = lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    return completedCount / lessons.length;
  }

  /// Calculates the progress of a course using named parameters.
  double calculateProgress({
    required List<Lesson> lessons,
    required Set<String> completedLessonIds,
  }) {
    if (lessons.isEmpty) return 0.0;

    final completedCount = lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    return completedCount / lessons.length;
  }


  /// Resolves the learning status for a specific lesson:
  /// - [LessonStatus.completed] if completed == true.
  /// - [LessonStatus.inProgress] if not completed, but position > 0.
  /// - [LessonStatus.notStarted] otherwise.
  LessonStatus getLessonStatus(
    String lessonId,
    List<LessonProgress> progressList,
  ) {
    final progress = progressList.cast<LessonProgress?>().firstWhere(
          (p) => p?.lessonId == lessonId,
          orElse: () => null,
        );

    if (progress == null) {
      return LessonStatus.notStarted;
    }

    if (progress.completed) {
      return LessonStatus.completed;
    }

    if (progress.position > Duration.zero) {
      return LessonStatus.inProgress;
    }

    return LessonStatus.notStarted;
  }

  /// Returns the next lesson in the course sequence after [currentLessonId],
  /// or null if [currentLessonId] is the final lesson.
  Lesson? getNextLesson(Course course, String currentLessonId) {
    final lessons = course.sections.expand((s) => s.lessons).toList();
    final currentIndex = lessons.indexWhere((l) => l.id == currentLessonId);
    if (currentIndex == -1 || currentIndex >= lessons.length - 1) {
      return null;
    }
    return lessons[currentIndex + 1];
  }

  /// Finds the first in-progress lesson in the course (completed == false && position > 0),
  /// or null if none are currently in progress.
  Lesson? findContinueWatching(
    Course course,
    List<LessonProgress> progressList,
  ) {
    final lessons = course.sections.expand((s) => s.lessons).toList();
    final progressMap = {for (final p in progressList) p.lessonId: p};

    for (final lesson in lessons) {
      final progress = progressMap[lesson.id];
      if (progress != null && !progress.completed && progress.position > Duration.zero) {
        return lesson;
      }
    }

    return null;
  }

  /// Finds the first incomplete lesson across all courses.
  /// 
  /// Returns a record containing:
  /// - The course containing the incomplete lesson
  /// - The lesson to continue
  /// - The progress data for that lesson
  /// 
  /// Returns null if no incomplete lesson is found.
  /// 
  /// Priority:
  /// 1. First looks for lessons with progress (position > 0) that are not completed
  /// 2. If none found, returns the first unlocked lesson with no progress
  ({Course course, Lesson lesson, LessonProgress? progress})? findNextIncompleteLesson(
    List<Course> courses,
    List<LessonProgress> progressList,
  ) {
    final progressMap = {for (final p in progressList) p.lessonId: p};
    final completedLessonIds = progressList
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toSet();

    // First pass: Look for in-progress lessons (watched but not completed)
    for (final course in courses) {
      final lessons = course.sections.expand((s) => s.lessons).toList();
      
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        final progress = progressMap[lesson.id];
        
        // Check if this lesson is in progress (has position > 0 but not completed)
        if (progress != null && 
            !progress.completed && 
            progress.position > Duration.zero) {
          return (course: course, lesson: lesson, progress: progress);
        }
      }
    }

    // Second pass: Look for the first unlocked lesson with no progress
    for (final course in courses) {
      final lessons = course.sections.expand((s) => s.lessons).toList();
      
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        final progress = progressMap[lesson.id];
        
        // Check if this lesson is unlocked and not started
        final isUnlocked = i == 0 || completedLessonIds.contains(lessons[i - 1].id);
        final hasNoProgress = progress == null || 
            (progress.position == Duration.zero && !progress.completed);
        
        if (isUnlocked && hasNoProgress) {
          return (course: course, lesson: lesson, progress: null);
        }
      }
    }

    return null;
  }
}
