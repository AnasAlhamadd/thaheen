import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../courses/domain/repositories/course_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/services/progress_service.dart';
import '../cubit/lesson_player_cubit.dart';
import '../cubit/lesson_player_state.dart';
import '../widgets/course_plan_section.dart';
import '../widgets/lesson_info_card.dart';
import '../widgets/video_player_surface.dart';

/// Screen wrapping the BlocProvider for the lesson player.
class LessonPlayerScreen extends StatelessWidget {
  /// The course this lesson belongs to.
  final String courseId;

  /// The lesson to play.
  final String lessonId;

  /// Creates a [LessonPlayerScreen].
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonPlayerCubit(
        courseRepository: context.read<CourseRepository>(),
        progressRepository: context.read<ProgressRepository>(),
        progressService: context.read<ProgressService>(),
      )..loadLesson(courseId, lessonId),
      child: _LessonPlayerView(courseId: courseId, lessonId: lessonId),
    );
  }
}

class _LessonPlayerView extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const _LessonPlayerView({
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<_LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<_LessonPlayerView> {
  VideoPlayerController? _controller;
  bool _isFullscreen = false;
  bool _controlsVisible = true;
  double _playbackSpeed = 1.0;
  bool _isSavingProgress = false;
  bool _isNoteSaved = false;

  LessonPlayerCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<LessonPlayerCubit>();
  }

  @override
  void dispose() {
    _saveAndDispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _saveAndDispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _cubit?.saveProgressNow(
        _controller!.value.position,
      );
    }
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _initializePlayer(Lesson lesson, Duration resumePosition) async {
    try {
      _controller = VideoPlayerController.asset(lesson.video);
      await _controller!.initialize();

      Duration safePosition = resumePosition;
      final totalDuration = _controller!.value.duration;
      if (safePosition < Duration.zero) {
        safePosition = Duration.zero;
      }
      if (safePosition > totalDuration) {
        safePosition = totalDuration;
      }

      if (safePosition > Duration.zero) {
        await _controller!.seekTo(safePosition);
      }

      _controller!.addListener(_onVideoTick);
      await _controller!.setPlaybackSpeed(_playbackSpeed);
      await _controller!.play();

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        context.read<LessonPlayerCubit>().setError(
              'تعذر تشغيل الفيديو. تأكد من وجود ملف الفيديو.',
            );
      }
    }
  }

  void _onVideoTick() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    context.read<LessonPlayerCubit>().onPositionChanged(position, duration);
    setState(() {});
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _seekForward10() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final newPosition = _controller!.value.position + const Duration(seconds: 10);
    final clamped = newPosition > _controller!.value.duration
        ? _controller!.value.duration
        : newPosition;
    _controller!.seekTo(clamped);
  }

  void _seekRewind10() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final newPosition = _controller!.value.position - const Duration(seconds: 10);
    final clamped = newPosition < Duration.zero ? Duration.zero : newPosition;
    _controller!.seekTo(clamped);
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying) {
      _controller!.pause();
      setState(() => _isSavingProgress = true);
      await context
          .read<LessonPlayerCubit>()
          .saveProgressNow(_controller!.value.position);
      if (mounted) setState(() => _isSavingProgress = false);
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Handles navigation logic when user pops the screen.
  ///
  /// Smart navigation rules:
  /// 1. If lesson is completed AND has next lesson → Navigate to next
  /// 2. If lesson is completed AND no next lesson → Return to course (all done)
  /// 3. Otherwise → Normal back navigation
  Future<void> _handleNavigation(LessonPlayerReady state) async {
    // Save progress before navigation
    final cubit = context.read<LessonPlayerCubit>();
    await cubit.onWillPop();

    // Check if lesson was completed and has next lesson
    if (state.isCompleted && state.nextLesson != null) {
      // Show brief feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تم إكمال الدرس! الانتقال إلى: ${state.nextLesson!.title}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Small delay for user to see the completion
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to next lesson
        if (mounted) {
          context.pushReplacement(
            '/courses/${widget.courseId}/lessons/${state.nextLesson!.id}',
          );
        }
      }
    }
    // If completed but no next lesson, show completion message
    else if (state.isCompleted && state.nextLesson == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 تهانينا! أكملت جميع دروس هذه الدورة',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF7C3AED),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonPlayerCubit, LessonPlayerState>(
      listener: (context, state) {
        if (state is LessonPlayerReady && _controller == null) {
          _initializePlayer(state.currentLesson, state.resumePosition);
        }
      },
      builder: (context, state) {
        return switch (state) {
          LessonPlayerInitial() || LessonPlayerLoading() => _buildLoadingScreen(),
          LessonPlayerError(:final message) => _buildErrorScreen(message),
          LessonPlayerReady() => _buildPlayerScreen(state),
        };
      },
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جارٍ تحميل الدرس...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('مشغل الدرس'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorCoral.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam_off_rounded,
                  size: 40,
                  color: AppColors.errorCoral,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تحقق من اتصالك وحاول مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.read<LessonPlayerCubit>().loadLesson(
                      widget.courseId,
                      widget.lessonId,
                    ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? const Color(0xFF0284C7) : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScreen(LessonPlayerReady state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen();
          return;
        }
        if (didPop) {
          await _handleNavigation(state);
        }
      },
      child: _isFullscreen
          ? Scaffold(
              backgroundColor: Colors.black,
              body: VideoPlayerSurface(
                controller: _controller,
                isFullscreen: true,
                controlsVisible: _controlsVisible,
                playbackSpeed: _playbackSpeed,
                isSavingProgress: _isSavingProgress,
                onToggleControls: () =>
                    setState(() => _controlsVisible = !_controlsVisible),
                onTogglePlayPause: _togglePlayPause,
                onToggleFullscreen: _toggleFullscreen,
                onSpeedChanged: (speed) {
                  setState(() => _playbackSpeed = speed);
                  _controller?.setPlaybackSpeed(speed);
                },
                onForward10: _seekForward10,
                onRewind10: _seekRewind10,
                lessonTitle: state.currentLesson.title,
                instructorName: state.course.instructor,
              ),
            )
          : Scaffold(
              backgroundColor: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    snap: false,
                    expandedHeight: 0,
                    collapsedHeight: 56,
                    toolbarHeight: 56,
                    backgroundColor: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    scrolledUnderElevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.04),
                    surfaceTintColor: Colors.transparent,
                    leadingWidth: 52,
                    leading: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFF1F5F9),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 22,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0284C7)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'ذ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مشغل المحاضرة | ذهين',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Video ──────────────────────────────────────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: VideoPlayerSurface(
                            controller: _controller,
                            isFullscreen: false,
                            controlsVisible: _controlsVisible,
                            playbackSpeed: _playbackSpeed,
                            isSavingProgress: _isSavingProgress,
                            onToggleControls: () => setState(
                                () => _controlsVisible = !_controlsVisible),
                            onTogglePlayPause: _togglePlayPause,
                            onToggleFullscreen: _toggleFullscreen,
                            onSpeedChanged: (speed) {
                              setState(() => _playbackSpeed = speed);
                              _controller?.setPlaybackSpeed(speed);
                            },
                            onForward10: _seekForward10,
                            onRewind10: _seekRewind10,
                            lessonTitle: state.currentLesson.title,
                            instructorName: state.course.instructor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: _buildInfoPanelSlivers(state),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoPanelSlivers(LessonPlayerReady state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve language code for localized strings.
    final langCode = Localizations.localeOf(context).languageCode;

    String currentSectionTitle = '';
    for (final section in state.course.sections) {
      if (section.lessons.any((l) => l.id == state.currentLesson.id)) {
        currentSectionTitle = section.localizedTitle(langCode);
        break;
      }
    }

    // SliverChildListDelegate expects plain Box widgets, not slivers.
    final children = <Widget>[];

    children.add(
      LessonInfoCard(
        lessonTitle: state.currentLesson.localizedTitle(langCode),
        sectionTitle: currentSectionTitle,
        instructorName: state.course.localizedInstructor(langCode),
        durationSec: state.currentLesson.durationSec,
        description: state.course.localizedDescription(langCode).isNotEmpty
            ? state.course.localizedDescription(langCode)
            : null,
      ),
    );

    children.add(const SizedBox(height: 16));

    children.add(_buildSaveNoteAction(isDark));

    children.add(const SizedBox(height: 16));

    if (state.isCompleted) {
      children.add(_buildCompletionBadge(isDark));
      children.add(const SizedBox(height: 16));
    }

    if (state.isCompleted && state.nextLesson != null) {
      children.add(_buildNextLessonButton(state, isDark));
      children.add(const SizedBox(height: 16));
    }

    if (state.isCompleted && state.nextLesson == null) {
      children.add(_buildCourseCompletedCard(isDark));
      children.add(const SizedBox(height: 16));
    }


    children.add(const SizedBox(height: 20));

    children.add(
      CoursePlanSection(
        course: state.course,
        currentLessonId: state.currentLesson.id,
        completedLessonIds: state.completedLessonIds,
        onLessonTap: (lesson) {
          context.pushReplacement(
            '/courses/${widget.courseId}/lessons/${lesson.id}',
          );
        },
      ),
    );

    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }

  Widget _buildSaveNoteAction(bool isDark) {
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final resolvedIconBg = _isNoteSaved
        ? (isDark
            ? const Color(0xFF0284C7).withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.1))
        : (isDark
            ? AppColors.darkSurfaceVariant
            : const Color(0xFFF1F5F9));
    final resolvedIconColor = _isNoteSaved
        ? (isDark ? const Color(0xFF38BDF8) : AppColors.primary)
        : textSec;

    final bookmarkTimestamp = _controller != null
        ? 'الدقيقة ${_formatDuration(_controller!.value.position)}'
        : '';

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          setState(() => _isNoteSaved = !_isNoteSaved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isNoteSaved ? 'تم حفظ الملاحظة!' : 'تم إزالة الملاحظة',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: _isNoteSaved
                  ? const Color(0xFF059669)
                  : const Color(0xFF64748B),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isNoteSaved
                  ? (isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.15))
                  : borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resolvedIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isNoteSaved
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_add_rounded,
                  size: 20,
                  color: resolvedIconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حفظ الملاحظة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    if (bookmarkTimestamp.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        bookmarkTimestamp,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _isNoteSaved ? Icons.check_circle_rounded : Icons.add_rounded,
                size: 22,
                color: resolvedIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.successEmerald.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successEmerald,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم إكمال هذا الدرس بنجاح!',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يمكنك الانتقال إلى الدرس التالي',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                        : const Color(0xFF065F46).withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLessonButton(LessonPlayerReady state, bool isDark) {
    return Material(
      color: isDark ? const Color(0xFF0284C7) : AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          context.pushReplacement(
            '/courses/${widget.courseId}/lessons/${state.nextLesson!.id}',
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.skip_next_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'الدرس التالي: ${state.nextLesson!.title}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCompletedCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0C4A6E),
                  const Color(0xFF0369A1),
                  const Color(0xFF0284C7),
                ]
              : [
                  const Color(0xFF004B73),
                  const Color(0xFF006194),
                  const Color(0xFF0369A1),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 44),
          const SizedBox(height: 14),
          const Text(
            'تهانينا! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لقد أنهيت جميع دروس هذه الدورة بنجاح.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'العودة إلى الدورات',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
