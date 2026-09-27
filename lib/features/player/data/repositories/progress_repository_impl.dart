import '../../../../domain/entities/lesson_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';

/// Implementation of [ProgressRepository] delegating to [ProgressLocalDataSource].
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource localDataSource;

  /// Creates a [ProgressRepositoryImpl] with required [localDataSource].
  const ProgressRepositoryImpl({required this.localDataSource});

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async {
    return await localDataSource.getLessonProgress(lessonId);
  }

  @override
  Future<Map<String, LessonProgress>> getAllProgress() async {
    return await localDataSource.getAllProgress();
  }

  @override
  Future<void> savePosition(String lessonId, Duration position) async {
    await localDataSource.savePosition(lessonId, position);
  }

  @override
  Future<void> markCompleted(String lessonId) async {
    await localDataSource.markCompleted(lessonId);
  }

  @override
  Future<String?> getLastWatchedLessonId() async {
    return await localDataSource.getLastWatchedLessonId();
  }

  @override
  Future<void> setLastWatchedLessonId(String lessonId) async {
    await localDataSource.setLastWatchedLessonId(lessonId);
  }
}
