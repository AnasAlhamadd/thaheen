# 🚀 Academic Kickoff Banner - Quick Start Guide

## 📖 Overview

The `AcademicKickoffBanner` is a smart hero banner that automatically switches between two states based on student progress:

- **State A**: "Continue Watching" (متابعة المشاهدة) - Shows unfinished lesson
- **State B**: "Academic Kickoff" (انطلاقة الفصل الدراسي) - Promotional welcome banner

---

## ⚡ Quick Implementation

### Step 1: Import Dependencies

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/academic_kickoff_banner.dart';
import '../../../player/domain/services/progress_service.dart';
```

### Step 2: Basic Usage

```dart
@override
Widget build(BuildContext context) {
  final progressService = context.read<ProgressService>();

  // Find unfinished lesson across all courses
  Course? continueCourse;
  Lesson? continueLesson;

  for (final course in courses) {
    final inProgressLesson = progressService.findContinueWatching(
      course,
      progressList,
    );
    if (inProgressLesson != null) {
      continueCourse = course;
      continueLesson = inProgressLesson;
      break; // Found the first unfinished lesson
    }
  }

  return AcademicKickoffBanner(
    continueCourse: continueCourse,
    continueLesson: continueLesson,
    lessonProgress: continueLesson != null && continueCourse != null
        ? progressList.cast<LessonProgress?>().firstWhere(
            (p) => p?.lessonId == continueLesson!.id,
            orElse: () => null,
          )
        : null,
  );
}
```

---

## 🎨 State Behavior

### Continue Watching State (Automatic)

**Triggers when:**
- `continueLesson != null`
- `continueCourse != null`
- `lessonProgress != null`
- `lessonProgress.completed == false`
- `lessonProgress.position > Duration.zero`

**Displays:**
- Badge: "متابعة المشاهدة"
- Title: Lesson title (e.g., "العظام والمفاصل")
- Subtitle: Course name + progress (e.g., "مقدمة في التشريح • تم مشاهدة 45%")
- Progress bar showing video position
- Button: "استكمال الدرس" → navigates to `/courses/:courseId/lessons/:lessonId`

### Academic Kickoff State (Default)

**Triggers when:** No valid unfinished lesson exists

**Displays:**
- Badge: "انطلاقة الفصل الدراسي الجديد"
- Title: "ابدأ أول محاضرة اليوم 🎯"
- Subtitle: Promotional text
- Button: Configurable action

---

## 🔧 Customization Options

### Custom Kickoff Text

```dart
AcademicKickoffBanner(
  title: 'استعد للامتحان النهائي 📚',
  subtitle: 'راجع المحاضرات الأساسية قبل الامتحان',
  actionLabel: 'بدء المراجعة',
  timeEstimate: 'متبقي ساعتان',
  onKickoffActionPressed: () {
    context.go('/exam-prep');
  },
)
```

### Only Continue Watching State

```dart
AcademicKickoffBanner(
  continueCourse: course,
  continueLesson: lesson,
  lessonProgress: progress,
  // No kickoff parameters needed - will fallback to defaults
)
```

---

## 📊 How It Works

### 1. **Data Flow**

```
CoursesCubit (BLoC)
  ↓
DashboardScreen (finds unfinished lesson)
  ↓
