# Custom Bottom Navigation Bar - دليل الاستخدام

## ✨ الميزات

- **تصميم عصري عائم**: شريط التنقل يطفو فوق المحتوى مع ظلال أنيقة
- **رقاقة نشطة متحركة**: انتقالات سلسة عند التبديل بين التبويبات
- **تصميم متجاوب**: حجم ثابت للعنصر النشط والباقي يتوسع
- **دعم RTL**: يعمل بشكل صحيح مع اللغة العربية
- **ألوان قابلة للتخصيص**: سهل التخصيص ليتناسب مع ثيم التطبيق

## 📦 التبعيات المطلوبة

التبعيات موجودة بالفعل في `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  go_router: ^18.0.1
```

## 🚀 طريقة الاستخدام

### 1. استخدم الـ Navigation Bar في التطبيق

```dart
import 'package:flutter/material.dart';
import 'package:thaheen/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:thaheen/app/theme/app_theme.dart';

class MainNavigationScreen extends StatelessWidget {
  final Widget child;

  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      // استخدام ألوان التطبيق من AppColors
      primaryColor: AppColors.primary,
      backgroundColor: AppColors.lightSurface,
      surfaceColor: AppColors.lightBackground,
      textColor: AppColors.lightTextPrimary,
      inactiveColor: AppColors.lightTextDisabled,
      borderColor: AppColors.lightBorder,
      
      // تعريف عناصر التنقل المناسبة للتطبيق التعليمي
      navItems: const [
        NavItem(
          icon: Icons.home_rounded,
          route: '/',
          label: 'الرئيسية',
        ),
        NavItem(
          icon: Icons.school_rounded,
          route: '/courses',
          label: 'الدورات',
        ),
        NavItem(
          icon: Icons.quiz_rounded,
          route: '/tests',
          label: 'الاختبارات',
        ),
        NavItem(
          icon: Icons.leaderboard_rounded,
          route: '/progress',
          label: 'تقدمي',
        ),
        NavItem(
          icon: Icons.person_rounded,
          route: '/profile',
          label: 'الملف',
        ),
      ],
      child: child,
    );
  }
}
```

### 2. إعداد الـ Router

