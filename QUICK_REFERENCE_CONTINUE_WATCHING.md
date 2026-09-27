# Continue Watching - Quick Reference Card

## 🚀 Quick Start

### Using the Service

```dart
// 1. Inject ProgressService
final progressService = context.read<ProgressService>();

// 2. Call findNextIncompleteLesson
final next = progressService.findNextIncompleteLesson(
  courses,        // List<Course>
  progressList,   // List<LessonProgress>
);

// 3. Extract results
final course = next?.course;     // Course?
final lesson = next?.lesson;     // Lesson?
final progress = next?.progress; // LessonProgress?

// 4. Use in your UI
if (next != null) {
  // Show continue watching UI
  AcademicKickoffBanner(
    continueCourse: course,
    continueLesson: lesson,
    lessonProgress: progress,
  );
}
```

---

## 🎯 Method Signature

```dart
({Course course, Lesson lesson, LessonProgress? progress})? findNextIncompleteLesson(
  List<Course> courses,
  List<LessonProgress> progressList,
)
```

**Returns:**
- **Non-null record** if incomplete lesson found
- **null** if all lessons completed or no courses exist

**Record Fields:**
- `course` - The course containing the lesson (never null in record)
- `lesson` - The lesson to continue/start (never null in record)
- `progress` - Progress data, **null if lesson not started**

---

## 🔍 Search Priority

```dart
// Priority 1: In-Progress Lessons
if (progress != null && 
    !progress.completed && 
    progress.position > Duration.zero) {
  return lesson; // 🔥 HIGHEST PRIORITY
}

// Priority 2: Unlocked, Not Started
if (isUnlocked && 
    (progress == null || progress.position == Duration.zero)) {
  return lesson; // 🟢 LOWER PRIORITY
}

// Priority 3: Nothing Found
return null; // Falls back to kickoff banner
```

---

## 📊 Example Usage Patterns

### Pattern 1: Simple Check

```dart
final next = progressService.findNextIncompleteLesson(courses, progress);

if (next != null) {
  print('Continue: ${next.lesson.title} in ${next.course.title}');
  print('Has progress: ${next.progress != null}');
} else {
  print('No incomplete lessons');
}
```

### Pattern 2: Banner Display

```dart
Widget build(BuildContext context) {
  final next = progressService.findNextIncompleteLesson(
    widget.courses,
    widget.progressList,
  );

  return AcademicKickoffBanner(
    continueCourse: next?.course,
    continueLesson: next?.lesson,
    lessonProgress: next?.progress,
    onKickoffActionPressed: () {
      // Fallback action when no lesson found
      _navigateToFirstLesson();
    },
  );
}
```

### Pattern 3: Navigation

```dart
void navigateToNextLesson() {
  final next = progressService.findNextIncompleteLesson(courses, progress);
  
  if (next != null) {
    context.go('/courses/${next.course.id}/lessons/${next.lesson.id}');
  } else {
    // No lesson to navigate to
    showCompletionDialog();
  }
}
```

---

## 🧪 Testing Examples

### Test 1: No Progress

```dart
test('returns first lesson when no progress exists', () {
  final courses = [
    Course(
      id: 'c1',
      sections: [
        Section(lessons: [
          Lesson(id: 'l1'),
          Lesson(id: 'l2'),
        ])
      ],
    ),
  ];

  final result = progressService.findNextIncompleteLesson(courses, []);

  expect(result?.lesson.id, 'l1');
  expect(result?.progress, null);
});
```

### Test 2: In-Progress Lesson

```dart
test('returns in-progress lesson', () {
  final courses = [...];
  final progress = [
    LessonProgress(
      lessonId: 'l1',
      position: Duration(seconds: 50),
      completed: false,
    ),
  ];

  final result = progressService.findNextIncompleteLesson(courses, progress);

  expect(result?.lesson.id, 'l1');
  expect(result?.progress?.position.inSeconds, 50);
});
```

### Test 3: Next Unlocked

```dart
test('returns next unlocked lesson when previous completed', () {
  final courses = [...];
  final progress = [
    LessonProgress(lessonId: 'l1', completed: true),
  ];

  final result = progressService.findNextIncompleteLesson(courses, progress);

  expect(result?.lesson.id, 'l2');
  expect(result?.progress, null);
});
```

---

## 🎨 UI State Handling

### Check if Has Progress

```dart
bool hasProgress(LessonProgress? progress) {
  return progress != null && progress.position > Duration.zero;
}

// Usage
if (hasProgress(next?.progress)) {
  // Show "Continue Watching" state
  showProgressBar();
  showPercentage();
  buttonLabel = 'استكمال الدرس';
} else {
  // Show "Start Now" state
  hideProgressBar();
  hidePercentage();
  buttonLabel = 'ابدأ الدرس';
}
```

