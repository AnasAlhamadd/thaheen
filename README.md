# Thaheen – Flutter Screening Task

## Mini Offline LMS with Video Player

> **Reference implementation guide / Agent specification**
>
> هذا الملف هو المرجع التنفيذي للمشروع. الهدف منه تحويل نص الـ screening task إلى خطوات واضحة وقابلة للتنفيذ والمراجعة، مع الحفاظ على نطاق المهمة ضمن **4–6 ساعات**.

---

## 1. هدف المشروع

بناء تطبيق Flutter صغير **Offline بالكامل** لمنصة تعلم عربية للطلاب في العلوم الصحية.

المستخدم يستطيع:

1. مشاهدة قائمة الدورات.
2. رؤية نسبة التقدم.
3. متابعة آخر درس غير مكتمل من بطاقة **متابعة المشاهدة**.
4. فتح تفاصيل الدورة ورؤية الأقسام والدروس.
5. الوصول إلى الدروس بالتسلسل فقط.
6. تشغيل الفيديو والتحكم به.
7. استئناف الفيديو من آخر موضع محفوظ.
8. اعتبار الدرس مكتملًا تلقائيًا عند الوصول إلى 90% من مدة الفيديو.
9. الانتقال إلى الدرس التالي بعد فتحه وفق قاعدة التسلسل.
10. إغلاق التطبيق وإعادة فتحه مع بقاء التقدم محفوظًا.

**لا يوجد Backend ولا API ولا Authentication ولا Network dependency.** كل البيانات والمقاطع تأتي من assets محلية داخل المشروع.

---

## 2. قواعد غير قابلة للتفاوض

هذه القواعد تعتبر جزءًا من الـ acceptance criteria:

1. Flutter stable + null safety.
2. التطبيق يعمل Offline.
3. يوجد **دورتان** على الأقل.
4. كل دورة تحتوي **قسمين**.
5. كل قسم يحتوي **2–3 دروس**.
6. يوجد **2–3 ملفات MP4** قصيرة داخل `assets/videos/`، وكل ملف أقل من 10 MB.
7. واجهة التطبيق عربية مع RTL صحيح.
8. يجب حفظ progress بعد إغلاق التطبيق وإعادة تشغيله.
9. الدرس الثاني لا يفتح قبل اكتمال الأول.
10. الدرس يعتبر مكتملًا عند `position >= duration * 0.90`.
11. يجب توفر Play/Pause/Seek/Current Time/Duration/Playback Speed.
12. السرعات المطلوبة: `1x`, `1.25x`, `1.5x`, `2x`.
13. يجب دعم fullscreen والـ landscape.
14. حالات loading / empty / error يجب أن تكون صريحة ولا تؤدي إلى Red Screen.
15. توجد **3 Unit Tests على الأقل** لمنطق progress/unlock.
16. الكود يجب أن يفصل Data عن Domain/Logic عن UI بدون over-engineering.
17. يجب توفير README وشرح trade-offs والوقت المستخدم.

---

## 3. تعريف النجاح

يعتبر المشروع مكتملًا عندما يمر السيناريو التالي بدون كسر:

```text
تشغيل التطبيق
  ↓
عرض دورتين
  ↓
فتح دورة
  ↓
الدرس الأول مفتوح
  ↓
الدرس الثاني مقفل
  ↓
تشغيل الدرس الأول
  ↓
المشاهدة حتى 30%
  ↓
إغلاق/إيقاف التطبيق
  ↓
إعادة التشغيل
  ↓
فتح نفس الدرس
  ↓
استئناف قريب من 30%
  ↓
الوصول إلى 90%
  ↓
الدرس يصبح Completed
  ↓
الدرس التالي يصبح Unlocked
  ↓
نسبة تقدم الدورة تتحدث
  ↓
الانتقال إلى الشاشة الرئيسية
  ↓
Continue Watching يشير إلى أول درس غير مكتمل
```

انظر [SCENARIO.md](docs/SCENARIO.md) للسيناريو الكامل وحالات الـ QA.

---

## 4. القرار المعماري المرجعي

المشروع يفضّل **Feature-oriented + layered separation** بشكل خفيف.

### 4.1 طبقات المشروع

```text
Presentation
    ↓
Domain
    ↑
Data
```

