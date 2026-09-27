# 🌐 Bilingual System - Quick Start
# النظام المزدوج اللغة - البداية السريعة

> **النظام مكتمل وجاهز للاستخدام! ✅**  
> System is complete and ready to use! ✅

---

## 🎯 What Was Done / ما تم إنجازه

تم تطبيق نظام اللغة المزدوج (عربي/إنجليزي) بالكامل في تطبيق ذهين. الآن التطبيق يعرض النصوص بناءً على اللغة المختارة من قبل المستخدم.

A complete bilingual system (Arabic/English) has been implemented in the Thaheen app. The app now displays text based on the user's selected language.

---

## 📁 Key Files / الملفات الرئيسية

| File | Purpose |
|------|---------|
| `lib/domain/entities/course.dart` | Course entity with localization methods |
| `lib/features/courses/data/models/course_model.dart` | Course model with bilingual parsing |
| `lib/core/localization/app_language.dart` | Language management and helper functions |
| `assets/data/courses.json` | Course data with bilingual content |

---

## 🚀 Quick Usage / الاستخدام السريع

### Display Course Description / عرض وصف المقرر

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

final langCode = context.read<SettingsCubit>().state.language.languageCode;

Text(course.localizedDescription(langCode))
```

**Result / النتيجة:**
- Arabic language → Shows Arabic description
- English language → Shows English description

---

## 📖 Available Methods / الدوال المتاحة

### For Course Entity

```dart
course.localizedTitle(langCode)        // العنوان / Title
course.localizedInstructor(langCode)   // المدرس / Instructor  
course.localizedDescription(langCode)  // الوصف / Description
```

### For Static Strings

```dart
AppStrings.tr('courses', langCode)                          // Simple string
AppStrings.trArgs('lessons_count', langCode, {'count': 5})  // With variables
AppStrings.getLocalizedText(langCode, arabic, english)      // Custom text
```

---

## 📚 Documentation / التوثيق

| Document | Description |
|----------|-------------|
| **[BILINGUAL_USAGE_GUIDE.md](BILINGUAL_USAGE_GUIDE.md)** | 📘 Comprehensive guide with examples (Arabic + English) |
| **[BILINGUAL_SUMMARY_AR.md](BILINGUAL_SUMMARY_AR.md)** | 📝 Quick summary in Arabic |
| **[BILINGUAL_CHECKLIST.md](BILINGUAL_CHECKLIST.md)** | ✅ Implementation checklist |

---

## 🎨 Example / مثال

### JSON Data

```json
{
  "title": "مقدمة في التشريح",
  "titleEn": "Introduction to Anatomy",
  "description": "استكشاف البنية النسيجية والهيكلية...",
  "descriptionEn": "Exploring the histological and structural anatomy..."
}
```

### Widget Code

```dart
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (prev, curr) => prev.language != curr.language,
  builder: (context, state) {
    final langCode = state.language.languageCode;
    
    return Column(
      children: [
        Text(course.localizedTitle(langCode)),
        Text(course.localizedDescription(langCode)),
      ],
    );
  },
)
```

---

## ✅ Status / الحالة

| Check | Status |
|-------|--------|
| Entity updated | ✅ Complete |
| Model updated | ✅ Complete |
| JSON data added | ✅ Complete |
| Helper functions | ✅ Complete |
| Documentation | ✅ Complete |
| Testing | ✅ Passed |
| Ready for use | ✅ Yes |

---

## 🧪 Test It / جربه

1. **Run the app** / شغل التطبيق
   ```bash
   flutter run
   ```

2. **Go to Profile** / انتقل للملف الشخصي
   - Tap on "الملف الشخصي" / "Profile" tab

3. **Open Settings** / افتح الإعدادات
   - Tap "إعدادات النظام والتفضيلات" / "System Settings"

4. **Switch Language** / غيّر اللغة
   - Select "العربية" or "English"

5. **See the Magic!** / شاهد السحر!
   - All text updates automatically / تتحدث جميع النصوص تلقائياً

---

## 💡 Pro Tips / نصائح احترافية

### ✅ DO / افعل

```dart
// Use entity methods
course.localizedTitle(langCode)

// Use BlocBuilder for auto-rebuild
BlocBuilder<SettingsCubit, SettingsState>(...)

// Add English field with "En" suffix
"titleEn": "English Title"
```

### ❌ DON'T / لا تفعل

```dart
// Don't access fields directly
langCode.startsWith('en') ? course.titleEn : course.title

// Don't use context.read without BlocBuilder (if you need rebuild)
final lang = context.read<SettingsCubit>().state.language;
Text(course.localizedTitle(lang.languageCode)) // Won't rebuild!

// Don't forget English translation
"title": "عنوان" // Missing titleEn!
```

---

## 🎓 Real-World Example / مثال من الواقع

### Skeletal System Course / مقرر الجهاز الهيكلي

**Arabic Description:**
```
استكشاف البنية النسيجية والهيكلية لمنظومة العظام في جسم الإنسان، 
مع التركيز على التعظم الغشائي والداخل الغضروفي، وتكوين النخاع 
ووظائف الدعم الميكانيكي والحماية الحيوية.
```

**English Description:**
```
Exploring the histological and structural anatomy of the skeletal system 
in the human body, focusing on intramembranous and endochondral ossification, 
bone marrow formation, and the functions of mechanical support and 
biological protection.
```

**Implementation:**
```dart
Text(course.localizedDescription(langCode))
```

**Result:** Displays the correct language version automatically! ✨

---

## 🔗 Related Files / ملفات ذات صلة

See working implementation in:
- `lib/features/courses/presentation/widgets/course_card_item.dart`
- `lib/features/courses/presentation/screens/courses_screen.dart`

---

## 📞 Need Help? / تحتاج مساعدة؟

1. Check the **[Usage Guide](BILINGUAL_USAGE_GUIDE.md)** first
2. Review the **[Summary (Arabic)](BILINGUAL_SUMMARY_AR.md)**
3. Look at the **[Checklist](BILINGUAL_CHECKLIST.md)**
4. See existing implementation in course widgets

---

## 🎉 Summary / الخلاصة

The bilingual system is fully implemented and ready to use. All course data now supports Arabic and English, with automatic switching based on user preference.

النظام المزدوج اللغة مطبق بالكامل وجاهز للاستخدام. جميع بيانات المقررات تدعم الآن العربية والإنجليزية، مع التبديل التلقائي بناءً على تفضيل المستخدم.

**Status:** ✅ Ready for Production  
**Date:** September 27, 2026  
**Version:** 1.0

---

**Made with ❤️ for Thaheen Medical Platform**
