import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../courses/domain/repositories/course_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/progress_service.dart';
import '../../domain/services/progress_stream_controller.dart';
import 'lesson_player_state.dart';

/// Cubit managing lesson player business logic with streaming progress tracking:
/// - Debounced progress saves via ProgressStreamController
/// - Automatic 90% completion detection
/// - Next-lesson resolution
/// - Smart navigation on completion
class LessonPlayerCubit extends Cubit<LessonPlayerState> {
  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
  final ProgressService progressService;

  /// Streaming progress controller for efficient, debounced saves.
  ProgressStreamController? _progressController;

  /// Subscription to progress stream updates.
  StreamSubscription<Duration>? _progressSubscription;

  /// Whether the completion event has already been written for this session.
  bool _completionSaved = false;

  /// Tracks if user has watched enough to consider navigation valid.
  bool _hasWatchedContent = false;

  /// Minimum watch time before allowing auto-navigation (prevents accidental skips).
  static const Duration _minWatchTime = Duration(seconds: 5);

  /// Creates a [LessonPlayerCubit] with required dependencies.
  LessonPlayerCubit({
    required this.courseRepository,
    required this.progressRepository,
    required this.progressService,
  }) : super(const LessonPlayerInitial());

  /// Loads the course, lesson, and existing progress for the player.
  Future<void> loadLesson(String courseId, String lessonId) async {
    emit(const LessonPlayerLoading());
    try {
      final Course? course = await courseRepository.getCourseById(courseId);
      if (course == null) {
        emit(const LessonPlayerError('لم يتم العثور على الدورة المطلوبة.'));
        return;
      }

      final allLessons = course.sections.expand((s) => s.lessons).toList();
      final lessonIndex = allLessons.indexWhere((l) => l.id == lessonId);
      if (lessonIndex == -1) {
        emit(const LessonPlayerError('لم يتم العثور على الدرس المطلوب.'));
        return;
      }

      final Lesson lesson = allLessons[lessonIndex];
      final LessonProgress? progress =
          await progressRepository.getLessonProgress(lessonId);

      // Load all progress for course plan display
      final allProgress = await progressRepository.getAllProgress();
      final completedIds = allProgress.entries
          .where((e) => e.value.completed)
          .map((e) => e.key)
          .toSet();

      final resumePosition = progress?.position ?? Duration.zero;
      final isCompleted = progress?.completed ?? false;
      _completionSaved = isCompleted;
      _hasWatchedContent = resumePosition > _minWatchTime;

      // Initialize streaming progress controller
      _initializeProgressController(lessonId, resumePosition);

      // Mark as last watched
      await progressRepository.setLastWatchedLessonId(lessonId);

      // Resolve next lesson
      final Lesson? nextLesson =
          progressService.getNextLesson(course, lessonId);

      emit(LessonPlayerReady(
        course: course,
        currentLesson: lesson,
        resumePosition: resumePosition,
        isCompleted: isCompleted,
        nextLesson: nextLesson,
        completedLessonIds: completedIds,
      ));
    } catch (e) {
      debugPrint('❌ Failed to load lesson: $e');
      emit(const LessonPlayerError('فشل في تحميل الدرس. يرجى المحاولة مرة أخرى.'));
    }
  }

  /// Initializes the progress streaming controller.
  void _initializeProgressController(String lessonId, Duration initialPosition) {
    // Dispose existing controller if any
    _disposeProgressController();

    _progressController = ProgressStreamController(
      onSave: (position) async {
        await progressRepository.savePosition(lessonId, position);
        debugPrint('💾 Progress saved: ${position.inSeconds}s for lesson: $lessonId');
      },
      saveDuration: const Duration(seconds: 3),
      minChangeThreshold: 2,
    );

    _progressController!.resetSavedPosition(initialPosition);

    // Listen to progress stream for UI updates and completion checks
    _progressSubscription = _progressController!.stream.listen(_onProgressUpdate);
  }

  /// Handles progress updates from the stream.
  void _onProgressUpdate(Duration position) {
    if (state is! LessonPlayerReady) return;

    // Track minimum watch time
    if (!_hasWatchedContent && position > _minWatchTime) {
      _hasWatchedContent = true;
      debugPrint('✅ Minimum watch time reached');
    }
  }

  /// Called by the video listener on each position tick.
  /// Updates the streaming controller which handles debouncing and completion checks.
  Future<void> onPositionChanged(Duration position, Duration duration) async {
    if (state is! LessonPlayerReady) return;
    final currentState = state as LessonPlayerReady;

    // Update streaming controller (automatically debounced)
    _progressController?.updatePosition(position);

    // --- 90% completion check ---
    if (!_completionSaved) {
      final shouldComplete =
          progressService.shouldCompleteLesson(position, duration);
      if (shouldComplete) {
        _completionSaved = true;
        await _markLessonCompleted(currentState, position);
      }
    }
  }

  /// Marks the lesson as completed and updates state.
  Future<void> _markLessonCompleted(
    LessonPlayerReady currentState,
    Duration position,
  ) async {
    try {
      await progressRepository.markCompleted(currentState.currentLesson.id);
      await progressRepository.savePosition(
        currentState.currentLesson.id,
        position,
      );

      debugPrint('🎉 Lesson completed: ${currentState.currentLesson.title}');

      // Update completedLessonIds set with the newly completed lesson
      final updatedIds = {...currentState.completedLessonIds, currentState.currentLesson.id};

      emit(currentState.copyWith(
        isCompleted: true,
        resumePosition: position,
        completedLessonIds: updatedIds,
      ));
    } catch (e) {
      debugPrint('❌ Failed to mark lesson completed: $e');
    }
  }

  /// Saves progress immediately — called on pause, seek, and dispose.
  Future<void> saveProgressNow(Duration position) async {
    if (state is! LessonPlayerReady) return;

    _progressController?.updatePosition(position);
    await _progressController?.saveNow();
  }

  /// Checks if enough content has been watched to consider valid viewing.
  bool hasWatchedEnoughContent() {
    return _hasWatchedContent;
  }

  /// Gets unsaved changes status.
  bool hasUnsavedChanges() {
    return _progressController?.hasUnsavedChanges ?? false;
  }

  /// Called when user navigates away (back button, etc.).
  /// Ensures progress is saved before navigation.
  Future<bool> onWillPop() async {
    await saveProgressNow(_progressController?.currentPosition ?? Duration.zero);
    return true; // Allow navigation
  }

  /// Emits an error state (e.g. video initialization failure).
  void setError(String message) {
    emit(LessonPlayerError(message));
  }

  /// Disposes the progress controller and cancels subscriptions.
  void _disposeProgressController() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    _progressController?.dispose();
    _progressController = null;
  }

  @override
  Future<void> close() async {
    _disposeProgressController();
    return super.close();
  }
}
