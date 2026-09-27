# Thaheen — Cursor Implementation Specification

> **Purpose:** This file is the single implementation reference for Cursor / an AI coding agent building the Thaheen Flutter screening task.
>
> **Rule:** Treat this document and the original screening task as the source of truth. Implement the required scope first. Do not spend time on optional features until every required feature is stable and tested.

---

## 0. Mission

Build a small, production-minded **offline Arabic-first LMS mobile app** for health-sciences students.

The app must demonstrate:

- clean Flutter architecture without over-engineering,
- reliable local state and persistence,
- correct sequential lesson unlocking,
- video playback with resume,
- automatic completion at 90%,
- correct RTL Arabic UX,
- loading / empty / error handling,
- meaningful unit tests,
- and a README that explains technical decisions and trade-offs honestly.

This is a **screening task**, not a full commercial LMS. Favor correctness, clarity, maintainability, and edge-case handling over feature volume.

### Time-box

Target implementation effort: **4–6 hours**.

Do not expand scope unnecessarily. When a feature is optional, build it only after all required behavior is complete.

---

# 1. Non-Negotiable Product Requirements

## 1.1 Offline only

The application must work without a backend and without API calls.

All course content must come from bundled local assets:

- `assets/data/courses.json`
- `assets/images/...`
- `assets/videos/...`

Do not introduce network repositories, HTTP clients, remote image URLs, Firebase, or any backend dependency.

---

## 1.2 Required bundled data

Create:

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

Requirements:

- exactly **2 courses** for the screening build,
- each course has **2 sections**,
- each section has **2–3 lessons**,
- use **2–3 short royalty-free MP4 files** under 10 MB each,
- it is acceptable for several lessons to reference the same bundled sample video if needed to stay within the time box,
- video file paths must resolve from Flutter assets.

### Suggested JSON shape

The schema may be changed if there is a clear reason, but keep content and progress separate.

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
            }
          ]
        }
      ]
    }
  ]
}
```

---

# 2. Product UX

## 2.1 Courses screen

Display a course list containing:

- course thumbnail,
- Arabic course title,
- instructor,
- total lesson count,
- progress percentage.

If there is an unfinished lesson anywhere in the available progress data, show a prominent **Continue Watching** card at the top.

Continue Watching should identify the relevant course and lesson and allow the user to resume it directly.

### Course progress formula

```text
completedLessons / totalLessons * 100
```

Rules:

- completed lesson = a lesson whose `completed == true`,
- round the displayed percentage to a whole number unless the design explicitly chooses another consistent rule,
- course with zero lessons must return `0%`, never divide by zero,
- in-progress lessons do not count as completed.

---

## 2.2 Course details

Show:

- course title and supporting information,
- all sections,
- all lessons under each section,
- lesson duration,
- current lesson status,
- lock state where applicable.

### Lesson status

Every lesson must resolve to exactly one of:

```text
Not Started
In Progress
Completed
```

Recommended Arabic labels:

```text
لم تبدأ
قيد المشاهدة
مكتملة
```

### Sequential unlock rule

Lessons are unlocked strictly in course order.

Flatten the course lessons across sections:

```dart
final lessons = course.sections
    .expand((section) => section.lessons)
    .toList();
```

Then:

```text
Lesson 1 -> unlocked
Lesson N -> unlocked only when Lesson N-1 is completed
```

The section boundary does **not** reset the sequence.

Example:

```text
Section 1
  L1 -> unlocked
  L2 -> locked until L1 completed

Section 2
  L3 -> locked until L2 completed
  L4 -> locked until L3 completed
