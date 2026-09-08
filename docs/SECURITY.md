# Security boundary
This is a local demonstration, NOT secure production authentication.

Implemented: no embedded API/provider secrets; explicit mock OTP; no backend calls;
Android cleartext disabled; backup disabled; future SecureStorage token adapter;
local mutation validation; destructive plan/timer confirmation; no health collection;
no real payment/wallet mutation; no external trackers or personal analytics payload.

Not implemented: server authorization, encrypted study database, real refresh/revoke,
account deletion/export, biometric unlock, device compromise protection, CSRF/web
session hardening, secure multi-user partitions, upload sanitization, abuse controls.

Before enabling real students:
1. Adopt consent/age-appropriate privacy design, retention and deletion rules.
2. Enforce per-user isolation server-side and locally; never trust client user IDs.
3. Keep refresh tokens in native keychain/keystore; Web preferably uses secure
   HttpOnly same-site cookies via backend session rather than localStorage tokens.
4. Encrypt sensitive local stores with managed device-bound keys and key rotation.
5. Build TLS-only proxy for AI and server-validated payment webhook flow.
6. Room/social data exposes aliases, not phone, school, location, health or chat.
7. Menstrual tracking is opt-in regardless of gender label. Separate consent,
   encryption, private export/delete and approximate/non-medical cycle messaging.
8. Gamification must not reward unhealthy sleep loss or endless hours. Server-side
   scoring caps, breaks, fraud validation and humane streak handling need design.
9. Exercise notification denial/revocation and never imply reliable exact alarms.
10. Audit dependencies and licenses and replace demo entities before publication.

API_BASE_URL / APP_ENV are public compile-time config. Environment variables compiled
into Flutter are readable and are NOT a way to hide API keys. Do not paste signing
secrets, production tokens or student records into coding-agent chats.