في ملف الـ Router الخاص بك (مثلاً `lib/core/routing/app_router.dart`):

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: '/courses',
          name: 'courses',
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: '/tests',
          name: 'tests',
          builder: (context, state) => const TestsScreen(),
        ),
        GoRoute(
          path: '/progress',
          name: 'progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    // الشاشات التي لا تحتاج Navigation Bar
    GoRoute(
      path: '/courses/:courseId',
      name: 'course-details',
      builder: (context, state) => CourseDetailsScreen(
        courseId: state.pathParameters['courseId']!,
      ),
    ),
    GoRoute(
      path: '/courses/:courseId/lessons/:lessonId',
      name: 'lesson-player',
      builder: (context, state) => LessonPlayerScreen(
        courseId: state.pathParameters['courseId']!,
        lessonId: state.pathParameters['lessonId']!,
      ),
    ),
  ],
);
```

## 🎨 الأيقونات المقترحة لتطبيق Thaheen التعليمي

### خيار 1: أيقونات Material (موجودة حالياً) ✅

```dart
navItems: const [
  NavItem(
    icon: Icons.home_rounded,
    route: '/',
    label: 'الرئيسية',
  ),
  NavItem(
    icon: Icons.school_rounded,  // أيقونة الدورات/التعليم
    route: '/courses',
    label: 'الدورات',
  ),
  NavItem(
    icon: Icons.quiz_rounded,  // أيقونة الاختبارات
    route: '/tests',
    label: 'الاختبارات',
  ),
  NavItem(
    icon: Icons.leaderboard_rounded,  // أيقونة التقدم/الإحصائيات
    route: '/progress',
    label: 'تقدمي',
  ),
  NavItem(
    icon: Icons.person_rounded,  // أيقونة الملف الشخصي
    route: '/profile',
    label: 'الملف',
  ),
],
```

### خيار 2: أيقونات بديلة للمحتوى الطبي

```dart
navItems: const [
  NavItem(
    icon: Icons.home_rounded,
    route: '/',
    label: 'الرئيسية',
  ),
  NavItem(
    icon: Icons.library_books_rounded,  // مكتبة الكتب للدروس
    route: '/courses',
    label: 'الدورات',
  ),
  NavItem(
    icon: Icons.science_rounded,  // أيقونة العلوم للمحتوى الطبي
    route: '/labs',
    label: 'المختبر',
  ),
  NavItem(
    icon: Icons.description_rounded,  // أيقونة الملاحظات
    route: '/notes',
    label: 'ملاحظاتي',
  ),
  NavItem(
    icon: Icons.account_circle_rounded,
    route: '/profile',
    label: 'حسابي',
  ),
],
```

### خيار 3: تركيز على المراجعة والاختبارات

```dart
navItems: const [
  NavItem(
    icon: Icons.dashboard_rounded,
    route: '/',
    label: 'لوحتي',
  ),
  NavItem(
    icon: Icons.video_library_rounded,  // مكتبة الفيديوهات
    route: '/lessons',
    label: 'الدروس',
  ),
  NavItem(
    icon: Icons.question_answer_rounded,  // الأسئلة والأجوبة
    route: '/qa',
    label: 'الأسئلة',
  ),
  NavItem(
    icon: Icons.analytics_rounded,  // التحليلات والإحصائيات
    route: '/analytics',
    label: 'الإحصائيات',
  ),
  NavItem(
    icon: Icons.settings_rounded,
    route: '/settings',
    label: 'الإعدادات',
  ),
],
```

## 🎨 تخصيص الألوان للوضع الداكن

```dart
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return CustomBottomNavBar(
    primaryColor: isDark 
        ? const Color(0xFF38BDF8)  // أزرق فاتح للوضع الداكن
        : AppColors.primary,
    backgroundColor: isDark 
        ? AppColors.darkSurface 
        : AppColors.lightSurface,
    surfaceColor: isDark 
        ? AppColors.darkBackground 
        : AppColors.lightBackground,
    textColor: isDark 
        ? AppColors.darkTextPrimary 
        : AppColors.lightTextPrimary,
    inactiveColor: isDark 
        ? AppColors.darkTextDisabled 
        : AppColors.lightTextDisabled,
    borderColor: isDark 
        ? AppColors.darkBorder 
        : AppColors.lightBorder,
    navItems: const [...],
    child: child,
  );
}
```

## 📐 المواصفات التصميمية

- **عرض الرقاقة النشطة**: 118px
- **الحشو الأفقي**: 12px من حواف الشاشة
- **الحشو الداخلي العمودي**: 10px
- **الحشو الداخلي الأفقي**: 8px
- **المسافة من الأسفل**: 10px
- **نصف القطر الخارجي**: 35px
- **نصف القطر الداخلي**: 25px
- **حجم الأيقونة النشطة**: 20x20px
- **حجم الأيقونة غير النشطة**: 22x22px
- **حجم النص**: 11sp
- **وزن النص**: 500 (Medium)
- **مدة الحركة**: 220ms

## ⚙️ الثوابت القابلة للتعديل

يمكنك تعديل الثوابت في الكود مباشرةً:

```dart
// في ملف custom_bottom_nav_bar.dart
static const double _navBarHorizontalPadding = 12.0;
static const double _navActiveChipWidth = 118.0;
static const double _navBarBottomMargin = 10.0;
// ... إلخ
```

## 🔄 الحركات والتأثيرات

- **انتقال الرقاقة النشطة**: Smooth transition مع easing curves
- **ظهور النص**: FadeTransition للنص عند التفعيل
- **المدة**: 220ms لجميع الحركات
- **Curves**: 
  - `easeOutCubic` للتبديل إلى النشط
  - `easeInCubic` للتبديل إلى غير النشط

## 📝 ملاحظات مهمة

1. **الأيقونات**: استخدمنا أيقونات Material Icons المضمنة في Flutter (لا حاجة لملفات SVG)
2. **الدعم RTL**: الـ widget يدعم RTL تلقائياً مع Flutter
3. **التكامل مع go_router**: يتتبع المسارات تلقائياً
4. **resizeToAvoidBottomInset: false**: الكيبورد يغطي الـ nav bar بدلاً من دفعه للأعلى
5. **ShellRoute**: استخدم ShellRoute لإبقاء الـ nav bar ظاهراً في الشاشات المطلوبة

## ✅ ما تم توفيره

✓ تصميم عائم أنيق مع ظلال  
✓ رقاقة نشطة متحركة بعرض ثابت  
✓ أيقونات Material Icons (بدون الحاجة لملفات SVG)  
✓ دعم RTL كامل للعربية  
✓ تكامل مع go_router  
✓ ألوان متناسقة مع ثيم التطبيق  
✓ حركات سلسة ومُحسّنة  

## 🎯 الفرق عن النسخة الأصلية في NAV_BAR_README.md

1. **الأيقونات**: استخدام Material Icons بدلاً من ملفات SVG
2. **ScreenUtil**: إزالة الاعتماد على flutter_screenutil (استخدام أرقام ثابتة بدلاً منه)
3. **التكامل**: متكامل مع بنية تطبيق Thaheen الحالية
4. **الألوان**: استخدام ألوان AppColors من ثيم التطبيق
5. **الأيقونات المقترحة**: أيقونات تعليمية وطبية مناسبة لمحتوى التطبيق

---

**تم إنشاؤه لـ Thaheen - تطبيق LMS للطلاب الطبيين** 🎓
