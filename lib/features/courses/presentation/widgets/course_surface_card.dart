import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Shared elevated surface used by course details tabs and empty states.
class CourseSurfaceCard extends StatelessWidget {
  /// Inner content of the card.
  final Widget child;

  /// Inner padding. Defaults to 16.
  final EdgeInsetsGeometry padding;

  /// Creates a [CourseSurfaceCard].
  const CourseSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}
