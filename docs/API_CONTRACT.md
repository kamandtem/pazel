# Future backend contract, NOT implemented
Transport-independent repository ports allow REST or GraphQL. The included
spec/openapi.json is a draft for server/client coordination, not a running API.
Base URL is public non-secret config. Authentication secrets never enter Dart builds.

## Envelope conventions
UTC instants ISO8601, local civil day explicit, durations integer seconds,
money integer Iranian RIALS (UI must state rial/toman if converted), IDs server-validated.
Success: {data: T, nextCursor?: string}. Error: {code, message, requestId, retryAfter?}.
Pagination uses opaque cursors. All endpoints require per-resource ownership checks.
State machine in future repository: loading / success / empty / error / retry.

## Proposed endpoints
POST /auth/otp/request {phone} -> {challengeId, expiresAt, resendAt}
POST /auth/otp/verify {challengeId, code} -> {accessToken, refreshToken, user}
POST /auth/refresh: rotate refresh token; revoke on reuse. Rate limit OTP attempts.
GET/PATCH /me; DELETE /me schedules deletion and revokes sessions.
GET/POST /study/sessions; immutable append, idempotency key required.
GET/POST/PATCH/DELETE /study/plans; revision/If-Match for conflicts.
GET/POST /flashcards; POST /flashcards/:id/reviews with previous revision.
POST /sync/push {events} -> {acceptedEventIds, conflicts, rejected}
GET /sync/pull?cursor=... -> {events, nextCursor}; tombstones retained until ACK.
GET /reports?days=7|30|90&timezone=Asia/Tehran; same aggregation definitions as local.
GET/POST /leagues; POST /leagues/:id/join; GET /leagues/:id/leaderboard.
GET/POST /rooms; membership-scoped WebSocket presence, server timer anchor.
GET /podcasts; time-limited media URLs; resumable downloads owned by audio service.
POST /ai/messages streaming server proxy; consented context, quotas and audit.
POST /ai/solve image upload: MIME/size checks, strip EXIF, signed URL, OCR pipeline.
POST /advisor/requests; ownership-checked chat and booking, explicit timezone.
GET /products; POST /checkout; webhook-verified fulfillment only.
GET /wallet; GET /wallet/transactions; append-only double-entry server ledger.

## Sync conflict strategy
Session ID is idempotent append, client edits prohibited. Plans use revision conflict
responses, not silent last-write wins. Cards store review events, re-run schedule
on ordered events. Deletions use tombstones. Money and competitive ranking only
accepted after server validation. Outbox worker retries with jitter and backoff;
acknowledge each accepted event, never clear all on partial success.

## AI and minor/student privacy
Do not send study history without explicit consent. Health data never included by
default. AI provider keys server-side secret manager, not --dart-define/.env in app.
Assistant suggestions are proposals; user explicitly confirms plan writes.
For question solving show uncertainty, reasoning steps and correction affordance.
No unsupported percentile/rank estimates without validated reference population.
