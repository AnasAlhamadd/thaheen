import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_theme_mode.dart';
import '../../../../core/localization/app_language.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// Interactive Settings & Language card widget for the Profile tab.
class ProfileSettingsSection extends StatelessWidget {
  /// Creates a [ProfileSettingsSection].
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final langCode = state.language.languageCode;
        final cubit = context.read<SettingsCubit>();

        // Dark mode is ON when theme is explicitly dark; otherwise OFF.
        final isDarkMode = state.themeMode == AppThemeMode.dark;

        // English is ON when language is English; Arabic is OFF.
        final isEnglish = state.language == AppLanguage.english;

        return Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.tr('settings', langCode),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),

              // ── Theme / Dark Mode ────────────────────────────────────
              _SettingSwitchTile(
                icon: isDarkMode
                    ? Icons.nightlight_round
                    : Icons.wb_sunny_rounded,
                title: AppStrings.tr('theme', langCode),
                subtitle: AppStrings.tr('theme_mode_subtitle', langCode),
                value: isDarkMode,
                onChanged: (value) => cubit.updateThemeMode(
                  value ? AppThemeMode.dark : AppThemeMode.light,
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),

              // ── Language ─────────────────────────────────────────────
              _SettingSwitchTile(
                icon: Icons.translate_rounded,
                title: AppStrings.tr('language', langCode),
                subtitle: state.language.displayName,
                value: isEnglish,
                onChanged: (value) => cubit.updateLanguage(
                  value ? AppLanguage.english : AppLanguage.arabic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private tile widget
// ─────────────────────────────────────────────────────────────────────────────

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: () => onChanged(!value),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: isDark ? 0.2 : 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
