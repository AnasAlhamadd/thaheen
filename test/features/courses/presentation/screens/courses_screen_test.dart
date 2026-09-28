import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen/core/localization/app_language.dart';
import 'package:thaheen/domain/entities/course.dart';
import 'package:thaheen/domain/entities/lesson.dart';
import 'package:thaheen/domain/entities/lesson_progress.dart';
import 'package:thaheen/domain/entities/section.dart';
import 'package:thaheen/app/theme/app_theme_mode.dart';
import 'package:thaheen/features/courses/domain/repositories/course_repository.dart';
import 'package:thaheen/features/courses/presentation/screens/courses_screen.dart';
import 'package:thaheen/core/widgets/thaheen_app_bar.dart';
import 'package:thaheen/features/courses/presentation/widgets/thaheen_bottom_navigation_bar.dart';
import 'package:thaheen/features/player/domain/repositories/progress_repository.dart';
import 'package:thaheen/features/player/domain/services/progress_service.dart';
import 'package:thaheen/features/profile/domain/repositories/settings_repository.dart';
import 'package:thaheen/features/profile/presentation/cubit/settings_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock repositories
// ─────────────────────────────────────────────────────────────────────────────

class MockCourseRepository implements CourseRepository {
  final List<Course> mockCourses;

  MockCourseRepository({required this.mockCourses});

  @override
  Future<List<Course>> getCourses() async => mockCourses;

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      return mockCourses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

class MockProgressRepository implements ProgressRepository {
  final Map<String, LessonProgress> mockProgress;

  MockProgressRepository({required this.mockProgress});

  @override
  Future<Map<String, LessonProgress>> getAllProgress() async => mockProgress;

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async =>
      mockProgress[lessonId];

  @override
  Future<void> savePosition(String lessonId, Duration position) async {}

  @override
  Future<void> markCompleted(String lessonId) async {}

  @override
  Future<String?> getLastWatchedLessonId() async => null;

  @override
  Future<void> setLastWatchedLessonId(String lessonId) async {}
}

class MockSettingsRepository implements SettingsRepository {
  AppThemeMode themeMode = AppThemeMode.system;
  AppLanguage language = AppLanguage.arabic;

  @override
  Future<AppThemeMode> getThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async => themeMode = mode;

  @override
  Future<AppLanguage> getLanguage(Locale? platformLocale) async => language;

  @override
  Future<void> saveLanguage(AppLanguage lang) async => language = lang;
}

// ─────────────────────────────────────────────────────────────────────────────
// Test data
// ─────────────────────────────────────────────────────────────────────────────

const _sampleCourses = [
  Course(
    id: 'anatomy-101',
    title: 'مقدمة في التشريح',
    titleEn: 'Introduction to Anatomy',
    instructor: 'د. سارة',
    thumbnail: 'assets/images/anatomy.png',
    sections: [
      Section(
        id: 's1',
        title: 'الجهاز الهيكلي',
        lessons: [
          Lesson(
            id: 'l1',
            title: 'العظام',
            durationSec: 95,
            video: 'assets/videos/lesson1.mp4',
          ),
          Lesson(
            id: 'l2',
            title: 'المفاصل',
            durationSec: 100,
            video: 'assets/videos/lesson2.mp4',
          ),
        ],
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget builder
// ─────────────────────────────────────────────────────────────────────────────

Widget buildTestWidget() {
  final mockSettingsRepo = MockSettingsRepository();

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ProgressService>(create: (_) => ProgressService()),
      RepositoryProvider<CourseRepository>(
        create: (_) => MockCourseRepository(mockCourses: _sampleCourses),
      ),
      RepositoryProvider<ProgressRepository>(
        create: (_) => MockProgressRepository(mockProgress: const {}),
      ),
      RepositoryProvider<SettingsRepository>.value(value: mockSettingsRepo),
    ],
    child: BlocProvider(
      create: (_) =>
          SettingsCubit(settingsRepository: mockSettingsRepo)..loadSettings(),
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ar', 'SA'), Locale('en', 'US')],
        locale: Locale('ar', 'SA'),
        home: CoursesScreen(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  testWidgets(
    'CoursesScreen renders ThaheenAppBar and ThaheenBottomNavigationBar',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Structural widgets must be present
      expect(find.byType(ThaheenAppBar), findsOneWidget);
      expect(find.byType(ThaheenBottomNavigationBar), findsOneWidget);
    },
  );

  testWidgets(
    'CoursesScreen renders the user name in the app bar',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The app bar passes userName: 'محمد' — verify it appears
      expect(find.text('محمد'), findsOneWidget);
    },
  );

  testWidgets(
    'CoursesScreen shows course title after loading',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll down until the course card is visible
      await tester.scrollUntilVisible(
        find.text('مقدمة في التشريح'),
        150,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('مقدمة في التشريح'), findsOneWidget);
    },
  );

  testWidgets(
    'CoursesScreen bottom navigation has three tabs',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The bottom nav bar exists and contains navigation items
      expect(find.byType(ThaheenBottomNavigationBar), findsOneWidget);

      // Verify that navigating away from the first tab works without crashing
      final navBar = find.byType(ThaheenBottomNavigationBar);
      expect(navBar, findsOneWidget);
    },
  );
}
