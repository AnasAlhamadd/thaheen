import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../features/profile/presentation/cubit/settings_state.dart';
import '../localization/app_language.dart';

/// A Text widget that translates a given [translationKey] automatically
/// based on the active language from [SettingsCubit].
///
/// Usage:
/// ```dart
/// AppCustomText(
///   'active_courses_section',
///   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
/// )
/// ```
///
/// The key maps to an entry in [AppStrings]. If the key is not found,
/// the key itself is rendered as a fallback.
class AppCustomText extends StatelessWidget {
  /// The translation key defined in [AppStrings].
  final String translationKey;

  /// Text style — same semantics as [Text.style].
  final TextStyle? style;

  /// Maximum number of lines before overflow kicks in.
  final int? maxLines;

  /// How visual overflow is handled.
  final TextOverflow? overflow;

  /// Text alignment.
  final TextAlign? textAlign;

  /// Explicit text direction override. When null the direction is inferred
  /// from the active language (RTL for Arabic, LTR for English).
  final TextDirection? textDirection;

  /// Soft-wrap override.
  final bool? softWrap;

  const AppCustomText(
    this.translationKey, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textDirection,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        final text = AppStrings.tr(translationKey, langCode);

        // Infer direction from language unless explicitly overridden.
        final direction = textDirection ??
            (state.language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr);

        return Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
          textDirection: direction,
          softWrap: softWrap ?? true,
        );
      },
    );
  }
}
