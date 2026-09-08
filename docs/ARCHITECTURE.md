# Architecture v0.1

## Scope and honesty
Real Flutter source, not an HTML prototype. P0 local flows and selected P1 logic.
No SDK was available during authoring. Compilation, analyzer, Flutter tests and
physical device behavior are NOT verified. SMS, server sync, AI and payments are
not implemented. See FEATURE_STATUS.md for the exact boundaries.

## Decisions made before widgets
Feature-first architecture. Presentation -> Riverpod controller -> repository ->
Sembast database. Pure Dart domain services never import Flutter or plugins.
The controller publishes an immutable AppData snapshot after transactional writes.
Separate record stores, not one shared-preferences JSON blob.
IO uses an app-support file; Web uses IndexedDB via conditional imports.
Outbox events are committed with writes; NO sync worker exists yet.
Demo auth is one local profile, not a production multi-account login system.
SecureStorage is an adapter for future tokens. Current study data is NOT encrypted
at rest. Sensitive health collection stays disabled until consent and encryption.

Timer: persisted elapsed base + UTC running anchor. Tickers repaint only. Pause
freezes elapsed. Process restoration reconstructs from anchor. System clock changes
are a known limitation requiring native monotonic checkpoints in production.
Pomodoro never silently counts hours away as multiple completed cycles. A phase
ends and awaits user transition. Rest is never recorded as study.
Session finalize + timer clear + linked plan completion + outbox is atomic and
idempotent. Timer IDs become session IDs. Repeated finalize cannot double-award XP.
Reports include empty days; elapsed time spanning midnight is proportionally
allocated across local dates. Paused intervals are not individually stored, so this
allocation is approximate for paused cross-midnight sessions (documented limitation).
All stored instants UTC, calendar civil dates ISO local, display Jalali.

## Source structure
lib/core: config, database (IO/Web), models, state, services, routing, localization,
theme and reusable widgets.
lib/features: auth, home, planning, study, reports, calendar, profile, notifications,
flashcards, tools, gamification; later features have typed ports and explicit status.
Business logic lives in domain services; UI owns only form/presentation state.

## Agent continuation rules
Read README, FEATURE_STATUS, DATABASE, API_CONTRACT and tests first. Small commits.
Run formatter/analyzer/tests/build after every change. No fake metrics or silent
mock production endpoints. Add record roundtrip and repository tests for new data.
Test airplane mode, process kill, midnight, permission denial, RTL and 200% text.
