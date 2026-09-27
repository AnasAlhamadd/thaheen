import 'package:flutter/material.dart';

/// Design tokens and semantic color definitions for light and dark modes.
abstract final class AppColors {
  // Brand colors
  /// Primary brand blue.
  static const Color primary = Color(0xFF006194);

  /// Dark shade of primary blue used in cards and banners.
  static const Color primaryDark = Color(0xFF0369A1);

  /// Light tint of primary blue used in chips and metric backgrounds.
  static const Color primaryLight = Color(0xfffafafa);

  /// Primary container color.  
  static const Color primaryContainer = Color(0xFF007BB9);

  /// Secondary teal tone used in science and test bank components.
  static const Color secondary = Color(0xFF006A61);

  /// Light teal container for secondary highlights.
  static const Color secondaryContainer = Color(0xFFE0F7F5);

  /// Accent emerald green used for success and online indicators.
  static const Color successEmerald = Color(0xFF10B981);

  /// Warning and streak gold color.
  static const Color warningGold = Color(0xFFF59E0B);

  /// Error and notification badge coral color.
  static const Color errorCoral = Color(0xFFEF4444);

  // Light Mode Canvas & Surfaces
  /// Background canvas color for light mode.
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Pure white surface color for light cards.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Primary high-contrast text color for light mode.
  static const Color lightTextPrimary = Color(0xFF0F172A);

  /// Secondary muted text color for light mode.
  static const Color lightTextSecondary = Color(0xFF475569);

  /// Disabled slate text color for light mode.
  static const Color lightTextDisabled = Color(0xFF94A3B8);

  /// Default border color for light mode.
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Subtle divider color for light mode.
  static const Color lightDivider = Color(0xFFF1F5F9);

  /// Background color for locked items in light mode.
  static const Color lightLockedSurface = Color(0xFFF1F5F9);

  // Dark Mode Canvas & Surfaces
  /// Deep midnight background canvas for dark mode.
  static const Color darkBackground = Color(0xFF0B111E);

  /// Elevated dark card surface.
  static const Color darkSurface = Color(0xFF161F30);

  /// Secondary elevated dark surface.
  static const Color darkSurfaceVariant = Color(0xFF1E293B);

  /// High-contrast white/slate text for dark mode.
  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  /// Muted slate text for dark mode.
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Subtle disabled text for dark mode.
  static const Color darkTextDisabled = Color(0xFF64748B);

  /// Subtle borders for dark cards.
  static const Color darkBorder = Color(0xFF1E293B);

  /// Dark divider color.
  static const Color darkDivider = Color(0xFF1E293B);

  /// Dark locked surface color.
  static const Color darkLockedSurface = Color(0xFF1E293B);

  // Backward compatibility aliases
  /// Default background canvas for legacy light references.
  static const Color backgroundCanvas = lightBackground;

  /// Default surface for legacy light references.
  static const Color surface = lightSurface;

  /// Default text primary for legacy light references.
  static const Color textPrimary = lightTextPrimary;

  /// Default text secondary for legacy light references.
  static const Color textSecondary = lightTextSecondary;

  /// Default text disabled for legacy light references.
  static const Color textDisabled = lightTextDisabled;

  /// Default border for legacy light references.
  static const Color borderDefault = lightBorder;

  /// Default divider for legacy light references.
  static const Color dividerSubtle = lightDivider;

  /// Default locked surface for legacy light references.
  static const Color lockedSurface = lightLockedSurface;
}

/// Central application theme configuration providing Light and Dark themes with typography.
class AppTheme {
  /// Builds ThemeData for light mode based on active locale font family.
  static ThemeData getLightTheme({String fontFamily = 'Cairo'}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.secondary,
        error: AppColors.errorCoral,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightLockedSurface,
        outline: AppColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.lightDivider,
    );
  }

  /// Builds ThemeData for dark mode based on active locale font family.
  static ThemeData getDarkTheme({String fontFamily = 'Cairo'}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF38BDF8),
        onPrimary: Color(0xFF082F49),
        primaryContainer: Color(0xFF0284C7),
        onPrimaryContainer: Colors.white,
        secondary: Color(0xFF2DD4BF),
        onSecondary: Color(0xFF042F2E),
        secondaryContainer: Color(0xFF115E59),
        onSecondaryContainer: Color(0xFFCCFBF1),
        error: AppColors.errorCoral,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkLockedSurface,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.darkDivider,
    );
  }

  /// Returns standard light theme with Cairo font.
  static ThemeData get lightTheme => getLightTheme(fontFamily: 'Cairo');

  /// Returns standard dark theme with Cairo font.
  static ThemeData get darkTheme => getDarkTheme(fontFamily: 'Cairo');
}
