import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/domain/entities/lesson.dart';
import 'package:thaheen/features/player/domain/services/progress_service.dart';

void main() {
  late ProgressService progressService;

  setUp(() {
    progressService = ProgressService();
  });

  group('90% completion', () {
    test('returns false when position is at 89%', () {
      final duration = const Duration(seconds: 100);
      final position = const Duration(seconds: 89);
      
      final result = progressService.isCompleted(position: position, duration: duration);
      
      expect(result, isFalse);
    });

    test('returns true when position is exactly at 90%', () {
      final duration = const Duration(seconds: 100);
      final position = const Duration(seconds: 90);
      
      final result = progressService.isCompleted(position: position, duration: duration);
      
      expect(result, isTrue);
    });

    test('returns true when position is over 90% (e.g. 91%)', () {
      final duration = const Duration(seconds: 100);
      final position = const Duration(seconds: 91);
      
      final result = progressService.isCompleted(position: position, duration: duration);
      
      expect(result, isTrue);
    });
  });

  group('Sequential unlock', () {
    final lessons = [
      const Lesson(id: 'L1', title: 'L1', durationSec: 100, video: 'v'),
      const Lesson(id: 'L2', title: 'L2', durationSec: 100, video: 'v'),
      const Lesson(id: 'L3', title: 'L3', durationSec: 100, video: 'v'),
    ];

    test('L1 is always unlocked', () {
      final result = progressService.isUnlocked(
        lessons: lessons, 
        index: 0, 
        completedLessonIds: {}
      );
      expect(result, isTrue);
    });

    test('L2 is locked before L1 completion', () {
      final result = progressService.isUnlocked(
        lessons: lessons, 
        index: 1, 
        completedLessonIds: {}
      );
      expect(result, isFalse);
    });

    test('L2 is unlocked after L1 completion', () {
      final result = progressService.isUnlocked(
        lessons: lessons, 
        index: 1, 
        completedLessonIds: {'L1'}
      );
      expect(result, isTrue);
    });

    test('L3 is still locked until L2 completion', () {
      final result = progressService.isUnlocked(
        lessons: lessons, 
        index: 2, 
        completedLessonIds: {'L1'} // Only L1 completed
      );
      expect(result, isFalse);
    });
  });

  group('Course progress', () {
    final lessons = [
      const Lesson(id: 'L1', title: 'L1', durationSec: 100, video: 'v'),
      const Lesson(id: 'L2', title: 'L2', durationSec: 100, video: 'v'),
      const Lesson(id: 'L3', title: 'L3', durationSec: 100, video: 'v'),
      const Lesson(id: 'L4', title: 'L4', durationSec: 100, video: 'v'),
    ];

    test('0 / 4 -> 0%', () {
      final result = progressService.calculateProgress(
        lessons: lessons, 
        completedLessonIds: {}
      );
      expect(result, equals(0.0));
    });

    test('1 / 4 -> 25%', () {
      final result = progressService.calculateProgress(
        lessons: lessons, 
        completedLessonIds: {'L1'}
      );
      expect(result, equals(0.25));
    });

    test('2 / 4 -> 50%', () {
      final result = progressService.calculateProgress(
        lessons: lessons, 
        completedLessonIds: {'L1', 'L2'}
      );
      expect(result, equals(0.50));
    });

    test('4 / 4 -> 100%', () {
      final result = progressService.calculateProgress(
        lessons: lessons, 
        completedLessonIds: {'L1', 'L2', 'L3', 'L4'}
      );
      expect(result, equals(1.0));
    });

    test('0 lessons -> 0%', () {
      final result = progressService.calculateProgress(
        lessons: [], 
        completedLessonIds: {'L1'}
      );
      expect(result, equals(0.0));
    });
  });
}