- **Presentation:** الشاشات، الـ widgets، controllers/providers، حالات loading/error/empty.
- **Domain:** الـ entities وقواعد progress/unlock/completion.
- **Data:** قراءة JSON، persistence المحلي، repositories implementations.

لا نحتاج Clean Architecture ضخمة أو عشرات الـ use cases.

### 4.2 State Management

الاختيار المرجعي: **Riverpod**.

السبب:

- بسيط ومناسب لحجم المهمة.
- واضح في dependency injection.
- مناسب للحالات asynchronous.
- يسهل فصل repositories عن UI.
- يقلل boilerplate مقارنة بمشروع Bloc كبير لهذه المهمة.

> يمكن استخدام Cubit/Bloc أو Provider بدلًا من Riverpod، بشرط الالتزام باختيار واحد بشكل ثابت. لا تغير الـ stack في منتصف التنفيذ.

### 4.3 Navigation

الاختيار المرجعي: **go_router**.

المسارات المقترحة:

```text
/courses
/courses/:courseId
/courses/:courseId/lessons/:lessonId
```

لا تمرر كائنات كبيرة بين الشاشات إذا كان يمكن تمرير IDs وإعادة القراءة من repository.

### 4.4 Local Persistence

الاختيار المرجعي: **SharedPreferences**.

السبب: حجم البيانات صغير جدًا ومحدود أساسًا إلى:

- lesson ID
- playback position
- completion state
- last watched lesson
- ويمكن لاحقًا حفظ playback speed

إذا نما المشروع لاحقًا ليصبح LMS حقيقيًا ببيانات أكبر أو notes أو queries معقدة، يمكن الانتقال إلى Isar/Hive/SQLite.

---

## 5. هيكل المجلدات المرجعي

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       └── app_theme.dart
│
├── core/
│   ├── constants/
│   ├── error/
│   └── utils/
│
├── data/
│   ├── datasources/
│   │   ├── local_course_data_source.dart
│   │   └── progress_local_data_source.dart
│   │
│   ├── models/
│   │   ├── course_model.dart
│   │   ├── section_model.dart
│   │   └── lesson_model.dart
│   │
│   └── repositories/
│       ├── course_repository_impl.dart
│       └── progress_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── course.dart
│   │   ├── section.dart
│   │   ├── lesson.dart
│   │   └── lesson_progress.dart
│   │
│   ├── repositories/
│   │   ├── course_repository.dart
│   │   └── progress_repository.dart
│   │
│   └── services/
│       └── progress_service.dart
│
└── presentation/
    ├── courses/
    │   ├── courses_screen.dart
    │   └── courses_controller.dart
    │
    ├── course_details/
    │   ├── course_details_screen.dart
    │   └── course_details_controller.dart
    │
    └── lesson_player/
        ├── lesson_player_screen.dart
        └── lesson_player_controller.dart
```

> يمكن تعديل أسماء الملفات، لكن يجب الحفاظ على نفس الفصل المنطقي.

---

## 6. Assets المطلوبة

```text
assets/
├── data/
│   └── courses.json
├── images/
│   ├── anatomy.png
│   └── physiology.png
└── videos/
    ├── lesson1.mp4
    ├── lesson2.mp4
    └── lesson3.mp4
```

في `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/data/courses.json
    - assets/images/
    - assets/videos/
```

يجب أن تكون المسارات داخل JSON مطابقة لمسارات assets حرفيًا.

مثال صحيح:

```json
"video": "assets/videos/lesson1.mp4"
```

---

## 7. Data Contract للـ JSON

الشكل المقترح:

```json
{
  "courses": [
    {
      "id": "anatomy-101",
      "title": "مقدمة في التشريح",
      "instructor": "د. سارة",
      "thumbnail": "assets/images/anatomy.png",
      "sections": [
        {
          "id": "anatomy-s1",
          "title": "الجهاز الهيكلي",
          "lessons": [
            {
              "id": "anatomy-l1",
              "title": "العظام",
              "durationSec": 95,
              "video": "assets/videos/lesson1.mp4"
            },
            {
              "id": "anatomy-l2",
              "title": "المفاصل",
              "durationSec": 100,
              "video": "assets/videos/lesson2.mp4"
            }
          ]
        },
        {
          "id": "anatomy-s2",
          "title": "الجهاز العضلي",
          "lessons": [
            {
              "id": "anatomy-l3",
              "title": "العضلات الرئيسية",
              "durationSec": 90,
              "video": "assets/videos/lesson3.mp4"
            }
          ]
        }
      ]
    }
  ]
}
```

### ملاحظات مهمة

1. `durationSec` هو metadata للعرض، وليس المصدر النهائي لحساب 90%.
2. مدة الفيديو الفعلية من `VideoPlayerController.value.duration` هي المصدر الأفضل أثناء التشغيل.
3. الـ progress لا يوضع داخل JSON لأنه بيانات ثابتة للمحتوى، بينما progress بيانات مستخدم.

---

## 8. Domain Models

### Course

```dart
class Course {
  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<Section> sections;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });
}
```

### Section

```dart
class Section {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const Section({
    required this.id,
    required this.title,
    required this.lessons,
  });
}
```

### Lesson

```dart
class Lesson {
  final String id;
  final String title;
  final int durationSec;
  final String video;

