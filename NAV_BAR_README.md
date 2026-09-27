# Custom Bottom Navigation Bar - Implementation Guide

## 📦 Dependencies Required

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_screenutil: ^5.9.0
  flutter_svg: ^2.0.9
  go_router: ^14.0.0
```

Run: `flutter pub get`

## 🎨 Features

- **Animated Active Chip**: Smooth transition when switching tabs
- **Floating Design**: Bottom nav floats above content with shadow
- **Responsive Design**: Uses ScreenUtil for consistent sizing
- **Customizable Colors**: Easy to match your app theme
- **SVG Icons**: Supports vector icons

## 📁 File Structure

Place `custom_bottom_nav_bar.dart` in your project (e.g., `lib/widgets/`)

## 🚀 Usage Example

### 1. Setup ScreenUtil in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
```

### 2. Define your routes

```dart
class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/horses',
        name: 'horses',
        builder: (context, state) => const HorsesScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/auctions',
        name: 'auctions',
        builder: (context, state) => const AuctionsScreen(),
      ),
      GoRoute(
        path: '/championships',
        name: 'championships',
        builder: (context, state) => const ChampionshipsScreen(),
      ),
    ],
  );
}
```

### 3. Use the Custom Bottom Navigation Bar

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_bottom_nav_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      primaryColor: const Color(0xFF1E88E5), // Your app's primary color
      backgroundColor: const Color(0xFFFFFFFF),
      surfaceElevatedColor: const Color(0xFFF5F5F5),
      textColor: const Color(0xFF1A1A1A),
      textTertiaryColor: const Color(0xFF9E9E9E),
      borderColor: const Color(0xFFE0E0E0),
      navItems: const [
        NavItem(
          iconPath: 'assets/icons/home_icon.svg',
          route: '/',
          label: 'Home',
        ),
        NavItem(
          iconPath: 'assets/icons/horse_icon.svg',
          route: '/horses',
          label: 'Horses',
        ),
        NavItem(
          iconPath: 'assets/icons/community_icon.svg',
          route: '/community',
          label: 'Community',
        ),
        NavItem(
          iconPath: 'assets/icons/auction_icon.svg',
          route: '/auctions',
          label: 'Auctions',
        ),
        NavItem(
          iconPath: 'assets/icons/championship_icon.svg',
          route: '/championships',
          label: 'Championships',
        ),
      ],
      child: const YourMainContentWidget(),
    );
  }
}
```

### 4. Add SVG icons to your assets

Create SVG icons in `assets/icons/` folder and add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/
```

## 🎨 Customization

### Colors

You can customize the colors by passing these parameters:

- `primaryColor`: Color of the active chip
- `backgroundColor`: Background color of the nav bar
- `surfaceElevatedColor`: Gradient start color
- `textColor`: Text color (for labels)
- `textTertiaryColor`: Inactive icon color
- `borderColor`: Border color

### Dimensions

The design uses these constants (can be modified in the code):

- `_navBarHorizontalPadding`: 12 (horizontal padding from screen edges)
- `_navBarInnerVerticalPadding`: 10 (vertical padding inside nav bar)
- `_navBarInnerHorizontalPadding`: 8 (horizontal padding inside nav bar)
- `_navActiveChipWidth`: 118 (width of active chip)

## 🤖 AI Prompt for Recreation

If you want to recreate this in another project using AI, use this prompt:

---

**PROMPT:**

Create a Flutter custom bottom navigation bar with the following specifications:

**Design Requirements:**
1. Floating bottom navigation bar that sits 10px from the bottom of the screen
2. Horizontal padding of 12px from screen edges
3. Rounded corners with 35px outer radius and 25px inner radius
4. Gradient background from surface color to background color
5. Subtle shadow with two layers (blur 20px offset 8px, and blur 24px offset 4px)
6. Border with 1px width and 10% opacity

**Active State:**
1. When a tab is active, show a pill-shaped chip with 118px width
2. Chip should have the app's primary color background
3. White border around the chip
4. White icon + text label inside the chip
5. Icon size: 20x22px
6. Text: 11sp font size, weight 500
7. 8px spacing between icon and text

**Inactive State:**
1. Show only the icon
2. Icon size: 22x24px
3. Gray/tertiary color for inactive icons
4. 6px padding around icon

**Animation:**
1. Smooth transition between active/inactive states
2. Duration: 220ms
3. Use easeOutCubic for switch-in, easeInCubic for switch-out

**Technical Requirements:**
1. Use flutter_screenutil for responsive sizing (.w, .h, .r, .sp)
2. Use flutter_svg for icons
3. Use go_router for navigation
4. The active item should NOT expand (fixed width), inactive items should expand to fill space
5. Listen to route changes to update active state automatically
6. Use PositionedDirectional for RTL support
7. The nav bar should overlay content (not push it up)

**Dependencies:**
- flutter_screenutil
- flutter_svg
- go_router

Provide the code as a reusable widget that accepts:
- List of navigation items (icon path, route, label)
- Customizable colors
- Child widget for the main content

---

## 📝 Notes

- The nav bar uses `resizeToAvoidBottomInset: false` so the keyboard overlays it instead of pushing it up
- The active item has fixed width while inactive items expand to fill remaining space
- RTL support is built-in with `PositionedDirectional`
- The widget automatically tracks route changes using GoRouter listener
