import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Shimmer loading widget matching the course card layout.
/// Used during search filtering to indicate loading state.
class CourseCardShimmer extends StatefulWidget {
  const CourseCardShimmer({super.key});

  @override
  State<CourseCardShimmer> createState() => _CourseCardShimmerState();
}

class _CourseCardShimmerState extends State<CourseCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Stack(
            children: [
              // Base shimmer content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Thumbnail shimmer
                        _ShimmerBox(
                          width: 80,
                          height: 80,
                          borderRadius: 12,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title shimmer
                              _ShimmerBox(
                                width: double.infinity,
                                height: 18,
                                borderRadius: 6,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 8),
                              // Subtitle shimmer
                              _ShimmerBox(
                                width: 120,
                                height: 14,
                                borderRadius: 6,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              // Metadata row shimmer
                              Row(
                                children: [
                                  _ShimmerBox(
                                    width: 60,
                                    height: 12,
                                    borderRadius: 6,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  _ShimmerBox(
                                    width: 60,
                                    height: 12,
                                    borderRadius: 6,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar shimmer
                    _ShimmerBox(
                      width: double.infinity,
                      height: 6,
                      borderRadius: 3,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              // Shimmer gradient overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: [
                          _animation.value - 0.3,
                          _animation.value,
                          _animation.value + 0.3,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBorder.withOpacity(0.5)
            : AppColors.lightBorder.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
