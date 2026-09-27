import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Premium video player surface with HUD-style overlay controls.
///
/// Features a gradient scrim, centered playback controls (rewind 10s,
/// play/pause, forward 10s), top HUD bar with speed selector, and
/// bottom seekbar with time display — matching the Thaheen clinical
/// design language.
class VideoPlayerSurface extends StatelessWidget {
  /// The active video player controller.
  final VideoPlayerController? controller;

  /// Whether the player is in fullscreen mode.
  final bool isFullscreen;

  /// Whether overlay controls are visible.
  final bool controlsVisible;

  /// Current playback speed.
  final double playbackSpeed;

  /// Whether progress is being saved.
  final bool isSavingProgress;

  /// Callback to toggle controls visibility.
  final VoidCallback onToggleControls;

  /// Callback to toggle play/pause.
  final VoidCallback onTogglePlayPause;

  /// Callback to toggle fullscreen.
  final VoidCallback onToggleFullscreen;

  /// Callback when playback speed changes.
  final ValueChanged<double> onSpeedChanged;

  /// Callback to seek forward by 10 seconds.
  final VoidCallback onForward10;

  /// Callback to seek backward by 10 seconds.
  final VoidCallback onRewind10;

  /// Lesson title shown in the top HUD badge.
  final String lessonTitle;

  /// Instructor name shown in the top HUD badge.
  final String instructorName;

  /// Creates a [VideoPlayerSurface].
  const VideoPlayerSurface({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.controlsVisible,
    required this.playbackSpeed,
    required this.isSavingProgress,
    required this.onToggleControls,
    required this.onTogglePlayPause,
    required this.onToggleFullscreen,
    required this.onSpeedChanged,
    required this.onForward10,
    required this.onRewind10,
    required this.lessonTitle,
    required this.instructorName,
  });

  @override
  Widget build(BuildContext context) {
    final isInitialized =
        controller != null && controller!.value.isInitialized;

    return GestureDetector(
      onTap: onToggleControls,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF283044),
          borderRadius: isFullscreen
              ? null
              : const BorderRadius.vertical(bottom: Radius.circular(20)),
          boxShadow: isFullscreen
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        clipBehavior: isFullscreen ? Clip.none : Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: isFullscreen
              ? MediaQuery.of(context).size.aspectRatio
              : 16 / 9,
          child: isInitialized
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video layer
                    VideoPlayer(controller!),

                    // Gradient scrim for contrast
                    if (controlsVisible)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF283044).withValues(alpha: 0.8),
                              const Color(0xFF283044).withValues(alpha: 0.2),
                              const Color(0xFF283044).withValues(alpha: 0.4),
                              const Color(0xFF283044).withValues(alpha: 0.85),
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                        ),
                      ),

                    // HUD Controls overlay
                    if (controlsVisible)
                      _HudControlsOverlay(
                        controller: controller!,
                        isFullscreen: isFullscreen,
                        playbackSpeed: playbackSpeed,
                        isSavingProgress: isSavingProgress,
                        onTogglePlayPause: onTogglePlayPause,
                        onToggleFullscreen: onToggleFullscreen,
                        onSpeedChanged: onSpeedChanged,
                        onForward10: onForward10,
                        onRewind10: onRewind10,
                        lessonTitle: lessonTitle,
                        instructorName: instructorName,
                      ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF86F2E4),
                    strokeWidth: 3,
                  ),
                ),
        ),
      ),
    );
  }
}

class _HudControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final double playbackSpeed;
  final bool isSavingProgress;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleFullscreen;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onForward10;
  final VoidCallback onRewind10;
  final String lessonTitle;
  final String instructorName;

  const _HudControlsOverlay({
    required this.controller,
    required this.isFullscreen,
    required this.playbackSpeed,
    required this.isSavingProgress,
    required this.onTogglePlayPause,
    required this.onToggleFullscreen,
    required this.onSpeedChanged,
    required this.onForward10,
    required this.onRewind10,
    required this.lessonTitle,
    required this.instructorName,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFullscreen ? 16 : 12,
        vertical: isFullscreen ? 12 : 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top HUD bar
          _buildTopBar(context),

          // Center controls
          _buildCenterControls(isPlaying),

          // Bottom seekbar & metadata
          _buildBottomBar(position, duration),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Lesson badge
        Expanded(
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF006194).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF86F2E4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$lessonTitle · $instructorName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Save indicator
        if (isSavingProgress)
          Container(
            margin: const EdgeInsetsDirectional.only(end: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'حفظ...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Fullscreen button
        _HudIconButton(
          icon: isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          onTap: onToggleFullscreen,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildCenterControls(bool isPlaying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        _HudCircleButton(
          icon: Icons.replay_10_rounded,
          onTap: onRewind10,
          size: 42,
          iconSize: 22,
        ),

        const SizedBox(width: 32),

        // Play / Pause
        GestureDetector(
          onTap: onTogglePlayPause,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF006194),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCCE5FF).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006194).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        const SizedBox(width: 32),

        // Forward 10s
        _HudCircleButton(
          icon: Icons.forward_10_rounded,
          onTap: onForward10,
          size: 42,
          iconSize: 22,
        ),
      ],
    );
  }

  Widget _buildBottomBar(Duration position, Duration duration) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seekbar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 6),
            colors: VideoProgressColors(
              playedColor: const Color(0xFF86F2E4),
              bufferedColor: Colors.white.withValues(alpha: 0.25),
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),

        // Time & utility row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Time display
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  ' / ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Speed chip + PiP
            Row(
              children: [
                // Speed selector chip
                _SpeedChip(
                  speed: playbackSpeed,
                  onSpeedChanged: onSpeedChanged,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

/// Small circular button used in the HUD overlay.
class _HudCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _HudCircleButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF283044).withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

/// Small translucent icon button for the top HUD bar.
class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _HudIconButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF283044).withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

/// Playback speed selector chip with teal accent color.
class _SpeedChip extends StatelessWidget {
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  const _SpeedChip({
    required this.speed,
    required this.onSpeedChanged,
  });

  static const List<double> _speeds = [1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: speed,
      tooltip: 'سرعة التشغيل',
      onSelected: onSpeedChanged,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _speeds
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(
                '${s}x',
                style: TextStyle(
                  color: s == speed
                      ? const Color(0xFF86F2E4)
                      : Colors.white70,
                  fontWeight:
                      s == speed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF283044).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${speed}x',
          style: const TextStyle(
            color: Color(0xFF86F2E4),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
