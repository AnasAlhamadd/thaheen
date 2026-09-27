import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_custom_text.dart';

/// Compact production stats strip: lessons, hours, and completion.
class CourseStatsStrip extends StatelessWidget {
  /// Total lessons in the course.
  final int totalLessons;

  /// Formatted hours label.
  final String totalHours;

  /// Completion ratio from 0.0 to 1.0.
  final double progressRatio;

  /// Creates a [CourseStatsStrip].
  const CourseStatsStrip({
    super.key,
    required this.totalLessons,
    required this.totalHours,
    required this.progressRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (progressRatio * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.play_lesson_outlined,
            value: '$totalLessons',
            labelKey: 'stat_lessons',
          ),
          _StatDivider(isDark: isDark),
          _StatCell(
            icon: Icons.schedule_rounded,
            value: totalHours,
            labelKey: 'stat_hours',
          ),
          _StatDivider(isDark: isDark),
          _StatCell(
            icon: Icons.verified_outlined,
            value: '$percent%',
            labelKey: 'stat_completed',
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;

  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String labelKey;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.labelKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF38BDF8) : AppColors.primary;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          AppCustomText(
            labelKey,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
