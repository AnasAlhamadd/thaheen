import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Floating sticky bottom bar allowing the student to continue watching the active lesson.
class CourseStickyBottomBar extends StatelessWidget {
  /// Total completed lessons count.
  final int completedLessonsCount;

  /// Total lessons in the course.
  final int totalLessonsCount;

  /// The active or current lesson to resume.
  final Lesson activeLesson;

  /// Callback to open the lesson player for [activeLesson].
  final VoidCallback onResume;

  /// Creates a [CourseStickyBottomBar].
  const CourseStickyBottomBar({
    super.key,
    required this.completedLessonsCount,
    required this.totalLessonsCount,
    required this.activeLesson,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : AppColors.lightSurface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (prev, curr) => prev.language != curr.language,
          builder: (context, state) {
            final langCode = state.language.languageCode;
            final textDirection = state.language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr;
            final fontFamily = state.language.fontFamily;

            final progressText = AppStrings.trArgs(
              'progress_lessons',
              langCode,
              {
                'completed': '$completedLessonsCount',
                'total': '$totalLessonsCount',
              },
            );

            final activeTitle = activeLesson.localizedTitle(langCode);
            final resumeText = AppStrings.trArgs(
              'resume_lesson_title',
              langCode,
              {'title': activeTitle},
            );

            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progressText,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resumeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: textDirection,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF0284C7)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 20),
                      const SizedBox(width: 4),
                      AppCustomText(
                        'continue_learning',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