  const Lesson({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });
}
```

### LessonProgress

```dart
class LessonProgress {
  final String lessonId;
  final Duration position;
  final bool completed;

  const LessonProgress({
    required this.lessonId,
    required this.position,
    required this.completed,
  });
}
```

يفضل جعل الـ domain objects immutable.

---

## 9. قواعد الـ Progress والـ Unlock

هذه أهم قواعد التطبيق، ويجب أن تكون في **Domain Service واحد** وليس موزعة على الـ Widgets.

### 9.1 Completion Rule

```text
completed = position >= duration * 0.90
```

مثال:

```text
duration = 100 sec
89 sec → not completed
90 sec → completed
95 sec → completed
```

إذا كانت duration صفر أو غير صالحة:

```text
completed = false
```

### 9.2 Unlock Rule

اعتبر جميع دروس الدورة كسلسلة واحدة بعد flattening للـ sections:

```text
L1 → L2 → L3 → L4 → L5 ...
```

القواعد:

- الدرس الأول دائمًا unlocked.
- كل درس لاحق لا يفتح إلا إذا كان الدرس السابق `completed == true`.
- اكتمال درس في Section لا يفتح فقط الدرس داخل نفس Section؛ بل يفتح العنصر التالي في التسلسل العام.

### 9.3 Progress Percentage

تعريف الـ course progress المرجعي:

```text
completed lessons / total lessons
```

مثال:

```text
8 lessons
3 completed
→ 37.5%
```

إذا كان عدد الدروس `0`:

```text
progress = 0
```

### 9.4 Continue Watching

الدرس يعتبر unfinished إذا:

```text
position > 0
AND completed == false
```

يفضل حفظ `lastWatchedLessonId` لتحديد الدرس المقصود بشكل deterministic.

---

## 10. Progress Service – API مقترح

يفضل أن تكون القواعد قريبة من الشكل التالي:

```dart
class ProgressService {
  bool isCompleted({
    required Duration position,
    required Duration duration,
  }) {
    if (duration <= Duration.zero) return false;
    return position >= duration * 0.9;
  }

  bool isUnlocked({
    required List<Lesson> lessons,
    required int index,
    required Set<String> completedLessonIds,
  }) {
    if (index == 0) return true;
    return completedLessonIds.contains(lessons[index - 1].id);
  }

  double calculateCourseProgress({
    required List<Lesson> lessons,
    required Set<String> completedLessonIds,
  }) {
    if (lessons.isEmpty) return 0;
    final completed = lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
    return completed / lessons.length;
  }
}
```

> الكود أعلاه مرجع تصميم، وليس إلزامًا حرفيًا. الأهم أن semantics والقواعد تبقى نفسها.

---

## 11. خطوات التنفيذ المرقمة

### Step 1 — إنشاء المشروع

1. أنشئ Flutter project جديد.
2. فعّل null safety.
3. استخدم Flutter stable.
4. أضف dependencies المطلوبة.
5. أنشئ assets directories.

Dependencies المرجعية:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.0.0
  go_router: ^14.0.0
  shared_preferences: ^2.0.0
  video_player: ^2.0.0
```

> الإصدارات الدقيقة يجب أن تتوافق مع Flutter SDK المثبت؛ لا تعتبر الأرقام أعلاه قيدًا إذا ظهرت نسخة مستقرة أحدث متوافقة.

---

