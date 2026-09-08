# Next work, ordered

## Gate zero: validate this source
- Bootstrap with Flutter 3.29.3, resolve/pin dependencies, format, analyze, run tests.
- Fix compile/plugin integration issues revealed by real tools. Build/install debug APK.
- Capture actual Android screenshots, not renderings of another stack.
- Verify notification plugin API and Android manifests on API23/33/35.

## P0 correctness and completeness
- Persist running segments (start/end) per session. Allocate exact active time across
  midnight and late Pomodoro confirmations. Add monotonic/native lifecycle checkpoints.
- Persist lifetime daily aggregates and XP/level ledger; reconcile on edits/imports.
- Add timer foreground-service UX where platform-compliant; explain force-stop limits.
- Atomically separate essential study persistence from retryable notification/analytics effects.
- Prompt on unsaved editor exits and calendar note date switches; typed input formatters.
- Complete reusable plan templates, repetitions, slot-based drag and scheduling presets.
- Add notification reconciliation worker for enable/login/reboot/permission changes.
- Account recovery/delete/export and real profile/auth before accepting private data.
- Add line and donut reports plus accessible equivalent text/table views.
- Add paginated history, plans and cards; precise index/aggregate strategy.
- Test iOS keychain and browser IndexedDB; automated multi-size golden tests.

## P1
- Flashcard editing/media/category/tags/favorite/archive/share; FSRS or calibrated
  scheduler backed by immutable review events and testing.
- Exam model/builder/runner/timed answers/results/topic strengths. Percent != rank.
- GPA UI, sleep settings persistence, study schedule editor, mock-independent tests.
- Badges/coins/stars and lifetime streak freeze ledger with balanced behavior.

## P2
- Server auth and sync first, then leagues/rooms and server-trusted scoring.
- Podcast repository, licensed seed audio and app-level audio_service/just_audio player.
- Consented AI proxy, question OCR and generation confirmation; no provider keys in app.
- Advisor requests/bookings/chat, catalog/cart/checkout, webhook receipt validation,
  double-entry wallet, coupons with server time and limits.

## P3
- Adaptive plan proposals with explicit accept/reject, energy/availability constraints.
- Weakness detection using exam-topic evidence, enough samples and uncertainty.
- Social/challenges with aliases and privacy protections; focus sounds/DND permission.
- Advanced analytics with data minimization and opt-out; never claim causal sleep insights.

No automated builds or completed P2/P3 features are claimed by this file.
