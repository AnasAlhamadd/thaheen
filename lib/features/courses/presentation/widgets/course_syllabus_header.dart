import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Syllabus header with lesson count, duration, and expand/collapse action.
class CourseSyllabusHeader extends StatelessWidget {
  /// Total lessons in the course.
  final int totalLessons;

  /// Formatted hours label (e.g. `1.2`).
  final String totalHours;

  /// Whether every section is currently expanded.
  final bool allExpanded;

  /// Toggles expand/collapse for all sections.
  final VoidCallback onToggleExpandAll;

  /// Creates a [CourseSyllabusHeader].
  const CourseSyllabusHeader({
    super.key,
    required this.totalLessons,
    required this.totalHours,
    required this.allExpanded,
    required this.onToggleExpandAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF38BDF8) : AppColors.primary;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final meta = AppStrings.trArgs(
          'syllabus_meta',
          state.language.languageCode,
          {
            'lessons': '$totalLessons',
            'hours': totalHours,
          },
        );

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: AppCustomText(
                      'lesson_plan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightLockedSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onToggleExpandAll,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: AppCustomText(
                allExpanded ? 'collapse_all' : 'expand_all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
