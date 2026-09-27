import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/lesson.dart';

/// Bottom sheet dialog displayed when a user taps on a locked lesson.
///
/// Clearly explains that the previous prerequisite lesson must be completed first
/// and offers direct action to jump to the prerequisite lesson.
class CourseLockBottomSheet extends StatelessWidget {
  /// The locked target lesson name.
  final String targetLessonTitle;

  /// The required previous lesson to complete first.
  final Lesson? prerequisiteLesson;

  /// Callback executed when the user chooses to navigate directly to the current active prerequisite lesson.
  final VoidCallback onNavigateToPrerequisite;

  /// Creates a [CourseLockBottomSheet].
  const CourseLockBottomSheet({
    super.key,
    required this.targetLessonTitle,
    required this.prerequisiteLesson,
    required this.onNavigateToPrerequisite,
  });

  /// Helper static method to show the lock bottom sheet modal.
  static Future<void> show(
    BuildContext context, {
    required String targetLessonTitle,
    required Lesson? prerequisiteLesson,
    required VoidCallback onNavigateToPrerequisite,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => CourseLockBottomSheet(
        targetLessonTitle: targetLessonTitle,
        prerequisiteLesson: prerequisiteLesson,
        onNavigateToPrerequisite: onNavigateToPrerequisite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final prereqMinutes = prerequisiteLesson != null
        ? (prerequisiteLesson!.durationSec ~/ 60).toString()
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),

          // Glowing lock icon badge
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.primaryContainer.withValues(alpha: 0.25)
                  : const Color(0xFFE0F2FE),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                    : const Color(0xFFBAE6FD),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.lock_clock_outlined,
                size: 34,
                color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            'أكمل الدرس السابق أولاً 🔒',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle description
          Text(
            'بعد إتمام الدرس السابق بنسبة 90%، سيفتح لك هذا الدرس تلقائياً لضمان الفهم الطبي السليم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Target Locked Lesson Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightLockedSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدرس المحدد:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextDisabled
                        : AppColors.lightTextDisabled,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextDisabled
                          : AppColors.lightTextDisabled,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        targetLessonTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Required prerequisite card
          if (prerequisiteLesson != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0C4A6E).withValues(alpha: 0.3)
                    : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF0284C7).withValues(alpha: 0.4)
                      : const Color(0xFFBAE6FD),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF0284C7).withValues(alpha: 0.4)
                          : const Color(0xFFE0F2FE),
                    ),
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color:
                          isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المطلوب إكماله أولاً:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prerequisiteLesson!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (prereqMinutes != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        '$prereqMinutes د',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ] else ...[
            const SizedBox(height: 10),
          ],

          // Primary action: Navigate to prerequisite lesson
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onNavigateToPrerequisite();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'الانتقال إلى الدرس المطلوب الآن',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF0284C7)
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary action: Dismiss
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'حسناً، فهمت ذلك',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
