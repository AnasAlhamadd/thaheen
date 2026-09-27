import 'package:equatable/equatable.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';

/// Base state for the Lesson Player.
sealed class LessonPlayerState extends Equatable {
  const LessonPlayerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any loading has started.
final class LessonPlayerInitial extends LessonPlayerState {
  const LessonPlayerInitial();
}

/// Loading state while fetching course, lesson, and progress data.
final class LessonPlayerLoading extends LessonPlayerState {
  const LessonPlayerLoading();
}

/// Data is loaded and the player screen can initialize the video controller.
final class LessonPlayerReady extends LessonPlayerState {
  /// The full course (needed for next-lesson resolution).
  final Course course;

  /// The current lesson being played.
  final Lesson currentLesson;

  /// Stored resume position from persistence (clamped to valid range by the screen).
  final Duration resumePosition;

  /// Whether this lesson has been marked as completed (90% rule).
  final bool isCompleted;

  /// The next lesson in sequence if one exists, or null for the final lesson.
  final Lesson? nextLesson;

  /// IDs of all completed lessons in this course (for course plan display).
  final Set<String> completedLessonIds;

  /// Creates a [LessonPlayerReady] state.
  const LessonPlayerReady({
    required this.course,
    required this.currentLesson,
    required this.resumePosition,
    required this.isCompleted,
    this.nextLesson,
    this.completedLessonIds = const {},
  });

  /// Creates a copy of this state with optional overrides.
  LessonPlayerReady copyWith({
    Course? course,
    Lesson? currentLesson,
    Duration? resumePosition,
    bool? isCompleted,
    Lesson? nextLesson,
    bool clearNextLesson = false,
    Set<String>? completedLessonIds,
  }) {
    return LessonPlayerReady(
      course: course ?? this.course,
      currentLesson: currentLesson ?? this.currentLesson,
      resumePosition: resumePosition ?? this.resumePosition,
      isCompleted: isCompleted ?? this.isCompleted,
      nextLesson: clearNextLesson ? null : (nextLesson ?? this.nextLesson),
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  @override
  List<Object?> get props =>
      [course, currentLesson, resumePosition, isCompleted, nextLesson, completedLessonIds];
}

/// Error state with a user-facing Arabic message.
final class LessonPlayerError extends LessonPlayerState {
  /// The Arabic error message.
  final String message;

  /// Creates a [LessonPlayerError].
  const LessonPlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
