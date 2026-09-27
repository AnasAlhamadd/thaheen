import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_custom_text.dart';
import 'course_surface_card.dart';

/// Empty syllabus placeholder when a course has no sections or lessons.
class CourseEmptySectionsCard extends StatelessWidget {
  /// Creates a [CourseEmptySectionsCard].
  const CourseEmptySectionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CourseSurfaceCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            size: 52,
            color: isDark ? AppColors.darkTextDisabled : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          AppCustomText(
            'empty_lessons',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
