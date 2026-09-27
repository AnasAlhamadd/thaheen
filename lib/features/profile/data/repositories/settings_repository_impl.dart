import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../app/theme/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] leveraging [StorageService].
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language_code';

  final StorageService _storageService;

  /// Creates a [SettingsRepositoryImpl] with required [_storageService].
  SettingsRepositoryImpl({required this._storageService});

  @override
  Future<AppThemeMode> getThemeMode() async {
    final rawValue = await _storageService.getString(_themeModeKey);
    return AppThemeMode.fromKey(rawValue);
  }

  @override
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    await _storageService.setString(_themeModeKey, themeMode.key);
  }

  @override
  Future<AppLanguage> getLanguage(Locale? platformLocale) async {
    final rawCode = await _storageService.getString(_languageKey);
    if (rawCode != null && rawCode.isNotEmpty) {
      return AppLanguage.fromCode(rawCode);
    }

    // Determine from device/platform locale
    if (platformLocale != null) {
      final deviceCode = platformLocale.languageCode.toLowerCase();
      if (deviceCode.startsWith('ar')) {
        return AppLanguage.arabic;
      } else if (deviceCode.startsWith('en')) {
        return AppLanguage.english;
      }
    }

    // Default to Arabic
    return AppLanguage.arabic;
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    await _storageService.setString(_languageKey, language.languageCode);
  }
}
