import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../player/domain/repositories/progress_repository.dart';
import '../../../player/domain/services/progress_service.dart';
import '../../domain/repositories/course_repository.dart';
import 'course_details_state.dart';

/// Cubit managing state for the Course Details screen.
class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
  final ProgressService progressService;

  /// Creates a [CourseDetailsCubit] with required repositories and services.
  CourseDetailsCubit({
    required this.courseRepository,
    required this.progressRepository,
    required this.progressService,
  }) : super(const CourseDetailsInitial());

  /// Loads course information by [courseId] along with all latest lesson progress.
  ///
  /// When [silent] is true, an existing loaded screen is kept visible while
  /// progress is refreshed after returning from the lesson player.
  Future<void> loadCourseDetails(
    String courseId, {
    bool silent = false,
  }) async {
    if (!silent || state is! CourseDetailsLoaded) {
      emit(const CourseDetailsLoading());
    }

    try {
      final Course? course = await courseRepository.getCourseById(courseId);
      if (course == null) {
        emit(const CourseDetailsError('course_not_found'));
        return;
      }

      final Map<String, LessonProgress> progressMap =
          await progressRepository.getAllProgress();
      final progressList = progressMap.values.toList();

      emit(_buildLoadedState(course, progressList));
    } catch (_) {
      emit(const CourseDetailsError('course_load_failed'));
    }
  }

  CourseDetailsLoaded _buildLoadedState(
    Course course,
    List<LessonProgress> progressList,
  ) {
    final allLessons = course.sections.expand((s) => s.lessons).toList();
    final completedLessonIds =
        progressList.where((p) => p.completed).map((p) => p.lessonId).toSet();
    final completedCount =
        allLessons.where((l) => completedLessonIds.contains(l.id)).length;
    final progressRatio =
        progressService.calculateCourseProgress(course, progressList);
    final totalHours = allLessons.fold<int>(0, (sum, l) => sum + l.durationSec) /
        3600;

    final Lesson? activeLesson = progressService.findContinueWatching(
          course,
          progressList,
        ) ??
        (allLessons.isEmpty
            ? null
            : allLessons.firstWhere(
                (l) => !completedLessonIds.contains(l.id),
                orElse: () => allLessons.first,
              ));

    return CourseDetailsLoaded(
      course: course,
      progressList: progressList,
      allLessons: allLessons,
      progressRatio: progressRatio,
      completedLessonsCount: completedCount,
      totalHours: totalHours,
      activeLesson: activeLesson,
    );
  }
}
