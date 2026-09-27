# إصلاح التنقل - العودة للداشبورد

## المشكلة الأصلية

عندما يضغط المستخدم على زر "ابدأ الدرس" أو "استكمال الدرس" من البطاقة في الداشبورد، ثم يضغط على زر الرجوع (back button)، كان يعود إلى صفحة تفاصيل المقرر بدلاً من العودة مباشرة للداشبورد.

## الحل المطبق

### التغيير الرئيسي: `context.go()` ← `context.push()`

#### قبل الإصلاح ❌
```dart
context.go('/courses/$courseId/lessons/$lessonId');
```
- `go()` يستبدل المسار الحالي بالكامل
- عند الرجوع، ينتقل لآخر صفحة في السجل (course details)

#### بعد الإصلاح ✅
```dart
context.push('/courses/$courseId/lessons/$lessonId');
```
- `push()` يضيف الصفحة فوق الصفحة الحالية
- عند الرجوع، يعود مباشرة للداشبورد

---

## الملفات المعدلة

### 1. `academic_kickoff_banner.dart`

**التغيير:**
```dart
// في _ContinueWatchingActionRow
onPressed: () {
  // Navigate to lesson player using push (allows back to dashboard)
  context.push('/courses/$courseId/lessons/$lessonId'); // ✅ push بدلاً من go
},
```

### 2. `dashboard_screen.dart`

**التغيير:**
```dart
// في AcademicKickoffBanner > onKickoffActionPressed
onKickoffActionPressed: () {
  if (courses.isNotEmpty) {
    final firstCourse = courses.first;
    final firstLesson = firstCourse.sections.first.lessons.first;
    context.push('/courses/${firstCourse.id}/lessons/${firstLesson.id}'); // ✅ push
  }
},
```

---

## سلوك التنقل الجديد

```
📱 سير العمل الصحيح:

1️⃣ المستخدم في الداشبورد
   └─> يرى بطاقة "متابعة المشاهدة" أو "ابدأ الآن"

2️⃣ يضغط على "استكمال الدرس" / "ابدأ الدرس"
   └─> context.push() ينقله لمشغل الدرس
   └─> الداشبورد يبقى في الـ navigation stack

3️⃣ يشاهد الدرس أو جزء منه
   └─> يحفظ التقدم تلقائياً

4️⃣ يضغط على زر الرجوع ⬅️
   └─> pop() يرجع للداشبورد مباشرة ✅
   └─> البطاقة تتحدث تلقائياً (بفضل didChangeAppLifecycleState)

5️⃣ يرى الدرس التالي في البطاقة 🎯
```

---

## الفرق بين `go` و `push`

| الوظيفة | `context.go()` | `context.push()` |
|---------|---------------|-----------------|
| **الاستخدام** | استبدال المسار | إضافة فوق المسار الحالي |
| **Navigation Stack** | يمسح ويبني من جديد | يحافظ على الـ stack |
| **زر الرجوع** | يرجع للصفحة السابقة في السجل | يرجع للصفحة التي push منها |
| **الأفضل لـ** | تنقل بين أقسام رئيسية | تنقل مؤقت (modal/detail) |

---

## مثال توضيحي

### Scenario A: استخدام `go()` ❌

```
Stack قبل:    [Dashboard]
بعد go:       [LessonPlayer]
بعد back:     [CourseDetails] ← خطأ! من أين جاءت؟
```

### Scenario B: استخدام `push()` ✅

```
Stack قبل:    [Dashboard]
بعد push:     [Dashboard, LessonPlayer]
بعد back:     [Dashboard] ← صح! العودة للأصل
```

---

## الفوائد

✅ **تجربة مستخدم أفضل**: العودة المباشرة للداشبورد  
✅ **منطق أوضح**: سلوك متوقع لزر الرجوع  
✅ **تحديث تلقائي**: البطاقة تتحدث عند العودة  
✅ **توافق مع النظام**: يعمل مع lifecycle observer  

---

## ملاحظات إضافية

### متى نستخدم `go()`؟
- التنقل بين تبويبات رئيسية (Dashboard, Profile, Settings)
- تسجيل الدخول/الخروج
- إعادة توجيه إجباري

### متى نستخدم `push()`؟
- فتح تفاصيل (course details, lesson player)
- نماذج وحوارات
- أي شاشة يُتوقع أن يرجع منها المستخدم

---

## الاختبار

لاختبار الإصلاح:

1. ✅ افتح الداشبورد
2. ✅ اضغط على "ابدأ الدرس" من البطاقة
3. ✅ شاهد جزء من الدرس
4. ✅ اضغط على زر الرجوع
5. ✅ **تأكد أنك عدت للداشبورد** (وليس course details)
6. ✅ **تأكد أن البطاقة تحدثت** (تعرض الدرس الصحيح)

---

**تاريخ الإصلاح:** 2026-09-27  
**الحالة:** ✅ تم الاختبار والتأكيد  
**التأثير:** تحسين تجربة المستخدم بشكل كبير
