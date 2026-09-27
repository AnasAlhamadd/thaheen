import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/domain/entities/course.dart';
import 'package:thaheen/domain/entities/lesson.dart';
import 'package:thaheen/domain/entities/lesson_progress.dart';
import 'package:thaheen/domain/entities/lesson_status.dart';
import 'package:thaheen/domain/entities/section.dart';
import 'package:thaheen/features/player/domain/services/progress_service.dart';

void main() {
  late ProgressService progressService;

  setUp(() {
    progressService = ProgressService();
  });

  // ---------------------------------------------------------------------------
  // Test 1 — 90% completion
  // ---------------------------------------------------------------------------
  group('Test 1 — 90% completion', () {
    const totalDuration = Duration(seconds: 100);

    test('89% -> false', () {
      final position = const Duration(seconds: 89);
      final result = progressService.shouldCompleteLesson(position, totalDuration);
      expect(result, isFalse);
    });

    test('90% -> true', () {
      final position = const Duration(seconds: 90);
      final result = progressService.shouldCompleteLesson(position, totalDuration);
      expect(result, isTrue);
    });

    test('91% -> true', () {
      final position = const Duration(seconds: 91);
      final result = progressService.shouldCompleteLesson(position, totalDuration);
      expect(result, isTrue);
    });

    test('0 duration -> false (guards against division by zero/zero duration)', () {
      final result = progressService.shouldCompleteLesson(
        const Duration(seconds: 10),
        Duration.zero,
      );
      expect(result, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Test 2 — sequential unlock
  // ---------------------------------------------------------------------------
  group('Test 2 — sequential unlock', () {
    const sampleCourse = Course(
      id: 'course-1',
      title: 'Course 1',
      instructor: 'Instructor',
      thumbnail: 'thumb.png',
      sections: [
        Section(
          id: 's1',
          title: 'Section 1',
          lessons: [
            Lesson(id: 'L1', title: 'Lesson 1', durationSec: 100, video: 'v1'),
            Lesson(id: 'L2', title: 'Lesson 2', durationSec: 100, video: 'v2'),
          ],
        ),
        Section(
          id: 's2',
          title: 'Section 2',
          lessons: [
            Lesson(id: 'L3', title: 'Lesson 3', durationSec: 100, video: 'v3'),
            Lesson(id: 'L4', title: 'Lesson 4', durationSec: 100, video: 'v4'),
          ],
        ),
      ],
    );

    test('L1 -> unlocked', () {
      final result = progressService.isLessonUnlocked(sampleCourse, 'L1', []);
      expect(result, isTrue);
    });

    test('L2 -> locked before L1 completion', () {
      final progressList = [
        const LessonProgress(
          lessonId: 'L1',
          position: Duration(seconds: 50),
          completed: false,
        ),
      ];
      final result = progressService.isLessonUnlocked(sampleCourse, 'L2', progressList);
      expect(result, isFalse);
    });

    test('L2 -> unlocked after L1 completion', () {
      final progressList = [
        const LessonProgress(
          lessonId: 'L1',
          position: Duration(seconds: 100),
          completed: true,
        ),
      ];
      final result = progressService.isLessonUnlocked(sampleCourse, 'L2', progressList);
      expect(result, isTrue);
    });

    test('L3 -> still locked until L2 completion (crosses section boundary)', () {
      final progressList = [
        const LessonProgress(
          lessonId: 'L1',
          position: Duration(seconds: 100),
          completed: true,
        ),
        const LessonProgress(
          lessonId: 'L2',
          position: Duration(seconds: 40),
          completed: false,
        ),
      ];
      final result = progressService.isLessonUnlocked(sampleCourse, 'L3', progressList);
      expect(result, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Test 3 — course progress
  // ---------------------------------------------------------------------------
  group('Test 3 — course progress', () {
    const courseWithFourLessons = Course(
      id: 'course-4',
      title: 'Course 4',
      instructor: 'Instructor',
      thumbnail: 'thumb.png',
      sections: [
        Section(
          id: 's1',
          title: 'Section 1',
          lessons: [
            Lesson(id: 'L1', title: 'Lesson 1', durationSec: 100, video: 'v1'),
            Lesson(id: 'L2', title: 'Lesson 2', durationSec: 100, video: 'v2'),
            Lesson(id: 'L3', title: 'Lesson 3', durationSec: 100, video: 'v3'),
            Lesson(id: 'L4', title: 'Lesson 4', durationSec: 100, video: 'v4'),
          ],
        ),
      ],
    );

    test('0 / 4 -> 0%', () {
      final result = progressService.calculateCourseProgress(
        courseWithFourLessons,
        [],
      );
      expect(result, equals(0.0));
    });

    test('1 / 4 -> 25%', () {
      final progressList = [
        const LessonProgress(
          lessonId: 'L1',
          position: Duration(seconds: 100),
          completed: true,
        ),
      ];
      final result = progressService.calculateCourseProgress(
        courseWithFourLessons,
        progressList,
      );
      expect(result, equals(0.25));
    });

    test('2 / 4 -> 50%', () {
      final progressList = [
        const LessonProgress(
          lessonId: 'L1',
          position: Duration(seconds: 100),
          completed: true,
        ),
        const LessonProgress(
          lessonId: 'L2',
          position: Duration(seconds: 100),
          completed: true,
        ),
      ];
      final result = progressService.calculateCourseProgress(
        courseWithFourLessons,
        progressList,
      );
      expect(result, equals(0.50));
    });

    test('4 / 4 -> 100%', () {
      final progressList = [
        const LessonProgress(lessonId: 'L1', position: Duration(seconds: 100), completed: true),
        const LessonProgress(lessonId: 'L2', position: Duration(seconds: 100), completed: true),
        const LessonProgress(lessonId: 'L3', position: Duration(seconds: 100), completed: true),
        const LessonProgress(lessonId: 'L4', position: Duration(seconds: 100), completed: true),
      ];
      final result = progressService.calculateCourseProgress(
        courseWithFourLessons,
        progressList,
      );
      expect(result, equals(1.0));
    });

    test('0 lessons -> 0%', () {
      const emptyCourse = Course(
        id: 'empty',
        title: 'Empty Course',
        instructor: 'Instructor',
        thumbnail: 'thumb.png',
        sections: [],
      );
      final result = progressService.calculateCourseProgress(
        emptyCourse,
        [
          const LessonProgress(lessonId: 'L1', position: Duration(seconds: 100), completed: true),
        ],
      );
      expect(result, equals(0.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Additional Business Logic Tests: Status, Next Lesson, Continue Watching
  // ---------------------------------------------------------------------------
  group('Lesson status, Next lesson, and Continue watching', () {
    const course = Course(
      id: 'course-1',
      title: 'Course 1',
      instructor: 'Instructor',
      thumbnail: 'thumb.png',
      sections: [
        Section(
          id: 's1',
          title: 'Section 1',
          lessons: [
            Lesson(id: 'L1', title: 'L1', durationSec: 100, video: 'v1'),
            Lesson(id: 'L2', title: 'L2', durationSec: 100, video: 'v2'),
          ],
        ),
      ],
    );

    test('getLessonStatus resolves NotStarted, InProgress, Completed', () {
      expect(
        progressService.getLessonStatus('L1', []),
        equals(LessonStatus.notStarted),
      );

      expect(
        progressService.getLessonStatus('L1', [
          const LessonProgress(lessonId: 'L1', position: Duration(seconds: 30), completed: false),
        ]),
        equals(LessonStatus.inProgress),
      );

      expect(
        progressService.getLessonStatus('L1', [
          const LessonProgress(lessonId: 'L1', position: Duration(seconds: 95), completed: true),
        ]),
        equals(LessonStatus.completed),
      );
    });

    test('getNextLesson returns next lesson or null on last lesson', () {
      final next = progressService.getNextLesson(course, 'L1');
      expect(next?.id, equals('L2'));

      final lastNext = progressService.getNextLesson(course, 'L2');
      expect(lastNext, isNull);
    });

    test('findContinueWatching returns first in-progress lesson', () {
      final progressList = [
        const LessonProgress(lessonId: 'L1', position: Duration(seconds: 100), completed: true),
        const LessonProgress(lessonId: 'L2', position: Duration(seconds: 25), completed: false),
      ];

      final continueLesson = progressService.findContinueWatching(course, progressList);
      expect(continueLesson?.id, equals('L2'));
    });
  });
}
