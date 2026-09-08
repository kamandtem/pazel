# Validation and QA
## Executed in authoring environment
Python structural audit: relative/local imports, localization symbol references,
delimiter balance, XML/SVG parse, bundled font existence. Native icons generated
from original SVG; static font files generated from the installed licensed font.
These checks are not a Dart parser or type checker. Read VALIDATION.json.

## NOT executed
flutter pub get, dart format, flutter analyze, flutter test, flutter run,
Android APK/AAB build, Web build, iOS build, visual screenshots from runtime,
TalkBack/VoiceOver, lifecycle or notification device tests.
SDKs are unavailable in authoring sandbox. Do not turn unrun tests into pass claims.

## Source tests
8 files: tracker/Pomodoro, XP/streak/ranking, Leitner/repetition, 7/30/90 reports,
planning/calculators/formatting, mock auth, transactional repository, RTL widget smoke uses bounded pumps; it must not use unbounded pumpAndSettle while the app controller owns a periodic ticker.
Use `flutter test --coverage`; never treat number of tests as coverage percentage.

## Manual acceptance sequence after successful build
1. Fresh install: onboarding skip, demo phone/code, save profile, reopen persistence.
2. New plan with Persian digits and Jalali date, adjacent times allowed, overlap rejected.
3. Reorder and re-open: order persists, clock times unchanged. Edit/delete/undo-not-supported clarity.
4. Start linked tracker, 20 seconds, pause 20 seconds, resume 20 seconds, finish.
   Saved study should be ~40 seconds, not 60. Reports and plan update once.
5. Navigate tabs and background app during timer; terminate process, reopen and
   compare elapsed. Reboot and change time to expose known wall-clock limitations.
6. Custom 1/1 Pomodoro, app background: notification permission grant/deny, focus
   phase cap, saved session, rest not counted, next focus, no duplicate finalize.
7. Midnight, month/year changes and timezone changes; compare report definitions.
8. Again at box 0 stays 0, at box 3 becomes 2; answer due after 10 minutes. Good/Easy
   schedule days forward; review log written once, empty state not fake content.
9. 7/30/90 switch, zero-day means, best/weakest days, sample-data warning visible.
10. Dark/light, 320/390/840/1280 widths, 200% text, large Persian topic/name, keyboard
    covering form bottom, screen-reader traversal, all controls focusable.
11. Android API23/33/35: reboot delivery, battery restrictions, denied permissions;
    reminders intentionally inexact and may not fire on force-stopped apps.
12. Web reload IndexedDB and clearing site data; localhost origin stability.
13. Deep link while logged out never exposes private routes; invalid route recovers.
14. Disk write failure/database newer version: error state, no destructive reset.

## Release gates
Zero analyzer errors/warnings, all tests passing, signed build on device, recorded
QA results, policy/security/privacy review, server integration tests if enabled,
performance profiling for long lists and large datasets. Only then call a release ready.
