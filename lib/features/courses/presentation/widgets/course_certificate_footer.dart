import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_custom_text.dart';

/// Certificate promise shown at the bottom of the syllabus tab.
class CourseCertificateFooter extends StatelessWidget {
  /// Creates a [CourseCertificateFooter].
  const CourseCertificateFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF38BDF8) : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 28, color: accent),
          const SizedBox(height: 6),
          AppCustomText(
            'certificate_footer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
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
