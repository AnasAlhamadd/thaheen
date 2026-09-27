import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Skeleton placeholder shown while course details are loading.
class CourseDetailsLoadingView extends StatefulWidget {
  /// Creates a [CourseDetailsLoadingView].
  const CourseDetailsLoadingView({super.key});

  @override
  State<CourseDetailsLoadingView> createState() =>
      _CourseDetailsLoadingViewState();
}

class _CourseDetailsLoadingViewState extends State<CourseDetailsLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _ShimmerBlock(height: 210, radius: 24, isDark: isDark, t: _animation.value),
            const SizedBox(height: 14),
            _ShimmerBlock(height: 72, radius: 16, isDark: isDark, t: _animation.value),
            const SizedBox(height: 14),
            _ShimmerBlock(height: 44, radius: 12, isDark: isDark, t: _animation.value),
            const SizedBox(height: 14),
            _ShimmerBlock(height: 140, radius: 20, isDark: isDark, t: _animation.value),
            const SizedBox(height: 12),
            _ShimmerBlock(height: 140, radius: 20, isDark: isDark, t: _animation.value),
          ],
        );
      },
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double height;
  final double radius;
  final bool isDark;
  final double t;

  const _ShimmerBlock({
    required this.height,
    required this.radius,
    required this.isDark,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.35),
                Colors.transparent,
              ],
              stops: [t - 0.3, t, t + 0.3],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: ColoredBox(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightLockedSurface,
          ),
        ),
      ),
    );
  }
}
