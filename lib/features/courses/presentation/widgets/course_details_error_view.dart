import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_custom_text.dart';

/// Error state for course details with a retry action.
class CourseDetailsErrorView extends StatelessWidget {
  /// Localization key for the error message.
  final String messageKey;

  /// Retry callback.
  final VoidCallback onRetry;

  /// Creates a [CourseDetailsErrorView].
  const CourseDetailsErrorView({
    super.key,
    required this.messageKey,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorCoral,
            ),
            const SizedBox(height: 16),
            AppCustomText(
              messageKey,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const AppCustomText('retry_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? const Color(0xFF0284C7) : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
