# Thaheen — Offline Mini LMS

Thaheen is a small, fully offline mini Learning Management System (LMS) built with Flutter for a medical-education screening task. It demonstrates a correct, maintainable implementation of a sequential video-based learning flow: learners browse courses, watch locally-bundled video lessons, have their playback position and completion state persisted across restarts, and unlock the next lesson only after completing the previous one at the 90% threshold. The application is Arabic-first with full RTL support, and additionally offers English localization, a dark mode, and search functionality.

## Features

- Offline course browsing from a bundled JSON data source (2 courses, 4 sections, 7 lessons)
- Course progress tracking (completed lessons / total lessons)
- Continue Watching banner that surfaces the first in-progress or next-unlocked lesson
- Sequential lesson unlocking — lessons unlock strictly in order, across section boundaries
- Local video playback via `video_player` (asset-based, no network)
- Resume playback from the last saved position
- Seek controls (scrubbable progress bar, ±10s shortcuts)
- Playback speed selection (1.0x, 1.25x, 1.5x, 2.0x)
- Fullscreen / landscape mode with immersive UI
- Automatic lesson completion when `position >= duration * 0.90`
- Next-lesson auto-navigation after completion (with Snackbar feedback)
- Arabic-first RTL interface with Cairo typography
- Arabic / English language switching with per-language font family (Cairo / Inter)
- Light / Dark / System theme modes
- Local course search with debouncing, Arabic diacritic/alef normalization, and bilingual (Ar + En) matching
- Persistent local progress (playback position, completion, last-watched lesson) via SharedPreferences
- Loading / empty / error states across all primary screens
- Bottom navigation with 3 tabs: Dashboard (0), Courses (1), Profile (2)
- Silent progress refresh when returning from the player

## Tech Stack

- **Flutter / Dart** — SDK constraint: `^3.12.1` (null-safe)
- **State management** — `flutter_bloc` (`Cubit`-based: `CoursesCubit`, `CourseDetailsCubit`, `LessonPlayerCubit`, `SettingsCubit`)
- **Video playback** — `video_player` (bundled asset videos only)
- **Persistence** — `shared_preferences` (via a `StorageService` abstraction)
- **Navigation** — `go_router` (declarative routing with `/:courseId/lessons/:lessonId`)
- **Localization** — Custom in-app dictionary via `AppStrings.tr` / `AppStrings.trArgs`; `flutter_localizations` delegates for RTL/cupertino/material
- **Testing** — `flutter_test` (unit tests for pure domain services + Cubit logic)

## Architecture

The codebase uses a lightweight feature-first layout with an explicit domain/data/presentation split within each feature. It is intentionally not "full Clean Architecture" — there are no use-case classes — but business rules are isolated in pure Dart domain services, repositories mediate between data sources and the UI, and Cubits translate repository results into typed view-state.

```
lib/
├── app/
│   ├── app.dart              # Root: MultiRepositoryProvider + SettingsCubit + MaterialApp.router
│   ├── router.dart           # Exports appRouter (go_router)
│   └── theme/                # AppTheme, AppThemeMode enum
├── core/
│   ├── localization/         # AppLanguage enum, AppStrings dictionary
│   ├── routing/              # GoRouter configuration
│   ├── storage/              # StorageService abstraction + SharedPreferences impl
│   └── widgets/              # AppCustomText, GradientScaffold, ThaheenAppBar
├── domain/
│   └── entities/             # Course, Lesson, Section, LessonProgress, LessonStatus
└── features/
    ├── courses/
    │   ├── data/
    │   │   ├── datasources/  # LocalCourseDataSource (rootBundle → courses.json)
    │   │   ├── models/       # CourseModel / SectionModel / LessonModel (fromJson)
    │   │   └── repositories/ # CourseRepositoryImpl
    │   ├── domain/
    │   │   └── repositories/ # CourseRepository abstract
    │   └── presentation/
    │       ├── cubit/        # CoursesCubit, CourseDetailsCubit
    │       ├── screens/      # CoursesScreen, DashboardScreen, MyCoursesScreen, CourseDetailsScreen
    │       └── widgets/      # ~20 widgets (cards, banners, tabs, shimmer, sections)
    ├── player/
    │   ├── data/
    │   │   ├── datasources/  # ProgressLocalDataSourceImpl (SharedPreferences JSON map)
    │   │   ├── models/       # LessonProgressModel
    │   │   └── repositories/ # ProgressRepositoryImpl
    │   ├── domain/
    │   │   ├── repositories/ # ProgressRepository abstract
    │   │   └── services/     # ProgressService, ProgressStreamController
    │   └── presentation/
    │       ├── cubit/        # LessonPlayerCubit
    │       ├── screens/      # LessonPlayerScreen
    │       └── widgets/      # VideoPlayerSurface, CoursePlanSection, LessonInfoCard, …
    └── profile/
        ├── data/repositories/# SettingsRepositoryImpl
        ├── domain/repositories/SettingsRepository abstract
        └── presentation/
            ├── cubit/        # SettingsCubit (theme + language)
            ├── screens/      # ProfileScreen
            └── widgets/      # SettingsPreferencesSheet, ProfileSettingsSection
```

