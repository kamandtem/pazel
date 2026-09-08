# Exact feature status, source delivery v0.1

**Written** means implemented in source, NOT built or device-tested.
There is no APK in the ZIP. SDK-dependent validation remains entirely unrun.

| Priority | Feature | Written now | Missing / boundary |
|---|---|---|---|
| P0 | Splash / onboarding | DB skeleton, retry, 3 steps, skip, persistence | Native branded splash polish |
| P0 | Auth | Mock OTP, validation, expiry, resend throttle, route guard, local session | Real SMS, recovery, server tokens, multi-account isolation |
| P0 | Profile | Name, surname, phone from login, gender opt-out, grade, field, exam year, goal, city, school, sleep/wake, target | Avatar upload, account deletion/export |
| P0 | Home | Live local report, daily target, ring, streak, tests, plans, recent sessions, links | Countdown, authoritative rank, richer achievement feed |
| P0 | Planning | CRUD, priority, activity, notes, target tests, start/duration/end, overlap guard, done, reorder, tomorrow move | Templates, repeated schedules, actual drag-to-change-time, auto-adaptation |
| P0 | Planning views | Selected day, next 7 days, Jalali month calendar | Week currently rolling 7 days, not fixed Saturday-week grid |
| P0 | Time tracker | Start/pause/resume, disk checkpoint, restore anchor, finish form, history | Native monotonic clock, exact pause-interval ledger, foreground service, reset-with-reuse |
| P0 | Pomodoro | 3 presets/custom, explicit focus/rest, pause, finish and rest, skip rest via next focus | Monthly cycle aggregates, auto transitions, native focus music, session-level cycle summary |
| P0 | Reports | 7/30/90, zero-day mean, bars, subject shares, tests, counts, adherence, best/weakest | Line/donut charts, test speed, per-topic reports, full-history aggregates |
| P0 | Database | Separate stores, version guard, transactions, review log, outbox, IO/Web adapters | Real migration beyond v1, encryption, conflict reconciliation, sync worker, pagination |
| P0 | Calendar | Jalali month navigation/day selection, plan/session markers, per-day notes | Exam/event entities, health overlay, rich event editor |
| P0 | Notifications | In-app center/read, local Android/iOS adapter, permissions, timer end, saved plan reminders | Web notifications, tap-to-route, permission revocation recovery, full reschedule reconciliation |
| P1 | Flashcards | Text front/back, subject, due queue, 5 boxes, Again/Hard/Good/Easy, review log | Edit/delete, media, tags, favorites/archive/share, FSRS fitting |
| P1 | Gamification | Pure XP/level/streak/freeze/ranking functions; XP/level/streak in UI | Persistent lifetime aggregate, coins/stars/badges, actual freeze UI/ledger, anti-cheat |
| P1 | Exam | Percent service and calculator; weighted-grade service | Exam builder/runner/history/timing UI, GPA UI; no fabricated rank/standard score |
| P1 | Sleep tool | Wake input and rough 90-minute-cycle options with caution | Individualized sleep guidance; no medical claim |
| P1 | Study schedule | Extension folder and documentation | Presets and availability editor |
| P2 | League, room, podcast, AI, advisor, store, wallet | Typed ports and simple future entity models only | All UI, server, realtime/audio/payment/AI integration |
| P3 | Insights | Three deterministic rules with sample evidence and thresholds | Sleep correlation, trends, weaknesses, model-backed coach |
| P3 | Adaptive/social/focus | Manual move-tomorrow; architectural seams | Smart daily plan, friends/challenges, OS DND, music, advanced analytics |

| P1 | Reference-inspired room | Local visual room detail, members and rank sections | Realtime presence, backend membership and shared timer |
| P1 | Reference-inspired flash packs | Pack browse surface, subject chips and card-style catalog | Real products, downloads, payments and creator tools |
| P1 | Reference-inspired leaderboard | Podium and ranked list surface | Server-trusted scores, friends, leagues and anti-cheat |
| P1 | Reference-inspired grade tools | Grade average and percent calculator routes | Full final-grade subject/coefficient model and rank estimator |
| P1 | Reference-inspired sleep | Dark sleep routine surface and approximate guidance | Persistent sleep model, reminders, audio and medical review |

## Cross-cutting
Persian/RTL; explicit Light/Dark; 3 bundled Vazirmatn weights; responsive rail;
semantic labels; 48dp principal controls; zero essential animation; local error
feedback; source-side unit/repository/widget tests; CI recipe and build bootstrap.
Actual contrast/overflow/TalkBack/200% scale and rendering are UNVERIFIED.
Subjects are seeded; lesson/topic management is not implemented (topic is a string).
No misleading fake provider credentials, payments, AI answer or online presence.

## Known correctness limits needing first attention
* Session duration itself excludes pauses, but midnight distribution is proportional
  over wall duration because individual running segments are not stored. A long
  pause or late Pomodoro confirmation can assign time to the wrong civil day.
* Timer uses wall clock anchors. Manual time changes can over/undercount elapsed.
* XP/streak UI currently derives from the loaded ~91-day session snapshot. It is
  not a lifetime ledger and cannot represent a true 100-day streak yet.
* Plan adherence counts user-marked completion, not verified target minutes.
* Review count in reports is completed REVIEW PLANS, not flashcard answer count.
* Reordering changes visual order only, not start/end time. Moving to tomorrow
  preserves original clock and rejects collisions. No silent auto-rescheduling.
* Enabling reminders does not reconcile every pre-existing plan/timer; newly saved
  plans and started/resumed timers are scheduled. Delivery is intentionally inexact.
* A rest can be started after a partial focus session; cycles then counts recorded
  focus sessions, not necessarily all full-duration Pomodoro blocks.
* Finishing a linked session without starting rest marks the plan done regardless
  of planned target duration. Production should offer explicit completion control.
* Data mutation plus outbox is atomic; ancillary notice/analytics writes may occur
  separately. Improve partial-side-effect error recovery before production.
* Calendar date switch abandons an unsaved note draft; save before switching.
* The in-app history shows 30 most recent sessions; reports see the loaded 91 days.
* Login accepts a different demo number into the same local profile. Never treat it
  as real multi-user auth or deploy with real student records.
* Login after a logout does not reschedule previously canceled plan reminders.
