import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Top bar for Course Details screen with back, share, and bookmark actions.
class CourseDetailsTopBar extends StatelessWidget {
  /// Optional course title. Falls back to the localized screen title.
  final String? title;

  /// Whether the course is currently bookmarked.
  final bool isBookmarked;

  /// Callback when back button is pressed.
  final VoidCallback onBack;

  /// Callback when share button is pressed.
  final VoidCallback onShare;

  /// Callback when bookmark/save button is pressed.
  final VoidCallback onBookmark;

  /// Creates a [CourseDetailsTopBar].
  const CourseDetailsTopBar({
    super.key,
    this.title,
    this.isBookmarked = false,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bookmarkColor =
        isDark ? const Color(0xFF38BDF8) : AppColors.primary;

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;

        return Material(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.55),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              bottom: 8,
              left: 4,
              right: 4,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: AppStrings.tr('back', langCode),
                  color: titleColor,
                ),
                Expanded(
                  child: title == null
                      ? AppCustomText(
                          'course_details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        )
                      : Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                ),
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 20),
                  tooltip: AppStrings.tr('share', langCode),
                  color: iconColor,
                ),
                IconButton(
                  onPressed: onBookmark,
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22,
                  ),
                  tooltip: AppStrings.tr('bookmark', langCode),
                  color: bookmarkColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
