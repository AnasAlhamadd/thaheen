import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

/// A scaffold with a gradient background that adapts to light/dark theme.
///
/// Light mode: Transitions from top blue (#73ADFA) to white.
/// Dark mode: Transitions from deep navy (#0A1628) to dark background
/// matching [AppColors.darkBackground] for consistency with the app theme.
///
/// The AppBar is integrated into the body and scrolls with the content
/// for a seamless experience.
class GradientScaffold extends StatelessWidget {
  /// The scrollable content of the scaffold.
  /// This will be placed below the integrated AppBar.
  final Widget body;

  /// Optional app bar widget to display at the top.
  /// This will be integrated into the scrollable area.
  final Widget? appBar;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Creates a [GradientScaffold] with theme-adaptive gradient background.
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [
            Color(0xFF0A1628),
            AppColors.darkBackground,
          ]
        : const [
            Color(0xFF73ADFA),
            Colors.white,
          ];

    final gradientStops = isDark
        ? const [0.0, 0.35]
        : const [0.0, 0.4];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: gradientStops,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            ...[appBar].whereType<Widget>(),
            Expanded(child: body),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
