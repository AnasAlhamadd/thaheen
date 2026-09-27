# السيناريو المطلوب – Thaheen

> **Operational Scenario / QA / Demo Reference**
>
> هذا الملف يصف كيف يجب أن يعمل التطبيق من منظور المستخدم، وما المتوقع في كل خطوة. يستخدم أيضًا كمرجع للـ Agent أثناء التنفيذ وكقائمة تحقق نهائية قبل التسليم.

---

# 1. الهدف

يجب أن يثبت التطبيق أن الطالب يستطيع الانتقال من:

```text
Courses
  ↓
Course Details
  ↓
Unlocked Lesson
  ↓
Video Playback
  ↓
Persisted Progress
  ↓
90% Completion
  ↓
Sequential Unlock
  ↓
Next Lesson
```

مع بقاء الحالة بعد **App Restart**.

---

# 2. بيانات الاختبار المفترضة

يفضل وجود دورة باسم:

```text
مقدمة في التشريح
```

وتكون دروسها المنطقية:

```text
Section 1 — الجهاز الهيكلي
├── L1 العظام
├── L2 المفاصل
└── L3 الهيكل العظمي

Section 2 — الجهاز العضلي
├── L4 العضلات الرئيسية
├── L5 الأوتار
└── L6 الحركة العضلية
```

لأغراض السيناريو، لا يهم الاسم الدقيق ما دام يوجد تسلسل واضح من 6 دروس أو أقل ضمن المتطلبات.

---

# 3. السيناريو الرئيسي End-to-End

## Step 1 — Launch

### إجراء المستخدم

يفتح التطبيق لأول مرة.

### المتوقع

1. ظهور Loading مناسب لفترة قصيرة إذا لزم.
2. ظهور شاشة Courses.
3. ظهور دورتين على الأقل.
4. ظهور thumbnail لكل دورة.
5. ظهور title.
6. ظهور instructor.
7. ظهور lesson count.
8. ظهور progress.
9. لا توجد Red Screen.
10. الواجهة عربية وRTL.

---

## Step 2 — الحالة الأولى للـ Progress

### إجراء المستخدم

يرى الدورات لأول مرة قبل مشاهدة أي شيء.

### المتوقع

```text
progress = 0%
```

ولا تظهر بطاقة Continue Watching لأن لا يوجد unfinished lesson.

---

## Step 3 — فتح الدورة

### إجراء المستخدم

يضغط على:

```text
مقدمة في التشريح
```

### المتوقع

الانتقال إلى Course Details.

تظهر:

- اسم الدورة.
- المدرب.
- sections.
- lessons.
- duration لكل درس.
- حالة كل درس.

---

# 4. اختبار Sequential Unlock

## Step 4 — الحالة الابتدائية

### المتوقع

```text
L1 → Unlocked
L2 → Locked
L3 → Locked
L4 → Locked
...
```

الدرس الأول فقط متاح.

---

## Step 5 — الضغط على درس مقفل

### إجراء المستخدم

يضغط على L2 قبل إكمال L1.

### المتوقع

لا يفتح Video Player.

تظهر رسالة ودية مثل:

```text
أكمل الدرس السابق أولاً لفتح هذا الدرس.
```

بعد إغلاق الرسالة تبقى الشاشة في Course Details.

---

# 5. اختبار Video Player

## Step 6 — فتح L1

### إجراء المستخدم

يضغط على الدرس الأول.

### المتوقع

فتح Lesson Player بدون crash.

إذا كان الفيديو يتم تحميله:

```text
loading state
```

ثم:

```text
video ready
```

---

## Step 7 — Video Controls

### يجب اختبار

1. Play.
2. Pause.
3. Seek.
4. Current time.
5. Duration.
6. Speed 1x.
7. Speed 1.25x.
8. Speed 1.5x.
9. Speed 2x.
10. Fullscreen.

كلها يجب أن تعمل بدون تغيير غير متوقع في progress.

---

# 6. اختبار Resume

## Step 8 — مشاهدة جزئية

### إجراء المستخدم

يشغل L1 حتى يصل تقريبًا إلى:

```text
30% – 40%
```

ثم يعمل Pause.

