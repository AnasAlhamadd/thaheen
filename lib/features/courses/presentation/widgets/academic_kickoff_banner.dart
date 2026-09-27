import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/app_custom_text.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../../domain/entities/lesson_progress.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Hero banner presenting the academic kickoff or continue-studying prompt.
///
/// Automatically switches between two states based on student's learning progress:
/// - **State A: "Continue Watching"** - Displays when an unfinished lesson exists
///   (position > 0 and completed == false)
/// - **State B: "Academic Kickoff"** - Default promotional banner when no lesson
///   is currently in progress
///
/// ## Usage Example:
/// ```dart
/// AcademicKickoffBanner(
///   continueCourse: course,
///   continueLesson: lesson,
///   lessonProgress: progress,
///   onKickoffActionPressed: () => navigateToFirstLesson(),
/// )
/// ```
///
/// ## Integration with State Management:
/// This widget is designed to work with `ProgressService` and `ProgressRepository`.
/// The parent screen should:
/// 1. Fetch all progress using `progressRepository.getAllProgress()`
/// 2. Use `progressService.findContinueWatching()` to find the unfinished lesson
/// 3. Pass the results to this widget
class AcademicKickoffBanner extends StatelessWidget {
  /// The course containing the lesson to continue (for continue watching state).
  final Course? continueCourse;

  /// The lesson to continue watching (for continue watching state).
  final Lesson? continueLesson;

  /// The progress data for the lesson (for continue watching state).
  final LessonProgress? lessonProgress;

  /// Callback executed when returning from lesson player to reload data.
  final VoidCallback? onReturnFromLesson;

  /// Fallback title for the academic kickoff state.
  /// When null, falls back to the localized [AppStrings] title.
  final String? title;

  /// Fallback subtitle for the academic kickoff state.
  /// When null, falls back to the localized [AppStrings] subtitle.
  final String? subtitle;

  /// Fallback action label for the academic kickoff state.
  /// When null, falls back to the localized [AppStrings] action label.
  final String? actionLabel;

  /// Fallback time estimate for the academic kickoff state.
  /// When null, falls back to the localized [AppStrings] time estimate.
  final String? timeEstimate;

  /// Callback executed when the action button is pressed in kickoff state.
  final VoidCallback? onKickoffActionPressed;

  /// Creates an [AcademicKickoffBanner].
  ///
  /// If [continueLesson] is provided with valid [lessonProgress], the banner
  /// shows the "Continue Watching" state. Otherwise, it shows the "Academic
  /// Kickoff" state with fallback text.
  ///
  /// Text parameters ([title], [subtitle], [actionLabel], [timeEstimate]) are
  /// optional — when omitted, localized strings from [AppStrings] are used.
  const AcademicKickoffBanner({
    super.key,
    this.continueCourse,
    this.continueLesson,
    this.lessonProgress,
    this.onReturnFromLesson,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.timeEstimate,
    this.onKickoffActionPressed,
  });

  /// Determines if the banner should display the "Continue Watching" state.
  ///
  /// Returns true when:
  /// - [continueLesson] is not null
  /// - [continueCourse] is not null (required for navigation)
  /// - Lesson has progress data (either in progress OR ready to start)
  bool _hasValidUnfinishedLesson() {
    return continueLesson != null && continueCourse != null;
  }

  @override
  Widget build(BuildContext context) {
    final hasUnfinishedLesson = _hasValidUnfinishedLesson();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      child: hasUnfinishedLesson
          ? _ContinueWatchingBanner(
              key: const ValueKey('continue_watching'),
              course: continueCourse!,
              lesson: continueLesson!,
              progress: lessonProgress,
              onReturnFromLesson: onReturnFromLesson,
            )
          : _KickoffBanner(
              key: const ValueKey('kickoff'),
              title: title,
              subtitle: subtitle,
              actionLabel: actionLabel,
              timeEstimate: timeEstimate,
              onPressed: onKickoffActionPressed ?? () {},
            ),
    );
  }
}

class _AmbientGlowCircles extends StatelessWidget {
  const _AmbientGlowCircles();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Continue Watching" banner state displayed when an unfinished lesson exists.
///
/// This banner shows:
/// - "متابعة المشاهدة" badge for in-progress lessons
/// - "ابدأ الآن" badge for lessons not yet started
/// - Current lesson title
/// - Course title with progress percentage (if progress exists)
/// - Linear progress indicator (if progress exists)
/// - Action button that navigates to the lesson player
class _ContinueWatchingBanner extends StatelessWidget {
  final Course course;
  final Lesson lesson;
  final LessonProgress? progress;
  final VoidCallback? onReturnFromLesson;

