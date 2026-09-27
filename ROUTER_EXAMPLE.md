# مثال على إعداد Router مع Custom Navigation Bar

## الخطوة 1: إنشاء ملف Router

أنشئ ملف `lib/core/routing/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen/presentation/navigation/main_navigation_screen.dart';
import 'package:thaheen/features/courses/presentation/screens/courses_screen.dart';
import 'package:thaheen/features/courses/presentation/screens/course_details_screen.dart';
import 'package:thaheen/features/player/presentation/screens/lesson_player_screen.dart';

/// Global router configuration for the application
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route - يعرض الـ navigation bar
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        // الصفحة الرئيسية / قائمة الدورات
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CoursesScreen(),
          ),
        ),
        
        // قائمة الدورات (نفس الصفحة الرئيسية)
        GoRoute(
          path: '/courses',
          name: 'courses',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CoursesScreen(),
          ),
        ),
        
        // صفحة الاختبارات (مستقبلية)
        GoRoute(
          path: '/tests',
          name: 'tests',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(
                child: Text(
                  'الاختبارات',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
        
        // صفحة التقدم (مستقبلية)
        GoRoute(
          path: '/progress',
          name: 'progress',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(
                child: Text(
                  'تقدمي',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
        
        // الملف الشخصي (مستقبلي)
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(
                child: Text(
                  'الملف الشخصي',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    
    // الشاشات التي لا تحتاج navigation bar
    
    // تفاصيل الدورة
    GoRoute(
      path: '/courses/:courseId',
      name: 'course-details',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        return CourseDetailsScreen(courseId: courseId);
      },
    ),
    
    // مشغل الدرس
    GoRoute(
      path: '/courses/:courseId/lessons/:lessonId',
      name: 'lesson-player',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        final lessonId = state.pathParameters['lessonId']!;
        return LessonPlayerScreen(
          courseId: courseId,
          lessonId: lessonId,
        );
      },
    ),
  ],
  
  // معالجة الأخطاء
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'الصفحة غير موجودة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(state.uri.toString()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('العودة للرئيسية'),
          ),
        ],
      ),
    ),
  ),
);
```

## الخطوة 2: استخدام الـ Router في main.dart

عدّل ملف `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thaheen/app/theme/app_theme.dart';
import 'package:thaheen/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // قفل الاتجاه على Portrait فقط (اختياري)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ThaheenApp());
}

class ThaheenApp extends StatelessWidget {
  const ThaheenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ذهين | Thaheen',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Localization - Arabic first
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // English (optional)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Router configuration
      routerConfig: appRouter,
    );
  }
}
```

## الخطوة 3: التنقل بين الشاشات

### من داخل أي widget:

```dart
import 'package:go_router/go_router.dart';

// الانتقال إلى صفحة معينة
context.go('/courses');

// الانتقال إلى تفاصيل دورة
context.push('/courses/anatomy-101');

// الانتقال إلى مشغل الدرس
context.push('/courses/anatomy-101/lessons/lesson-1');

// العودة للخلف
context.pop();

// الاستبدال (بدون إضافة للـ stack)
context.replace('/courses');

// الانتقال باستخدام الاسم مع parameters
context.goNamed(
  'lesson-player',
  pathParameters: {
    'courseId': 'anatomy-101',
    'lessonId': 'lesson-1',
  },
);
```

## ملاحظات مهمة

### 1. NoTransitionPage

استخدمنا `NoTransitionPage` للصفحات داخل الـ navigation bar لتجنب الحركات المزعجة عند التبديل بين التبويبات:

```dart
pageBuilder: (context, state) => NoTransitionPage(
  key: state.pageKey,
  child: const CoursesScreen(),
),
```

### 2. ShellRoute vs StatefulShellRoute

- **ShellRoute**: يعيد بناء الصفحة كل مرة (بسيط ومناسب لهذا التطبيق)
- **StatefulShellRoute**: يحفظ حالة كل صفحة (مفيد للصفحات المعقدة)

### 3. الصفحات بدون Navigation Bar

الصفحات التي لا تحتاج navigation bar (مثل تفاصيل الدورة ومشغل الفيديو) يتم تعريفها خارج الـ `ShellRoute`:

```dart
// ✅ خارج ShellRoute - بدون navigation bar
GoRoute(
  path: '/courses/:courseId',
  name: 'course-details',
  builder: (context, state) => CourseDetailsScreen(...),
),
```

### 4. معالجة الأخطاء

استخدمنا `errorBuilder` لعرض صفحة خطأ مخصصة عندما يحاول المستخدم الوصول لصفحة غير موجودة.

## مثال كامل للتنقل في CoursesScreen

```dart
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            course: course,
            onTap: () {
              // الانتقال إلى تفاصيل الدورة
              context.push('/courses/${course.id}');
            },
          );
        },
      ),
    );
  }
}
```

## اختبار التنقل

للتأكد من عمل كل شيء بشكل صحيح:

1. ✅ التنقل بين التبويبات الخمسة من الـ navigation bar
2. ✅ فتح تفاصيل دورة (يختفي الـ navigation bar)
3. ✅ فتح مشغل الدرس (يختفي الـ navigation bar)
4. ✅ الرجوع بزر الرجوع
5. ✅ حالة الـ navigation bar تتحدث تلقائياً حسب المسار
6. ✅ معالجة الأخطاء للصفحات غير الموجودة

---

**جاهز للتطبيق مباشرةً في Thaheen! 🚀**
