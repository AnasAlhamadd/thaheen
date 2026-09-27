import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../domain/entities/course.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'course_surface_card.dart';

/// About tab content for a course: overview, description, and learning outcomes.
class CourseAboutTab extends StatelessWidget {
  /// Course whose overview is displayed.
  final Course course;

  /// Creates a [CourseAboutTab].
  const CourseAboutTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return CourseSurfaceCard(
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) => prev.language != curr.language,
        builder: (context, state) {
          final description = course.localizedDescription(
            state.language.languageCode,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCustomText(
                'about_overview_title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              AppCustomText(
                'about_what_you_learn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 8),
              const _OutcomeItem(translationKey: 'about_outcome_1'),
              const _OutcomeItem(translationKey: 'about_outcome_2'),
              const _OutcomeItem(translationKey: 'about_outcome_3'),
            ],
          );
        },
      ),
    );
  }
}

class _OutcomeItem extends StatelessWidget {
  final String translationKey;

  const _OutcomeItem({required this.translationKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.successEmerald,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppCustomText(
              translationKey,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