```

### Locked interaction

Tapping a locked lesson must not navigate to the player.

Instead, show a friendly user-facing message, for example:

> أكمل الدرس السابق أولاً لفتح هذا الدرس.

The exact wording may differ, but the behavior must be clear and non-blocking.

---

# 3. Lesson Player

The player is a first-class feature and must be treated carefully because most state bugs will appear here.

## 3.1 Required controls

Provide:

- play,
- pause,
- seek bar,
- current position,
- total duration,
- playback speed selection,
- fullscreen / landscape mode,
- resume from stored position,
- completion at 90%,
- next lesson action.

### Playback speeds

Support exactly:

```text
1x
1.25x
1.5x
2x
```

Keep speed in local UI/player state. Persist it only if implementing the optional "remember speed" bonus.

---

## 3.2 Resume behavior

When reopening a lesson:

1. load the persisted progress record,
2. initialize the video controller,
3. wait for initialization to finish,
4. obtain the actual controller duration,
5. clamp the stored position to the valid duration range,
6. seek to the stored position,
7. update the UI.

Never seek before the controller is initialized.

If no position exists, start from zero.

If stored position is invalid or beyond the current duration, safely clamp it rather than crashing.

---

## 3.3 Completion rule

A lesson becomes completed automatically when playback reaches **90% of the actual video duration**.

Use runtime controller duration, not the `durationSec` value from JSON, for the completion threshold.

Conceptually:

```dart
bool isCompleted(Duration position, Duration duration) {
  if (duration <= Duration.zero) return false;
  return position >= duration * 0.9;
}
```

The implementation must avoid repeatedly writing the same completed state.

Once completed:

- mark it completed,
- persist completion,
- unlock the next lesson,
- update course progress,
- expose the Next Lesson action when a next lesson exists.

### Important scope decision

For this screening task, completion means **playback position reached 90% of the video duration**. It is not a unique-watch-ranges system. Do not build watch-history analytics or seek-proof logic.

---

## 3.4 Progress persistence frequency

Do **not** write to local storage on every video position update.

Use a lightweight strategy such as:

- save on pause,
- save on seek,
- save on completion,
- save periodically while playing (for example every ~5 seconds),
- save during appropriate lifecycle/dispose handling where safe.

The exact implementation can vary, but storage writes must be throttled/debounced sufficiently to avoid unnecessary I/O.

---

## 3.5 Video lifecycle

Keep the `VideoPlayerController` scoped to the lesson player.

Do not place the live video controller inside global app state.

Responsibilities:

- initialize,
- listen to playback updates,
- restore position,
- detect completion threshold,
- save progress,
- pause/dispose correctly,
- handle initialization errors,
- restore device orientation when leaving fullscreen.

Always dispose the controller.

---

# 4. Fullscreen / Landscape

The player must support fullscreen/landscape mode.

Expected behavior:

1. Enter fullscreen.
2. Allow landscape orientation.
3. Present the video using the available screen area.
4. Exit fullscreen.
5. Restore the previous supported orientation behavior.
6. Keep playback position and state intact.

Do not leave the application stuck in landscape after exiting fullscreen.

Prefer a small dedicated fullscreen/player presentation rather than mixing fullscreen state throughout unrelated screens.

---

# 5. Persistence

Use a local persistence package appropriate to the tiny data size.

### Preferred choice for this task

**SharedPreferences** is recommended because the persisted data is tiny and consists of simple values such as:

- lesson position,
- completion state,
- optionally last watched lesson.

A repository abstraction should hide the storage implementation from the domain/UI layers.

Do not introduce a heavier database only for architectural fashion.

Hive/Isar/sqflite are acceptable if there is a concrete reason and the README explains it.

---

# 6. Progress Data Model

Keep static course content separate from mutable learner progress.

### Course content

Loaded from JSON:

```text
Course
  Sections
    Lessons
```

### Learner progress

Stored locally, conceptually:

```text
LessonProgress
- courseId
- lessonId
- positionSeconds
- completed
```

Optional:

```text
lastWatchedCourseId
lastWatchedLessonId
playbackSpeed
```

Do not mutate the bundled JSON model to store user progress.

---

# 7. Recommended Architecture

Use a medium-weight architecture. The goal is clear separation, not ceremony.

Recommended structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── core/
│   ├── constants/
│   ├── error/
│   └── utils/
│
├── data/
│   ├── models/
│   │   ├── course_model.dart
│   │   ├── section_model.dart
│   │   ├── lesson_model.dart
│   │   └── lesson_progress_model.dart
│   ├── datasources/
│   │   ├── local_course_data_source.dart
│   │   └── progress_local_data_source.dart
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
│   ├── repositories/
│   │   ├── course_repository.dart
│   │   └── progress_repository.dart
│   └── services/
│       └── progress_service.dart
│
└── presentation/
    ├── courses/
    ├── course_details/
    └── lesson_player/
```

This structure is a recommendation, not a reason to create unnecessary abstractions. A simpler equivalent structure is acceptable if the same separation and testability are preserved.