### المتوقع

يتم حفظ الـ playback position محليًا.

ليس شرطًا أن يكون الرقم دقيقًا إلى frame واحدة، لكن يجب أن يكون قريبًا من آخر موضع محفوظ ضمن سلوك التخزين الدوري/عند pause.

---

## Step 9 — الخروج من الدرس

### إجراء المستخدم

يرجع إلى Course Details أو Courses.

### المتوقع

L1 تصبح:

```text
In Progress
```

L2 لا تزال:

```text
Locked
```

---

## Step 10 — العودة إلى L1

### إجراء المستخدم

يفتح L1 من جديد.

### المتوقع

الفيديو يقوم بعملية seek إلى آخر position محفوظ.

لا يبدأ من 0 إلا إذا لم يوجد progress سابق.

---

# 7. اختبار Continue Watching

## Step 11 — العودة إلى Courses

### إجراء المستخدم

يرجع إلى Courses.

### المتوقع

في أعلى الشاشة تظهر:

```text
متابعة المشاهدة
```

وتعرض الدرس غير المكتمل الحالي.

يجب أن تتضمن البطاقة على الأقل:

- course title.
- lesson title.
- thumbnail.
- progress.
- action للمتابعة.

---

## Step 12 — الضغط على Continue Watching

### المتوقع

الانتقال مباشرة إلى L1.

والفيديو يستأنف من آخر موضع محفوظ.

---

# 8. اختبار 90% Completion

## Step 13 — الاقتراب من النهاية

### إجراء المستخدم

يحرك الفيديو أو يشاهده حتى:

```text
89%
```

### المتوقع

```text
completed = false
```

L2 تبقى locked.

---

## Step 14 — الوصول إلى 90%

### إجراء المستخدم

يصل playback position إلى:

```text
90% أو أكثر
```

### المتوقع

1. L1 تصبح Completed.
2. completion تحفظ محليًا.
3. L2 تصبح Unlocked.
4. progress الخاص بالدورة يتغير.
5. لا توجد Red Screen.

---

# 9. اختبار Next Lesson

## Step 15 — الضغط على Next Lesson

### المتوقع

إذا كان L2 هو الدرس التالي المتاح:

```text
انتقال → L2
```

إذا كان L1 هو آخر درس:

```text
لا يوجد درس تالٍ
```

ويظهر UI مناسب بدل navigation خاطئ.

---

# 10. اختبار Course Progress

افترض وجود:

```text
6 lessons
1 completed
```

المتوقع:

```text
16.67%
```

إذا أصبح:

```text
3 completed
```

المتوقع:

```text
50%
```

إذا أصبحت كلها completed:

```text
100%
```

إذا كانت الدورة بدون دروس:

```text
0%
```

---

# 11. اختبار App Restart الحقيقي

هذا السيناريو إلزامي.

## Step 16 — إغلاق التطبيق

بعد إكمال L1 أو مشاهدة L2 جزئيًا:

1. أوقف التطبيق فعليًا.
2. أعد تشغيله.
3. لا تعتمد على مجرد الرجوع باستخدام `Navigator.pop`.

---

## Step 17 — التحقق من persistence

بعد restart:

### يجب أن يبقى:

- completion states.
- playback positions.
- unlock states الناتجة عن completion.
- course progress.
- last watched lesson إذا كان محفوظًا.

### يجب ألا يحدث:

```text
كل شيء يرجع إلى 0
```

---

# 12. Empty State Scenario

## Step 18 — دورة بدون دروس

لأغراض QA، عدّل JSON مؤقتًا بحيث توجد دورة:

```text
Empty Course
sections = []
```

### المتوقع

ظهور رسالة مثل:

```text
لا توجد دروس في هذه الدورة حالياً.
```

ولا يحدث:

- RangeError.
- NoSuchElementException / StateError.
- crash.
- Red Screen.

ويجب أن يكون progress:

```text
0%
```

---

# 13. Missing/Corrupt Video Scenario

## Step 19 — Missing asset

لأغراض الاختبار، غيّر video path إلى path غير موجود.

### المتوقع

داخل Player:

