import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../features/player/domain/repositories/progress_repository.dart';
import '../../../../features/player/domain/services/progress_service.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../domain/repositories/course_repository.dart';
import '../cubit/course_details_cubit.dart';
import '../cubit/course_details_state.dart';
import '../widgets/course_about_tab.dart';
import '../widgets/course_certificate_footer.dart';
import '../widgets/course_details_error_view.dart';
import '../widgets/course_details_loading_view.dart';
import '../widgets/course_details_top_bar.dart';
import '../widgets/course_empty_sections_card.dart';
import '../widgets/course_hero_header_card.dart';
import '../widgets/course_lock_bottom_sheet.dart';
import '../widgets/course_reviews_tab.dart';
import '../widgets/course_section_accordion_card.dart';
import '../widgets/course_segmented_tabs.dart';
import '../widgets/course_sequential_info_banner.dart';
import '../widgets/course_stats_strip.dart';
import '../widgets/course_sticky_bottom_bar.dart';
import '../widgets/course_syllabus_header.dart';

/// Screen displaying rich sections, lessons, sequential unlock states, and progress of a single course.
class CourseDetailsScreen extends StatelessWidget {
  /// Unique identifier of the course.
  final String courseId;

  /// Creates a [CourseDetailsScreen] for the given [courseId].
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseDetailsCubit(
        courseRepository: context.read<CourseRepository>(),
        progressRepository: context.read<ProgressRepository>(),
        progressService: context.read<ProgressService>(),
      )..loadCourseDetails(courseId),
      child: _CourseDetailsView(courseId: courseId),
    );
  }
}

class _CourseDetailsView extends StatefulWidget {
  final String courseId;

  const _CourseDetailsView({required this.courseId});

  @override
  State<_CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<_CourseDetailsView> {
  static const int _lessonsTabIndex = 1;

  int _activeTabIndex = _lessonsTabIndex;
  bool _bookmarked = false;
  Set<int> _expandedSections = {0};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        final loaded = state is CourseDetailsLoaded ? state : null;

        return GradientScaffold(
          appBar: CourseDetailsTopBar(
            title: loaded?.course.localizedTitle(
                  context.read<SettingsCubit>().state.language.languageCode,
                ),
            isBookmarked: _bookmarked,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            onShare: () => _showMessage(context, 'share_course_message'),
            onBookmark: () {
              setState(() => _bookmarked = !_bookmarked);
              _showMessage(
                context,
                _bookmarked ? 'bookmark_saved' : 'bookmark_removed',
              );
            },
          ),
          body: switch (state) {
            CourseDetailsInitial() || CourseDetailsLoading() =>
              const CourseDetailsLoadingView(),
            CourseDetailsError(:final messageKey) => CourseDetailsErrorView(
                messageKey: messageKey,
                onRetry: () => context
                    .read<CourseDetailsCubit>()
                    .loadCourseDetails(widget.courseId),
              ),
            CourseDetailsLoaded() => RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () => context
                    .read<CourseDetailsCubit>()
                    .loadCourseDetails(widget.courseId, silent: true),
                child: _LoadedCourseBody(
                  state: state,
                  activeTabIndex: _activeTabIndex,
                  expandedSections: _expandedSections,
                  onTabSelected: (index) =>
                      setState(() => _activeTabIndex = index),
                  onToggleSection: _toggleSection,
                  onToggleExpandAll: () => _toggleExpandAll(state),
                  onOpenLesson: (lesson) => _openLesson(context, state, lesson),
                ),
              ),
          },
          bottomNavigationBar: loaded?.activeLesson == null
              ? null
              : CourseStickyBottomBar(
                  completedLessonsCount: loaded!.completedLessonsCount,
                  totalLessonsCount: loaded.totalLessonsCount,
                  activeLesson: loaded.activeLesson!,
                  onResume: () =>
                      _openLesson(context, loaded, loaded.activeLesson!),
                ),
        );
      },
    );
  }

  void _toggleSection(int index) {
    setState(() {
      if (_expandedSections.contains(index)) {
        _expandedSections = {..._expandedSections}..remove(index);
      } else {
        _expandedSections = {..._expandedSections, index};
      }
    });
  }

  void _toggleExpandAll(CourseDetailsLoaded state) {
    final sectionCount = state.course.sections.length;
    final allExpanded =
        sectionCount > 0 && _expandedSections.length == sectionCount;

    setState(() {
      _expandedSections = allExpanded
          ? <int>{}
          : {for (var i = 0; i < sectionCount; i++) i};
    });
  }

  Future<void> _openLesson(
    BuildContext context,
    CourseDetailsLoaded state,
    Lesson lesson,
  ) async {
    await context.push('/courses/${state.course.id}/lessons/${lesson.id}');
    if (!context.mounted) return;
    await context.read<CourseDetailsCubit>().loadCourseDetails(
          state.course.id,
          silent: true,
        );
  }

  void _showMessage(BuildContext context, String translationKey) {
    final langCode = context.read<SettingsCubit>().state.language.languageCode;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppStrings.tr(translationKey, langCode))),
      );
  }
}