  const _ContinueWatchingBanner({
    super.key,
    required this.course,
    required this.lesson,
    required this.progress,
    this.onReturnFromLesson,
  });

  /// Checks if this lesson has been started (has progress data)
  bool _hasProgress() {
    return progress != null && progress!.position > Duration.zero;
  }

  /// Calculates progress ratio (0.0 to 1.0) based on video position and duration.
  ///
  /// Returns 0.0 if duration is invalid or no progress exists.
  double _calculateProgressRatio() {
    if (!_hasProgress()) return 0.0;
    
    final totalDuration = Duration(seconds: lesson.durationSec);
    if (totalDuration <= Duration.zero) return 0.0;
    
    final ratio = progress!.position.inSeconds / totalDuration.inSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Formats remaining time as localized text (e.g., "متبقي 15 دقيقة").
  ///
  /// Handles edge cases:
  /// - Returns total duration if no progress exists
  /// - Returns "أقل من دقيقة" if less than 1 minute remains
  /// - Returns "متبقي دقيقة واحدة" for exactly 1 minute
  /// - Returns standard format for multiple minutes
  String _formatTimeRemaining(BuildContext context) {
    final langCode =
        context.read<SettingsCubit>().state.language.languageCode;
    final totalDuration = Duration(seconds: lesson.durationSec);

    if (!_hasProgress()) {
      // No progress - show total duration
      final minutes = totalDuration.inMinutes;
      if (minutes == 0) {
        return AppStrings.tr('time_less_than_minute', langCode);
      } else if (minutes == 1) {
        return AppStrings.tr('time_one_minute', langCode);
      } else if (minutes == 2) {
        return AppStrings.tr('time_two_minutes', langCode);
      } else {
        return AppStrings.trArgs(
          'time_n_minutes',
          langCode,
          {'count': '$minutes'},
        );
      }
    }

    final remaining = totalDuration - progress!.position;

    if (remaining <= Duration.zero) {
      return AppStrings.tr('time_less_than_minute', langCode);
    }

    final minutes = remaining.inMinutes;

    if (minutes == 0) {
      return AppStrings.tr('time_less_than_minute', langCode);
    } else if (minutes == 1) {
      return AppStrings.tr('time_remaining_one', langCode);
    } else if (minutes == 2) {
      return AppStrings.tr('time_remaining_two', langCode);
    } else {
      return AppStrings.trArgs(
        'time_remaining_n',
        langCode,
        {'count': '$minutes'},
      );
    }
  }

  /// Returns the appropriate action label based on progress state
  String _getActionLabel(BuildContext context) {
    final langCode = context.read<SettingsCubit>().state.language.languageCode;
    return _hasProgress()
        ? AppStrings.tr('resume_lesson', langCode)
        : AppStrings.tr('start_lesson', langCode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final gradientColors = isDark
        ? [
            Color(0xFF004B73),
            Color(0xFF006194),
            Color(0xFF0369A1),
          ]
        : [
            Color(0xFF004B73),
            Color(0xFF006194),
            Color(0xFF0369A1),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          isDark ? const _AmbientGlowCircles() : Container(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (prev, curr) => prev.language != curr.language,
              builder: (context, state) {
                final langCode = state.language.languageCode;
                final textDirection = state.language == AppLanguage.arabic
                    ? TextDirection.rtl
                    : TextDirection.ltr;
                final fontFamily = state.language.fontFamily;

                final progressRatio = _calculateProgressRatio();
                final progressPercentage = _hasProgress()
                    ? AppStrings.trArgs(
                        'progress_percentage',
                        langCode,
                        {'percentage': '${(progressRatio * 100).round().clamp(0, 100)}'},
                      )
                    : null;

                final timeRemaining = _formatTimeRemaining(context);
                final actionLabel = _getActionLabel(context);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContinueWatchingBadge(hasProgress: _hasProgress()),
                    const SizedBox(height: 12),
                    Text(
                      lesson.localizedTitle(langCode),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        fontFamily: fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      progressPercentage != null
                          ? '${course.localizedTitle(langCode)} • $progressPercentage'
                          : course.localizedTitle(langCode),
                      style: TextStyle(
                        color: AppColors.primaryLight.withValues(alpha: 0.95),
                        fontSize: 13,
                        height: 1.4,
                        fontFamily: fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 12),
                    if (_hasProgress())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warningGold,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    if (_hasProgress()) const SizedBox(height: 16),
                    if (!_hasProgress()) const SizedBox(height: 4),
                    _ContinueWatchingActionRow(
                      courseId: course.id,
                      lessonId: lesson.id,
                      timeRemaining: timeRemaining,
                      actionLabel: actionLabel,
                      onReturnFromLesson: onReturnFromLesson,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "Academic Kickoff" banner state displayed when no lesson is in progress.
///
/// This is the default/promotional state encouraging students to start learning.
class _KickoffBanner extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final String? timeEstimate;
  final VoidCallback onPressed;

  const _KickoffBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.timeEstimate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final gradientColors = isDark
        ? [
            Color(0xFF004B73),
            Color(0xFF006194),
            Color(0xFF0369A1),
          ]
        : [
            Color(0xFF004B73),
            Color(0xFF006194),
            Color(0xFF0369A1),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          isDark ? const _AmbientGlowCircles() : Container(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: BlocBuilder<SettingsCubit, SettingsState>(
              buildWhen: (prev, curr) => prev.language != curr.language,
              builder: (context, state) {
                final langCode = state.language.languageCode;
                final textDirection = state.language == AppLanguage.arabic
                    ? TextDirection.rtl
                    : TextDirection.ltr;
                final fontFamily = state.language.fontFamily;

                final resolvedTitle =
                    title ?? AppStrings.tr('kickoff_title', langCode);
                final resolvedSubtitle =
                    subtitle ?? AppStrings.tr('kickoff_subtitle', langCode);
                final resolvedAction =
                    actionLabel ?? AppStrings.tr('academic_kickoff_action', langCode);
                final resolvedTime =
                    timeEstimate ?? AppStrings.tr('kickoff_time_estimate', langCode);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _KickoffBadgesRow(),
                    const SizedBox(height: 12),
                    Text(
                      resolvedTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        fontFamily: fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resolvedSubtitle,
                      style: TextStyle(
                        color: AppColors.primaryLight.withValues(alpha: 0.95),
                        fontSize: 13,
                        height: 1.4,
                        fontFamily: fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 16),
                    _ActionFooterRow(
                      actionLabel: resolvedAction,
                      timeEstimate: resolvedTime,
                      onPressed: onPressed,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingBadge extends StatelessWidget {
  final bool hasProgress;
  
  const _ContinueWatchingBadge({required this.hasProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warningGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasProgress ? Icons.play_circle_rounded : Icons.rocket_launch_rounded,
            size: 14,
            color: AppColors.warningGold,
          ),
          const SizedBox(width: 4),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev.language != curr.language,
            builder: (context, state) {
              final langCode = state.language.languageCode;
              return Text(
                hasProgress
                    ? AppStrings.tr('continue_watching_badge', langCode)
                    : AppStrings.tr('start_now_badge', langCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KickoffBadgesRow extends StatelessWidget {
  const _KickoffBadgesRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: AppColors.warningGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.tr('kickoff_semester_badge', langCode),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.warningGold,
                ),
                const SizedBox(width: 3),
                AppCustomText(
                  'top_priority',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Action row for the "Continue Watching" state with resume button.
class _ContinueWatchingActionRow extends StatelessWidget {
  final String courseId;
  final String lessonId;
  final String timeRemaining;
  final String actionLabel;
  final VoidCallback? onReturnFromLesson;

  const _ContinueWatchingActionRow({
    required this.courseId,
    required this.lessonId,
    required this.timeRemaining,
    required this.actionLabel,
    this.onReturnFromLesson,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final textDirection = state.language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr;
        final fontFamily = state.language.fontFamily;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.push('/courses/$courseId/lessons/$lessonId');
                  onReturnFromLesson?.call();
                },
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  actionLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: fontFamily,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeRemaining,
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: fontFamily,
                  ),
                  textDirection: textDirection,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Action row for the "Academic Kickoff" state with start button.
class _ActionFooterRow extends StatelessWidget {
  final String actionLabel;
  final String timeEstimate;
  final VoidCallback onPressed;

  const _ActionFooterRow({
    required this.actionLabel,
    required this.timeEstimate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final textDirection = state.language == AppLanguage.arabic
            ? TextDirection.rtl
            : TextDirection.ltr;
        final fontFamily = state.language.fontFamily;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  actionLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: fontFamily,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeEstimate,
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: fontFamily,
                  ),
                  textDirection: textDirection,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
