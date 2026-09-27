import 'dart:async';
import 'package:flutter/foundation.dart';

/// Streaming-like controller for efficient video progress tracking.
///
/// Features:
/// - Debounced updates to reduce write frequency
/// - Stream-based progress emission
/// - Automatic cleanup
/// - Memory-efficient buffering
///
/// Usage:
/// ```dart
/// final controller = ProgressStreamController(
///   saveDuration: Duration(seconds: 3),
///   onSave: (position) async {
///     await repository.savePosition(lessonId, position);
///   },
/// );
///
/// // Listen to progress updates
/// controller.stream.listen((position) {
///   print('Progress: ${position.inSeconds}s');
/// });
///
/// // Update position (debounced automatically)
/// controller.updatePosition(Duration(seconds: 45));
///
/// // Force immediate save
/// await controller.saveNow();
///
/// // Cleanup
/// controller.dispose();
/// ```
class ProgressStreamController {
  /// Stream controller for broadcasting progress updates.
  final StreamController<Duration> _controller = StreamController<Duration>.broadcast();

  /// Timer for debouncing save operations.
  Timer? _saveTimer;

  /// The most recent position received.
  Duration _currentPosition = Duration.zero;

  /// The last position that was persisted.
  Duration _lastSavedPosition = Duration.zero;

  /// Callback to persist progress to storage.
  final Future<void> Function(Duration position) onSave;

  /// Duration to wait before auto-saving (debounce interval).
  final Duration saveDuration;

  /// Minimum position change required to trigger a save (in seconds).
  /// Prevents saving if user is at same position.
  final int minChangeThreshold;

  /// Whether a save operation is currently in progress.
  bool _isSaving = false;

  /// Whether the controller has been disposed.
  bool _isDisposed = false;

  /// Creates a [ProgressStreamController].
  ///
  /// [onSave] - Async callback to persist progress
  /// [saveDuration] - Debounce duration (default: 3 seconds)
  /// [minChangeThreshold] - Minimum seconds change to trigger save (default: 2)
  ProgressStreamController({
    required this.onSave,
    this.saveDuration = const Duration(seconds: 3),
    this.minChangeThreshold = 2,
  });

  /// Stream of progress updates.
  Stream<Duration> get stream => _controller.stream;

  /// Current position.
  Duration get currentPosition => _currentPosition;

  /// Last saved position.
  Duration get lastSavedPosition => _lastSavedPosition;

  /// Whether there are unsaved changes.
  bool get hasUnsavedChanges {
    final diff = (_currentPosition.inSeconds - _lastSavedPosition.inSeconds).abs();
    return diff >= minChangeThreshold;
  }

  /// Updates the current position and schedules a debounced save.
  ///
  /// This method can be called frequently (e.g., every video frame).
  /// It will only trigger a save after [saveDuration] of inactivity.
  void updatePosition(Duration position) {
    if (_isDisposed) return;

    _currentPosition = position;
    _controller.add(position);

    // Cancel existing timer
    _saveTimer?.cancel();

    // Schedule new save
    _saveTimer = Timer(saveDuration, () {
      if (!_isDisposed && hasUnsavedChanges) {
        _performSave();
      }
    });
  }

  /// Forces an immediate save of the current position.
  ///
  /// Returns true if save was performed, false if already saving or no changes.
  Future<bool> saveNow() async {
    if (_isDisposed || _isSaving) return false;
    if (!hasUnsavedChanges) return false;

    _saveTimer?.cancel();
    await _performSave();
    return true;
  }

  /// Performs the actual save operation.
  Future<void> _performSave() async {
    if (_isSaving) return;

    _isSaving = true;
    try {
      await onSave(_currentPosition);
      _lastSavedPosition = _currentPosition;
      debugPrint('✅ Progress saved: ${_currentPosition.inSeconds}s');
    } catch (e) {
      debugPrint('❌ Failed to save progress: $e');
      // Don't update lastSavedPosition on error, will retry next time
    } finally {
      _isSaving = false;
    }
  }

  /// Resets the last saved position (useful when starting a new lesson).
  void resetSavedPosition(Duration initialPosition) {
    _lastSavedPosition = initialPosition;
    _currentPosition = initialPosition;
  }

  /// Disposes the controller and cancels pending operations.
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _saveTimer?.cancel();
    _isDisposed = true;
    
    // Final save if there are unsaved changes
    if (hasUnsavedChanges && !_isSaving) {
      await _performSave();
    }
    
    await _controller.close();
  }
}

/// Statistics tracker for progress stream performance monitoring.
///
/// Useful for debugging and performance optimization.
class ProgressStreamStats {
  int totalUpdates = 0;
  int totalSaves = 0;
  int skippedSaves = 0;
  DateTime? firstUpdate;
  DateTime? lastUpdate;
  DateTime? lastSave;

  /// Resets all statistics.
  void reset() {
    totalUpdates = 0;
    totalSaves = 0;
    skippedSaves = 0;
    firstUpdate = null;
    lastUpdate = null;
    lastSave = null;
  }

  /// Records an update event.
  void recordUpdate() {
    totalUpdates++;
    final now = DateTime.now();
    firstUpdate ??= now;
    lastUpdate = now;
  }

  /// Records a save event.
  void recordSave() {
    totalSaves++;
    lastSave = DateTime.now();
  }

  /// Records a skipped save event.
  void recordSkip() {
    skippedSaves++;
  }

  /// Calculates the save efficiency ratio (saves / updates).
  double get efficiency {
    if (totalUpdates == 0) return 0.0;
    return totalSaves / totalUpdates;
  }

  /// Returns a formatted summary string.
  String get summary {
    return 'Updates: $totalUpdates | Saves: $totalSaves | '
        'Skipped: $skippedSaves | Efficiency: ${(efficiency * 100).toStringAsFixed(1)}%';
  }
}

/// Enhanced progress controller with statistics tracking.
class ProgressStreamControllerWithStats extends ProgressStreamController {
  final ProgressStreamStats stats = ProgressStreamStats();

  ProgressStreamControllerWithStats({
    required super.onSave,
    super.saveDuration,
    super.minChangeThreshold,
  });

  @override
  void updatePosition(Duration position) {
    stats.recordUpdate();
    super.updatePosition(position);
  }

  @override
  Future<void> _performSave() async {
    stats.recordSave();
    await super._performSave();
  }

  /// Prints current statistics to debug console.
  void printStats() {
    debugPrint('📊 Progress Stream Stats: ${stats.summary}');
  }
}
