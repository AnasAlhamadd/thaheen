# التحديث التلقائي للبطاقة عند العودة من الدرس

## المشكلة
عند إكمال درس والعودة للداشبورد، كان عنوان الدرس في البطاقة لا يتحدث تلقائياً ليعرض الدرس التالي.

## الحل المطبق

### 1. إضافة `onReturnFromLesson` Callback

تم إضافة callback جديد للبطاقة لإعادة تحميل البيانات عند العودة:

```dart
AcademicKickoffBanner(
  continueCourse: continueCourse,
  continueLesson: continueLesson,
  lessonProgress: continueProgress,
  onReturnFromLesson: () {
    // ✅ إعادة تحميل البيانات عند العودة
    context.read<CoursesCubit>().reloadCourses();
  },
  // ...
)
```

### 2. استخدام `await` مع `context.push()`

```dart
// في _ContinueWatchingActionRow
onPressed: () async {
  // الذهاب للدرس
  await context.push('/courses/$courseId/lessons/$lessonId');
  
  // ✅ عند العودة (await ينتهي)، يُنفّذ الـ callback
  onReturnFromLesson?.call();
},
```

## كيف يعمل النظام الآن

```
📱 السيناريو الكامل:

1️⃣ الطالب في الداشبورد
   └─> يرى: "العظام - متابعة المشاهدة (50%)"

2️⃣ يضغط "استكمال الدرس"
   └─> context.push() ← ينتظر
   └─> ينتقل لمشغل الدرس

3️⃣ يشاهد باقي الدرس ويصل لـ 90%
   └─> النظام يحفظ: completed = true ✓
   └─> يظهر: "✅ تم إكمال الدرس"

4️⃣ يضغط زر الرجوع ⬅️
   └─> await ينتهي
   └─> onReturnFromLesson() يُنفّذ
   └─> CoursesCubit.reloadCourses() يُنفّذ

5️⃣ البطاقة تُحدّث تلقائياً ✨
   └─> findNextIncompleteLesson() يبحث
   └─> يعرض: "المفاصل - ابدأ الآن" 🎯
```

## الكود المضاف

### في `academic_kickoff_banner.dart`

```dart
class AcademicKickoffBanner extends StatelessWidget {
  // ...
  final VoidCallback? onReturnFromLesson; // ✅ جديد
  
  const AcademicKickoffBanner({
    // ...
    this.onReturnFromLesson, // ✅ جديد
  });
}

class _ContinueWatchingActionRow extends StatelessWidget {
  // ...
  final VoidCallback? onReturnFromLesson; // ✅ جديد
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async { // ✅ async
        await context.push(...); // ✅ await
        onReturnFromLesson?.call(); // ✅ reload عند العودة
      },
    );
  }
}
```

### في `dashboard_screen.dart`

```dart
AcademicKickoffBanner(
  onReturnFromLesson: () {
    context.read<CoursesCubit>().reloadCourses(); // ✅ إعادة تحميل
  },
)
```

## المزايا

✅ **تحديث فوري**: البطاقة تتحدث مباشرة بعد العودة  
✅ **بدون تأخير**: لا حاجة للانتظار أو التحديث اليدوي  
✅ **تجربة سلسة**: يشعر المستخدم بنظام "ذكي" ومتجاوب  
✅ **كود نظيف**: استخدام callback pattern البسيط  

## الفرق قبل وبعد

### قبل الإصلاح ❌
```
عودة من الدرس → البطاقة تعرض نفس الدرس القديم 😕
المستخدم: "لماذا لا يتغير؟"
```

### بعد الإصلاح ✅
```
عودة من الدرس → البطاقة تتحدث تلقائياً → تعرض الدرس التالي 🎯
المستخدم: "رائع! النظام يعرف ما أحتاجه"
```

## الاختبار

### خطوات الاختبار:

1. ✅ افتح الداشبورد
2. ✅ لاحظ عنوان الدرس في البطاقة (مثلاً: "العظام")
3. ✅ اضغط "استكمال الدرس"
4. ✅ شاهد الدرس حتى 90% ليكتمل
5. ✅ اضغط زر الرجوع ⬅️
6. ✅ **تحقق:** البطاقة تعرض الآن "المفاصل" (الدرس التالي) ✨
7. ✅ **تحقق:** الشارة تغيرت من "متابعة المشاهدة" إلى "ابدأ الآن"

### النتيجة المتوقعة:
- العنوان يتغير تلقائياً ✅
- الشارة تتغير حسب الحالة ✅
- النسبة المئوية تُحدّث (أو تختفي للدرس الجديد) ✅
- شريط التقدم يُحدّث ✅

## الملفات المعدلة

1. **`academic_kickoff_banner.dart`**
   - إضافة `onReturnFromLesson` parameter
   - تمرير الـ callback للـ action row
   - استخدام `async/await` مع `context.push()`

2. **`dashboard_screen.dart`**
   - تمرير `onReturnFromLesson` callback
   - استدعاء `reloadCourses()` عند العودة

3. **`courses_screen.dart`**
   - تبسيط lifecycle management
   - إزالة `WidgetsBindingObserver` (لم تعد ضرورية)

## التكامل مع الميزات الأخرى

✅ **Progress Streaming**: يعمل مع نظام حفظ التقدم التلقائي  
✅ **Smart Navigation**: يعمل مع `push/pop` بدلاً من `go`  
✅ **90% Completion**: يتفاعل مع قاعدة الإكمال التلقائي  
✅ **Next Lesson Logic**: يستخدم `findNextIncompleteLesson()`  

---

**التاريخ:** 2026-09-27  
**الحالة:** ✅ مكتمل ومختبر  
**النتيجة:** تحديث تلقائي كامل للبطاقة 🎉
