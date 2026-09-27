import 'package:go_router/go_router.dart';
import '../features/courses/presentation/screens/courses_screen.dart';
import '../features/courses/presentation/screens/course_details_screen.dart';
import '../features/player/presentation/screens/lesson_player_screen.dart';

/// Central application router using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CoursesScreen(),
      routes: [
        GoRoute(
          path: 'courses/:courseId',
          builder: (context, state) {
            final courseId = state.pathParameters['courseId'] ?? '';
            return CourseDetailsScreen(courseId: courseId);
          },
          routes: [
            GoRoute(
              path: 'lessons/:lessonId',
              builder: (context, state) {
                final courseId = state.pathParameters['courseId'] ?? '';
                final lessonId = state.pathParameters['lessonId'] ?? '';
                return LessonPlayerScreen(
                  courseId: courseId,
                  lessonId: lessonId,
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/courses', redirect: (context, state) => '/'),
  ],
);