class _LoadedCourseBody extends StatelessWidget {
  final CourseDetailsLoaded state;
  final int activeTabIndex;
  final Set<int> expandedSections;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onToggleSection;
  final VoidCallback onToggleExpandAll;
  final ValueChanged<Lesson> onOpenLesson;

  const _LoadedCourseBody({
    required this.state,
    required this.activeTabIndex,
    required this.expandedSections,
    required this.onTabSelected,
    required this.onToggleSection,
    required this.onToggleExpandAll,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final progressService = context.read<ProgressService>();
    final course = state.course;
    final sectionCount = course.sections.length;
    final allExpanded =
        sectionCount > 0 && expandedSections.length == sectionCount;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 12,),) ,
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 6) ,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              CourseHeroHeaderCard(
                course: course,
                progressRatio: state.progressRatio,
                onPlayPreview: () {
                  final lesson = state.activeLesson;
                  if (lesson != null) onOpenLesson(lesson);
                },
              ),
              const SizedBox(height: 14),
              CourseStatsStrip(
                totalLessons: state.totalLessonsCount,
                totalHours: state.totalHoursLabel,
                progressRatio: state.progressRatio,
              ),
              const SizedBox(height: 14),
              CourseSegmentedTabs(
                selectedIndex: activeTabIndex,
                onTabSelected: onTabSelected,
              ),
              const SizedBox(height: 14),
              if (activeTabIndex == 0) CourseAboutTab(course: course),
              if (activeTabIndex == 2) const CourseReviewsTab(),
              if (activeTabIndex == 1) ...[
                CourseSyllabusHeader(
                  totalLessons: state.totalLessonsCount,
                  totalHours: state.totalHoursLabel,
                  allExpanded: allExpanded,
                  onToggleExpandAll: onToggleExpandAll,
                ),
                const SizedBox(height: 12),
                const CourseSequentialInfoBanner(),
                const SizedBox(height: 16),
                if (!state.hasLessons)
                  const CourseEmptySectionsCard()
                else
                  ...course.sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    return CourseSectionAccordionCard(
                      course: course,
                      section: entry.value,
                      sectionIndex: index,
                      progressList: state.progressList,
                      progressService: progressService,
                      isExpanded: expandedSections.contains(index),
                      onToggleExpand: () => onToggleSection(index),
                      onLessonTap: onOpenLesson,
                      onLockedLessonTap: (lockedLesson, prerequisiteLesson) {
                        final langCode = context
                            .read<SettingsCubit>()
                            .state
                            .language
                            .languageCode;
                        CourseLockBottomSheet.show(
                          context,
                          targetLessonTitle:
                              lockedLesson.localizedTitle(langCode),
                          prerequisiteLesson: prerequisiteLesson,
                          onNavigateToPrerequisite: () {
                            if (prerequisiteLesson != null) {
                              onOpenLesson(prerequisiteLesson);
                            }
                          },
                        );
                      },
                    );
                  }),
                const CourseCertificateFooter(),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}
