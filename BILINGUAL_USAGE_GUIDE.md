# دليل استخدام النظام المزدوج اللغة
# Bilingual System Usage Guide

## 📚 Overview / نظرة عامة

This guide demonstrates how to implement bilingual (Arabic/English) text display throughout the Thaheen app.

يشرح هذا الدليل كيفية تطبيق عرض النصوص المزدوجة (عربي/إنجليزي) في تطبيق ذهين.

---

## 🎯 Quick Start / البداية السريعة

### 1. Using Static Strings / استخدام النصوص الثابتة

For UI labels and static text, use `AppStrings.tr()`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../features/profile/presentation/cubit/settings_cubit.dart';

// في أي Widget
final langCode = context.read<SettingsCubit>().state.language.languageCode;

Text(AppStrings.tr('courses', langCode))
// Arabic: "دوراتي"
// English: "My Courses"
```

### 2. Using Dynamic Data / استخدام البيانات الديناميكية

For data from JSON (like courses), use the localized methods:

```dart
// Course entity already has these methods:
course.localizedTitle(langCode)        // Returns title or titleEn
course.localizedInstructor(langCode)   // Returns instructor or instructorEn
course.localizedDescription(langCode)  // Returns description or descriptionEn
```

### 3. Using Helper Function / استخدام الدالة المساعدة

For custom bilingual data:

```dart
final text = AppStrings.getLocalizedText(
  langCode,
  'النص بالعربي',
  'English Text',
);
```

---

## 📋 JSON Data Structure / هيكل بيانات JSON

When adding bilingual data to `courses.json` or other JSON files:

```json
{
  "id": "course-id",
  "title": "العنوان بالعربي",
  "titleEn": "English Title",
  "description": "الوصف التفصيلي بالعربية",
  "descriptionEn": "Detailed description in English",
  "instructor": "د. أحمد",
  "instructorEn": "Dr. Ahmed"
}
```

**Convention / الاتفاقية:**
- Arabic field: use the base name (e.g., `title`, `description`)
- English field: add `En` suffix (e.g., `titleEn`, `descriptionEn`)

---

## 🔧 Implementation Examples / أمثلة التطبيق

### Example 1: Simple Text Widget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.language != curr.language,
      builder: (context, state) {
        final langCode = state.language.languageCode;
        
        return Text(
          AppStrings.tr('welcome', langCode),
          style: TextStyle(fontSize: 20),
        );
      },
    );
  }
}
```

### Example 2: Course Description Display

```dart
class CourseDescriptionWidget extends StatelessWidget {
  final Course course;
  
  const CourseDescriptionWidget({required this.course});
  
  @override
  Widget build(BuildContext context) {
    final langCode = context.read<SettingsCubit>().state.language.languageCode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          course.localizedTitle(langCode),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 8),
        
        // Instructor
        Text(
          course.localizedInstructor(langCode),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Description
        Text(
          course.localizedDescription(langCode),
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
```

### Example 3: Dynamic Count Messages

```dart
final langCode = context.read<SettingsCubit>().state.language.languageCode;

Text(
  AppStrings.trArgs(
    'available_courses_count',
    langCode,
    {'count': '15'},
  ),
)
// Arabic: "15 مقررات متاحة"
// English: "15 courses available"
```

### Example 4: Conditional Text without BlocBuilder

```dart
class SimpleTextWidget extends StatelessWidget {
  final String arabicText;
  final String englishText;
  
  @override
  Widget build(BuildContext context) {
    // Read once - doesn't rebuild on language change
    final langCode = context.read<SettingsCubit>().state.language.languageCode;
    
    return Text(
      AppStrings.getLocalizedText(langCode, arabicText, englishText),
    );
  }
}
```

---

## 🎨 Best Practices / أفضل الممارسات

### 1. Use BlocBuilder for Language-Dependent Widgets

```dart
// ✅ Good - Rebuilds when language changes
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (prev, curr) => prev.language != curr.language,
  builder: (context, state) {
    return Text(AppStrings.tr('home', state.language.languageCode));
  },
)

// ❌ Bad - Doesn't rebuild on language change
final langCode = context.read<SettingsCubit>().state.language.languageCode;
Text(AppStrings.tr('home', langCode))
```

### 2. Add English Translation for All New Fields

