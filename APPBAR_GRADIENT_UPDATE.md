# تحديث تصميم AppBar و Gradient Background

## التغييرات المنفذة

### 1. إنشاء AppBar موحد (`ThaheenAppBar`)
تم إنشاء مكون AppBar موحد يحتوي على:
- **Leading**: صورة البروفايل (قابلة للنقر)
- **Center**: رسالة ترحيب "مرحباً، [اسم المستخدم]"
- **Trailing**: أيقونة الإعدادات (قابلة للنقر)

**الموقع**: `lib/core/widgets/thaheen_app_bar.dart`

**الميزات**:
- تصميم شفاف يتناسب مع الـ Gradient
- نص أبيض للوضوح فوق الخلفية الزرقاء
- أيقونات وظلال جذابة
- قابل لإعادة الاستخدام في جميع الصفحات

### 2. إنشاء Gradient Scaffold (`GradientScaffold`)
تم إنشاء مكون Scaffold مع خلفية Gradient:
- **اللون العلوي**: `#73ADFA` (أزرق فاتح)
- **اللون السفلي**: أبيض
- **التدرج**: من الأعلى إلى الأسفل مع توقف عند 40% من الشاشة

**الموقع**: `lib/core/widgets/gradient_scaffold.dart`

**الميزات**:
- يدعم جميع خصائص Scaffold العادي
- خلفية شفافة للـ Scaffold الداخلي
- سهل الاستخدام كبديل مباشر لـ Scaffold

### 3. تطبيق التصميم الجديد على جميع صفحات الـ Navigation

#### صفحة Courses (`courses_screen.dart`)
- استبدال `HomeTopHeader` بـ `ThaheenAppBar`
- استبدال `Scaffold` بـ `GradientScaffold`
- يتم عرض الـ AppBar فوق الـ Gradient بشكل جميل

#### صفحة Course Details (`course_details_screen.dart`)
- إضافة `ThaheenAppBar`
- إضافة `GradientScaffold`
- إزالة `CourseDetailsTopBar` القديم

#### صفحة Profile (`profile_screen.dart`)
- إضافة Container مع Gradient مباشرةً (لأنها tab وليست صفحة مستقلة)
- التدرج من `#73ADFA` إلى الأبيض

#### صفحة Lesson Player (`lesson_player_screen.dart`)
- إضافة `ThaheenAppBar` و `GradientScaffold` في الوضع العادي
- الاحتفاظ بالشاشة الكاملة السوداء بدون تغيير

### 4. تحديث التبويبات الداخلية

التبويبات التالية داخل `CoursesScreen` تحصل تلقائياً على الـ Gradient:
- **Dashboard Tab**: الصفحة الرئيسية مع البطاقات
- **My Courses Tab**: جميع الدورات
- **Library Tab**: المكتبة الرقمية
- **Profile Tab**: صفحة الملف الشخصي

## ملاحظات التصميم

### الألوان
- اللون الأساسي للـ Gradient: `#73ADFA`
- اللون النهائي: `Colors.white`
- نقطة التوقف: 40% من ارتفاع الشاشة

### النصوص في AppBar
- نص "مرحباً،": أبيض شبه شفاف (90%)
- اسم المستخدم: أبيض بالكامل وعريض
- حجم الخط: 12 للترحيب، 16 للاسم

### الأيقونات
- حجم الأيقونات: 22-24
- لون الأيقونات: أبيض
- خلفية أيقونة الإعدادات: أبيض شبه شفاف
- حد صورة البروفايل: أبيض شبه شفاف

## التوافقية

- ✅ يعمل مع Dark Mode
- ✅ يعمل مع RTL (العربية)
- ✅ يدعم جميع أحجام الشاشات
- ✅ لا يؤثر على وضع الشاشة الكاملة في المشغل

## الملفات المعدلة

1. `lib/core/widgets/thaheen_app_bar.dart` - **جديد**
2. `lib/core/widgets/gradient_scaffold.dart` - **جديد**
3. `lib/features/courses/presentation/screens/courses_screen.dart` - معدل
4. `lib/features/courses/presentation/screens/course_details_screen.dart` - معدل
5. `lib/features/profile/presentation/screens/profile_screen.dart` - معدل
6. `lib/features/player/presentation/screens/lesson_player_screen.dart` - معدل

## كيفية الاستخدام

### استخدام ThaheenAppBar
```dart
ThaheenAppBar(
  userName: 'محمد',
  onProfileTap: () => // تنقل إلى الصفحة الشخصية,
  onSettingsTap: () => // فتح الإعدادات,
  profileImageUrl: 'assets/images/profile.png', // اختياري
)
```

### استخدام GradientScaffold
```dart
GradientScaffold(
  appBar: ThaheenAppBar(...),
  body: YourContent(),
  bottomNavigationBar: YourBottomNav(),
)
```

## التحسينات المستقبلية المقترحة

1. إضافة صورة حقيقية للمستخدم من البروفايل
2. جعل اسم المستخدم ديناميكي من قاعدة البيانات
3. إضافة شارة للإشعارات على أيقونة الإعدادات
4. إضافة animation عند التنقل بين الصفحات
5. دعم تخصيص ألوان الـ Gradient من الإعدادات
