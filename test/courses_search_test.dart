import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen/domain/entities/course.dart';
import 'package:thaheen/domain/entities/lesson_progress.dart';
import 'package:thaheen/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:thaheen/features/courses/presentation/cubit/courses_state.dart';
import 'package:thaheen/features/courses/domain/repositories/course_repository.dart';
import 'package:thaheen/features/player/domain/repositories/progress_repository.dart';

/// Mock repository that returns test courses.
class MockCourseRepository implements CourseRepository {
  final List<Course> _courses;

  MockCourseRepository(this._courses);

  @override
  Future<List<Course>> getCourses() async => _courses;

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Mock repository that returns empty progress.
class MockProgressRepository implements ProgressRepository {
  @override
  Future<Map<String, LessonProgress>> getAllProgress() async => {};

  @override
  Future<String?> getLastWatchedLessonId() async => null;

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async => null;

  @override
  Future<void> savePosition(String lessonId, Duration position) async {}

  @override
  Future<void> markCompleted(String lessonId) async {}

  @override
  Future<void> setLastWatchedLessonId(String lessonId) async {}
}

void main() {
  late CoursesCubit cubit;
  late List<Course> testCourses;

  setUp(() {
    // Create test courses with Arabic and English content
    testCourses = [
      const Course(
        id: 'course1',
        title: 'التشريح السريري',
        titleEn: 'Clinical Anatomy',
        instructor: 'د. أحمد محمد',
        instructorEn: 'Dr. Ahmed Mohamed',
        thumbnail: 'thumb1.jpg',
        sections: [],
      ),
      const Course(
        id: 'course2',
        title: 'علم وظائف الأعضاء',
        titleEn: 'Physiology',
        instructor: 'د. فاطمة علي',
        instructorEn: 'Dr. Fatima Ali',
        thumbnail: 'thumb2.jpg',
        sections: [],
      ),
      const Course(
        id: 'course3',
        title: 'الكيمياء الحيوية',
        titleEn: 'Biochemistry',
        instructor: 'د. محمود حسن',
        instructorEn: 'Dr. Mahmoud Hassan',
        thumbnail: 'thumb3.jpg',
        sections: [],
      ),
      // Course with alef variations for testing normalization
      const Course(
        id: 'course4',
        title: 'أمراض القلب والأوعية',
        titleEn: 'Cardiovascular Diseases',
        instructor: 'د. إبراهيم',
        instructorEn: 'Dr. Ibrahim',
        thumbnail: 'thumb4.jpg',
        sections: [],
      ),
    ];

    cubit = CoursesCubit(
      courseRepository: MockCourseRepository(testCourses),
      progressRepository: MockProgressRepository(),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Course Search - Character Count Rules', () {
    test('0 characters → shows all courses', () async {
      // Load courses first
      await cubit.loadCourses();
      
      // Search with empty string
      cubit.searchCourses('');
      
      final state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, '');
      expect(state.filteredCourses.length, 4);
      expect(state.isSearching, false);
    });

    test('1 character → shows all courses (no search)', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('ت');
      
      final state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, 'ت');
      expect(state.filteredCourses.length, 4);
      expect(state.isSearching, false);
    });

    test('2+ characters → triggers search with loading state', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('تش');
      
      // Should immediately show loading state
      var state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, 'تش');
      expect(state.isSearching, true);
      
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Should show filtered results
      state = cubit.state as CoursesLoaded;
      expect(state.isSearching, false);
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.title, 'التشريح السريري');
    });
  });

  group('Course Search - Arabic Title Match', () {
    test('finds course by exact Arabic title', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('التشريح');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.id, 'course1');
    });

    test('finds course by partial Arabic title', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('وظائف');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.id, 'course2');
    });

    test('normalizes alef variations (أ/إ/آ → ا)', () async {
      await cubit.loadCourses();
      
      // Search with plain alef when course has أ and إ
      cubit.searchCourses('امراض');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.id, 'course4');
    });

    test('normalizes instructor alef variations', () async {
      await cubit.loadCourses();
      
      // Search for إبراهيم with plain alef
      cubit.searchCourses('ابراهيم');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.instructorEn, 'Dr. Ibrahim');
    });
  });

  group('Course Search - Instructor Match', () {
    test('finds course by Arabic instructor name', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('أحمد');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.instructor, 'د. أحمد محمد');
    });

    test('finds course by partial instructor name', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('فاطمة');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.id, 'course2');
    });
  });

  group('Course Search - English Case-Insensitive', () {
    test('finds course by lowercase English title', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('anatomy');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.titleEn, 'Clinical Anatomy');
    });

    test('finds course by uppercase English title', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('PHYSIOLOGY');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.titleEn, 'Physiology');
    });

    test('finds course by mixed case English title', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('BiOcHeMiStRy');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.id, 'course3');
    });

    test('finds course by case-insensitive English instructor', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('fatima');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      expect(state.filteredCourses.first.instructorEn, 'Dr. Fatima Ali');
    });
  });

  group('Course Search - No Results', () {
    test('returns empty list when no match found', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('xyz123');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.isEmpty, true);
      expect(state.searchQuery, 'xyz123');
    });

    test('returns empty list for non-existent Arabic term', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('كلمة غير موجودة');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.isEmpty, true);
    });
  });

  group('Course Search - Debounce Behavior', () {
    test('rapid query changes cancel previous debounce', () async {
      await cubit.loadCourses();
      
      // Rapid changes
      cubit.searchCourses('ت');
      await Future.delayed(const Duration(milliseconds: 100));
      
      cubit.searchCourses('تش');
      await Future.delayed(const Duration(milliseconds: 100));
      
      cubit.searchCourses('تشر');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should still be in loading state
      var state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, 'تشر');
      
      // Wait for final debounce
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Should show final filtered results
      state = cubit.state as CoursesLoaded;
      expect(state.isSearching, false);
      expect(state.filteredCourses.length, 1);
    });

    test('debounce waits 400ms before filtering', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('تشريح');
      
      // After 200ms, should still be searching
      await Future.delayed(const Duration(milliseconds: 200));
      var state = cubit.state as CoursesLoaded;
      expect(state.isSearching, true);
      
      // After 500ms total, should be done
      await Future.delayed(const Duration(milliseconds: 300));
      state = cubit.state as CoursesLoaded;
      expect(state.isSearching, false);
      expect(state.filteredCourses.length, 1);
    });
  });

  group('Course Search - Clear Functionality', () {
    test('clearing query restores all courses immediately', () async {
      await cubit.loadCourses();
      
      // Search first
      cubit.searchCourses('تشريح');
      await Future.delayed(const Duration(milliseconds: 500));
      
      var state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 1);
      
      // Clear search
      cubit.clearSearch();
      
      // Should immediately restore all courses
      state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, '');
      expect(state.filteredCourses.length, 4);
      expect(state.isSearching, false);
    });

    test('clearing cancels pending debounce', () async {
      await cubit.loadCourses();
      
      // Start search
      cubit.searchCourses('تشريح');
      
      // Clear immediately before debounce completes
      cubit.clearSearch();
      
      // Wait for would-be debounce
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Should still show all courses
      final state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, '');
      expect(state.filteredCourses.length, 4);
    });
  });

  group('Course Search - State Preservation', () {
    test('search does not mutate original courses list', () async {
      await cubit.loadCourses();
      
      final initialState = cubit.state as CoursesLoaded;
      final originalCount = initialState.courses.length;
      
      cubit.searchCourses('تشريح');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final searchState = cubit.state as CoursesLoaded;
      
      // Original courses should remain unchanged
      expect(searchState.courses.length, originalCount);
      expect(searchState.filteredCourses.length, 1);
    });

    test('multiple searches preserve course data', () async {
      await cubit.loadCourses();
      
      // Search 1
      cubit.searchCourses('أحمد');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Search 2
      cubit.searchCourses('فاطمة');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear
      cubit.clearSearch();
      
      final state = cubit.state as CoursesLoaded;
      expect(state.courses.length, 4);
      expect(state.filteredCourses.length, 4);
    });
  });

  group('Course Search - Edge Cases', () {
    test('handles whitespace-only query', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('   ');
      
      final state = cubit.state as CoursesLoaded;
      expect(state.filteredCourses.length, 4);
      expect(state.isSearching, false);
    });

    test('trims leading and trailing whitespace', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('  تشريح  ');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      expect(state.searchQuery, 'تشريح');
      expect(state.filteredCourses.length, 1);
    });

    test('handles special characters in search', () async {
      await cubit.loadCourses();
      
      cubit.searchCourses('د.');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final state = cubit.state as CoursesLoaded;
      // Should match all instructors with د. prefix
      expect(state.filteredCourses.length, 4);
    });
  });
}
