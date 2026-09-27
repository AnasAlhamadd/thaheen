import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/widgets/thaheen_app_bar.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/my_courses_screen.dart';
import '../../domain/repositories/course_repository.dart';
import '../../../player/domain/repositories/progress_repository.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/thaheen_bottom_navigation_bar.dart';

/// Primary root screen presenting the Thaheen LMS dashboard and bottom navigation.
class CoursesScreen extends StatefulWidget {
  /// Creates the [CoursesScreen].
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late final ValueNotifier<int> _currentTabIndex;
  CoursesCubit? _coursesCubit;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = ValueNotifier<int>(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize cubit here where context is available
    _coursesCubit ??= CoursesCubit(
      courseRepository: context.read<CourseRepository>(),
      progressRepository: context.read<ProgressRepository>(),
    )..loadCourses();
  }

  @override
  void dispose() {
    _currentTabIndex.dispose();
    _coursesCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check
    if (_coursesCubit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _coursesCubit!,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentTabIndex,
        builder: (context, activeIndex, _) {
          return BlocBuilder<CoursesCubit, CoursesState>(
            builder: (context, state) {
              return ThaheenBottomNavigationBar(
                currentIndex: activeIndex,
                onTabSelected: (index) => _currentTabIndex.value = index,
                child: GradientScaffold(
                  body: switch (state) {
                    CoursesInitial() || CoursesLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    CoursesError(:final message) => _ErrorStateView(
                      message: message,
                    ),
                    CoursesLoaded(:final courses, :final progressList) =>
                      _buildTabBodyWithAppBar(
                        activeIndex: activeIndex,
                        courses: courses,
                        progressList: progressList,
                      ),
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabBodyWithAppBar({
    required int activeIndex,
    required List<Course> courses,
    required List<LessonProgress> progressList,
  }) {
    // Build the content slivers based on active tab
    final contentSlivers = _buildTabContentSlivers(
      activeIndex: activeIndex,
      courses: courses,
      progressList: progressList,
    );

    return CustomScrollView(
      slivers: [
        // Integrated AppBar as a sliver
        SliverToBoxAdapter(
          child: ThaheenAppBar(
            userName: 'محمد',
            onProfileTap: () => _currentTabIndex.value = 2,
            onSettingsTap: () => _currentTabIndex.value = 2,
          ),
        ),
        // Tab content as slivers
        ...contentSlivers,
        // مساحة إضافية للـ nav bar العائم
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  List<Widget> _buildTabContentSlivers({
    required int activeIndex,
    required List<Course> courses,
    required List<LessonProgress> progressList,
  }) {
    return switch (activeIndex) {
      0 => _buildDashboardSlivers(courses, progressList),
      1 => _buildMyCoursesSlivers(courses, progressList),
      2 => _buildProfileSlivers(),
      _ => _buildDashboardSlivers(courses, progressList),
    };
  }

  List<Widget> _buildDashboardSlivers(
    List<Course> courses,
    List<LessonProgress> progressList,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            DashboardScreen(courses: courses, progressList: progressList),
          ]),
        ),
      ),
    ];
  }

  List<Widget> _buildMyCoursesSlivers(
    List<Course> courses,
    List<LessonProgress> progressList,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            MyCoursesScreen(courses: courses, progressList: progressList),
          ]),
        ),
      ),
    ];
  }

  List<Widget> _buildProfileSlivers() {
    return [SliverToBoxAdapter(child: const ProfileScreen())];
  }
}

class _ErrorStateView extends StatelessWidget {
  final String message;

  const _ErrorStateView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorCoral,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<CoursesCubit>().loadCourses(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF0284C7)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
