import 'package:equatable/equatable.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../app/theme/app_theme_mode.dart';

/// Immutable state holding active settings: theme mode and language.
class SettingsState extends Equatable {
  /// Currently selected theme mode (light, dark, or system).
  final AppThemeMode themeMode;

  /// Currently active application language.
  final AppLanguage language;

  /// True when settings are still being read from disk.
  final bool isLoading;

  /// Creates a [SettingsState].
  const SettingsState({
    required this.themeMode,
    required this.language,
    this.isLoading = false,
  });

  /// Factory for initial state before storage load.
  factory SettingsState.initial() => const SettingsState(
        themeMode: AppThemeMode.system,
        language: AppLanguage.arabic,
        isLoading: true,
      );

  /// Returns a copy of the state with updated fields.
  SettingsState copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, language, isLoading];
}
