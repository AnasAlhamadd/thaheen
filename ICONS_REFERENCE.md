# دليل الأيقونات المقترحة - Thaheen Navigation Bar

## 📱 Material Icons - جاهزة للاستخدام مباشرةً

جميع هذه الأيقونات متوفرة في Flutter بدون الحاجة لأي ملفات إضافية!

---

## 🎓 أيقونات تعليمية

### الدورات والدروس

```dart
Icons.school_rounded           // 🎓 الدورات التعليمية
Icons.library_books_rounded    // 📚 مكتبة الدروس
Icons.menu_book_rounded        // 📖 الكتب
Icons.book_rounded             // 📕 كتاب واحد
Icons.auto_stories_rounded     // 📘 القصص/المحتوى
Icons.video_library_rounded    // 🎬 مكتبة الفيديوهات
Icons.cast_for_education_rounded // 🎥 التعليم عن بُعد
```

### الاختبارات والتقييم

```dart
Icons.quiz_rounded             // ❓ الاختبارات
Icons.assignment_rounded       // 📝 الواجبات
Icons.grading_rounded          // ✅ التقييم
Icons.fact_check_rounded       // ☑️ التحقق
Icons.playlist_add_check_rounded // ✓ قائمة المهام
```

### التقدم والإحصائيات

```dart
Icons.leaderboard_rounded      // 📊 لوحة التصدر
Icons.analytics_rounded        // 📈 التحليلات
Icons.insights_rounded         // 💡 الرؤى
Icons.trending_up_rounded      // 📈 التقدم
Icons.bar_chart_rounded        // 📊 الرسوم البيانية
Icons.pie_chart_rounded        // 🥧 المخططات الدائرية
Icons.show_chart_rounded       // 📉 المخططات
```

---

## 🏥 أيقونات طبية وعلمية

### الطب والصحة

```dart
Icons.medical_services_rounded    // 🏥 الخدمات الطبية
Icons.science_rounded             // 🔬 العلوم/المختبر
Icons.biotech_rounded             // 🧬 التكنولوجيا الحيوية
Icons.local_hospital_rounded      // 🏥 المستشفى
Icons.health_and_safety_rounded   // ❤️‍🩹 الصحة والسلامة
Icons.medication_rounded          // 💊 الأدوية
Icons.vaccines_rounded            // 💉 اللقاحات
```

### المختبر والبحث

```dart
Icons.science_rounded          // 🔬 المختبر
Icons.psychology_rounded       // 🧠 علم النفس/الدماغ
Icons.microbiology_rounded     // 🦠 الأحياء الدقيقة (إن وُجد)
Icons.coronavirus_rounded      // 🦠 الفيروسات
Icons.medical_information_rounded // ℹ️ المعلومات الطبية
```

---

## 🏠 أيقونات أساسية

### التنقل الرئيسي

```dart
Icons.home_rounded             // 🏠 الرئيسية
Icons.dashboard_rounded        // 📊 لوحة التحكم
Icons.explore_rounded          // 🧭 استكشاف
Icons.search_rounded           // 🔍 البحث
Icons.menu_rounded             // ☰ القائمة
```

### الملف الشخصي

```dart
Icons.person_rounded           // 👤 الملف الشخصي
Icons.account_circle_rounded   // 👤 الحساب
Icons.badge_rounded            // 🏷️ الشارة/الهوية
Icons.contact_page_rounded     // 📇 صفحة الاتصال
```

### الإعدادات والأدوات

```dart
Icons.settings_rounded         // ⚙️ الإعدادات
Icons.tune_rounded             // 🎛️ التخصيص
Icons.build_rounded            // 🔧 الأدوات
Icons.help_rounded             // ❓ المساعدة
Icons.info_rounded             // ℹ️ المعلومات
```

---

## 💬 أيقونات تفاعلية

### التواصل والمجتمع

```dart
Icons.forum_rounded            // 💬 المنتدى
Icons.chat_rounded             // 💬 الدردشة
Icons.comment_rounded          // 💭 التعليقات
Icons.question_answer_rounded  // 💬 الأسئلة والأجوبة
Icons.groups_rounded           // 👥 المجموعات
Icons.people_rounded           // 👥 الأشخاص
```

### الإشعارات والتنبيهات

```dart
Icons.notifications_rounded    // 🔔 الإشعارات
Icons.notification_important_rounded // 🔔 إشعار مهم
Icons.alarm_rounded            // ⏰ المنبه
Icons.campaign_rounded         // 📢 الإعلانات
```

---

## 📋 أيقونات المحتوى

### الملفات والمستندات

```dart
Icons.description_rounded      // 📄 المستندات
Icons.note_rounded             // 📝 الملاحظات
Icons.sticky_note_2_rounded    // 📌 ملاحظة لاصقة
Icons.folder_rounded           // 📁 المجلد
Icons.insert_drive_file_rounded // 📄 الملف
```

### الوسائط

