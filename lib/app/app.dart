import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_language.dart';
import '../core/storage/storage_service.dart';
import '../features/courses/data/datasources/local_course_data_source.dart';
import '../features/courses/data/repositories/course_repository_impl.dart';
import '../features/courses/domain/repositories/course_repository.dart';
import '../features/player/data/datasources/progress_local_data_source.dart';
import '../features/player/data/repositories/progress_repository_impl.dart';
import '../features/player/domain/repositories/progress_repository.dart';
import '../features/player/domain/services/progress_service.dart';
import '../features/profile/data/repositories/settings_repository_impl.dart';
import '../features/profile/domain/repositories/settings_repository.dart';
import '../features/profile/presentation/cubit/settings_cubit.dart';
import '../features/profile/presentation/cubit/settings_state.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget for the Thaheen LMS application.
class ThaheenApp extends StatelessWidget {
  /// Instance of shared preferences used for persistent storage.
  final SharedPreferences sharedPreferences;

  /// Creates a [ThaheenApp].
  const ThaheenApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final storageService = SharedPreferencesStorageService(sharedPreferences);
    final settingsRepository = SettingsRepositoryImpl(
      storageService: storageService,
    );
    final deviceLocale = PlatformDispatcher.instance.locale;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProgressService>(create: (_) => ProgressService()),
        RepositoryProvider<CourseRepository>(
          create: (_) => CourseRepositoryImpl(
            localDataSource: LocalCourseDataSourceImpl(),
          ),
        ),
        RepositoryProvider<ProgressRepository>(
          create: (_) => ProgressRepositoryImpl(
            localDataSource: ProgressLocalDataSourceImpl(
              storageService: storageService,
            ),
          ),
        ),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
      ],
      child: BlocProvider(
        create: (context) =>
            SettingsCubit(settingsRepository: settingsRepository)
              ..loadSettings(platformLocale: deviceLocale),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final activeFontFamily = state.language.fontFamily;
            final activeLocale = state.language.locale;
            final themeMode = state.themeMode.toThemeMode;

            return MaterialApp.router(
              title: AppStrings.tr('app_title', state.language.languageCode),
              theme: AppTheme.getLightTheme(fontFamily: activeFontFamily),
              darkTheme: AppTheme.getDarkTheme(fontFamily: activeFontFamily),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                AppLanguage.arabic.locale,
                AppLanguage.english.locale,
              ],
              locale: activeLocale,
            );
          },
        ),
      ),
    );
  }
}
