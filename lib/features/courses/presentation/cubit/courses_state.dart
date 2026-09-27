import 'package:equatable/equatable.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson_progress.dart';

/// Base state for Courses Cubit.
sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before courses loading starts.
final class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

/// State emitted while loading courses and learner progress.
final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

/// State emitted when courses and learner progress have been successfully loaded.
final class CoursesLoaded extends CoursesState {
  /// The complete list of available courses (never filtered).
  final List<Course> courses;

  /// The list of recorded progress items for all lessons across courses.
  final List<LessonProgress> progressList;

  /// Optional specific last-watched lesson ID, if tracked.
  final String? lastWatchedLessonId;

  /// Current search query (empty if no search active).
  final String searchQuery;

  /// Filtered courses based on search query (same as courses when no search).
  final List<Course> filteredCourses;

  /// Whether a search filter operation is in progress (shows loading shimmer).
  final bool isSearching;

  /// Creates a [CoursesLoaded] state.
  const CoursesLoaded({
    required this.courses,
    required this.progressList,
    this.lastWatchedLessonId,
    this.searchQuery = '',
    List<Course>? filteredCourses,
    this.isSearching = false,
  }) : filteredCourses = filteredCourses ?? courses;

  /// Map of lessonId to LessonProgress for convenient lookups.
  Map<String, LessonProgress> get progressMap => {
        for (final p in progressList) p.lessonId: p,
      };

  /// Creates a copy with updated fields.
  CoursesLoaded copyWith({
    List<Course>? courses,
    List<LessonProgress>? progressList,
    String? lastWatchedLessonId,
    String? searchQuery,
    List<Course>? filteredCourses,
    bool? isSearching,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      progressList: progressList ?? this.progressList,
      lastWatchedLessonId: lastWatchedLessonId ?? this.lastWatchedLessonId,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        progressList,
        lastWatchedLessonId,
        searchQuery,
        filteredCourses,
        isSearching,
      ];
}

/// State emitted when an error occurs while fetching courses or progress.
final class CoursesError extends CoursesState {
  /// The localized user-facing error message.
  final String message;

  /// Creates a [CoursesError] state with [message].
  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
