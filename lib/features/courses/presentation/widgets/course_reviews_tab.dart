import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'course_surface_card.dart';

/// Reviews tab with aggregate rating and verified student feedback.
class CourseReviewsTab extends StatelessWidget {
  /// Total reviews used in the summary label.
  final int reviewsCount;

  /// Aggregate rating displayed in the header.
  final String rating;

  /// Creates a [CourseReviewsTab].
  const CourseReviewsTab({
    super.key,
    this.reviewsCount = 340,
    this.rating = '4.9',
  });

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
          final summary = AppStrings.trArgs(
            'reviews_verified_summary',
            state.language.languageCode,
            {'count': '$reviewsCount'},
          );

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: AppColors.warningGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      summary,
                      style: TextStyle(fontSize: 13, color: secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _ReviewItem(
                authorKey: 'review_1_author',
                bodyKey: 'review_1_body',
              ),
              Divider(
                height: 24,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              const _ReviewItem(
                authorKey: 'review_2_author',
                bodyKey: 'review_2_body',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String authorKey;
  final String bodyKey;

  const _ReviewItem({
    required this.authorKey,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 14, color: AppColors.warningGold),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.warningGold),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.warningGold),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.warningGold),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.warningGold),
            const SizedBox(width: 8),
            Expanded(
              child: AppCustomText(
                authorKey,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppCustomText(
          bodyKey,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