```json
{
  "newField": "قيمة بالعربي",
  "newFieldEn": "English Value"  // ✅ Always add this
}
```

### 3. Use Entity Methods for Course Data

```dart
// ✅ Good - Uses built-in entity methods
course.localizedTitle(langCode)

// ❌ Bad - Manual field access
langCode.startsWith('en') ? course.titleEn : course.title
```

### 4. Keep Translations Consistent

Add all new UI strings to both dictionaries in `app_language.dart`:

```dart
static const Map<String, String> _ar = {
  'new_key': 'النص بالعربي',
  // ... other keys
};

static const Map<String, String> _en = {
  'new_key': 'English Text',
  // ... other keys
};
```

---

## 🌐 Language Detection Flow / آلية الكشف عن اللغة

```
User changes language in settings
         ↓
SettingsCubit updates language state
         ↓
BlocBuilder rebuilds widgets
         ↓
AppStrings.tr() returns correct text based on langCode
         ↓
UI displays in selected language
```

---

## 📝 Adding New Translations / إضافة ترجمات جديدة

### Step 1: Add to AppStrings (for UI strings)

Edit `/lib/core/localization/app_language.dart`:

```dart
static const Map<String, String> _ar = {
  // ... existing keys
  'my_new_key': 'النص الجديد بالعربي',
};

static const Map<String, String> _en = {
  // ... existing keys
  'my_new_key': 'My New English Text',
};
```

### Step 2: Add to JSON (for data)

Edit `/assets/data/courses.json`:

```json
{
  "myField": "القيمة بالعربي",
  "myFieldEn": "English Value"
}
```

### Step 3: Update Entity Model (if needed)

Add localized getter in the entity class:

```dart
class Course {
  final String myField;
  final String? myFieldEn;
  
  String localizedMyField(String langCode) {
    return langCode.startsWith('en') && myFieldEn != null
        ? myFieldEn!
        : myField;
  }
}
```

---

## 🔍 Real Example: Skeletal System Course Description

### Arabic (Default):
```
استكشاف البنية النسيجية والهيكلية لمنظومة العظام في جسم الإنسان، 
مع التركيز على التعظم الغشائي والداخل الغضروفي، وتكوين النخاع 
ووظائف الدعم الميكانيكي والحماية الحيوية.
```

### English:
```
Exploring the histological and structural anatomy of the skeletal system 
in the human body, focusing on intramembranous and endochondral ossification, 
bone marrow formation, and the functions of mechanical support and biological protection.
```

### Implementation:
```dart
// In courses.json
{
  "id": "anatomy-101",
  "title": "مقدمة في التشريح",
  "titleEn": "Introduction to Anatomy",
  "description": "استكشاف البنية النسيجية والهيكلية...",
  "descriptionEn": "Exploring the histological and structural anatomy..."
}

// In widget
Text(course.localizedDescription(langCode))
```

---

## 🚀 Testing / الاختبار

To test language switching:

1. Run the app / شغل التطبيق
2. Navigate to Profile tab / انتقل لتبويب الملف الشخصي
3. Tap "إعدادات النظام والتفضيلات" / "System Settings & Preferences"
4. Change language between "العربية" and "English"
5. Verify all text updates correctly / تحقق من تحديث جميع النصوص

---

## 📞 Support / الدعم

For questions or issues with the bilingual system:
- Check this guide first
- Review existing implementations in `course_card_item.dart`
- Consult `app_language.dart` for available methods

لأي استفسارات أو مشاكل في النظام المزدوج اللغة:
- راجع هذا الدليل أولاً
- استعرض التطبيقات الحالية في `course_card_item.dart`
- استشر `app_language.dart` للدوال المتاحة

---

## ✅ Checklist for New Features / قائمة التحقق للميزات الجديدة

When adding new features with text:

- [ ] Add Arabic text to JSON/entity
- [ ] Add English text with `En` suffix
- [ ] Use `AppStrings.tr()` for UI strings
- [ ] Use entity's `localized*()` methods for data
- [ ] Wrap in BlocBuilder if text should update on language change
- [ ] Test with both Arabic and English
- [ ] Verify RTL/LTR layout works correctly

---

**Created:** 2026-09-27  
**Version:** 1.0  
**Maintained by:** Thaheen Development Team
