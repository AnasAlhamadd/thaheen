import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/localization/app_language.dart';

/// Standard Thaheen app bar with profile picture, greeting, and settings icon.
///
/// This is the unified app bar design used across all main navigation screens.
class ThaheenAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// User's display name shown in the greeting.
  final String userName;

  /// Callback when the profile picture is tapped.
  final VoidCallback? onProfileTap;

  /// Callback when the settings icon is tapped.
  final VoidCallback? onSettingsTap;

  /// Profile image asset path. Defaults to assets/images/avatar.png.
  final String profileImageUrl;

  /// Creates a [ThaheenAppBar].
  const ThaheenAppBar({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.onSettingsTap,
    this.profileImageUrl = 'assets/images/avatar.png',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.white;
    final containerColor = isDark ? AppColors.darkSurface.withOpacity(0.8) : Colors.transparent;
    final borderColor = isDark ? AppColors.darkBorder : Colors.white.withOpacity(0.3);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: containerColor,
        ),
        child: Row(
          children: [
            // Leading: Profile Picture
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    profileImageUrl,
                    fit: BoxFit.cover,
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Center: Greeting Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('welcome', 'ar'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Trailing: Settings Icon
            GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  // color: iconContainerColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: textColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
