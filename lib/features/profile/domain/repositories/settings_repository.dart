import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../app/theme/app_theme_mode.dart';

/// Abstract contract for managing user and device preferences (theme & language).
abstract class SettingsRepository {
  /// Fetches saved theme mode or defaults to [AppThemeMode.system].
  Future<AppThemeMode> getThemeMode();

  /// Persists selected [AppThemeMode].
  Future<void> saveThemeMode(AppThemeMode themeMode);

  /// Fetches saved language or infers from platform dispatcher / device locale.
  Future<AppLanguage> getLanguage(Locale? platformLocale);

  /// Persists selected [AppLanguage].
  Future<void> saveLanguage(AppLanguage language);
}