Dependencies are composed at the root in `ThaheenApp` using `RepositoryProvider` and `BlocProvider`. Repositories and services are constructed from the `SharedPreferences` instance obtained in `main()` so there is no ad-hoc global state lookup inside features.

## State Management

State is managed with `Cubit` (from `flutter_bloc`). Each screen-scoped Cubit depends on repositories and services injected through its constructor:

| Cubit | Responsibility |
|---|---|
| `CoursesCubit` | Loads the course catalog + all progress; provides search (debounced, normalized) and reload |
| `CourseDetailsCubit` | Loads a single course and computes progress ratio, active/continue lesson, total hours |
| `LessonPlayerCubit` | Loads a lesson + resume position, coordinates the `ProgressStreamController`, fires 90% completion, resolves next lesson |
| `SettingsCubit` | Loads/persists `AppThemeMode` and `AppLanguage`, reacts to platform locale |

Business rules live in pure Dart classes — `ProgressService` and `ProgressStreamController` — and are fully unit-testable without any Flutter runtime dependency. The Cubits simply call those services and emit state; the UI rebuilds via `BlocBuilder`/`BlocConsumer`.

## Course & Lesson Progress

All rules below are implemented in `ProgressService` and covered by unit tests.

### Lesson Completion

A lesson is marked completed when playback position reaches 90% of the video's actual runtime (as reported by the initialized `VideoPlayerController`):

```
completed = position >= duration * 0.90
```

If `duration <= Duration.zero`, completion is always `false` (prevents a zero-duration or uninitialized video from being auto-completed).

### Sequential Unlocking

Lessons are flattened across sections into a single ordered list.

- The first lesson is **always** unlocked.
- For lesson N (index > 0): lesson N is unlocked **iff** lesson N-1 has `completed == true`.
- The rule continues across section boundaries — the last lesson of Section 1 being completed unlocks the first lesson of Section 2.
- Unknown lesson IDs resolve to "locked" (`false`).

### Course Progress

Course-wide progress is the ratio of completed lessons to total lessons in the flattened list:

```
progress = (completedLessonIds ∩ course.lessonIds).length / course.totalLessons
```

An empty course (0 lessons) returns `0.0` rather than dividing by zero.

### Continue Watching

Resolved by `ProgressService.findNextIncompleteLesson` in two priority passes across all courses:

1. **First pass**: the first lesson with `position > 0 AND completed == false` (the user had started and not yet finished it).
2. **Second pass**: if nothing in progress, the first unlocked lesson with no progress at all.

This tuple `(course, lesson, progress?)` is used by the dashboard's `AcademicKickoffBanner`.

## Persistence

Progress is persisted locally using **SharedPreferences**, wrapped behind a `StorageService` interface with a `SharedPreferencesStorageService` implementation.

### What is stored

- **Lesson progress map** — key `LESSON_PROGRESS`, a JSON-encoded map of `lessonId → {lessonId, position (sec), completed (bool)}`.
- **Last watched lesson** — key `LAST_WATCHED_LESSON`, storing the most recently opened lesson ID.
- **App settings** — theme mode and language preference (stored separately by `SettingsRepositoryImpl`).