### Step 2 — تجهيز المحتوى

1. أنشئ `assets/data/courses.json`.
2. أضف دورتين.
3. لكل دورة قسمان.
4. لكل قسم 2–3 دروس.
5. أضف 2–3 MP4 قصيرة أقل من 10 MB.
6. أضف thumbnails محلية.
7. تأكد من أن كل video path يعمل كـ Flutter asset.

---

### Step 3 — بناء Data Layer

أنشئ:

- `LocalCourseDataSource`
- `CourseModel`
- `CourseRepositoryImpl`

المسؤولية:

```text
Asset JSON
    ↓
parse JSON
    ↓
models/domain entities
```

لا تجعل الـ UI يقرأ `rootBundle` مباشرة.

---

### Step 4 — بناء Progress Persistence

أنشئ abstraction:

```dart
abstract class ProgressRepository {
  Future<LessonProgress?> getLessonProgress(String lessonId);
  Future<Map<String, LessonProgress>> getAllProgress();
  Future<void> savePosition(String lessonId, Duration position);
  Future<void> markCompleted(String lessonId);
  Future<String?> getLastWatchedLessonId();
  Future<void> setLastWatchedLessonId(String lessonId);
}
```

التنفيذ يستخدم SharedPreferences.

صيغة التخزين يمكن أن تكون JSON serialized map، مثال:

```json
{
  "l1": {
    "position": 45,
    "completed": false
  },
  "l2": {
    "position": 100,
    "completed": true
  }
}
```

---

### Step 5 — بناء Progress Domain Service

نفّذ واختبر:

1. `isCompleted`
2. `isUnlocked`
3. `calculateCourseProgress`
4. `getContinueWatchingLesson`

لا تكرر هذه القواعد في الـ screens.

---

### Step 6 — كتابة Unit Tests قبل إنهاء الـ UI

الحد الأدنى:

#### Test A — 90% completion

```text
89%  → false
90%  → true
95%  → true
```

#### Test B — sequential unlock

```text
first lesson → unlocked
previous incomplete → next locked
previous completed → next unlocked
```

#### Test C — course progress

```text
0/10  → 0%
5/10  → 50%
10/10 → 100%
0 lessons → 0%
```

يفضل إضافة edge tests إضافية لأن هذا هو أهم domain في المشروع.

---

### Step 7 — بناء Courses Screen

يجب أن تحتوي الشاشة على:

1. App bar مناسب للـ RTL.
2. Continue Watching في الأعلى إذا وجد unfinished lesson.
3. قائمة الدورات.
4. Thumbnail.
5. Title.
6. Instructor.
7. Lesson count.
8. Progress percentage.
9. Loading state.
10. Empty state.
11. Error state.

الـ course card لا يعرف كيفية حساب progress؛ يحصل على النتيجة من controller/domain layer.

---

### Step 8 — بناء Course Details Screen

اعرض:

1. عنوان الدورة.
2. المدرب.
3. progress.
4. كل Section.
5. كل Lesson.
6. duration.
7. status.
8. lock state.

الحالات المقترحة للدرس:

```text
Unlocked + Not Started
Unlocked + In Progress
Unlocked + Completed
Locked
```

عند الضغط على locked lesson:

```text
أكمل الدرس السابق أولاً لفتح هذا الدرس.
```

لا تفتح player للدرس المقفل.

---

### Step 9 — بناء Lesson Player

استخدم `video_player`.

الـ controller مسؤول عن:

1. Initialize.
2. Play/Pause.
3. Seek.
4. Current position.
5. Duration.
6. Playback speed.
7. Resume position.
8. Completion detection.
9. Persisted position.
10. Error handling.
11. Dispose.

لا تجعل `VideoPlayerController` global.

---

### Step 10 — Resume من آخر موضع

التسلسل الصحيح:

```text
Open lesson
  ↓
Load persisted progress
  ↓
Initialize VideoPlayer
  ↓
Read actual duration
  ↓
Clamp saved position if needed
  ↓
Seek to saved position
  ↓
Render player
```

لا تعمل `seekTo` قبل `initialize()`.

إذا كان saved position أكبر من actual duration:

```text
safePosition = duration
```

أو clamp ضمن `[Duration.zero, duration]`.

---

### Step 11 — حفظ الـ Position

لا تكتب SharedPreferences في كل frame.