---

# 8. State Management

Choose **one** approach and use it consistently.

Acceptable:

- Riverpod,
- Bloc/Cubit,
- Provider.

Preferred practical choice: **Riverpod** if already comfortable with it; otherwise Cubit is equally acceptable.

Do not mix multiple state-management styles without a strong reason.

Keep these concerns separate:

- content loading,
- learner progress state,
- player UI/controller lifecycle.

The video controller itself should remain a presentation/player concern.

---

# 9. Navigation

Use `go_router` or Navigator 2.0.

Recommended route concepts:

```text
/courses
/courses/:courseId
/courses/:courseId/lessons/:lessonId
```

Route parameters should identify content; do not pass large mutable objects through navigation unless there is a compelling reason.

The player must validate the requested lesson against unlock rules before allowing playback.

---

# 10. Arabic-First / RTL Requirements

Arabic is the primary language.

The app must use native Flutter RTL behavior rather than visually hacking individual screens.

Requirements:

- global RTL direction for Arabic mode,
- Arabic text hierarchy that is easy to scan,
- correct horizontal alignment,
- correct padding and spacing in RTL,
- directional icons must make semantic sense,
- progress indicators and seek bar must communicate direction correctly,
- back/navigation affordances must remain understandable,
- do not manually mirror every widget with transforms.

Use localization-ready structure even if English is not implemented.

### Optional language switch

Arabic/English is a bonus only. Do not sacrifice required features to implement it.

---

# 11. Design Direction

The application is branded:

**ذهين | Thaheen**

Use the approved Thaheen visual direction from the design reference/design workflow.

Design priorities:

1. Arabic-first usability.
2. Premium but restrained educational feel.
3. Strong information hierarchy.
4. Clear learning progress.
5. Calm video-learning experience.
6. Accessible touch targets.
7. Consistent cards, spacing, typography, and iconography.

Do not copy the website layout literally. Translate the brand into a student-focused LMS experience.

---

# 12. Required Screens

The minimum complete product should contain:

## Screen A — Courses

Must include:

- app header,
- Continue Watching card when applicable,
- course list,
- thumbnails,
- instructor,
- lesson count,
- progress percentage,
- loading state,
- empty state,
- error state.

## Screen B — Course Details

Must include:

- course summary,
- section grouping,
- lessons,
- duration,
- lesson status,
- lock affordance,
- friendly locked message,
- loading/error/empty handling where relevant.

## Screen C — Lesson Player

Must include:

- video,
- play/pause,
- position,
- duration,
- progress/seek control,
- speed menu,
- fullscreen,
- resume,
- completion at 90%,
- Next Lesson.

---

# 13. Loading / Empty / Error States

The app must never show an avoidable red error screen for expected failures.

## Loading

Provide a clear loading experience for:

- course JSON loading,
- initial course data transformation,
- progress restore where relevant,
- video initialization.

## Empty

Example: course has zero lessons.

The UI must communicate:

- there is no content to display,
- the app is still functioning,
- the user can navigate safely away.

Never assume at least one section or lesson exists.

## Error

At minimum handle:

- missing/corrupt JSON,
- malformed course data,
- missing thumbnail,
- missing/corrupt video asset,
- video initialization failure,
- persistence read/write failure where reasonable.

Show a user-friendly message and provide a safe recovery/navigation action where appropriate.

Never crash because an asset is unavailable.

---

# 14. Business Logic Rules

Business logic must be centralized and unit-testable.

Do not duplicate unlock/progress formulas across multiple widgets.

A dedicated service/helper should own rules such as:

```text
isLessonUnlocked(course, lessonId, progress)
getLessonStatus(lessonId, progress)
calculateCourseProgress(course, progress)
shouldCompleteLesson(position, duration)
getNextLesson(course, currentLessonId, progress)
findContinueWatching(...)
```

---

## 14.1 Unlock rule pseudo-code

```dart
bool isLessonUnlocked(
  List<Lesson> lessons,
  int index,
  Set<String> completedLessonIds,
) {
  if (index == 0) return true;
  return completedLessonIds.contains(lessons[index - 1].id);
}
```

The actual implementation may use IDs/maps instead of indexes, but the behavior must be identical.

---

## 14.2 Status rule

