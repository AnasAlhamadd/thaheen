import 'package:equatable/equatable.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';

/// Base state for Course Details.
sealed class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading begins.
final class CourseDetailsInitial extends CourseDetailsState {
  const CourseDetailsInitial();
}

/// State emitted while course details and progress are being loaded.
final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

/// State emitted when course details and progress are loaded successfully.
final class CourseDetailsLoaded extends CourseDetailsState {
  /// The specific course details.
  final Course course;

  /// All recorded lesson progress items.
  final List<LessonProgress> progressList;

  /// Flattened lesson list across all sections.
  final List<Lesson> allLessons;

  /// Course completion ratio from 0.0 to 1.0.
  final double progressRatio;

  /// Number of completed lessons in this course.
  final int completedLessonsCount;

  /// Total duration of all lessons in hours.
  final double totalHours;

  /// Lesson the student should resume, or the next unlocked incomplete lesson.
  final Lesson? activeLesson;

  /// Creates a [CourseDetailsLoaded] instance.
  const CourseDetailsLoaded({
    required this.course,
    required this.progressList,
    required this.allLessons,
    required this.progressRatio,
    required this.completedLessonsCount,
    required this.totalHours,
    required this.activeLesson,
  });

  /// Total lessons in the course.
  int get totalLessonsCount => allLessons.length;

  /// Formatted hours label with one decimal place.
  String get totalHoursLabel => totalHours.toStringAsFixed(1);

  /// Whether the syllabus has any playable content.
  bool get hasLessons => allLessons.isNotEmpty;

  @override
  List<Object?> get props => [
        course,
        progressList,
        allLessons,
        progressRatio,
        completedLessonsCount,
        totalHours,
        activeLesson,
      ];
}

/// State emitted when course details cannot be loaded.
final class CourseDetailsError extends CourseDetailsState {
  /// Localization key for the user-facing error message.
  final String messageKey;

  /// Creates a [CourseDetailsError] with [messageKey].
  const CourseDetailsError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}