```dart
Icons.play_circle_rounded      // ▶️ تشغيل
Icons.video_collection_rounded // 🎬 مجموعة الفيديوهات
Icons.image_rounded            // 🖼️ الصورة
Icons.photo_library_rounded    // 🖼️ مكتبة الصور
Icons.audiotrack_rounded       // 🎵 الصوت
```

---

## ✨ تركيبات مقترحة حسب محتوى التطبيق

### التركيبة 1: تعليمية كلاسيكية (موصى بها)

```dart
navItems: const [
  NavItem(
    icon: Icons.home_rounded,           // الرئيسية
    route: '/',
    label: 'الرئيسية',
  ),
  NavItem(
    icon: Icons.school_rounded,         // الدورات
    route: '/courses',
    label: 'الدورات',
  ),
  NavItem(
    icon: Icons.quiz_rounded,           // الاختبارات
    route: '/tests',
    label: 'الاختبارات',
  ),
  NavItem(
    icon: Icons.leaderboard_rounded,    // التقدم
    route: '/progress',
    label: 'تقدمي',
  ),
  NavItem(
    icon: Icons.person_rounded,         // الملف
    route: '/profile',
    label: 'الملف',
  ),
],
```

### التركيبة 2: طبية متخصصة

```dart
navItems: const [
  NavItem(
    icon: Icons.dashboard_rounded,        // لوحة التحكم
    route: '/',
    label: 'لوحتي',
  ),
  NavItem(
    icon: Icons.medical_services_rounded, // المحتوى الطبي
    route: '/medical',
    label: 'الطب',
  ),
  NavItem(
    icon: Icons.science_rounded,          // المختبر
    route: '/lab',
    label: 'المختبر',
  ),
  NavItem(
    icon: Icons.assignment_rounded,       // الواجبات
    route: '/assignments',
    label: 'الواجبات',
  ),
  NavItem(
    icon: Icons.analytics_rounded,        // الإحصائيات
    route: '/analytics',
    label: 'إحصائياتي',
  ),
],
```

### التركيبة 3: مكتبة فيديوهات

```dart
navItems: const [
  NavItem(
    icon: Icons.explore_rounded,          // استكشاف
    route: '/',
    label: 'استكشف',
  ),
  NavItem(
    icon: Icons.video_library_rounded,    // المكتبة
    route: '/library',
    label: 'المكتبة',
  ),
  NavItem(
    icon: Icons.bookmark_rounded,         // المحفوظات
    route: '/saved',
    label: 'محفوظاتي',
  ),
  NavItem(
    icon: Icons.history_rounded,          // السجل
    route: '/history',
    label: 'السجل',
  ),
  NavItem(
    icon: Icons.account_circle_rounded,   // الحساب
    route: '/account',
    label: 'حسابي',
  ),
],
```

### التركيبة 4: تركيز على الممارسة

```dart
navItems: const [
  NavItem(
    icon: Icons.home_rounded,             // الرئيسية
    route: '/',
    label: 'الرئيسية',
  ),
  NavItem(
    icon: Icons.library_books_rounded,    // المواد
    route: '/materials',
    label: 'المواد',
  ),
  NavItem(
    icon: Icons.fact_check_rounded,       // التمارين
    route: '/practice',
    label: 'التمارين',
  ),
  NavItem(
    icon: Icons.insights_rounded,         // الأداء
    route: '/performance',
    label: 'أدائي',
  ),
  NavItem(
    icon: Icons.settings_rounded,         // الإعدادات
    route: '/settings',
    label: 'الإعدادات',
  ),
],
```

---

## 🎨 نصائح لاختيار الأيقونات

### ✅ افعل:

1. **استخدم نفس النمط**: استخدم `_rounded` للجميع للحصول على مظهر متسق
2. **الوضوح أولاً**: اختر أيقونات واضحة ومعروفة
3. **التمايز**: تأكد أن كل أيقونة مختلفة بصرياً عن الأخرى
4. **المعنى**: الأيقونة يجب أن تعبر عن وظيفتها بوضوح

### ❌ تجنب:

1. **خلط الأنماط**: لا تخلط `_rounded` مع `_outlined` أو `_sharp`
2. **الأيقونات المشابهة**: تجنب أيقونات تبدو متشابهة جداً
3. **الكثرة**: 5 عناصر كحد أقصى للـ navigation bar
4. **الغموض**: تجنب الأيقونات غير الواضحة

---

## 📝 كيفية الاستخدام

ببساطة استبدل في ملف `main_navigation_screen.dart`:

```dart
navItems: const [
  NavItem(
    icon: Icons.YOUR_CHOSEN_ICON,  // 👈 ضع الأيقونة هنا
    route: '/your-route',
    label: 'التسمية',
  ),
  // ... باقي العناصر
],
```

---

## 🔍 استكشاف المزيد

لاستكشاف جميع أيقونات Material:
- قم بزيارة: [Material Icons](https://fonts.google.com/icons)
- أو داخل VS Code: اكتب `Icons.` وستظهر لك قائمة بجميع الأيقونات المتاحة

---

**جميع الأيقونات جاهزة ومضمنة في Flutter - لا حاجة لملفات SVG! ✨**