Recommended resolution:

```text
completed == true
    -> Completed

otherwise position > 0
    -> In Progress

otherwise
    -> Not Started
```

A tiny near-zero threshold may be used if needed to avoid floating-point noise, but keep the rule simple and documented.

---

## 14.3 Continue Watching rule

A lesson qualifies as unfinished when:

```text
completed == false
AND position > 0
```

Preferred selection strategy:

1. use an explicitly persisted last-watched lesson if implemented,
2. otherwise choose the most recently updated unfinished lesson,
3. otherwise show no Continue Watching card.

Do not show completed lessons as Continue Watching.

---

## 14.4 Next lesson rule

After completion:

- find the next lesson in the flattened course sequence,
- if it exists, it becomes unlocked,
- Next Lesson should navigate to it,
- if there is no next lesson, show a completion state instead of navigating to an invalid route.

---

# 15. Tests

Minimum: **3 unit tests**.

Recommended test suite:

### Test 1 — 90% completion

Cases:

```text
89% -> false
90% -> true
91% -> true
```

### Test 2 — sequential unlock

Cases:

```text
L1 -> unlocked
L2 -> locked before L1 completion
L2 -> unlocked after L1 completion
L3 -> still locked until L2 completion
```

### Test 3 — course progress

Cases:

```text
0 / 4 -> 0%
1 / 4 -> 25%
2 / 4 -> 50%
4 / 4 -> 100%
0 lessons -> 0%
```

Additional tests are encouraged when cheap:

- resume position clamping,
- status calculation,
- next lesson resolution,
- Continue Watching selection,
- empty course handling.

Tests must test business logic, not just constructors or widget existence.

---

# 16. Project Dependencies

Keep dependencies minimal.

Expected categories:

- Flutter SDK,
- state management package,
- `video_player`,
- routing package if using one,
- local persistence package,
- testing utilities only where useful.

Avoid packages that exist only to save a few lines unless they improve reliability meaningfully.

---

# 17. Implementation Sequence

Cursor should implement in this order unless a concrete dependency requires another order.

## Step 1 — Project setup

Verify:

- Flutter stable,
- null safety,
- clean build,
- Android/iOS configuration compatible with selected packages.

## Step 2 — Assets and JSON

Create:

- course JSON,
- thumbnails,
- MP4 assets,
- asset declarations in `pubspec.yaml`.

Validate that all referenced files exist.

## Step 3 — Models / entities

Implement course, section, lesson, and progress representations.

Keep parsing resilient to missing optional fields where practical.

## Step 4 — Repositories / data sources

Implement:

- local course loader,
- local progress storage.

No network layer.

## Step 5 — Progress domain service

Implement and test:

- completion rule,
- unlock rule,
- course progress,
- lesson status,
- next lesson,
- Continue Watching.

Do this before building many UI details.

## Step 6 — Courses screen

Build the main list and progress state.

## Step 7 — Course details

Build sections, lesson statuses, locks, and locked feedback.

## Step 8 — Player

Implement:

- initialization,
- restore position,
- play/pause,
- seek,
- speed,
- periodic persistence,
- 90% completion.

## Step 9 — Next Lesson / unlocking

Wire completion to the course state and next-lesson behavior.

## Step 10 — Fullscreen

Add landscape presentation and orientation restoration.

## Step 11 — Error / empty / loading states

Test failure paths explicitly.

## Step 12 — RTL polish

Verify actual Arabic layout, directional behavior, icons, and seek bar.

## Step 13 — Tests

Run all unit tests and fix failures before adding bonuses.

## Step 14 — README / documentation

Document:

- run instructions,
- architecture,
- state management,
- persistence choice,
- business rules,
- trade-offs,
- known issues,
- time spent,
- what would be improved with more time.

## Step 15 — Final QA

Run the acceptance checklist in Section 19.

---

# 18. Code Quality Rules for Cursor

Follow these rules while implementing:

### Rule A — Keep business logic out of widgets

Widgets should render state and send user actions. Unlock/progress/completion calculations belong in domain logic.

### Rule B — Avoid magic strings and numbers

Centralize important constants such as:

```text
completionThreshold = 0.90
supportedPlaybackSpeeds = [1.0, 1.25, 1.5, 2.0]
```

### Rule C — Defensive parsing

