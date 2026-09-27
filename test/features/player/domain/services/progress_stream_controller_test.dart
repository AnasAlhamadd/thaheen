import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/features/player/domain/services/progress_stream_controller.dart';

void main() {
  group('ProgressStreamController', () {
    late List<Duration> savedPositions;
    late ProgressStreamController controller;

    setUp(() {
      savedPositions = [];
      controller = ProgressStreamController(
        onSave: (position) async {
          savedPositions.add(position);
          await Future.delayed(const Duration(milliseconds: 10));
        },
        saveDuration: const Duration(milliseconds: 100),
        minChangeThreshold: 2,
      );
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('initializes with zero position', () {
      expect(controller.currentPosition, Duration.zero);
      expect(controller.lastSavedPosition, Duration.zero);
      expect(controller.hasUnsavedChanges, false);
    });

    test('emits position updates to stream', () async {
      final positions = <Duration>[];
      final subscription = controller.stream.listen(positions.add);

      controller.updatePosition(const Duration(seconds: 5));
      controller.updatePosition(const Duration(seconds: 10));
      controller.updatePosition(const Duration(seconds: 15));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(positions, [
        const Duration(seconds: 5),
        const Duration(seconds: 10),
        const Duration(seconds: 15),
      ]);

      await subscription.cancel();
    });

    test('debounces rapid updates', () async {
      // Update position multiple times rapidly
      controller.updatePosition(const Duration(seconds: 5));
      controller.updatePosition(const Duration(seconds: 6));
      controller.updatePosition(const Duration(seconds: 7));
      controller.updatePosition(const Duration(seconds: 8));

      // Wait less than debounce duration
      await Future.delayed(const Duration(milliseconds: 50));
      expect(savedPositions, isEmpty, reason: 'Should not save yet');

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(savedPositions.length, 1, reason: 'Should save once after debounce');
      expect(savedPositions.first, const Duration(seconds: 8));
    });

    test('respects minimum change threshold', () async {
      controller.updatePosition(const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 150));

      // Change is < 2 seconds, should not save
      expect(savedPositions, isEmpty);

      controller.updatePosition(const Duration(seconds: 5));
      await Future.delayed(const Duration(milliseconds: 150));

      // Change is > 2 seconds, should save
      expect(savedPositions.length, 1);
      expect(savedPositions.first, const Duration(seconds: 5));
    });

    test('saveNow forces immediate save', () async {
      controller.updatePosition(const Duration(seconds: 10));

      // Don't wait for debounce
      await controller.saveNow();

      expect(savedPositions.length, 1);
      expect(savedPositions.first, const Duration(seconds: 10));
      expect(controller.lastSavedPosition, const Duration(seconds: 10));
      expect(controller.hasUnsavedChanges, false);
    });

    test('saveNow returns false when no changes', () async {
      controller.updatePosition(const Duration(seconds: 10));
      await controller.saveNow();

      final result = await controller.saveNow();
      expect(result, false);
      expect(savedPositions.length, 1, reason: 'Should not save again');
    });

    test('saveNow returns false when already saving', () async {
      // Create slow save
      final slowController = ProgressStreamController(
        onSave: (position) async {
          savedPositions.add(position);
          await Future.delayed(const Duration(milliseconds: 200));
        },
        saveDuration: const Duration(milliseconds: 100),
      );

      slowController.updatePosition(const Duration(seconds: 10));

      // Start first save
      final future1 = slowController.saveNow();
      
      // Try to save again while first is in progress
      final future2 = slowController.saveNow();

      final results = await Future.wait([future1, future2]);
      expect(results[0], true, reason: 'First save should succeed');
      expect(results[1], false, reason: 'Second save should be blocked');
      expect(savedPositions.length, 1, reason: 'Should only save once');

      await slowController.dispose();
    });

    test('hasUnsavedChanges reflects state correctly', () async {
      expect(controller.hasUnsavedChanges, false);

      // Small change (< threshold)
      controller.updatePosition(const Duration(seconds: 1));
      expect(controller.hasUnsavedChanges, false);

      // Large change (>= threshold)
      controller.updatePosition(const Duration(seconds: 5));
      expect(controller.hasUnsavedChanges, true);

      // Save
      await controller.saveNow();
      expect(controller.hasUnsavedChanges, false);
    });

    test('resetSavedPosition updates state', () {
      controller.updatePosition(const Duration(seconds: 10));
      controller.resetSavedPosition(const Duration(seconds: 10));

      expect(controller.currentPosition, const Duration(seconds: 10));
      expect(controller.lastSavedPosition, const Duration(seconds: 10));
      expect(controller.hasUnsavedChanges, false);
    });

    test('dispose saves unsaved changes', () async {
      controller.updatePosition(const Duration(seconds: 10));
      
      await controller.dispose();

      expect(savedPositions.length, 1);
      expect(savedPositions.first, const Duration(seconds: 10));
    });

    test('dispose does not save if no changes', () async {
      controller.updatePosition(const Duration(seconds: 10));
      await controller.saveNow();
      savedPositions.clear();

      await controller.dispose();

      expect(savedPositions, isEmpty);
    });

    test('dispose prevents further operations', () async {
      await controller.dispose();

      // Should not throw, just no-op
      controller.updatePosition(const Duration(seconds: 10));
      final result = await controller.saveNow();

      expect(result, false);
      expect(savedPositions, isEmpty);
    });

    test('cancels pending save on dispose', () async {
      controller.updatePosition(const Duration(seconds: 10));
      
      // Immediately dispose without waiting for debounce
      await controller.dispose();

      // Should still save the last position
      expect(savedPositions.length, 1);
    });

    test('handles save errors gracefully', () async {
      final errorController = ProgressStreamController(
        onSave: (position) async {
          throw Exception('Save failed');
        },
        saveDuration: const Duration(milliseconds: 100),
      );

      errorController.updatePosition(const Duration(seconds: 10));
      
      // Should not throw
      await errorController.saveNow();

      // lastSavedPosition should not update on error
      expect(errorController.lastSavedPosition, Duration.zero);
      expect(errorController.hasUnsavedChanges, true);

      await errorController.dispose();
    });

    test('multiple rapid updates only save final position', () async {
      // Simulate video frame updates (many per second)
      for (int i = 0; i < 30; i++) {
        controller.updatePosition(Duration(seconds: i));
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Wait for final debounce
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only save once with the final position
      expect(savedPositions.length, 1);
      expect(savedPositions.first, const Duration(seconds: 29));
    });
  });

  group('ProgressStreamControllerWithStats', () {
    late List<Duration> savedPositions;
    late ProgressStreamControllerWithStats controller;

    setUp(() {
      savedPositions = [];
      controller = ProgressStreamControllerWithStats(
        onSave: (position) async {
          savedPositions.add(position);
        },
        saveDuration: const Duration(milliseconds: 100),
      );
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('tracks update statistics', () async {
      controller.updatePosition(const Duration(seconds: 5));
      controller.updatePosition(const Duration(seconds: 10));
      controller.updatePosition(const Duration(seconds: 15));

      expect(controller.stats.totalUpdates, 3);
      expect(controller.stats.firstUpdate, isNotNull);
      expect(controller.stats.lastUpdate, isNotNull);
    });

    test('tracks save statistics', () async {
      controller.updatePosition(const Duration(seconds: 10));
      await controller.saveNow();

      controller.updatePosition(const Duration(seconds: 20));
      await controller.saveNow();

      expect(controller.stats.totalSaves, 2);
      expect(controller.stats.lastSave, isNotNull);
    });

    test('calculates efficiency ratio', () async {
      // 10 updates
      for (int i = 0; i < 10; i++) {
        controller.updatePosition(Duration(seconds: i * 5));
      }

      // 2 saves
      await controller.saveNow();
      controller.updatePosition(const Duration(seconds: 100));
      await controller.saveNow();

      expect(controller.stats.totalUpdates, 11); // 10 + 1 extra
      expect(controller.stats.totalSaves, 2);
      expect(controller.stats.efficiency, closeTo(0.18, 0.01)); // 2/11
    });

    test('stats can be reset', () {
      controller.updatePosition(const Duration(seconds: 10));
      controller.stats.reset();

      expect(controller.stats.totalUpdates, 0);
      expect(controller.stats.totalSaves, 0);
      expect(controller.stats.firstUpdate, isNull);
      expect(controller.stats.lastUpdate, isNull);
    });
  });

  group('ProgressStreamStats', () {
    test('summary returns formatted string', () {
      final stats = ProgressStreamStats();
      
      stats.recordUpdate();
      stats.recordUpdate();
      stats.recordUpdate();
      stats.recordSave();

      final summary = stats.summary;
      
      expect(summary, contains('Updates: 3'));
      expect(summary, contains('Saves: 1'));
      expect(summary, contains('Efficiency: 33.3%'));
    });

    test('efficiency returns 0 when no updates', () {
      final stats = ProgressStreamStats();
      expect(stats.efficiency, 0.0);
    });
  });
}
