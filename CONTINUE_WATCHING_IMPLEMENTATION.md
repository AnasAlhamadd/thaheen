# Continue Watching / Next Lesson Implementation

## Overview

The Academic Kickoff Banner has been enhanced to intelligently display the next incomplete lesson across all courses. The system now:

1. **Finds the first incomplete lesson** - whether it's partially watched or not yet started
2. **Displays appropriate UI** - shows "Continue Watching" for in-progress lessons, "Start Now" for unstarted lessons
3. **Navigates directly** - clicking the action button takes you straight to the lesson player

## Architecture

### 1. ProgressService Enhancement

**File:** `lib/features/player/domain/services/progress_service.dart`

#### New Method: `findNextIncompleteLesson()`

```dart
({Course course, Lesson lesson, LessonProgress? progress})? findNextIncompleteLesson(
  List<Course> courses,
  List<LessonProgress> progressList,
)
```

**Purpose:** Finds the next incomplete lesson across all courses with intelligent priority.

**Returns:** A record containing:
- `course` - The course containing the lesson
- `lesson` - The lesson to continue/start
- `progress` - Progress data (null if not started)

**Logic:**

1. **First Pass (High Priority):** Look for in-progress lessons
   - Has `progress.position > 0`
   - Is NOT completed
   - These are lessons the student started but didn't finish

2. **Second Pass (Lower Priority):** Look for first unlocked lesson with no progress
   - Lesson is unlocked (first lesson OR previous lesson completed)
   - Has no progress OR position is zero
   - These are lessons ready to be started

**Example Scenarios:**

```dart
// Scenario 1: Student watched 50% of Lesson 2
// Result: Returns Lesson 2 with its progress data
({
  course: Course("anatomy-101"),
  lesson: Lesson("anatomy-l2"),
  progress: LessonProgress(position: 50sec, completed: false)
})

// Scenario 2: Student completed Lesson 1, hasn't started Lesson 2
// Result: Returns Lesson 2 with null progress
({
  course: Course("anatomy-101"),
  lesson: Lesson("anatomy-l2"),
  progress: null
})

// Scenario 3: No progress at all
// Result: Returns first lesson of first course
({
  course: Course("anatomy-101"),
  lesson: Lesson("anatomy-l1"),
  progress: null
})
```

### 2. Dashboard Screen Update

**File:** `lib/features/courses/presentation/screens/dashboard_screen.dart`

**Before:**
```dart
// Old: Loop through courses manually
Course? continueCourse;
Lesson? continueLesson;
for (final course in widget.courses) {
  final inProgressLesson = progressService.findContinueWatching(
    course,
    widget.progressList,
  );
  // ... manual lookup
}
```

**After:**
```dart
// New: Single clean call
final nextIncomplete = progressService.findNextIncompleteLesson(
  widget.courses,
  widget.progressList,
);

final continueCourse = nextIncomplete?.course;
final continueLesson = nextIncomplete?.lesson;
final continueProgress = nextIncomplete?.progress;
```

### 3. Banner Component Updates

**File:** `lib/features/courses/presentation/widgets/academic_kickoff_banner.dart`

#### Updated: `_hasValidUnfinishedLesson()`

**Before:** Required progress with `position > 0`
```dart
return continueLesson != null &&
    continueCourse != null &&
    lessonProgress != null &&
    !lessonProgress!.completed &&
    lessonProgress!.position > Duration.zero;
```

**After:** Only requires course and lesson (progress can be null)
```dart
return continueLesson != null && continueCourse != null;
```

#### Updated: `_ContinueWatchingBanner`

**Changes:**
1. **Progress is now nullable:** `LessonProgress? progress` (was required)
2. **Added `_hasProgress()` helper:** Checks if lesson has been started
3. **Dynamic badge display:**
   - Shows "متابعة المشاهدة" (Continue Watching) when `hasProgress == true`
   - Shows "ابدأ الآن" (Start Now) when `hasProgress == false`
4. **Conditional progress UI:**
   - Progress bar only shown when lesson has been started
   - Progress percentage only shown in subtitle when has progress
5. **Dynamic action labels:**
   - "استكمال الدرس" (Continue Lesson) when has progress
   - "ابدأ الدرس" (Start Lesson) when no progress
6. **Smart time formatting:**
   - Shows "متبقي X دقائق" (X minutes remaining) when has progress
   - Shows "X دقائق" (X minutes total) when no progress

## UI States

### State 1: In-Progress Lesson
**When:** Student started but didn't complete a lesson

```
┌─────────────────────────────────────────┐
│ 🟡 متابعة المشاهدة                      │
│                                         │
│ العظام                                  │
│ مقدمة في التشريح • تم مشاهدة 50%       │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░                   │
│                                         │
│ [▶ استكمال الدرس]     ⏰ متبقي 5 دقائق│
└─────────────────────────────────────────┘
```

### State 2: Next Unlocked Lesson (Not Started)
**When:** Previous lesson completed, next lesson ready to start