Asset data is local, but malformed data must not create a red screen.

### Rule D — Null safety

Do not use `!` blindly for values that may legitimately be absent.

### Rule E — Async lifecycle safety

After awaits, verify that a widget/controller is still mounted/alive before updating UI state where applicable.

### Rule F — Dispose resources

Dispose:

- video controllers,
- text controllers,
- stream subscriptions,
- timers/listeners,
- other owned resources.

### Rule G — Do not persist every frame

Throttle position writes.

### Rule H — Keep scope honest

Do not add authentication, payments, backend, chat, analytics, notifications, or unrelated LMS features.

### Rule I — Avoid premature abstraction

Do not create generic frameworks for one or two screens.

### Rule J — Accessibility basics

Use readable contrast, reasonable touch targets, and semantic labels where useful.

---

# 19. Mandatory End-to-End Acceptance Scenario

This scenario is the most important manual QA flow.

Assume Course A contains:

```text
L1 -> L2 -> L3 -> L4
```

### Scenario

1. Launch the app.
2. Courses screen loads successfully.
3. Course A is visible with 0% progress.
4. Open Course A.
5. Verify L1 is unlocked.
6. Verify L2, L3, and L4 are locked.
7. Open L1.
8. Verify video initializes.
9. Verify starting position is 0 for a fresh lesson.
10. Play the lesson.
11. Stop around 30%.
12. Leave the lesson/app.
13. Reopen the app.
14. Open the same lesson.
15. Verify the stored position is restored approximately where it was left.
16. Continue playback until at least 90%.
17. Verify the lesson becomes completed automatically.
18. Return to course details.
19. Verify L1 is completed.
20. Verify L2 is now unlocked.
21. Verify L3 remains locked.
22. Verify course progress increased accordingly.
23. Return to Courses.
24. Verify the progress percentage is updated.
25. Verify Continue Watching points to the next unfinished lesson when appropriate.
26. Kill/restart the app.
27. Verify completion and progress remain persisted.
28. Open L2.
29. Verify playback and persistence work again.
30. Test fullscreen and confirm portrait/orientation is restored after exit.

If this scenario fails, the app is not ready for submission.

---

# 20. Edge-Case QA Matrix

Before submission, manually verify:

| Case | Expected behavior |
|---|---|
| Course has 0 lessons | Empty state, no crash |
| Section has 0 lessons | Empty/appropriate section state, no crash |
| JSON fails to load | Friendly error state |
| Thumbnail missing | Safe placeholder/error presentation |
| Video file missing | Friendly player error, no red screen |
| Video initialization fails | Recovery/error UI |
| Stored position > duration | Clamp safely |
| Stored position < 0 | Treat as 0 / sanitize |
| Duration is zero | Never complete automatically |
| Exactly 90% | Lesson completes |
| 89% | Lesson not completed |
| First lesson | Always unlocked |
| Previous lesson incomplete | Next lesson locked |
| Previous lesson completed | Next lesson unlocked |
| Final lesson completed | No invalid next route |
| App restarted | Progress survives |
| Course fully complete | Progress = 100% |
| Course has no completed lessons | Progress = 0% |
| Arabic RTL | Layout and direction remain correct |
| Fullscreen exit | Orientation restored |

---

# 21. Final Acceptance Checklist

Cursor should not consider the task complete until all items below are true.

## Content

- [ ] 2 courses exist.
- [ ] Each course has 2 sections.
- [ ] Each section has 2–3 lessons.
- [ ] All referenced assets exist.
- [ ] MP4 files are bundled locally and under the required size.

## Courses

- [ ] Course list works.
- [ ] Thumbnail shown.
- [ ] Instructor shown.
- [ ] Lesson count shown.
- [ ] Progress percentage shown.
- [ ] Continue Watching appears only when appropriate.

## Course details

- [ ] Sections render correctly.
- [ ] Lessons render with duration.
- [ ] Not Started state works.
- [ ] In Progress state works.
- [ ] Completed state works.
- [ ] Sequential unlock works across section boundaries.
- [ ] Locked lesson shows friendly feedback.

## Player