المرجع المقترح:

- حفظ دوري كل عدة ثوانٍ.
- حفظ عند pause.
- حفظ عند seek.
- حفظ عند completion.
- حفظ عند مغادرة screen/dispose كطبقة حماية إضافية.

الهدف هو balance بين durability وعدم كثرة عمليات storage.

---

### Step 12 — Completion عند 90%

عند أي update للـ playback:

```text
if position >= actualDuration * 0.90
    mark completed
    save final position
    unlock next lesson
```

بعد completion، لا ينبغي إعادة الدرس إلى in-progress بسبب updates لاحقة.

---

### Step 13 — Playback Speed

القيم المسموحة فقط:

```text
1.0
1.25
1.5
2.0
```

استخدم:

```dart
await controller.setPlaybackSpeed(speed);
```

يمكن جعل السرعة current UI state محليًا داخل player controller.

Bonus: حفظ آخر سرعة محليًا، لكن هذا ليس ضمن الأولوية الأساسية.

---

### Step 14 — Next Lesson

بعد اكتمال الدرس الحالي:

1. flatten lessons في الدورة.
2. اعثر على index الحالي.
3. إذا يوجد next lesson:
   - يجب أن يكون unlocked.
   - انتقل إليه.
4. إذا كان آخر درس:
   - لا تعرض action مكسورًا.
   - اعرض completion state مناسبة أو زر رجوع للدورة.

إذا كانت قاعدة unlock تمنع الانتقال، يجب ألا يتم فتح الدرس التالي.

---

### Step 15 — Fullscreen / Landscape

عند fullscreen:

1. فعّل landscape المناسب.
2. أخفِ UI غير الضروري.
3. اجعل video يملأ المساحة بشكل مناسب.

عند الخروج:

1. عد إلى portrait.
2. أعد الـ system UI عند الحاجة.
3. لا تجعل الـ entire app landscape.

يجب اختبار الدخول والخروج من fullscreen فعليًا على target device/emulator.

---

### Step 16 — RTL وArabic-first

يجب أن تكون:

```text
Direction = RTL
Locale = ar
```

مع دعم Flutter localization.

تحقق من:

1. النصوص.
2. alignment.
3. padding.
4. back/forward icons.
5. section ordering.
6. lesson rows.
7. progress indicators.
8. seek bar semantics.
9. dialogs/snackbars.

لا تقلب كل icons آليًا؛ فقط الاتجاهية منها.

---

### Step 17 — Loading / Empty / Error States

#### Loading

استخدم loading indicator واضح.

#### Empty course

مثال:

```text
لا توجد دروس في هذه الدورة حالياً.
```

ولا تسمح لـ `first`, `last`, `index` غير الصالح بكسر التطبيق.

#### JSON/Data error

اعرض رسالة للمستخدم، مع retry إذا كان مناسبًا.

#### Video error

مثال:

```text
تعذر تشغيل الفيديو.
يرجى المحاولة مرة أخرى.
```

مع retry.

لا يوجد Red Screen كجزء من user flow الطبيعي.

---

### Step 18 — QA للـ Restart

اختبر فعليًا:

1. افتح lesson.
2. شغّل حتى 30–40%.
3. أوقف التطبيق أو أغلقه.
4. شغله من جديد.
5. افتح نفس lesson.
6. تحقق من resume.
7. أكمل 90%.
8. أغلق التطبيق.
9. افتحه.
10. تحقق أن completion بقيت محفوظة.
11. تحقق من unlock للدرس التالي.
12. تحقق من course progress.

لا تعتبر `Navigator.pop` اختبارًا للاستمرارية؛ المطلوب **app restart** فعلي.

---

## 12. Continue Watching – Contract

يجب أن تظهر البطاقة في أعلى Courses Screen فقط عندما يوجد درس غير مكتمل تمت مشاهدته.

المعلومات المقترحة:

```text
متابعة المشاهدة
[thumbnail]
اسم الدورة
اسم الدرس
progress
متابعة ▶
```

عند الضغط:

```text
navigate → lesson player
resume → persisted position
```

عند اكتمال الدرس:

- يختفي من Continue Watching إذا لم يوجد unfinished lesson آخر.
- أو تنتقل البطاقة إلى الدرس التالي إذا كان قد بدأ.

---

## 13. قواعد التصميم والـ UI

