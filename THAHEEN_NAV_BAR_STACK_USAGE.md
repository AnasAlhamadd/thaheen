# 📚 Thaheen Navigation Bar - دليل الاستخدام مع Stack

## ✅ التغييرات المُنفذة

تم تعديل `ThaheenBottomNavigationBar` ليعمل بنظام **Stack** بحيث:

1. **الطبقة الأولى (Scaffold)**: محتوى الشاشة الكامل
2. **الطبقة الأخيرة (Positioned)**: Navigation Bar عائم فوق المحتوى

---

## 🎯 الهيكل الجديد

```dart
ThaheenBottomNavigationBar(
  currentIndex: currentIndex,
  onTabSelected: (index) { /* ... */ },
  child: YourScreenContent(), // 👈 محتوى الشاشة هنا
)
```

### البنية الداخلية:

```dart
Scaffold
└── Stack
    ├── child (الطبقة الأولى - محتوى الشاشة)
    └── Positioned (الطبقة الأخيرة - Nav Bar العائم)
        ├── left: 15
        ├── right: 15
        └── bottom: 15
```

---

## 🚀 كيفية الاستخدام

### مثال 1: في شاشة الدورات

```dart
import 'package:flutter/material.dart';
import '../widgets/thaheen_bottom_navigation_bar.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ThaheenBottomNavigationBar(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
        // التنقل إلى الشاشة المطلوبة
        _navigateToTab(index);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ذهين'),
        ),
        body: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100, // 👈 مهم: اترك مساحة للـ nav bar
          ),
          children: [
            // محتوى الشاشة هنا
            const CourseCard(...),
            const CourseCard(...),
            // ... باقي المحتوى
          ],
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        // الرئيسية
        break;
      case 1:
        // دوراتي
        break;
      case 2:
        // المكتبة
        break;
      case 3:
        // الملف الشخصي
        break;
    }
  }
}
```

---

### مثال 2: مع PageView للتنقل بين الشاشات

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThaheenBottomNavigationBar(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          MyCoursesScreen(),
          LibraryScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
```

---

### مثال 3: مع Indexed Stack (أداء أفضل)

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyCoursesScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ThaheenBottomNavigationBar(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
```

---

## ⚠️ نقاط مهمة

### 1. **اترك مساحة للـ Nav Bar**

عند استخدام `ListView` أو `SingleChildScrollView`، تأكد من ترك مساحة كافية في الأسفل:

```dart
ListView(
  padding: const EdgeInsets.only(
    left: 16,
    right: 16,
    top: 16,
    bottom: 100, // ✅ مهم جداً: اترك مساحة للـ nav bar
  ),
  children: [...],
)
```

### 2. **resizeToAvoidBottomInset: false**

الـ widget يستخدم `resizeToAvoidBottomInset: false` لتجنب تحرك الـ nav bar عند ظهور الكيبورد.

### 3. **SafeArea**

الـ nav bar يحتوي على `SafeArea(top: false)` لضمان عدم التداخل مع الـ notch في الأجهزة الحديثة.

---

## 🎨 المظهر النهائي

```
┌─────────────────────────────────┐
│       AppBar                    │
├─────────────────────────────────┤
│                                 │
│       محتوى الشاشة              │
│                                 │
│       (ListView / PageView)     │
│                                 │
│                                 │
│                                 │
│    ╔═══════════════════════╗   │
│ 15 ║  [🏠] [📚] [📖] [👤]  ║ 15│
│    ╚═══════════════════════╝   │
│             15                  │
└─────────────────────────────────┘
```

---

## ✨ المميزات

✅ **تصميم عائم** - يطفو فوق المحتوى بشكل أنيق  
✅ **Gradient Background** - خلفية متدرجة جميلة  
✅ **Border Radius 30px** - حواف دائرية عصرية  
✅ **Shadow Effects** - ظلال احترافية  
✅ **15px Padding** - من جميع الجوانب  
✅ **Green Active Pill** - شكل أخضر للعنصر النشط  
✅ **Smooth Animations** - حركات سلسة  
✅ **RTL Support** - دعم كامل للعربية  
✅ **Dark Mode Ready** - جاهز للوضع الداكن  

---

## 🔧 التخصيص

### تغيير الألوان:

الألوان تأتي تلقائياً من `AppTheme`:
- Light Mode: `AppColors.primary` (#006194)
- Dark Mode: `Color(0xFF38BDF8)` (أزرق فاتح)

### تغيير المسافات:

في الكود، عدّل:
```dart
Positioned(
  left: 15,   // المسافة من اليسار
  right: 15,  // المسافة من اليمين
  bottom: 15, // المسافة من الأسفل
  child: ...
)
```

### تغيير الـ Radius:

```dart
borderRadius: BorderRadius.circular(30), // عدّل هذا الرقم
```

---

## 📝 مثال كامل جاهز للاستخدام

```dart
import 'package:flutter/material.dart';
import 'package:thaheen/features/courses/presentation/widgets/thaheen_bottom_navigation_bar.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ThaheenBottomNavigationBar(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ذهين | Thaheen'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return const MyCoursesContent();
      case 2:
        return const LibraryContent();
      case 3:
        return const ProfileContent();
      default:
        return const HomeContent();
    }
  }
}

// محتوى الشاشات
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 100, // ✅ مهم
      ),
      children: const [
        Text('محتوى الشاشة الرئيسية'),
        // ... باقي المحتوى
      ],
    );
  }
}
```

---

## ✅ جاهز للاستخدام!

الآن يمكنك استخدام `ThaheenBottomNavigationBar` في أي شاشة مع تمرير المحتوى عبر `child`!

**التصميم الجديد:**
- ✨ عائم فوق المحتوى
- 🎨 شكل أخضر دائري للعنصر النشط
- 📐 15px padding من كل الجوانب
- 🔵 Radius 30px

---

**بالتوفيق! 🚀**
