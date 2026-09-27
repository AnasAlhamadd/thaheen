import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Interactive segmented tabs header for Course Details (About / Lessons / Reviews).
///
/// Compact, minimalist design using Material ink splashes with a small bottom
/// indicator under the selected tab.
class CourseSegmentedTabs extends StatelessWidget {
  /// Active tab index (0 = About, 1 = Lessons & Content, 2 = Reviews).
  final int selectedIndex;

  /// Total reviews count to show in reviews badge.
  final int reviewsCount;

  /// Callback when a tab is selected.
  final ValueChanged<int> onTabSelected;

  /// Creates a compact [CourseSegmentedTabs].
  const CourseSegmentedTabs({
    super.key,
    required this.selectedIndex,
    this.reviewsCount = 340,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) => prev.language != curr.language,
        builder: (context, state) {
          final langCode = state.language.languageCode;
          final reviewsTitle = AppStrings.trArgs(
            'tab_reviews_count',
            langCode,
            {'count': '$reviewsCount'},
          );

          return Row(
            children: [
              _TabButton(
                translationKey: 'tab_about_course',
                isSelected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _TabButton(
                translationKey: 'tab_lessons_content',
                isSelected: selectedIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _TabButton.customText(
                customText: reviewsTitle,
                isSelected: selectedIndex == 2,
                onTap: () => onTabSelected(2),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String? translationKey;
  final String? customText;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.translationKey,
    required this.isSelected,
    required this.onTap,
  }) : customText = null;

  const _TabButton.customText({
    required this.customText,
    required this.isSelected,
    required this.onTap,
  }) : translationKey = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF38BDF8) : AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final activeBg = isDark
        ? const Color(0xFF0369A1).withValues(alpha: 0.30)
        : const Color(0xFFE0F2FE);

    return Expanded(
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (translationKey != null)
                  AppCustomText(
                    translationKey!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  )
                else
                  Text(
                    customText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 18,
                    height: 2,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
