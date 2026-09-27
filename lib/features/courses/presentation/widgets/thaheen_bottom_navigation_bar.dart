import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';
import '../../../../features/profile/presentation/cubit/settings_state.dart';

/// Bottom navigation bar widget providing tab switching for the primary LMS sections.
/// Uses Stack to overlay the navigation bar on top of the screen content.
class ThaheenBottomNavigationBar extends StatelessWidget {
  /// Index of the currently active tab.
  final int currentIndex;

  /// Callback triggered when a tab is selected.
  final ValueChanged<int> onTabSelected;

  /// The main screen content to display.
  final Widget child;

  /// Creates a [ThaheenBottomNavigationBar] with Stack layout.
  const ThaheenBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // الطبقة الأولى: محتوى الشاشة الكامل
          child,

          // الطبقة الأخيرة: Navigation Bar العائم
          Positioned(
            left: 15,
            right: 15,
            bottom: 15,
            child: _FloatingNavBar(
              currentIndex: currentIndex,
              onTabSelected: onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

/// The floating navigation bar component.
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
              .withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          // Shadow من الأعلى (الأصلي)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
          // Shadow من الأسفل (أبيض/أسود فاتح)
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4), // 👈 من الأسفل (سالب)
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58, // 👈 تصغير من 68 إلى 58
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0, // 👈 تقليل من 10 إلى 8
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (prev, curr) => prev.language != curr.language,
                    builder: (context, state) {
                      final langCode = state.language.languageCode;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NavItem(
                            index: 0,
                            currentIndex: currentIndex,
                            label: AppStrings.tr('navigation_home', langCode),
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            onTap: () => onTabSelected(0),
                          ),
                          _NavItem(
                            index: 1,
                            currentIndex: currentIndex,
                            label: AppStrings.tr('navigation_courses', langCode),
                            icon: Icons.school_outlined,
                            activeIcon: Icons.school_rounded,
                            onTap: () => onTabSelected(1),
                          ),
                          _NavItem(
                            index: 2,
                            currentIndex: currentIndex,
                            label: AppStrings.tr('navigation_profile', langCode),
                            icon: Icons.account_circle_outlined,
                            activeIcon: Icons.account_circle_rounded,
                            onTap: () => onTabSelected(2),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    if (widget.index == widget.currentIndex) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == widget.currentIndex &&
        oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward(from: 0);
    } else if (widget.index != widget.currentIndex &&
        oldWidget.currentIndex == widget.index) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = widget.index == widget.currentIndex;
    final primaryColor = isDark ? const Color(0xFF38BDF8) : AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextDisabled
        : AppColors.lightTextDisabled;

    return Expanded(
      flex: isSelected ? 0 : 1,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: isSelected ? Curves.easeOutCubic : Curves.easeInCubic,
          width: isSelected ? 128 : null,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(isSelected ? 8 : 6),
          decoration: isSelected
              ? BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                )
              : null,
          child: isSelected
              ? _buildActiveItem(widget.activeIcon, widget.label)
              : _buildInactiveItem(widget.icon, inactiveColor),
        ),
      ),
    );
  }

  Widget _buildActiveItem(IconData icon, String label) {
    return FadeTransition(
      opacity: _animationController,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveItem(IconData icon, Color color) {
    return Icon(icon, size: 22, color: color);
  }
}
