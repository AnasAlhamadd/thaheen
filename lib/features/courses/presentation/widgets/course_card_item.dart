import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../domain/entities/course.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// A modern premium course card that displays course metadata dynamically
/// derived from the course's nested sections/lessons tree.
///
/// Layout (RTL-aware):
/// ┌──────────────────────────────────────────────────────┐
/// │                                                      │
/// │  Title                                    [IMAGE]   │
/// │  Instructor                                          │
/// │                                                      │
/// │  ── Sections  •  Lessons  •  Duration ──             │
/// │                                                      │
/// │  ══ Progress bar ══════════════   42%                │
/// └──────────────────────────────────────────────────────┘
class CourseCardItem extends StatelessWidget {
  final Course course;
  final double progressRatio;
  final VoidCallback? onReturnFromCourse;

  const CourseCardItem({
    super.key,
    required this.course,
    required this.progressRatio,
    this.onReturnFromCourse,
  });

  // ── computed metadata ─────────────────────────────────

  int get _totalSections => course.sections.length;

  int get _totalLessons =>
      course.sections.fold(0, (sum, s) => sum + s.lessons.length);

  int get _totalDurationSec => course.sections.fold(
        0,
        (sum, s) => sum + s.lessons.fold(0, (ls, l) => ls + l.durationSec),
      );

  String _formatDuration(int totalSec) {
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')} س';
    return '$m د';
  }

  // ── build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = (progressRatio * 100).toInt();

    final Color progressColor = percentage == 100
        ? AppColors.successEmerald
        : (isDark ? const Color(0xFF38BDF8) : AppColors.primary);

    final Color cardBg =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await context.push('/courses/${course.id}');
          if (context.mounted) {
            onReturnFromCourse?.call();
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.07),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── card body ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── left / RTL-leading text column ─
                      Expanded(
                        child: _CardTextColumn(
                          course: course,
                          totalSections: _totalSections,
                          totalLessons: _totalLessons,
                          durationText: _formatDuration(_totalDurationSec),
                          progressRatio: progressRatio,
                          percentage: percentage,
                          progressColor: progressColor,
                          isDark: isDark,
                        ),
                      ),
                      // ── thumbnail image area ────────────
                      _CourseIllustration(
                        thumbnailPath: course.thumbnail,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Text column: title, instructor, metadata chips, progress
// ────────────────────────────────────────────────────────

class _CardTextColumn extends StatelessWidget {
  final Course course;
  final int totalSections;
  final int totalLessons;
  final String durationText;
  final double progressRatio;
  final int percentage;
  final Color progressColor;
  final bool isDark;

  const _CardTextColumn({
    required this.course,
    required this.totalSections,
    required this.totalLessons,
    required this.durationText,
    required this.progressRatio,
    required this.percentage,
    required this.progressColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final langCode =
        context.read<SettingsCubit>().state.language.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Course title
        Text(
          course.localizedTitle(langCode),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // Instructor row
        _InstructorRow(
          instructor: course.localizedInstructor(langCode),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Metadata chips row
        _MetadataRow(
          totalSections: totalSections,
          totalLessons: totalLessons,
          durationText: durationText,
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        // Progress bar
        _ProgressRow(
          progressRatio: progressRatio,
          percentage: percentage,
          progressColor: progressColor,
          isDark: isDark,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// Instructor row
// ────────────────────────────────────────────────────────

class _InstructorRow extends StatelessWidget {
  final String instructor;
  final bool isDark;

  const _InstructorRow({required this.instructor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_rounded,
            size: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            instructor,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────
// Metadata chips: sections · lessons · duration
// ────────────────────────────────────────────────────────

class _MetadataRow extends StatelessWidget {
  final int totalSections;
  final int totalLessons;
  final String durationText;
  final bool isDark;

  const _MetadataRow({
    required this.totalSections,
    required this.totalLessons,
    required this.durationText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MetaChip(
              icon: Icons.layers_rounded,
              label: AppStrings.trArgs(
                'sections_count',
                langCode,
                {'count': '$totalSections'},
              ),
              isDark: isDark,
            ),
            _MetaSeparator(isDark: isDark),
            _MetaChip(
              icon: Icons.play_lesson_rounded,
              label: AppStrings.trArgs(
                'lessons_count_label',
                langCode,
                {'count': '$totalLessons'},
              ),
              isDark: isDark,
            ),
            _MetaSeparator(isDark: isDark),
            _MetaChip(
              icon: Icons.schedule_rounded,
              label: durationText,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color:
              isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetaSeparator extends StatelessWidget {
  final bool isDark;

  const _MetaSeparator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Progress bar row
// ────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  final double progressRatio;
  final int percentage;
  final Color progressColor;
  final bool isDark;

  const _ProgressRow({
    required this.progressRatio,
    required this.percentage,
    required this.progressColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: progressRatio.clamp(0.0, 1.0),
                ),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Stack(
                      children: [
                        // Track
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkLockedSurface
                                : AppColors.lightLockedSurface,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        // Fill
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 1100),
                              curve: Curves.easeOutCubic,
                              width: constraints.maxWidth * value,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                gradient: LinearGradient(
                                  colors: [
                                    progressColor,
                                    progressColor.withValues(alpha: 0.75),
                                  ],
                                ),
                                boxShadow: value > 0
                                    ? [
                                        BoxShadow(
                                          color: progressColor.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 6,
                                          spreadRadius: -1,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                    CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: child,
                ),
              ),
              child: Text(
                '$percentage%',
                key: ValueKey(percentage),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppCustomText(
          percentage == 0
              ? 'not_started'
              : (percentage == 100 ? 'completed_with_check' : 'in_progress'),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: percentage == 100
                ? AppColors.successEmerald
                : (isDark
                    ? AppColors.darkTextDisabled
                    : AppColors.lightTextDisabled),
          ),
        ),
      ],
    );
      },
    );
  }
}

// ────────────────────────────────────────────────────────
// Course illustration — positioned on the trailing side
// ────────────────────────────────────────────────────────

class _CourseIllustration extends StatelessWidget {
  final String thumbnailPath;
  final bool isDark;

  const _CourseIllustration({
    required this.thumbnailPath,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      margin: const EdgeInsetsDirectional.only(start: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? AppColors.darkSurfaceVariant
            : const Color(0xFFF0F6FB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          thumbnailPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.menu_book_rounded,
              color: isDark ? AppColors.darkTextDisabled : AppColors.primary,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
