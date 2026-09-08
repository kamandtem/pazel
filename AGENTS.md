# Coding-agent handoff
Project: Pazel, Persian RTL Flutter study app, local pilot v0.1.
User wants actual Android app, not HTML. Do not replace this app with a mockup.

Read README.md and docs/FEATURE_STATUS.md first. Then ARCHITECTURE, DATABASE,
API_CONTRACT, SECURITY, TESTING, TODO and source tests.
Flutter/Dart/Android were NOT installed in the generation environment.
First command on a prepared machine: bash scripts/bootstrap.sh (Windows: bootstrap.ps1).
Then dart format lib test; flutter analyze; flutter test; flutter build apk --debug.
Commit a resolved pubspec.lock after successful verification.
Never state tests or builds passed unless you ran them and preserved the result.

Architecture: feature presentation -> Riverpod AppController -> StudyRepository ->
Sembast IO/Web. No business logic in widgets. Future ports live in feature_contracts.
Sembast writes + outbox are atomic, but sync is NOT implemented. No real SMS/AI/payment.
Do not expose real student info with the one-profile mock auth flow.
Do not drop existing data or silently replace local persistence when adding backend.
All Persian UI copy centralized; normalize Persian/Arabic input digits. Keep RTL,
Jalali display, accessibility, light/dark and offline font intact.

Priority fixes: exact running segments/midnight attribution, monotonic timer,
lifetime aggregates, notification reconciliation, unsaved form protection,
pagination, real auth. See FEATURE_STATUS for concrete known limitations.
No private health collection until encrypted stores and explicit consent.
No random insights, invented ranks, fake online people, or simulated payment success.
