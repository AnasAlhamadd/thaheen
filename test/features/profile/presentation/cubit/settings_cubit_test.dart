import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:thaheen/core/localization/app_language.dart';
import 'package:thaheen/app/theme/app_theme_mode.dart';
import 'package:thaheen/features/profile/domain/repositories/settings_repository.dart';
import 'package:thaheen/features/profile/presentation/cubit/settings_cubit.dart';

class FakeSettingsRepository implements SettingsRepository {
  AppThemeMode themeMode = AppThemeMode.system;
  AppLanguage language = AppLanguage.arabic;

  @override
  Future<AppThemeMode> getThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async => themeMode = mode;

  @override
  Future<AppLanguage> getLanguage(Locale? platformLocale) async => language;

  @override
  Future<void> saveLanguage(AppLanguage lang) async => language = lang;
}

void main() {
  group('SettingsCubit Tests', () {
    late FakeSettingsRepository repository;
    late SettingsCubit cubit;

    setUp(() {
      repository = FakeSettingsRepository();
      cubit = SettingsCubit(settingsRepository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state is loading', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.themeMode, equals(AppThemeMode.system));
      expect(cubit.state.language, equals(AppLanguage.arabic));
    });

    test(
      'loadSettings loads preferences and sets isLoading to false',
      () async {
        repository.themeMode = AppThemeMode.dark;
        repository.language = AppLanguage.english;

        await cubit.loadSettings();

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.themeMode, equals(AppThemeMode.dark));
        expect(cubit.state.language, equals(AppLanguage.english));
      },
    );

    test('updateThemeMode updates state and persists to repository', () async {
      await cubit.loadSettings();
      await cubit.updateThemeMode(AppThemeMode.dark);

      expect(cubit.state.themeMode, equals(AppThemeMode.dark));
      expect(repository.themeMode, equals(AppThemeMode.dark));
    });

    test('updateLanguage updates state and persists to repository', () async {
      await cubit.loadSettings();
      await cubit.updateLanguage(AppLanguage.english);

      expect(cubit.state.language, equals(AppLanguage.english));
      expect(repository.language, equals(AppLanguage.english));
    });
  });
}
