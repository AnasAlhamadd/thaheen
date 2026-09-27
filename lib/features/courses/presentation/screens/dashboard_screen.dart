import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../features/player/domain/services/progress_service.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/academic_kickoff_banner.dart';
import '../widgets/course_card_item.dart';
import '../widgets/course_card_shimmer.dart';

/// Dashboard screen showing student progress, active courses, and learning banners.
class DashboardScreen extends StatefulWidget {
  /// List of courses to display.
  final List<Course> courses;

  /// List of lesson progress data.
  final List<LessonProgress> progressList;

  /// Creates a [DashboardScreen].
  const DashboardScreen({
    super.key,
    required this.courses,
    required this.progressList,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressService = context.read<ProgressService>();

    // Find the first incomplete lesson across all courses
    final nextIncomplete = progressService.findNextIncompleteLesson(
      widget.courses,
      widget.progressList,
    );

    final continueCourse = nextIncomplete?.course;
    final continueLesson = nextIncomplete?.lesson;
    final continueProgress = nextIncomplete?.progress;

    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, coursesState) {
        final showShimmer = coursesState is CoursesLoaded && coursesState.isSearching;
        final filteredCourses = coursesState is CoursesLoaded 
            ? coursesState.filteredCourses 
            : widget.courses;
        final searchQuery = coursesState is CoursesLoaded 
            ? coursesState.searchQuery 
            : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AcademicKickoffBanner(
              continueCourse: continueCourse,
              continueLesson: continueLesson,
              lessonProgress: continueProgress,
              onReturnFromLesson: () {
                // Reload courses when returning from lesson player
                context.read<CoursesCubit>().reloadCourses();
              },
              onKickoffActionPressed: () async {
                // Navigate to first lesson when no progress exists
                // Use push instead of go to allow back navigation to dashboard
                if (widget.courses.isNotEmpty) {
                  final firstCourse = widget.courses.first;
                  final firstLesson = firstCourse.sections.first.lessons.first;
                  await context.push('/courses/${firstCourse.id}/lessons/${firstLesson.id}');
                  
                  // Reload courses when returning from lesson player
                  if (context.mounted) {
                    context.read<CoursesCubit>().reloadCourses();
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _SearchField(
              controller: _searchController,
              onChanged: (query) {
                context.read<CoursesCubit>().searchCourses(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<CoursesCubit>().clearSearch();
              },
            ),
            const SizedBox(height: 16),
            _ActiveCoursesSectionHeader(count: filteredCourses.length),
            const SizedBox(height: 12),
            if (showShimmer)
              ...List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: CourseCardShimmer(),
              ))
            else if (filteredCourses.isEmpty && searchQuery.isNotEmpty)
              _NoResultsWidget()
            else
              ...filteredCourses.map((course) {
                final progressRatio = progressService.calculateCourseProgress(
                  course,
                  widget.progressList,
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
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? AppColors.darkTextPrimary 
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.tr('search_courses', langCode),
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
                size: 20,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDark 
                            ? AppColors.darkTextSecondary 
                            : AppColors.lightTextSecondary,
                        size: 20,
                      ),
                      onPressed: widget.onClear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoResultsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.tr('no_search_results', langCode),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveCoursesSectionHeader extends StatelessWidget {
  final int count;

  const _ActiveCoursesSectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            AppCustomText(
              'active_courses_section',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.language != curr.language,
            builder: (context, state) {
              final langCode = state.language.languageCode;
              return Text(
                AppStrings.trArgs(
                  'available_courses_count',
                  langCode,
                  {'count': '$count'},
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
