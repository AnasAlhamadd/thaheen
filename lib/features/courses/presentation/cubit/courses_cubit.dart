import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/course_repository.dart';
import '../../../player/domain/repositories/progress_repository.dart';
import 'courses_state.dart';

/// Cubit managing state for the Courses screen.
class CoursesCubit extends Cubit<CoursesState> {
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  /// Creates a [CoursesCubit] with required repositories.
  CoursesCubit({
    required this.courseRepository,
    required this.progressRepository,
  }) : super(const CoursesInitial());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Loads courses and learner progress from repositories.
  Future<void> loadCourses() async {
    emit(const CoursesLoading());
    try {
      final List<Course> courses = await courseRepository.getCourses();
      final Map<String, LessonProgress> progressMap =
          await progressRepository.getAllProgress();
      final String? lastWatchedId =
          await progressRepository.getLastWatchedLessonId();

      emit(CoursesLoaded(
        courses: courses,
        progressList: progressMap.values.toList(),
        lastWatchedLessonId: lastWatchedId,
      ));
    } catch (_) {
      emit(const CoursesError(
        'تعذر تحميل بيانات الدورات. يرجى المحاولة مرة أخرى.',
      ));
    }
  }

  /// Reloads courses and progress data (useful after progress updates).
  Future<void> reloadCourses() async {
    await loadCourses();
  }

  /// Updates the search query with debouncing.
  /// 
  /// - 0–1 characters: shows all courses immediately (no search)
  /// - 2+ characters: debounces for 400ms, then filters locally
  void searchCourses(String query) {
    final currentState = state;
    if (currentState is! CoursesLoaded) return;

    // Cancel any pending debounce
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    // 0-1 characters → show all courses immediately
    if (trimmedQuery.length < 2) {
      emit(currentState.copyWith(
        searchQuery: trimmedQuery,
        filteredCourses: currentState.courses,
        isSearching: false,
      ));
      return;
    }

    // 2+ characters → show loading state, then debounce
    emit(currentState.copyWith(
      searchQuery: trimmedQuery,
      isSearching: true,
    ));

    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(trimmedQuery);
    });
  }

  /// Performs the actual local search filtering.
  void _performSearch(String query) {
    final currentState = state;
    if (currentState is! CoursesLoaded) return;

    final normalizedQuery = _normalizeArabic(query.toLowerCase());
    
    final filtered = currentState.courses.where((course) {
      // Search in Arabic title
      final normalizedTitle = _normalizeArabic(course.title.toLowerCase());
      if (normalizedTitle.contains(normalizedQuery)) return true;

      // Search in English title (case-insensitive)
      if (course.titleEn.isNotEmpty) {
        if (course.titleEn.toLowerCase().contains(query.toLowerCase())) {
          return true;
        }
      }

      // Search in Arabic instructor
      final normalizedInstructor = 
          _normalizeArabic(course.instructor.toLowerCase());
      if (normalizedInstructor.contains(normalizedQuery)) return true;

      // Search in English instructor (case-insensitive)
      if (course.instructorEn.isNotEmpty) {
        if (course.instructorEn.toLowerCase().contains(query.toLowerCase())) {
          return true;
        }
      }

      return false;
    }).toList();

    emit(currentState.copyWith(
      filteredCourses: filtered,
      isSearching: false,
    ));
  }

  /// Normalizes Arabic text for better search matching.
  /// 
  /// - Converts أ/إ/آ → ا
  /// - Converts ى → ي
  /// - Removes common Arabic diacritics (tashkeel)
  String _normalizeArabic(String text) {
    return text
        // Normalize alef variations
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        // Normalize yaa variations
        .replaceAll('ى', 'ي')
        // Remove tashkeel (diacritics)
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '');
  }

  /// Clears the search query and restores all courses.
  void clearSearch() {
    final currentState = state;
    if (currentState is! CoursesLoaded) return;

    _debounceTimer?.cancel();

    emit(currentState.copyWith(
      searchQuery: '',
      filteredCourses: currentState.courses,
      isSearching: false,
    ));
  }
}