### Data survival and defensive handling

- All data is written asynchronously during playback (debounced) and synchronously on pause, seek, and screen dispose. The `ProgressStreamController` also performs a final save on `dispose()` and on the Cubit's `close()`.
- On read, malformed JSON or an unexpected type is silently caught and falls back to an empty progress map, so corrupt storage cannot crash the app.
- On write, negative playback positions are clamped to 0 before serialization.

### Why SharedPreferences

SharedPreferences was chosen because the application only needs lightweight local key-value persistence for a small amount of playback/progress state: lesson IDs, integer positions in seconds, and boolean completion flags. A local database (Hive/Isar/SQLite) would add unnecessary complexity for the scope of this screening task; SharedPreferences integrates without native setup, is sufficient for the dataset size, and is well-understood by any reviewer.

## Video Playback

The player surface uses the official `video_player` package with **bundled asset videos** only — there is no backend, no streaming, and no network dependency at runtime.

### Playback lifecycle

1. Opening a lesson → `LessonPlayerCubit.loadLesson` resolves the course + lesson + saved position.
2. `VideoPlayerController.asset(lesson.video)` is initialized.
3. The saved position is clamped to `[Duration.zero, actualDuration]` (in case the stored position is invalid/out-of-range) and the controller is `seekTo`'d.
4. Playback starts automatically and a listener on `VideoPlayerController` forwards every position tick to `LessonPlayerCubit.onPositionChanged`.
5. On every tick the `ProgressStreamController` debounces saves (3s interval, ≥2s change threshold), and the Cubit checks the 90% completion rule exactly once per session (`_completionSaved` guard).
6. On pause, seek, pop, or dispose, progress is flushed immediately via `saveNow()`.

### Controls

- HUD-style overlay with tap-to-toggle visibility, gradient scrim for contrast
- Center controls: rewind 10s, play/pause, forward 10s
- Bottom: scrubbable `VideoProgressIndicator`, current-time / duration readout, speed chip
- Top: lesson/instructor badge, save-in-progress indicator, fullscreen toggle
- Speed chip exposes 1.0x, 1.25x, 1.5x, 2.0x (writes to controller via `setPlaybackSpeed`)
- Fullscreen: locks to landscape (`landscapeLeft`/`landscapeRight`), enables `SystemUiMode.immersiveSticky`, aspect ratio adapts to screen; exit restores `portraitUp` and `edgeToEdge`

### Error handling

- If `VideoPlayerController.initialize()` throws, the cubit emits a `LessonPlayerError` with a localized message and the screen renders a retry button that calls `loadLesson` again.
- A controller that isn't initialized yet is shown with a centered `CircularProgressIndicator`, never a blank area or a red screen.

## Localization & RTL

### Arabic-first