AcademicKickoffBanner (displays appropriate state)
```

### 2. **State Determination Logic**

```dart
// Internal method in AcademicKickoffBanner
bool _hasValidUnfinishedLesson() {
  return continueLesson != null &&
      continueCourse != null &&
      lessonProgress != null &&
      !lessonProgress!.completed &&
      lessonProgress!.position > Duration.zero;
}
```

### 3. **Progress Calculation**

```dart
// Automatically calculates from lesson duration and current position
double progressRatio = position.inSeconds / duration.inSeconds;
String percentage = "تم مشاهدة ${(ratio * 100).round()}%";
```

### 4. **Time Formatting**

Handles Arabic grammar automatically:
- 0 minutes: "أقل من دقيقة"
- 1 minute: "متبقي دقيقة واحدة"
- 2 minutes: "متبقي دقيقتان"
- 3-10 minutes: "متبقي X دقائق"
- 11+ minutes: "متبقي X دقيقة"

---

## 🧩 Required Dependencies

The banner requires these services to be available in the widget tree:

```dart
// In your app setup
MultiBlocProvider(
  providers: [
    Provider<ProgressService>(
      create: (_) => ProgressService(),
    ),
    RepositoryProvider<ProgressRepository>(
      create: (_) => ProgressRepositoryImpl(/* ... */),
    ),
    RepositoryProvider<CourseRepository>(
      create: (_) => CourseRepositoryImpl(/* ... */),
    ),
  ],
  child: MyApp(),
)
```

---

## 🎯 Common Use Cases

### Use Case 1: Dashboard Screen

```dart
// Show student's current learning status
AcademicKickoffBanner(
  continueCourse: currentCourse,
  continueLesson: currentLesson,
  lessonProgress: currentProgress,
)
```

### Use Case 2: Course Details Screen

```dart
// Show progress within a specific course
AcademicKickoffBanner(
  continueCourse: course,
  continueLesson: progressService.findContinueWatching(course, progressList),
  lessonProgress: /* fetch from progressList */,
  title: 'استكمل رحلتك التعليمية',
  actionLabel: 'ابدأ الدرس التالي',
)
```

### Use Case 3: Onboarding Screen

```dart
// Pure kickoff mode (no continue watching)
AcademicKickoffBanner(
  title: 'مرحباً بك في ثاهين 🎓',
  subtitle: 'ابدأ رحلتك الطبية اليوم',
  actionLabel: 'استكشف الدورات',
  timeEstimate: 'متبقي 60 دقيقة',
  onKickoffActionPressed: () => context.go('/courses'),
)
```

---

## 🔍 Debugging Tips

### Check if State is Switching Correctly

```dart
// Add logging to see which state is active
@override
Widget build(BuildContext context) {
  final hasUnfinished = _hasValidUnfinishedLesson();
  debugPrint('AcademicKickoffBanner state: ${hasUnfinished ? "Continue Watching" : "Kickoff"}');
  
  return AnimatedSwitcher(/* ... */);
}
```

### Verify Progress Data

```dart
// Check if progress is being fetched correctly
debugPrint('Progress List: ${progressList.length} items');
debugPrint('Continue Lesson: ${continueLesson?.title}');
debugPrint('Lesson Progress: ${lessonProgress?.position}');
```

### Test State Transitions

```dart
// Manually set progress to test transitions
final testProgress = LessonProgress(
  lessonId: 'test-lesson',
  position: Duration(minutes: 5),
  completed: false,
);
```

---

## ⚠️ Important Notes

1. **Navigation**: The banner uses `go_router` for navigation. Ensure routes are configured:
   ```dart
   GoRoute(
     path: '/courses/:courseId/lessons/:lessonId',
     builder: (context, state) => LessonPlayerScreen(/* ... */),
   )
   ```

2. **RTL Support**: All text is automatically formatted for RTL (Arabic).

3. **Null Safety**: The banner gracefully handles null values and invalid data.

4. **Animation**: State transitions are animated (350ms duration with ease curves).

5. **Responsive**: Buttons use `Flexible` widgets to prevent overflow on small screens.

---

## 🧪 Testing

### Unit Test Example

```dart
testWidgets('shows Continue Watching when lesson is unfinished', (tester) async {
  final course = Course(id: '1', title: 'Test Course');
  final lesson = Lesson(id: '1', title: 'Test Lesson', durationSec: 300);
  final progress = LessonProgress(
    lessonId: '1',
    position: Duration(seconds: 150),
    completed: false,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AcademicKickoffBanner(
          continueCourse: course,
          continueLesson: lesson,
          lessonProgress: progress,
        ),
      ),
    ),
  );

  expect(find.text('متابعة المشاهدة'), findsOneWidget);
  expect(find.text('استكمال الدرس'), findsOneWidget);
});
```

---

## 📚 API Reference

### Constructor Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `continueCourse` | `Course?` | No | Course containing the lesson to continue |
| `continueLesson` | `Lesson?` | No | Lesson to continue watching |
| `lessonProgress` | `LessonProgress?` | No | Progress data for the lesson |
| `title` | `String` | No | Fallback title for kickoff state |
| `subtitle` | `String` | No | Fallback subtitle for kickoff state |
| `actionLabel` | `String` | No | Fallback button label for kickoff state |
| `timeEstimate` | `String` | No | Fallback time estimate for kickoff state |
| `onKickoffActionPressed` | `VoidCallback?` | No | Callback for kickoff state button |

---

## ✅ Checklist

Before using the banner, ensure:

- [ ] `ProgressService` is available via `context.read<ProgressService>()`
- [ ] `ProgressRepository` is available via `context.read<ProgressRepository>()`
- [ ] Go router is configured with lesson player route
- [ ] Progress data is being loaded in parent screen
- [ ] Arabic fonts are properly configured in theme

---

## 🎉 That's It!

You're now ready to use the `AcademicKickoffBanner` in your Thaheen LMS app!

For detailed documentation, see: `ACADEMIC_KICKOFF_BANNER_REFACTORING.md`