```
┌─────────────────────────────────────────┐
│ 🚀 ابدأ الآن                            │
│                                         │
│ المفاصل                                 │
│ مقدمة في التشريح                        │
│                                         │
│ [▶ ابدأ الدرس]            ⏰ 10 دقائق  │
└─────────────────────────────────────────┘
```

### State 3: Academic Kickoff (Fallback)
**When:** All lessons completed OR no courses available

```
┌─────────────────────────────────────────┐
│ ⚡ انطلاقة الفصل الدراسي الجديد         │
│                                         │
│ ابدأ أول محاضرة اليوم 🎯                │
│ انطلق في التشريح السريري...            │
│                                         │
│ [➜ ابدأ بالتشريح السريري] ⏰ 45 دقيقة  │
└─────────────────────────────────────────┘
```

## Edge Cases Handled

### ✅ No Progress Exists
- System finds first lesson of first course
- Shows "ابدأ الآن" badge
- Shows total duration (not remaining time)
- No progress bar displayed

### ✅ All Courses Completed
- Falls back to "Academic Kickoff" banner
- Shows promotional content
- Action navigates to first lesson for re-watching

### ✅ Multiple Courses with Mixed Progress
- Scans courses in order
- Returns first in-progress lesson found
- If no in-progress lessons, returns first unlocked lesson

### ✅ Lesson Duration Edge Cases
- Handles lessons < 1 minute: shows "أقل من دقيقة"
- Handles 1 minute: shows "دقيقة واحدة"
- Handles 2 minutes: shows "دقيقتان" (dual form in Arabic)
- Handles 3-10 minutes: shows "X دقائق"
- Handles 11+ minutes: shows "X دقيقة"

## Testing Recommendations

### Unit Tests for `findNextIncompleteLesson()`

```dart
test('returns first in-progress lesson across multiple courses', () {
  // Given: Course1.L1 completed, Course1.L2 at 50%, Course2.L1 at 30%
  final result = progressService.findNextIncompleteLesson(courses, progress);
  
  // Then: Should return Course1.L2 (first in-progress found)
  expect(result?.lesson.id, 'anatomy-l2');
});

test('returns first unlocked lesson when no progress exists', () {
  // Given: No progress at all
  final result = progressService.findNextIncompleteLesson(courses, []);
  
  // Then: Should return first lesson of first course
  expect(result?.lesson.id, 'anatomy-l1');
  expect(result?.progress, null);
});

test('returns next unlocked lesson when previous completed', () {
  // Given: Course1.L1 completed, Course1.L2 not started
  final result = progressService.findNextIncompleteLesson(courses, progress);
  
  // Then: Should return Course1.L2 with null progress
  expect(result?.lesson.id, 'anatomy-l2');
  expect(result?.progress, null);
});
```

### Manual Testing Flow

1. **Fresh Start:**
   - ✅ Banner shows first lesson with "ابدأ الآن"
   - ✅ Click navigates to lesson player

2. **Watch 50% of Lesson 1:**
   - ✅ Banner shows Lesson 1 with "متابعة المشاهدة"
   - ✅ Progress bar shows 50%
   - ✅ Shows "متبقي X دقائق"

3. **Complete Lesson 1:**
   - ✅ Banner switches to Lesson 2 with "ابدأ الآن"
   - ✅ No progress bar shown
   - ✅ Shows total duration

4. **Watch 30% of Lesson 2:**
   - ✅ Banner shows Lesson 2 with "متابعة المشاهدة"
   - ✅ Progress bar shows 30%

5. **Complete All Lessons:**
   - ✅ Banner shows "Academic Kickoff" state

## Benefits

1. **Intelligent Resume:** Always shows the most relevant lesson for the student
2. **Cross-Course Support:** Works seamlessly across multiple courses
3. **Clear Visual Feedback:** Different badges and labels for different states
4. **Reduced Cognitive Load:** Student doesn't need to remember where they left off
5. **Encourages Completion:** Prominently displays unfinished lessons

## Future Enhancements

### Potential Improvements:
1. **Last Watched Timestamp:** Store and use `lastWatchedAt` for tie-breaking
2. **Course Priority:** Allow pinning certain courses to appear first
3. **Watch History:** Show "Recently Watched" section below the banner
4. **Smart Recommendations:** Use ML to suggest lessons based on student behavior
5. **Offline Sync:** Handle progress conflicts when coming back online

## Related Files

- `lib/features/player/domain/services/progress_service.dart` - Core business logic
- `lib/features/courses/presentation/screens/dashboard_screen.dart` - Banner integration
- `lib/features/courses/presentation/widgets/academic_kickoff_banner.dart` - Banner UI
- `lib/domain/entities/lesson_progress.dart` - Progress data model
- `assets/data/courses.json` - Course data structure

## Compliance with Spec

This implementation satisfies **Section 2.1** of `Thaheen_CURSOR_MASTER_SPEC.md`:

> If there is an unfinished lesson anywhere in the available progress data, show a prominent **Continue Watching** card at the top.
>
> Continue Watching should identify the relevant course and lesson and allow the user to resume it directly.

✅ **Completed:** The system now correctly identifies incomplete lessons across all courses and allows direct navigation to them.