### Calculate Progress Ratio

```dart
double getProgressRatio(Lesson lesson, LessonProgress? progress) {
  if (progress == null) return 0.0;
  
  final totalDuration = Duration(seconds: lesson.durationSec);
  if (totalDuration <= Duration.zero) return 0.0;
  
  return (progress.position.inSeconds / totalDuration.inSeconds)
      .clamp(0.0, 1.0);
}
```

### Format Time Remaining

```dart
String formatTimeRemaining(Lesson lesson, LessonProgress? progress) {
  final totalDuration = Duration(seconds: lesson.durationSec);
  
  final remaining = progress != null 
      ? totalDuration - progress.position
      : totalDuration;
  
  final minutes = remaining.inMinutes;
  
  if (minutes == 0) return 'أقل من دقيقة';
  if (minutes == 1) return progress != null ? 'متبقي دقيقة واحدة' : 'دقيقة واحدة';
  if (minutes == 2) return progress != null ? 'متبقي دقيقتان' : 'دقيقتان';
  if (minutes <= 10) return progress != null ? 'متبقي $minutes دقائق' : '$minutes دقائق';
  return progress != null ? 'متبقي $minutes دقيقة' : '$minutes دقيقة';
}
```

---

## 🔄 Common Scenarios

| Scenario | Returns | progress | State |
|----------|---------|----------|-------|
| Fresh start | First L1 | null | Start |
| L1 at 50% | L1 | 50% data | Continue |
| L1 complete | L2 | null | Start |
| L1 complete, L2 30% | L2 | 30% data | Continue |
| All complete | null | - | Kickoff |
| Multiple courses, C2-L1 at 40% | C2-L1 | 40% data | Continue |

---

## ⚠️ Edge Cases

### Empty Courses
```dart
final result = progressService.findNextIncompleteLesson([], progress);
// Returns: null
```

### All Completed
```dart
// All lessons have completed: true
final result = progressService.findNextIncompleteLesson(courses, progress);
// Returns: null
```

### Invalid Progress Position
```dart
// Progress position > lesson duration (shouldn't happen, but handled)
final ratio = getProgressRatio(lesson, progress);
// Returns: Clamped to 1.0 (100%)
```

### Duration Zero
```dart
// Lesson has durationSec: 0
final ratio = getProgressRatio(lesson, progress);
// Returns: 0.0 (prevents division by zero)
```

---

## 📦 Dependencies

```yaml
# Required in pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # No additional dependencies needed for this feature
```

---

## 🎯 Key Points

✅ **Always null-check the result** - May return null  
✅ **Progress can be null** - Even in non-null result  
✅ **Scans all courses** - Not limited to one course  
✅ **Priority matters** - In-progress before unlocked  
✅ **Pure Dart** - No Flutter dependencies in service  
✅ **Testable** - Easy to unit test  
✅ **Efficient** - Stops at first match

---

## 🐛 Common Mistakes

### ❌ Don't Do This
```dart
// Assuming progress is always non-null
final percentage = (next.progress.position.inSeconds / ...) * 100; // CRASH!
```

### ✅ Do This Instead
```dart
// Always check if progress exists
final percentage = next?.progress != null
    ? (next.progress!.position.inSeconds / ...) * 100
    : 0.0;
```

### ❌ Don't Do This
```dart
// Using ! operator without checking
final course = next!.course; // CRASH if next is null!
```

### ✅ Do This Instead
```dart
// Use null-aware operators
final course = next?.course;
if (course != null) {
  // Safe to use course
}
```

### ❌ Don't Do This
```dart
// Manually looping through courses
for (final course in courses) {
  for (final lesson in getAllLessons(course)) {
    // ... manual logic
  }
}
```

### ✅ Do This Instead
```dart
// Use the service method
final next = progressService.findNextIncompleteLesson(courses, progress);
```

---

## 📞 Support

**Files:**
- Implementation: `lib/features/player/domain/services/progress_service.dart`
- Usage: `lib/features/courses/presentation/screens/dashboard_screen.dart`
- UI: `lib/features/courses/presentation/widgets/academic_kickoff_banner.dart`

**Documentation:**
- Technical: `CONTINUE_WATCHING_IMPLEMENTATION.md`
- Arabic: `CONTINUE_WATCHING_AR.md`
- Summary: `IMPLEMENTATION_SUMMARY.md`

**Questions?** Check the comprehensive documentation files above.

---

**Quick Reference v1.0** | Last Updated: 2026-09-27
