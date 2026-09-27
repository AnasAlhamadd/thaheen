import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Informational banner highlighting sequential unlock requirements.
class CourseSequentialInfoBanner extends StatelessWidget {
  /// Creates a [CourseSequentialInfoBanner].
  const CourseSequentialInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0369A1).withValues(alpha: 0.2)
            : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.4)
              : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 22,
            color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (prev, curr) => prev.language != curr.language,
              builder: (context, state) {
                final langCode = state.language.languageCode;
                final textDirection = state.language == AppLanguage.arabic
                    ? TextDirection.rtl
                    : TextDirection.ltr;
                final fontFamily = state.language.fontFamily;

                return RichText(
                  textDirection: textDirection,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      height: 1.5,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: AppStrings.tr('sequential_banner_title', langCode),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primaryDark,
                        ),
                      ),
                      TextSpan(
                        text: AppStrings.tr(
                            'sequential_banner_description', langCode),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
