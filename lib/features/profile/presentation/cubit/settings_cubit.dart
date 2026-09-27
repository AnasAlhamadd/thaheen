import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../app/theme/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

/// Cubit managing app-level theme mode and language state with persistence.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  /// Creates a [SettingsCubit] with repository.
  SettingsCubit({required this._settingsRepository})
    : super(SettingsState.initial());

  /// Loads initial settings from persistent storage and platform locale.
  Future<void> loadSettings({Locale? platformLocale}) async {
    final themeMode = await _settingsRepository.getThemeMode();
    final language = await _settingsRepository.getLanguage(platformLocale);

    emit(
      SettingsState(themeMode: themeMode, language: language, isLoading: false),
    );
  }

  /// Changes and persists the application [AppThemeMode].
  Future<void> updateThemeMode(AppThemeMode newThemeMode) async {
    emit(state.copyWith(themeMode: newThemeMode));
    await _settingsRepository.saveThemeMode(newThemeMode);
  }

  /// Changes and persists the application [AppLanguage].
  Future<void> updateLanguage(AppLanguage newLanguage) async {
    emit(state.copyWith(language: newLanguage));
    await _settingsRepository.saveLanguage(newLanguage);
  }
}
