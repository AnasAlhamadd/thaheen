import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Three-column rapid action bar with micro-card buttons.
///
/// Actions: Save Note, Share Lesson, Clinical Transcript —
/// matching the Thaheen design language with hover-style
/// icon transitions and subtitle metadata.
class RapidActionBar extends StatelessWidget {
  /// Callback when the bookmark/save note action is tapped.
  final VoidCallback? onSaveNote;

  /// Callback when the share action is tapped.
  final VoidCallback? onShare;

  /// Callback when the transcript action is tapped.
  final VoidCallback? onTranscript;

  /// Whether the note is already saved.
  final bool isNoteSaved;

  /// Current position timestamp for the bookmark label.
  final String? bookmarkTimestamp;

  /// Creates a [RapidActionBar].
  const RapidActionBar({
    super.key,
    this.onSaveNote,
    this.onShare,
    this.onTranscript,
    this.isNoteSaved = false,
    this.bookmarkTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: isNoteSaved
                ? Icons.bookmark_added_rounded
                : Icons.bookmark_add_rounded,
            label: 'حفظ الملاحظة',
            subtitle: bookmarkTimestamp ?? '',
            onTap: onSaveNote,
            isDark: isDark,
            isActive: isNoteSaved,
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            icon: Icons.ios_share_rounded,
            label: 'مشاركة الدرس',
            subtitle: 'مع الزملاء',
            onTap: onShare,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            icon: Icons.description_rounded,
            label: 'التفريغ السريري',
            subtitle: 'ملخص PDF',
            onTap: onTranscript,
            isDark: isDark,
            subtitleColor:
                isDark ? const Color(0xFF2DD4BF) : AppColors.secondary,
            iconBgColor: isDark
                ? const Color(0xFF115E59).withValues(alpha: 0.4)
                : const Color(0xFF86F2E4).withValues(alpha: 0.2),
            iconColor: isDark
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF005049),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isActive;
  final Color? activeColor;
  final Color? subtitleColor;
  final Color? iconBgColor;
  final Color? iconColor;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.isActive = false,
    this.activeColor,
    this.subtitleColor,
    this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final resolvedIconBg = iconBgColor ??
        (isActive
            ? (isDark
                ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1))
            : (isDark
                ? AppColors.darkSurfaceVariant
                : const Color(0xFFF1F5F9)));
    final resolvedIconColor = iconColor ??
        (isActive
            ? (isDark ? const Color(0xFF38BDF8) : AppColors.primary)
            : textSec);

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? (isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.15))
                  : borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resolvedIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: resolvedIconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        subtitleColor != null ? FontWeight.w600 : FontWeight.w400,
                    color: subtitleColor ?? textSec,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