- Default locale is `AppLanguage.arabic` (`Locale('ar', 'SA')`) with `Cairo` as the default font family.
- `MaterialApp.router` registers `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, and `GlobalCupertinoLocalizations` so dates, dialogs, and widgets behave correctly in RTL.
- `Directionality` is driven by the active locale; all screens respect it via `EdgeInsetsDirectional`, `AlignmentDirectional`, and directional-aware `Row`/`Stack` children where relevant.

### Localization mechanism

All static UI strings go through `AppCustomText` which wraps `AppStrings.tr(key, langCode)`. Dynamic strings with placeholders (counters, percentages) use `AppStrings.trArgs` with a plain `Text` widget. Course/lesson titles use the bilingual model fields (`title` vs `titleEn`) via `localizedTitle(langCode)`. The dictionary is a hard-coded `Map<String, String>` in `AppStrings._ar` / `AppStrings._en`.

### Supported languages

- Arabic (`ar_SA`) — Cairo font, RTL — default.
- English (`en_US`) — Inter font, LTR.

### Known limitation

- Locale files under `assets/translations/` exist but are not wired into an ARB-based `gen_l10n` flow; the active dictionary is the in-memory `AppStrings` map. This is acceptable for the screening task (all ~200 keys are present for both languages) but would be replaced with `.arb`-generated localizations in a production app.
- Some ad-hoc strings in the lesson-player success Snackbars and error state are hard-coded Arabic rather than sourced through `AppStrings`. These do not break switching; they simply remain in Arabic when the UI is set to English. This is a genuine (minor) limitation.

## Error & Edge Case Handling

The following cases are explicitly handled:

- **Missing / malformed `courses.json`** — parse errors in the local data source propagate to `CoursesError` state, rendered with a retry button.
- **Unknown `courseId` route** — `CourseDetailsCubit` emits `CourseDetailsError('course_not_found')` with retry CTA.
- **Unknown `lessonId` in existing course** — `LessonPlayerCubit` emits `LessonPlayerError('لم يتم العثور على الدرس المطلوب.')`.
- **Missing video asset / video init failure** — try/catch around `initialize()` emits `LessonPlayerError` with retry.
- **Invalid saved progress** — corrupt JSON in `LESSON_PROGRESS` falls back to empty progress map; missing keys return `null` progress, which defaults to `position: 0, completed: false`.
- **Zero-duration video** — `shouldCompleteLesson` returns `false` when duration is zero; player still renders (no division-by-zero anywhere in the progress math).
- **Empty search** — 0 or 1 characters returns the full course list; 2+ chars triggers a 400ms debounce with a shimmer loading state.
- **No search results** — a dedicated "no results" widget is rendered instead of an empty list.
- **Empty course (0 lessons)** — `calculateCourseProgress` returns `0.0`; UI uses `orElse` fallbacks to avoid `.first` on empty.
- **Last lesson / no next lesson** — `getNextLesson` returns `null`; completion shows a "course finished" Snackbar instead of navigating.
- **Saved position exceeds actual video duration** — clamped to `min(saved, actualDuration)` before seek.
- **Loading states** — shimmer (`CourseCardShimmer`, `CourseDetailsLoadingView`) and `CircularProgressIndicator` fallbacks on every screen's initial/loading state.
- **Fullscreen back-press** — `PopScope` with `canPop: !isFullscreen` so that Android back first exits fullscreen before popping the route.
- **Unsaved progress on dispose** — `ProgressStreamController.dispose()` does a final flush; Cubit's `close()` disposes the controller; the `_saveAndDispose` in the screen state saves the current position before removing the controller listener.

## Testing

Unit tests exist under `test/` (the flutter cache on this machine has a permissions issue that prevents actually running the binary, so tests were verified against the source manually). Below is the actual test inventory.

### `test/features/player/domain/services/progress_service_test.dart`
Covers the four critical business rule groups:
- **90% completion** — 89% → false, 90% → true, 91% → true, zero-duration guard.
- **Sequential unlock** — first lesson unlocked, L2 locked before L1 completion, L2 unlocked after L1 completion, L3 still locked until L2 completes (crosses section boundary).
- **Course progress** — 0/4, 1/4, 2/4, 4/4, and zero-lesson course.
- **Status / next-lesson / continue-watching** — `LessonStatus` resolution (NotStarted / InProgress / Completed), `getNextLesson` (including final-lesson `null`), and `findContinueWatching` picks the first in-progress lesson.

### `test/progress_service_test.dart`
Duplicate but complementary coverage for the alias-based API on `ProgressService` (`isCompleted`, `isUnlocked`, `calculateProgress`).

### `test/courses_search_test.dart`
Thorough search behavior on `CoursesCubit` with a mock repository:
- 0 chars → all courses; 1 char → all courses (no filter); 2+ chars → debounced filter.
- Arabic exact & partial title match.
- Arabic alef normalization (`أمراض` / `إبراهيم` matched by plain `ا` input).
- Arabic instructor match.
- English case-insensitive title & instructor match.
- Whitespace-only query, trimmed query, special-characters query.
- Debounce timing (rapid input cancels prior timers, 400ms rule).
- Clear search restores the list immediately and cancels pending debounce.
- State preservation (original list not mutated; multiple searches + clear).

### `test/features/player/domain/services/progress_stream_controller_test.dart`
Tests the debouncing + persistence primitive:
- Initial position state.
- Stream emission.
- Debounced save after quiet period.
- Minimum change threshold (≥2 seconds required).
- `saveNow()` force save + idempotency.
- Concurrent saves are blocked (`saveNow` returns false while saving).
- `hasUnsavedChanges` transitions.
- `resetSavedPosition`.
- `dispose` saves pending changes and blocks further operations.
- Save errors are caught and do not mark the position saved (retry next cycle).
- Rapid updates save only the final position.
- `ProgressStreamControllerWithStats` + `ProgressStreamStats` counters.

### `test/features/profile/presentation/cubit/settings_cubit_test.dart`
- Initial state has `isLoading == true`.
- `loadSettings` resolves theme + language and sets `isLoading = false`.
- `updateThemeMode` and `updateLanguage` both emit new state AND write to the repository.

### `test/features/courses/presentation/screens/courses_screen_test.dart`
Widget-test scaffolding with mocks for `CoursesScreen` (bottom nav, app bar, three tabs).

**Test command:**
```bash
flutter test
```

## Getting Started

### Requirements

- Flutter SDK that satisfies `sdk: ^3.12.1` (Dart 3.x with null safety).
- Any supported target (Android emulator, iOS simulator, or desktop).
- No network access is required after the initial `flutter pub get` because all data and media are bundled.

### Installation

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Test

```bash
flutter test
```

### Analyze

```bash
flutter analyze
```

## Project Structure

```
lib/
├── app/               App root, router, theme
├── core/              Shared localization, routing, storage, reusable widgets
├── domain/            Pure Dart entities (zero Flutter dependency)
└── features/
    ├── courses/       Catalog, details, dashboard — JSON data source
    ├── player/        Video player, progress persistence, progress domain services
    └── profile/       Settings (theme mode + language), profile screen
