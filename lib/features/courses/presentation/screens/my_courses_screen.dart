import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../features/player/domain/services/progress_service.dart';
import '../cubit/courses_cubit.dart';
import '../widgets/course_card_item.dart';

/// My Courses screen showing all available courses with progress tracking.
class MyCoursesScreen extends StatelessWidget {
  /// List of courses to display.
  final List<Course> courses;

  /// List of lesson progress data.
  final List<LessonProgress> progressList;

  /// Creates a [MyCoursesScreen].
  const MyCoursesScreen({
    super.key,
    required this.courses,
    required this.progressList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressService = context.read<ProgressService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'جميع المسارات التعليمية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        ...courses.map((course) {
          final progressRatio = progressService.calculateCourseProgress(
            course,
            progressList,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CourseCardItem(
              course: course,
              progressRatio: progressRatio,
              onReturnFromCourse: () {
                context.read<CoursesCubit>().reloadCourses();
              },
            ),
          );
        }),
      ],
    );
  }
}