```text
تعذر تشغيل الفيديو.
يرجى المحاولة مرة أخرى.
```

مع retry أو action مناسب إن توفر.

لا يوجد Red Screen.

---

## Step 20 — Recover after video error

بعد إعادة تصحيح asset path:

### المتوقع

زر Retry أو إعادة فتح الدرس يعيد التهيئة بشكل صحيح.

ولا توجد state قديمة عالقة من initialization الفاشل.

---

# 14. Fullscreen Scenario

## Step 21 — Enter Fullscreen

### إجراء المستخدم

يضغط fullscreen.

### المتوقع

1. التحول إلى landscape عند دعم المنصة.
2. الفيديو يستغل مساحة الشاشة بشكل مناسب.
3. controls الرئيسية تبقى قابلة للاستخدام.

---

## Step 22 — Exit Fullscreen

### المتوقع

1. العودة إلى portrait.
2. استمرار الفيديو/progress بدون reset غير مقصود.
3. عدم تحويل باقي التطبيق إلى landscape دائمًا.

---

# 15. RTL Scenario

يجب مراجعة العناصر التالية بصريًا:

```text
[App Bar]
[Back]
[Course title]
[Instructor]
[Progress]
[Section header]
[Lesson rows]
[Lock icon]
[Completed icon]
[Play button]
[Seek bar]
[Next button]
[Dialogs/Snackbars]
```

### التحقق

- النص يبدأ من الاتجاه الصحيح.
- padding منطقي.
- الأيقونات الاتجاهية منطقية.
- slider/seek bar لا يعطي إحساسًا معكوسًا للمستخدم.
- لا يوجد overlap بين النص وicons.

---

# 16. State Matrix للـ Lesson

| Access | Progress | Expected UI | Can Open? |
|---|---|---|---|
| Locked | Not Started | 🔒 Locked | No |
| Unlocked | Not Started | ▶ Not Started | Yes |
| Unlocked | In Progress | ▶ In Progress + progress | Yes |
| Unlocked | Completed | ✓ Completed | Yes |

قاعدة مهمة:

```text
Locked ≠ Progress State
```

الـ locked يمثل access، بينما not-started/in-progress/completed تمثل progress.

---

# 17. Continue Watching Rules

### يظهر عندما:

```text
position > 0
AND completed == false
```

### لا يظهر عندما:

```text
لا يوجد progress
```

### يجب ألا يشير إلى:

- Lesson locked.
- Lesson completed.
- Lesson غير موجود.

### يفضل

حفظ:

```text
lastWatchedLessonId
```

لتحديد العنصر المقصود.

---

# 18. اختبار السرعات

يجب تنفيذ:

```text
1x
1.25x
1.5x
2x
```

والتحقق من:

- speed فعليًا يتغير.
- current position لا يعود إلى zero.
- completion rule تستمر بالاعتماد على position/duration.
- الرجوع إلى السرعة السابقة يعمل.

---

# 19. Unit Test Scenario Matrix

## Test 1 — Completion

```text
Input:
position = 89 sec
duration = 100 sec
Expected: false
```

```text
Input:
position = 90 sec
duration = 100 sec
Expected: true
```

```text
Input:
position = 95 sec
duration = 100 sec
Expected: true
```

---

## Test 2 — Unlock

```text
First lesson
Expected: unlocked
```

```text
Previous lesson incomplete
Expected: next locked
```

```text
Previous lesson completed
Expected: next unlocked
```

---

## Test 3 — Course Progress

```text
0 / 10 → 0%
5 / 10 → 50%
10 / 10 → 100%
0 / 0 → 0%
```

---

# 20. Acceptance Checklist النهائية

## Courses

- [ ] 2 courses موجودة.
- [ ] thumbnails تظهر.
- [ ] title يظهر.
- [ ] instructor يظهر.
- [ ] lesson count يظهر.
- [ ] progress يظهر.
- [ ] Continue Watching يظهر فقط عند الحاجة.

## Course Details

- [ ] 2 sections على الأقل لكل course.
- [ ] 2–3 lessons لكل section.
- [ ] duration لكل lesson.
- [ ] locked/unlocked صحيح.
- [ ] status صحيح.
- [ ] locked message موجود.