الأولوية ليست للـ animations، بل إلى:

1. clarity.
2. readability.
3. Arabic hierarchy.
4. large enough touch targets.
5. consistent spacing.
6. clear status icons.
7. no unnecessary custom drawing.

Material 3 مناسب للمهمة.

يفضل استخدام Theme موحد بدل ألوان مكتوبة في كل Widget.

---

## 14. ما يجب عدم بنائه في الـ Core Scope

لا تبدأ بهذه الأشياء قبل اكتمال كل الـ requirements:

1. Backend.
2. Firebase.
3. Authentication.
4. Payments.
5. API client.
6. Complex database.
7. Advanced animation system.
8. Custom video engine.
9. Search.
10. Notes.
11. Dark mode.
12. English localization.

هذه كلها Bonus أو خارج النطاق.

---

## 15. Bonus – بعد اكتمال Core

الأولوية للـ bonus:

1. Remember last playback speed.
2. Dark mode.
3. Arabic/English switch.
4. Search courses.
5. Per-lesson notes.
6. Widget tests.

إذا لم يتوفر الوقت، لا تضفها. اشرح ذلك في README.

---

## 16. Trade-offs المعتمدة

### 16.1 SharedPreferences بدل Database

البيانات صغيرة ولا توجد queries معقدة.

### 16.2 Course progress يعتمد على completed lessons

المرجع:

```text
completed lessons / total lessons
```

وليس نسبة مجموع الفيديوهات التي تمت مشاهدتها.

### 16.3 Completion مبني على playback position

لا يتم تتبع unique watch intervals.

إذا قام المستخدم بالقفز إلى 90%، يعتبر الدرس مكتملًا وفقًا للتفسير البسيط للمهمة.

هذا trade-off مقصود بسبب وقت المهمة.

### 16.4 Bundled JSON بدل Backend

مطلوب صراحة في الـ task، ويضمن Offline behavior قابلًا للتكرار.

---

## 17. Known Issues المتوقعة والمقبولة

يمكن تسجيل الملاحظات التالية في حال لم يكن هناك وقت لحلها بالكامل:

1. completion لا يقيس unique watched duration.
2. لا يوجد account sync بين الأجهزة.
3. لا توجد server-side analytics.
4. لا يوجد adaptive streaming.
5. لا يوجد subtitle system ما لم تتم إضافته كـ bonus.
6. لا توجد download manager لأن الفيديوهات bundled أصلًا.

يجب فقط ذكر ما ينطبق فعليًا على النسخة النهائية.

---

## 18. Definition of Done

### Functional

- [ ] Courses list تعمل.
- [ ] Continue Watching تعمل.
- [ ] Course details تعمل.
- [ ] Sections + lessons ظاهرة.
- [ ] Durations ظاهرة.
- [ ] Locked lessons تمنع الفتح.
- [ ] Friendly locked message موجود.
- [ ] Player يعمل.
- [ ] Play/Pause يعمل.
- [ ] Seek يعمل.
- [ ] Current time يعمل.
- [ ] Duration تعمل.
- [ ] Speeds الأربع تعمل.
- [ ] Fullscreen يعمل.
- [ ] Resume يعمل.
- [ ] 90% completion تعمل.
- [ ] Next lesson يحترم unlock.
- [ ] Restart persistence تعمل.

### UX

- [ ] Arabic UI.
- [ ] RTL صحيح.
- [ ] Directional icons منطقية.
- [ ] Seek bar behavior منطقي.
- [ ] Empty state واضح.
- [ ] Loading state واضح.
- [ ] Video error واضح.
- [ ] لا توجد Red Screens أثناء السيناريو الطبيعي.

### Engineering

- [ ] Null-safe.
- [ ] Data/Domain/Presentation مفصولة.
- [ ] State management ثابت.
- [ ] Repositories لا يتم استدعاؤها مباشرة من Widgets.
- [ ] Video controller يتم التخلص منه بـ dispose.
- [ ] لا يوجد storage write على كل frame.
- [ ] Business rules في مكان واحد.
- [ ] لا يوجد duplicated unlock logic.

### Testing

- [ ] Test 90% completion.
- [ ] Test sequential unlock.
- [ ] Test course progress.
- [ ] Optional edge tests.

### Documentation

