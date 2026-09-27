import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Title and medical abstract card below the video player.
///
/// Displays the lesson title, section badge, instructor, duration,
/// and an expandable lesson description — matching the Thaheen
/// clinical design language.
class LessonInfoCard extends StatefulWidget {
  /// Lesson title text.
  final String lessonTitle;

  /// Section title (e.g., "القسم 1: الجهاز الهيكلي").
  final String sectionTitle;

  /// Instructor name.
  final String instructorName;

  /// Lesson duration in seconds.
  final int durationSec;

  /// Optional lesson description / abstract.
  final String? description;

  /// Creates a [LessonInfoCard].
  const LessonInfoCard({
    super.key,
    required this.lessonTitle,
    required this.sectionTitle,
    required this.instructorName,
    required this.durationSec,
    this.description,
  });

  @override
  State<LessonInfoCard> createState() => _LessonInfoCardState();
}

class _LessonInfoCardState extends State<LessonInfoCard> {
  bool _isExpanded = false;

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0 && seconds > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')} د ($totalSeconds ث)';
    }
    if (minutes > 0) {
      return '$minutes:00 د ($totalSeconds ث)';
    }
    return '$totalSeconds ث';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Section badge + duration
          Row(
            children: [
              // Section badge
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF86F2E4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFF005049),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.sectionTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF2DD4BF)
                                    : const Color(0xFF005049),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.instructorName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Duration chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(widget.durationSec),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Lesson title
          Text(
            widget.lessonTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1.4,
            ),
          ),

          // Expandable description
          if (widget.description != null &&
              widget.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: Text(
                widget.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.6,
                ),
              ),
              secondChild: Text(
                widget.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.6,
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'إخفاء التفاصيل' : 'المزيد من التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
