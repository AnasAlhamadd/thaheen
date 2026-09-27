import 'dart:convert';
import '../../../../core/storage/storage_service.dart';
import '../models/lesson_progress_model.dart';

/// Data source interface for persisting learner progress.
abstract class ProgressLocalDataSource {
  /// Retrieves progress for [lessonId].
  Future<LessonProgressModel?> getLessonProgress(String lessonId);

  /// Retrieves progress for all recorded lessons.
  Future<Map<String, LessonProgressModel>> getAllProgress();

  /// Saves the playback position for [lessonId].
  Future<void> savePosition(String lessonId, Duration position);

  /// Marks [lessonId] as completed.
  Future<void> markCompleted(String lessonId);

  /// Returns the ID of the last watched lesson.
  Future<String?> getLastWatchedLessonId();

  /// Sets the ID of the last watched lesson.
  Future<void> setLastWatchedLessonId(String lessonId);
}

/// SharedPreferences-backed implementation of [ProgressLocalDataSource] using [StorageService].
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final StorageService storageService;

  static const String _progressKey = 'LESSON_PROGRESS';
  static const String _lastWatchedKey = 'LAST_WATCHED_LESSON';

  /// Creates a [ProgressLocalDataSourceImpl] using the injected [storageService].
  const ProgressLocalDataSourceImpl({required this.storageService});

  Future<Map<String, dynamic>> _getProgressMap() async {
    final String? progressJson = await storageService.getString(_progressKey);
    if (progressJson != null && progressJson.isNotEmpty) {
      try {
        final decoded = json.decode(progressJson);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // Fallback gracefully on corrupted storage
      }
    }
    return {};
  }

  Future<void> _saveProgressMap(Map<String, dynamic> progressMap) async {
    await storageService.setString(_progressKey, json.encode(progressMap));
  }

  @override
  Future<LessonProgressModel?> getLessonProgress(String lessonId) async {
    final progressMap = await _getProgressMap();
    final lessonData = progressMap[lessonId];
    if (lessonData is Map<String, dynamic>) {
      return LessonProgressModel.fromJson(lessonData, defaultLessonId: lessonId);
    }
    return null;
  }

  @override
  Future<Map<String, LessonProgressModel>> getAllProgress() async {
    final progressMap = await _getProgressMap();
    final Map<String, LessonProgressModel> result = {};

    progressMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = LessonProgressModel.fromJson(value, defaultLessonId: key);
      }
    });

    return result;
  }

  @override
  Future<void> savePosition(String lessonId, Duration position) async {
    final progressMap = await _getProgressMap();
    final existingData = progressMap[lessonId] as Map<String, dynamic>? ?? {};

    progressMap[lessonId] = {
      'lessonId': lessonId,
      'position': position.inSeconds < 0 ? 0 : position.inSeconds,
      'completed': existingData['completed'] ?? false,
    };

    await _saveProgressMap(progressMap);
  }

  @override
  Future<void> markCompleted(String lessonId) async {
    final progressMap = await _getProgressMap();
    final existingData = progressMap[lessonId] as Map<String, dynamic>? ?? {};

    progressMap[lessonId] = {
      'lessonId': lessonId,
      'position': existingData['position'] ?? 0,
      'completed': true,
    };

    await _saveProgressMap(progressMap);
  }

  @override
  Future<String?> getLastWatchedLessonId() async {
    return await storageService.getString(_lastWatchedKey);
  }

  @override
  Future<void> setLastWatchedLessonId(String lessonId) async {
    await storageService.setString(_lastWatchedKey, lessonId);
  }
}