- [ ] README محدث.
- [ ] Architecture موضحة.
- [ ] State management موضح.
- [ ] Persistence choice موضحة.
- [ ] Trade-offs موضحة.
- [ ] Known issues موضحة.
- [ ] Time spent موضح.

---

## 19. أوامر التشغيل المرجعية

بعد استنساخ المشروع:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

قبل التسليم:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

يفضل اختبار على Android emulator أو جهاز حقيقي، خصوصًا fullscreen/orientation/video assets.

---

## 20. Checklist قبل Commit النهائي

1. لا يوجد API call.
2. التطبيق يعمل بدون Internet.
3. كل assets موجودة.
4. لا يوجد missing asset path.
5. كل videos تعمل.
6. restart يحافظ على progress.
7. first lesson مفتوح.
8. next lessons مقفلة قبل completion.
9. 90% تغيّر completion.
10. progress percentage صحيح.
11. Continue Watching صحيح.
12. fullscreen يعمل.
13. RTL صحيح.
14. tests تمر.
15. `flutter analyze` بدون أخطاء.
16. README يطابق النسخة النهائية.

---

## 21. Recording / Demo Flow المقترح

إذا تم إرسال screen recording مدته 2–3 دقائق، نفذ بالترتيب:

1. افتح التطبيق.
2. اعرض Courses.
3. اعرض Course Details.
4. وضّح أن Lesson 1 مفتوح وLesson 2 مقفل.
5. افتح Lesson 1.
6. شغّل الفيديو.
7. أظهر speed control.
8. أظهر seek/time.
9. أكمل أو انتقل إلى 90% لإظهار completion.
10. أظهر unlock للدرس التالي.
11. ارجع إلى Courses وأظهر progress + Continue Watching.
12. اختياريًا: أظهر restart/resume بسرعة إذا كان التسجيل يسمح بذلك.

---

## 22. Time-box Strategy

إذا كان إجمالي الوقت 4–6 ساعات، استخدم الأولويات التالية:

### P0 – Must Have

1. Models + JSON.
2. Repositories.
3. Progress logic.
4. Persistence.
5. Courses.
6. Course details.
7. Video player.
8. Resume.
9. 90% completion.
10. Sequential unlock.
11. RTL.
12. 3+ unit tests.

### P1 – Polish

1. Better empty/error states.
2. Fullscreen polish.
3. Continue Watching polish.
4. Minor UI cleanup.
5. README.

### P2 – Bonus

1. Speed persistence.
2. Dark mode.
3. Search.
4. Notes.
5. English.
6. Widget tests.

**لا تبدأ P2 قبل إغلاق P0 بالكامل.**

---

## 23. What to do with more time

إذا امتد الوقت خارج الـ time box، يمكن تحسين المشروع في الخطوات التالية:

1. فصل watch history عن completion state.
2. Tracking فعلي للمقاطع المشاهدة بدل position فقط.
3. Local database حقيقية إذا توسع المحتوى.
4. Search/indexing.
5. Notes per lesson.
6. Download management إذا أصبحت الفيديوهات remote في نسخة مستقبلية.
7. Accessibility audit.
8. Widget / integration tests.
9. Better player controls.
10. Proper localization infrastructure.
11. Analytics abstraction.
12. Offline content validation.

لكن لا ينبغي تنفيذ هذه النقاط على حساب الـ core requirements في screening task.

---

## 24. Expected Git History

يفضل تقسيم العمل إلى commits واضحة بدل commit واحد ضخم، مثل:

```text
feat: bootstrap flutter project and assets
feat: add course models and local json datasource
feat: add progress domain rules
 test: cover progress and unlock rules
feat: add local progress persistence
feat: add courses screen
feat: add course details and sequential unlock
feat: add lesson video player and resume
feat: add fullscreen and rtl polish
fix: handle video and empty states
chore: finalize README and qa checklist
```

المهم أن الـ history يعكس خطوات العمل وليس مجرد snapshot نهائي.

---

## 25. Final Principle

هذه المهمة ليست مسابقة features.

المعيار الأساسي هو:

```text
Simple
+ Correct
+ Testable
+ Persistent
+ RTL-friendly
+ Maintainable
```

أي feature إضافية لا تستحق التضحية بهذه الصفات.

**المرجع النهائي للسلوك التشغيلي هو [SCENARIO.md](docs/SCENARIO.md).**