```

Each feature contains a `data` layer (models, data sources, repository impls), a `domain` layer (abstract repositories, services), and a `presentation` layer (Cubits + screens + widgets). Shared entities live under the top-level `domain/entities/` directory so they can be referenced by any feature without import cycles.

Assets live under `assets/data/courses.json`, `assets/images/`, `assets/videos/`, and `assets/fonts/` (Cairo + Inter), all declared in `pubspec.yaml`.

## Design Decisions & Trade-offs

- **Local JSON instead of a remote API.** The screening task requires 100% offline behavior; a bundled JSON file is deterministic, reproducible, and removes any flakiness from network or backend availability during a reviewer's evaluation.
- **Local asset videos instead of remote URLs.** Same reasoning as above — every evaluator gets the same experience, and there is no video player buffering/network-error surface area to worry about.
- **SharedPreferences instead of a database.** The data is small and strictly key-value: lessonId → (position, completed), plus a few scalar settings. A persistence library adds native build complexity and schema migration concerns that are not warranted by the dataset.
- **Cubit instead of Riverpod/Provider.** The original spec allowed either; `flutter_bloc` was chosen because it makes state events (loading/loaded/error) explicit via sealed state classes and gives a natural home for per-screen orchestration between repositories + domain services.
- **Centralized business rules in `ProgressService`.** All completion / unlock / progress / continue-watching math is in one pure-Dart class. This means the same logic is used uniformly by `CoursesCubit`, `CourseDetailsCubit`, and `LessonPlayerCubit` — there is no duplicated condition in any widget.
- **Intentionally lightweight architecture.** There is no explicit `UseCase` layer because each Cubit only needs one or two repository/service calls; adding intermediates would have been boilerplate without structural benefit. Repositories + services + Cubits already provide a clean, testable separation.
- **Position-based completion (not unique watch-time).** The spec requires "90% of duration", and the simplest correct interpretation is "current playback position ≥ 90%". A more sophisticated implementation (unique intervals, guard against scrubbing) is explicitly out of scope for this time-boxed task and is called out in "Known Limitations".

## Known Limitations

- **Bundled asset videos only.** The application has no remote streaming or CDN support; scaling content requires shipping new APK/IPA builds with additional MP4s.
- **Limited dataset.** `courses.json` ships with 2 courses, 4 sections, and 7 lessons. The architecture supports more — the data source is just `json.decode` of the file — but the demo content is small.
- **No backend / multi-device synchronization.** Progress is strictly local to one device installation. Clearing app data or reinstalling loses all progress.
- **Completion is position-based.** A user who scrubs directly to the 90% mark will have the lesson marked completed. This is the specified behavior (and matches the tests), but in a real LMS you would likely require cumulative unique watch-time.
- **Several Snackbar / error strings in the lesson player screen are hard-coded Arabic** rather than going through `AppStrings`. The UI does not break when switched to English, but those specific messages will not translate.
- **Locale infrastructure is dictionary-based (hard-coded maps), not `.arb`/`gen_l10n`.** Works for the current set of strings, but lacks the plural/gender/date formatting support of a proper i18n pipeline.
- **Playback speed is not persisted** — it always resets to 1.0x each session. The UI supports it, but storing/restoring the user's preference was not prioritized over core features.

## Scope

This implementation was intentionally scoped as a small offline LMS that focuses on the screening-task constraints. The emphasis is on:

- Correctness of the core learning flow (90% completion, sequential unlock, progress math).
- Maintainable separation of domain/data/presentation.
- Local progress persistence that actually survives an app restart.
- A correct video playback experience with resume, seek, speed, and fullscreen.
- An Arabic-first RTL UX that additionally exposes English + dark mode.
- Testable business rules (all progress math and search behavior are in pure Dart, covered by unit tests).

## What I Would Improve With More Time

1. **Backend synchronization + authentication.** Persist progress and user identity against a server (Firebase / Supabase / custom API) so progress travels across devices, with conflict resolution for offline edits.
2. **Remote video streaming (HLS/DASH via CDN) + adaptive bitrate.** Swap `asset` videos for network sources, add a download manager with offline cache, and a proper loading/buffering UI.
3. **Substitute SharedPreferences with a local database (Isar or drift).** Once content grows past ~50 lessons, progress queries, watch-history aggregation, and future notes/bookmarks need indexing that key-value storage cannot give.
4. **Proper `.arb`-based localization** generated via `flutter gen-l10n`, including plural forms, date formatting, and removing the last remaining hard-coded Arabic strings.
5. **Wider test coverage** — widget tests for each primary screen, integration tests that drive the full "open → watch 30% → restart app → resume → 90% → unlock next" QA scenario end-to-end, and golden tests for RTL/LTR light/dark renders.

## Submission Notes

A hiring reviewer can verify the implementation end-to-end with this walk-through:

1. Launch the app → confirm 2 courses load on the Dashboard tab.
2. Open a course from the card list.
3. In the course details, confirm Lesson 1 is openable while Lesson 2 shows a locked state / modal when tapped.
4. Start the first lesson. Confirm the video plays, HUD controls appear on tap, seek/±10s/speed chip all work.
5. Watch to ~30%, then deliberately exit the lesson (back button) and return to it — verify the video resumes near the 30% position.
6. Seek (or play) to ≥90% of the total duration. Confirm the completion Snackbar fires and the UI marks the lesson completed.
7. Go back to course details → the next lesson is now unlocked; the course progress percentage has advanced.
8. Return to the Dashboard → the "Continue Watching" banner now points at the next lesson (or first in-progress lesson) in the appropriate course.
9. Fully close and restart the application. Re-open the same lesson → resume position is preserved; completion/unlock state on the course card is preserved.
10. Open Profile tab (tab index 2), open settings. Switch language between Arabic and English — confirm font flips between Cairo and Inter, text direction flips RTL↔LTR, and most UI strings change. Toggle theme mode between Light / Dark / System — confirm the GradientScaffold and all cards react.
11. Go back to Dashboard, type into the search field (e.g. `تش` for anatomy, or `physio` for English). Confirm debounce, shimmer, and results; confirm alef normalization (e.g. plain `ا` matches `أمراض`).

---

No application code, tests, or `pubspec.yaml` were modified as part of preparing this README.
