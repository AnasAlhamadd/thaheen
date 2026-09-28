import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';

/// Course plan section showing the lesson queue for the current course.
///
/// Displays all sections and lessons with the current lesson highlighted
/// as "Now Playing", the next lesson marked, and locked lessons shown
/// with appropriate affordances — matching the Thaheen design reference.
class CoursePlanSection extends StatelessWidget {
  /// The course containing sections and lessons.
  final Course course;

  /// The currently playing lesson ID.
  final String currentLessonId;

  /// Set of completed lesson IDs.
  final Set<String> completedLessonIds;

  /// Callback when a lesson is tapped.
  final ValueChanged<Lesson>? onLessonTap;

  /// Creates a [CoursePlanSection].
  const CoursePlanSection({
    super.key,
    required this.course,
    required this.currentLessonId,
    required this.completedLessonIds,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Calculate total lessons and sections
    final allLessons =
        course.sections.expand((s) => s.lessons).toList();
    final totalLessons = allLessons.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 20,
              color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'خطة المقرر الدراسي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${course.title} ($totalLessons دروس)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sections and lessons
        ...course.sections.map(
          (section) => _SectionGroup(
            sectionTitle: section.title,
            sectionIcon: _sectionIcon(section.title),
            lessons: section.lessons,
            allLessons: allLessons,
            currentLessonId: currentLessonId,
            completedLessonIds: completedLessonIds,
            onLessonTap: onLessonTap,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  IconData _sectionIcon(String title) {
    if (title.contains('هيكلي') || title.contains('عظام')) {
      return Icons.accessibility_new_rounded;
    }
    if (title.contains('عضلي') || title.contains('عضل')) {
      return Icons.fitness_center_rounded;
    }
    if (title.contains('عصبي')) {
      return Icons.psychology_rounded;
    }
    return Icons.category_rounded;
  }
}

class _SectionGroup extends StatelessWidget {
  final String sectionTitle;
  final IconData sectionIcon;
  final List<Lesson> lessons;
  final List<Lesson> allLessons;
  final String currentLessonId;
  final Set<String> completedLessonIds;
  final ValueChanged<Lesson>? onLessonTap;
  final bool isDark;

  const _SectionGroup({
    required this.sectionTitle,
    required this.sectionIcon,
    required this.lessons,
    required this.allLessons,
    required this.currentLessonId,
    required this.completedLessonIds,
    this.onLessonTap,
    required this.isDark,
  });

  bool _isLessonUnlocked(Lesson lesson) {
    final index = allLessons.indexWhere((l) => l.id == lesson.id);
    if (index <= 0) return true;
    return completedLessonIds.contains(allLessons[index - 1].id);
  }

  int _totalSectionDuration() {
    return lessons.fold(0, (sum, l) => sum + l.durationSec);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  sectionIcon,
                  size: 18,
                  color: isDark
                      ? const Color(0xFF38BDF8)
                      : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${lessons.length} ${lessons.length == 1 ? 'درس' : 'دروس'} · ${_totalSectionDuration()} ث',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lesson cards
          ...lessons.map((lesson) {
            final isCurrent = lesson.id == currentLessonId;
            final isCompleted = completedLessonIds.contains(lesson.id);
            final isUnlocked = _isLessonUnlocked(lesson);
            final lessonIndex =
                allLessons.indexWhere((l) => l.id == lesson.id) + 1;

            // Determine if this is the next lesson after current
            final currentIndex = allLessons
                .indexWhere((l) => l.id == currentLessonId);
            final isNext = lessonIndex == currentIndex + 2 && isUnlocked;

            return _LessonTile(
              lesson: lesson,
              lessonIndex: lessonIndex,
              isCurrent: isCurrent,
              isCompleted: isCompleted,
              isLocked: !isUnlocked,
              isNext: isNext,
              onTap: onLessonTap,
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            );
          }),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int lessonIndex;
  final bool isCurrent;
  final bool isCompleted;
  final bool isLocked;
  final bool isNext;
  final ValueChanged<Lesson>? onTap;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _LessonTile({
    required this.lesson,
    required this.lessonIndex,
    required this.isCurrent,
    required this.isCompleted,
    required this.isLocked,
    required this.isNext,
    this.onTap,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} د ($sec ث)';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLocked ? null : () => onTap?.call(lesson),
          borderRadius: BorderRadius.circular(14),
          child: Opacity(
            opacity: isLocked ? 0.7 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? (isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.2))
                      : borderColor.withValues(alpha: 0.5),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Active indicator strip for current lesson
                  if (isCurrent)
                    Container(
                      width: 4,
                      height: 44,
                      margin: const EdgeInsetsDirectional.only(end: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                  // Leading icon
                  _buildLeadingIcon(),

                  const SizedBox(width: 12),

                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isCurrent) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0284C7)
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'يُعرض الآن',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (isNext && !isCurrent) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'الدرس القادم',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (isLocked) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'مقفل',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextDisabled
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              'الدرس $lessonIndex',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Duration & chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDuration(lesson.durationSec),
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrent
                              ? (isDark
                                  ? const Color(0xFF38BDF8)
                                  : AppColors.primary)
                              : textSecondary,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (isCompleted)
                        const Text(
                          'مكتملة ✓',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                    ],
                  ),

                  if (!isCurrent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkTextDisabled
                          : AppColors.lightTextDisabled,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (isCurrent) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0284C7) : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 22,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 22,
        ),
      );
    }

    if (isLocked) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_rounded,
          color: isDark
              ? AppColors.darkTextDisabled
              : const Color(0xFF94A3B8),
          size: 20,
        ),
      );
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.smart_display_rounded,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        size: 22,
      ),
    );
  }
}