- [ ] Play/pause works.
- [ ] Seek works.
- [ ] Current time works.
- [ ] Duration works.
- [ ] 1x works.
- [ ] 1.25x works.
- [ ] 1.5x works.
- [ ] 2x works.
- [ ] Resume works.
- [ ] 90% completion works.
- [ ] Next lesson respects unlock.
- [ ] Final lesson does not navigate to nowhere.
- [ ] Fullscreen works.
- [ ] Orientation is restored.

## Persistence

- [ ] Position survives restart.
- [ ] Completed lessons survive restart.
- [ ] Course progress survives restart.

## UX

- [ ] Arabic-first.
- [ ] RTL is correct.
- [ ] Directional icons make sense.
- [ ] Seek bar behavior is correct in RTL.
- [ ] Loading states exist.
- [ ] Empty states exist.
- [ ] Error states exist.
- [ ] No avoidable red screens.

## Tests

- [ ] 90% completion test.
- [ ] Unlock test.
- [ ] Progress percentage test.
- [ ] All tests pass.

## Documentation

- [ ] README explains how to run.
- [ ] README explains architecture.
- [ ] README explains state management.
- [ ] README explains persistence choice.
- [ ] README explains trade-offs.
- [ ] README documents known issues.
- [ ] README states approximate time spent.
- [ ] README explains what would be done with more time.

---

# 22. Optional Bonus Features

Only implement these after every mandatory acceptance item passes.

Priority order for optional work:

1. Remember playback speed.
2. Dark mode.
3. Search courses.
4. Per-lesson notes.
5. Widget tests.
6. Arabic/English switch.

Do not allow bonus work to destabilize the required product.

---

# 23. Recommended README Content

The project's final README should contain:

## Overview

A short description of the offline Thaheen LMS task.

## How to run

Example:

```bash
flutter pub get
flutter test
flutter run
```

Also mention any platform-specific setup required by `video_player`.

## Architecture

Explain the chosen data/domain/UI separation.

## State management

Name the chosen package and explain why it fits the scope.

## Persistence

Explain:

- what is stored,
- why the selected local store was chosen,
- how write frequency is controlled.

## Business rules

Explain:

- 90% completion,
- sequential unlock,
- course progress calculation,
- Continue Watching behavior.

## Trade-offs

Be explicit about what was intentionally simplified.

## Known issues

List real known issues only.

## Time spent

Give an honest approximate total.

## More time

Describe what would be improved with additional time.

---

# 24. Definition of Done

The implementation is DONE only when:

```text
Build succeeds
+ Tests pass
+ Offline data loads
+ Courses screen works
+ Course details work
+ Sequential unlock works
+ Player works
+ Resume works
+ 90% completion works
+ Persistence survives restart
+ Fullscreen works
+ RTL is correct
+ Loading/empty/error states work
+ Acceptance scenario passes
+ README is complete
```

Anything outside this list is secondary.

---

# 25. Cursor Working Protocol

When working from this file, follow this protocol:

### Before coding

1. Inspect the existing Flutter project.
2. Read `pubspec.yaml`.
3. Inspect the current `lib/`, `assets/`, and test directories.
4. Reuse working code where sensible.
5. Do not rewrite the whole project without a reason.
6. Identify missing pieces against this document.

### During coding

1. Implement one logical slice at a time.
2. Keep business rules testable.
3. Run formatter after meaningful changes.
4. Run analyzer/tests frequently.
5. Fix root causes rather than masking errors.
6. Avoid introducing unnecessary dependencies.

### After coding

Run at minimum:

```bash
flutter analyze
flutter test
flutter run
```

Then manually execute the end-to-end acceptance scenario from Section 19.

### If something is ambiguous

Prefer the interpretation that:

1. matches the explicit screening task,
2. minimizes scope,
3. preserves user-facing correctness,
4. is easy to explain in the README.

Do not invent product requirements that are not present here.

---

# 26. Final Guidance to the AI Coding Agent

You are not being asked to build a large LMS.

You are being asked to demonstrate **Senior Flutter engineering judgment** in a small offline product.

Optimize for:

```text
Correctness
> Reliability
> Maintainability
> UX clarity
> Testability
> Visual polish
> Optional features
```

The strongest submission is not the one with the most features.

It is the one where the required flow is complete, predictable, persisted, testable, Arabic-friendly, and easy for another developer to understand.

**Do not declare the task complete until the acceptance checklist and end-to-end scenario pass.**
