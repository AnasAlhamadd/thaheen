import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../domain/entities/lesson_status.dart';
import '../../../../domain/entities/section.dart';
import '../../../player/domain/services/progress_service.dart';

/// Section card widget rendering a module group and its constituent lessons.
class CourseSectionAccordionCard extends StatelessWidget {
  /// The course entity.
  final Course course;

  /// The section entity.
  final Section section;

  /// Index of the section (0-based).
  final int sectionIndex;

  /// Global progress list for status checks.
  final List<LessonProgress> progressList;

  /// Domain progress calculation service.
  final ProgressService progressService;

  /// Callback when an unlocked lesson is tapped.
  final ValueChanged<Lesson> onLessonTap;

  /// Callback when a locked lesson is tapped.
  final void Function(Lesson lockedLesson, Lesson? prerequisiteLesson)
      onLockedLessonTap;

  /// Whether the lessons list is expanded.
  final bool isExpanded;

  /// Toggles the expanded state when the section header is tapped.
  final VoidCallback? onToggleExpand;

  /// Creates a [CourseSectionAccordionCard].
  const CourseSectionAccordionCard({
    super.key,
    required this.course,
    required this.section,
    required this.sectionIndex,
    required this.progressList,
    required this.progressService,
    required this.onLessonTap,
    required this.onLockedLessonTap,
    this.isExpanded = true,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allCourseLessons =
        course.sections.expand((s) => s.lessons).toList();
    final completedLessonIds =
        progressList.where((p) => p.completed).map((p) => p.lessonId).toSet();

    final sectionCompletedCount = section.lessons
        .where((l) => completedLessonIds.contains(l.id))
        .length;
    final isSectionAllCompleted =
        section.lessons.isNotEmpty &&
        sectionCompletedCount == section.lessons.length;
    final isSectionLocked = section.lessons.isNotEmpty &&
        !progressService.isLessonUnlocked(
          course,
          section.lessons.first.id,
          progressList,
        );

    final sectionStatusBadge = isSectionAllCompleted
        ? 'مكتمل بالكامل ✓'
        : isSectionLocked
        ? '${section.lessons.length} دروس · مقفل حالياً 🔒'
        : sectionCompletedCount > 0
        ? '${section.lessons.length} دروس · مكتمل جزئياً'
        : '${section.lessons.length} دروس · متاح للبدء';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSectionAllCompleted
              ? AppColors.successEmerald.withValues(alpha: 0.35)
              : isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeaderBar(
            title: section.title,
            sectionIndex: sectionIndex,
            statusBadge: sectionStatusBadge,
            isLocked: isSectionLocked,
            isCompleted: isSectionAllCompleted,
            isExpanded: isExpanded,
            onTap: onToggleExpand,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        itemCount: section.lessons.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final lesson = section.lessons[index];
                          final globalIndex = allCourseLessons.indexOf(lesson);
                          final isUnlocked = progressService.isLessonUnlocked(
                            course,
                            lesson.id,
                            progressList,
                          );
                          final status = progressService.getLessonStatus(
                            lesson.id,
                            progressList,
                          );
                          final lessonProgress = progressList
                              .cast<LessonProgress?>()
                              .firstWhere(
                                (p) => p?.lessonId == lesson.id,
                                orElse: () => null,
                              );

                          final Lesson? prereqLesson = globalIndex > 0
                              ? allCourseLessons[globalIndex - 1]
                              : null;

                          return _LessonItemCard(
                            lessonNumber:
                                (globalIndex + 1).toString().padLeft(2, '0'),
                            lesson: lesson,
                            isUnlocked: isUnlocked,
                            status: status,
                            progress: lessonProgress,
                            onTap: () {
                              if (isUnlocked) {
                                onLessonTap(lesson);
                              } else {
                                onLockedLessonTap(lesson, prereqLesson);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderBar extends StatelessWidget {
  final String title;
  final int sectionIndex;
  final String statusBadge;
  final bool isLocked;
  final bool isCompleted;
  final bool isExpanded;
  final VoidCallback? onTap;

  const _SectionHeaderBar({
    required this.title,
    required this.sectionIndex,
    required this.statusBadge,
    required this.isLocked,
    required this.isCompleted,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sectionIcon = sectionIndex == 0
        ? Icons.view_in_ar_rounded
        : Icons.fitness_center_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successEmerald.withValues(alpha: 0.15)
                  : isLocked
                  ? (isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFE2E8F0))
                  : (isDark
                      ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                      : const Color(0xFFE0F2FE)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              sectionIcon,
              size: 18,
              color: isCompleted
                  ? AppColors.successEmerald
                  : isLocked
                  ? (isDark
                      ? AppColors.darkTextDisabled
                      : AppColors.lightTextSecondary)
                  : (isDark ? const Color(0xFF38BDF8) : AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successEmerald.withValues(alpha: 0.12)
                  : (isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightLockedSurface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted
                    ? AppColors.successEmerald.withValues(alpha: 0.25)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
              ),
            ),
            child: Text(
              statusBadge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? AppColors.successEmerald
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonItemCard extends StatelessWidget {
  final String lessonNumber;
  final Lesson lesson;
  final bool isUnlocked;
  final LessonStatus status;
  final LessonProgress? progress;
  final VoidCallback onTap;

  const _LessonItemCard({
    required this.lessonNumber,
    required this.lesson,
    required this.isUnlocked,
    required this.status,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minutes = (lesson.durationSec ~/ 60).toString();
    final formattedDuration = '$minutes دقيقة';

    final isCurrentActive = isUnlocked && status == LessonStatus.inProgress;
    final isCompleted = isUnlocked && status == LessonStatus.completed;

    if (isCurrentActive) {
      return _buildActiveLessonCard(context, isDark, formattedDuration);
    }

    if (isCompleted) {
      return _buildCompletedLessonCard(context, isDark, formattedDuration);
    }

    if (isUnlocked) {
      return _buildUnlockedLessonCard(context, isDark, formattedDuration);
    }

    return _buildLockedLessonCard(context, isDark, formattedDuration);
  }

  Widget _buildActiveLessonCard(
    BuildContext context,
    bool isDark,
    String formattedDuration,
  ) {
    final progressPercentage = progress != null && lesson.durationSec > 0
        ? ((progress!.position.inSeconds / lesson.durationSec) * 100).toInt().clamp(0, 99)
        : 45;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2942),
                Color(0xFF0A4165),
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        lessonNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'نشط الآن',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Color(0xFFBAE6FD),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDuration,
                              style: const TextStyle(
                                color: Color(0xFFBAE6FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      'إنجاز $progressPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercentage / 100,
                          minHeight: 5,
                          backgroundColor: Colors.black26,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF86F2E4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'استكمال الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedLessonCard(
    BuildContext context,
    bool isDark,
    String formattedDuration,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF064E3B).withValues(alpha: 0.15)
                : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF059669).withValues(alpha: 0.3)
                  : const Color(0xFFBBF7D0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    lessonNumber,
                    style: const TextStyle(
                      color: AppColors.successEmerald,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.successEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'مكتمل ✓',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDuration,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: AppColors.successEmerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockedLessonCard(
    BuildContext context,
    bool isDark,
    String formattedDuration,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0369A1).withValues(alpha: 0.25)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    lessonNumber,
                    style: TextStyle(
                      color:
                          isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDuration,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF0369A1).withValues(alpha: 0.2)
                      : const Color(0xFFE0F2FE),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 20,
                  color:
                      isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedLessonCard(
    BuildContext context,
    bool isDark,
    String formattedDuration,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                : AppColors.lightLockedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkLockedSurface
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    lessonNumber,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextDisabled
                          : AppColors.lightTextDisabled,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextDisabled
                                  : AppColors.lightTextDisabled,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkLockedSurface
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'مقفل',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextDisabled
                                  : AppColors.lightTextDisabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextDisabled
                              : AppColors.lightTextDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'يتطلب إكمال الدرس السابق · $formattedDuration',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextDisabled
                                : AppColors.lightTextDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFE2E8F0),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextDisabled
                      : AppColors.lightTextDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