## Player

- [ ] Play.
- [ ] Pause.
- [ ] Seek.
- [ ] Current time.
- [ ] Duration.
- [ ] 1x.
- [ ] 1.25x.
- [ ] 1.5x.
- [ ] 2x.
- [ ] Fullscreen.
- [ ] Landscape.
- [ ] Resume.
- [ ] 90% completion.
- [ ] Next Lesson.

## Persistence

- [ ] Position survives restart.
- [ ] Completed survives restart.
- [ ] Unlock survives restart through completed state.
- [ ] Progress survives restart.

## UX / Errors

- [ ] RTL.
- [ ] Loading.
- [ ] Empty.
- [ ] Video error.
- [ ] No Red Screen.

## Tests

- [ ] 90% rule.
- [ ] unlock rule.
- [ ] progress calculation.

---

# 21. Demo Recording Scenario – 2 إلى 3 دقائق

إذا كان المطلوب تسجيل فيديو للشاشة، نفذ هذا التسلسل:

### 00:00–00:20

افتح التطبيق وأظهر Courses:

- دورتان.
- progress.
- Arabic/RTL.

### 00:20–00:45

افتح Course Details:

- sections.
- L1 unlocked.
- L2 locked.

اضغط L2 لإظهار locked message.

### 00:45–01:30

افتح L1:

- play.
- pause.
- seek.
- speed.
- current time/duration.

### 01:30–02:00

الوصول إلى 90%:

- L1 يصبح completed.
- L2 يصبح unlocked.
- course progress يتغير.

### 02:00–02:30

ارجع إلى Courses:

- أظهر Continue Watching إذا كان يوجد lesson غير مكتمل.
- أظهر progress المحدث.

إذا سمح التسجيل، أظهر restart/resume بسرعة.

---

# 22. سيناريوهات إضافية للـ QA

## Case A — User leaves before completion

```text
L1 = 40%
Leave
Reopen
Expected: 40% تقريبًا
L1 = In Progress
L2 = Locked
```

## Case B — User completes lesson

```text
L1 = 90%
Expected: Completed
L2 = Unlocked
```

## Case C — Last lesson

```text
Last lesson = 90%
Expected: Completed
No invalid Next navigation
```

## Case D — Empty course

```text
0 lessons
Expected: Empty state + 0%
```

## Case E — Invalid video asset

```text
Video missing
Expected: friendly error state
```

## Case F — Saved position > duration

```text
saved position = 120s
duration = 100s
Expected: clamped safely
```

## Case G — Duration invalid/zero

```text
duration <= 0
Expected: not completed
No division by zero
```

---

# 23. Final Expected Behavior in One View

```text
┌───────────────────────────────┐
│           Courses             │
│                               │
│  Continue Watching (optional) │
│                               │
│  Course A       40%           │
│  Course B       0%            │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│        Course Details         │
│                               │
│ Section 1                     │
│ ✓ L1 Completed               │
│ ▶ L2 In Progress              │
│ 🔒 L3 Locked                  │
│                               │
│ Section 2                     │
│ 🔒 L4 Locked                  │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│          Player               │
│                               │
│       [   VIDEO   ]           │
│                               │
│  ▶  ────────●──────  01:20    │
│             / 02:00           │
│                               │
│  Speed: 1x 1.25x 1.5x 2x      │
│                               │
│      [ Next Lesson ]          │
└──────────────┬────────────────┘
               │
               ▼
        >= 90% watched
               │
               ▼
        Lesson Completed
               │
               ▼
       Next Lesson Unlocked
               │
               ▼
        Progress Updated
```

---

# 24. قاعدة المراجعة النهائية

قبل اعتبار المشروع جاهزًا، يجب أن يستطيع شخص آخر تشغيله واتباع هذا الملف دون الحاجة إلى معرفة القرارات الداخلية للمطور.

**إذا اختلف التطبيق عن هذا السيناريو، يجب إما:**

1. تعديل التطبيق ليطابق السيناريو، أو
2. تعديل السيناريو مع توثيق سبب الاختلاف في README ضمن `Trade-offs / Known Issues`.

لا تترك behavior غير موثق.
