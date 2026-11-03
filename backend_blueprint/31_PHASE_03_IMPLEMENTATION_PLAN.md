# DEAL ONE — PHASE 03 IMPLEMENTATION PLAN
**Document ID:** `31_PHASE_03_IMPLEMENTATION_PLAN`  
**Classification:** Core System Architecture & Implementation Blueprint  
**Date:** 2026-11-03  
**Status:** PLAN APPROVED — AWAITING FINAL AUTHORIZATION (HARDENED SECURITY BASELINE)  
**Scope:** Core Identity, Authentication, Phone OTP, Refresh Token Family Rotation & Tenant Context Foundation  

---

## 1. Executive Summary & Audit Baseline

Phase 02 established the authoritative 28-table database foundation with PostGIS 3.4 spatial indices, strict dual-Redis topology (`redis_cache` on 6379 with `allkeys-lru`, `redis_queue` on 6380 with `noeviction` + AOF), BullMQ asynchronous job architecture, and formal design patterns.

The objective of **Phase 03** is to implement the production-grade **Core Identity, Authentication & Phone OTP** foundation. In accordance with the audited project architecture:

1. **A User is NOT an Account:** Strict separation between human platform identities (`users`), commercial/personal operating contexts (`accounts`), their tenant memberships (`account_members`), and the active authenticated context (`AccountContext`).
2. **Centralized Phone Normalization:** Full parsing, validation, and E.164 canonicalization for Egyptian mobile numbers (`+2010`, `+2011`, `+2012`, `+2015`), preventing account fragmentation and duplicate identities.
3. **Hardened Phone OTP Lifecycle (PostgreSQL Authority + Redis Acceleration):**
   - **PostgreSQL is the durable source of truth** for all security-critical OTP state, attempt counts, row locking (`SELECT ... FOR UPDATE`), and atomic single-use consumption.
   - **Redis cache acceleration:** Sliding-window rate limiting and resend cooldown acceleration without security dependency on volatile LRU cache keys.
   - **Atomic PostgreSQL Fallback:** When Redis is unavailable, all rate limits (3 requests / 15m for Phone, 10 requests / 15m for IP, and 60s cooldown) are enforced atomically via independent transactional advisory locks (`pg_advisory_xact_lock`) acquired in fixed ascending order to prevent deadlocks, with limits checking and challenge creation executed within the same transaction.
   - **No third Redis instance:** Operates strictly within the verified dual-Redis deployment.
4. **Strict OTP Purpose Isolation:** Concrete partitioning among `REGISTRATION`, `LOGIN`, and `PHONE_VERIFICATION`. Cross-purpose token consumption is cryptographically and logically prohibited.
5. **Provider-Independent SMS Gateway:** Clean Port-and-Adapter architecture (`ISmsGatewayAdapter`) with an isolated `DevMockSmsAdapter` for development/testing. Production adapter selection is treated as an independent procurement decision; production fails safely without configured provider credentials.
6. **Persistent Refresh Token Family Lineage & Zero-Grace Replay Defense:**
   - Persistent token lineage via immutable history in `user_sessions`.
   - Refresh tokens are never stored in plaintext (only cryptographic SHA-256 hashes are persisted).
   - Consumed tokens retain hashes with `is_revoked = true` to guarantee replay detectability.
   - **Zero Grace Window / Immediate Family Revocation:** The 5-second grace window is completely eliminated. Any presentation of an already-consumed refresh token immediately triggers Token Reuse Detection and revokes the entire affected Token Family. Old tokens cannot be replayed to retrieve child tokens.
   - Strict transactional serialization via row-level locking (`SELECT ... FOR UPDATE`).
7. **Direct PostgreSQL Multi-Tenant Membership Authorization (V1 Baseline):**
   - In V1, PostgreSQL is the direct, authoritative source of truth for **every** Account Membership authorization decision (`AccountTenantGuard` queries `account_members` directly in PostgreSQL for every request presenting `X-Account-ID`).
   - Redis is **never** relied upon to permit access or verify membership validity.
   - Redis cache is strictly restricted to non-security display metadata (e.g., account profile display name, slug, avatar).
   - Any claim that Redis deletion after DB update guarantees atomic immediate revocation is explicitly rejected as a distributed dual-write fallacy; instead, true immediate revocation is guaranteed because PostgreSQL directly evaluates every authorization check on the subsequent request, completely independent of Redis availability or network partitions.
   - Integration tests verify that revoking membership immediately blocks access on the subsequent request with 403 Forbidden, even when Redis is offline or unreachable.
8. **Exclusion of Password Authentication:** Deal One is a phone-first marketplace. Password authentication is explicitly excluded from Phase 03.
9. **Bounded Account Context Foundation:** Implements only server-side `X-Account-ID` verification against active `account_members` and default account auto-creation. Full account management workflows remain deferred to Phase 04/05.
10. **Security Audit Logging:** Append-only audit trail for authentication, token rotation, reuse detection, and session events in `audit_log` without leaking credentials or tokens.

---

## 2. Existing Implementation & Database Inventory

### 2.1 Existing Code Inventory (`backend/src/modules/auth/`)
- `auth.controller.ts`: Legacy endpoints requiring modular refactoring.
- `auth.service.ts`: Monolithic implementation requiring decomposition into specialized services.
- `strategies/jwt.strategy.ts`: Passport JWT strategy extracting Bearer token and verifying user status.
- `guards/jwt-auth.guard.ts`: Standard NestJS `AuthGuard('jwt')`.
- `guards/roles.guard.ts`: User-level role guard (`UserRole`).
- `decorators/current-user.decorator.ts`: Extracts `AuthenticatedUser` from request.
- `dto/`: Validation DTOs requiring purpose isolation and strict phone validation.

### 2.2 Verified Prisma Database Models (`schema.prisma`)
The PostgreSQL schema contains all required tables and fields:
- `users`: ID (UUID), `phone` (unique VarChar 20), `full_name`, `is_phone_verified`, `is_active`, `deleted_at`.
- `user_sessions`: ID (UUID), `user_id`, `family_id` (UUID, indexed), `refresh_token_hash` (indexed), `user_agent`, `ip_address`, `is_revoked`, `expires_at`, `created_at`, `last_used_at`.
- `user_devices`: ID (UUID), `user_id`, `fcm_token`, `platform`, `app_version`.
- `otps`: ID (UUID), `phone`, `purpose` (`REGISTRATION`, `LOGIN`, `PHONE_VERIFICATION`, indexed), `code_hash`, `attempts`, `is_consumed`, `expires_at`, `created_at`.
- `accounts`: ID (UUID), `owner_user_id`, `account_type` (`individual`, `company`, etc.), `display_name`, `slug`, `verification_status`, `is_active`.
- `account_members`: ID (UUID), `account_id`, `user_id`, `role` (`owner`, `manager`, etc.), unique `[account_id, user_id]`.
- `audit_log`: ID (UUID), `actor_id`, `action`, `target_entity`, `target_id`, `ip_address`, `user_agent`, `diff_payload`, `created_at`.

---

## 3. Architectural Decisions & Scope Resolutions

### 3.1 Decision 1: PostgreSQL Security Authority, Atomic OTP Verification & Atomic Dispatch Rate Limiting
- **Context:** `redis_cache` operates with `maxmemory-policy: allkeys-lru`. Volatile keys may be evicted under memory pressure or cleared on restart. Furthermore, relying on uncoordinated application logic or non-transactional database checks during Redis outages creates race conditions and limit overshoots under concurrent traffic.
- **Resolution:**
  1. **PostgreSQL is the Sole Authoritative Source of Truth:**
     All security-critical decisions (OTP verification, attempt tracking, lockout enforcement, consumption, and fallback rate limiting) execute directly within serialized PostgreSQL transactions. Redis serves strictly as an acceleration tier.

  2. **Atomic OTP Verification Lifecycle (Row Locking & Single Consumption Authority):**
     To eliminate race conditions, brute-force bypasses, and invalid attempt collisions under concurrency:
     - **Row-Level Locking:** Every verification request begins by locking the specific OTP record using `SELECT ... FOR UPDATE`:
       ```sql
       -- Executed within an atomic verification transaction:
       BEGIN;
       SELECT id, phone, purpose, code_hash, attempts, is_consumed, expires_at
       FROM otps
       WHERE phone = $1 AND purpose = $2 AND is_consumed = FALSE
       ORDER BY created_at DESC
       LIMIT 1
       FOR UPDATE;
       ```
     - **Cryptographic Hash Comparison:** The submitted plain OTP code is hashed using the system pepper (`SHA-256(pepper || code)`) and compared against `code_hash` using constant-time string comparison (`crypto.timingSafeEqual`) to prevent timing side-channel attacks.
     - **Atomic Attempt Increment on Failure:** If the submitted code does NOT match, `attempts` is atomically incremented on the locked row:
       ```sql
       UPDATE otps SET attempts = attempts + 1 WHERE id = $otp_id;
       COMMIT;
       ```
     - **Strict 5-Attempt Ceiling Under Concurrency:** Because the record is locked with `FOR UPDATE`, concurrent verification attempts are strictly serialized. Even if an attacker executes 50 parallel requests, each request reads the sequentially incremented `attempts`. As soon as `attempts >= 5`, the OTP challenge is permanently locked. Any subsequent attempt (valid or invalid) is immediately rejected with HTTP 401 Unauthorized / Locked.
     - **Single-Use Atomic Consumption:** If the code matches and `attempts < 5` and `expires_at > NOW()`, the record is consumed atomically:
       ```sql
       UPDATE otps 
       SET is_consumed = TRUE, attempts = attempts + 1 
       WHERE id = $otp_id AND is_consumed = FALSE AND attempts < 5 AND expires_at > NOW()
       RETURNING id;
       ```
     - **Isolation From Concurrent Invalid Attempts:** A valid OTP is **never** consumed by a concurrent invalid attempt. An invalid attempt only increments `attempts`; it never sets `is_consumed = TRUE`. If an invalid attempt runs immediately before a valid attempt, it increments `attempts` (e.g. from 1 to 2). The subsequent valid attempt acquires the row lock, observes `attempts = 2` (< 5) and `is_consumed = FALSE`, verifies the matching hash, and marks `is_consumed = TRUE`. The valid attempt succeeds cleanly.
     - **Transaction Consistency:** The entire verification, attempt increment, and consumption lifecycle is executed consistently inside a single atomic database transaction.

  3. **Atomic OTP Dispatch Rate Limiting (Redis Acceleration + Atomic PostgreSQL Fallback):**
     All rate limits and cooldowns are fully enforced in both the Redis fast-path and the PostgreSQL fallback:
     - **Limits Baseline:**
       - **Phone Limit:** Max 3 requests per phone per 15 minutes.
       - **IP Limit:** Max 10 requests per IP per 15 minutes.
       - **Cooldown:** Exactly 60 seconds cooldown between dispatches for the same phone and purpose.
     - **Dual Independent Transactional Advisory Locks:**
       In the PostgreSQL fallback (when Redis is down or unreachable), atomicity is guaranteed using two independent 64-bit transactional advisory locks:
       - `phone_lock_key = ('x' || substr(md5('otp_dispatch_phone:' || $phone || ':' || $purpose), 1, 15))::bit(60)::bigint`
       - `ip_lock_key = ('x' || substr(md5('otp_dispatch_ip:' || $ip_address), 1, 15))::bit(60)::bigint`
     - **Fixed Deterministic Lock Acquisition Ordering (Deadlock Elimination):**
       To prevent deadlocks between concurrent requests (e.g. request A locking Phone X then IP Y, while request B locks IP Y then Phone X), locks MUST always be acquired in strict ascending numerical order:
       ```sql
       -- Deterministic sorting of lock keys mathematically eliminates circular wait deadlocks:
       SELECT pg_advisory_xact_lock(k)
       FROM (
         SELECT unnest(ARRAY[
           LEAST($phone_lock_key, $ip_lock_key),
           GREATEST($phone_lock_key, $ip_lock_key)
         ]) AS k
       ) s;
       ```
     - **Single-Transaction Limits Check & Challenge Creation:**
       All limit verifications and the OTP record insertion are executed inside the same transaction:
       ```sql
       BEGIN;
       -- 1. Acquire independent locks in fixed ascending order:
       SELECT pg_advisory_xact_lock(LEAST($phone_lock_key, $ip_lock_key));
       SELECT pg_advisory_xact_lock(GREATEST($phone_lock_key, $ip_lock_key));

       -- 2. Verify 60-second cooldown per phone & purpose:
       SELECT MAX(created_at) AS last_dispatch_time
       FROM otps
       WHERE phone = $1 AND purpose = $2;
       -- If last_dispatch_time IS NOT NULL AND last_dispatch_time > NOW() - INTERVAL '60 seconds':
       --   ROLLBACK; throw TooManyRequestsException('Please wait 60 seconds before requesting another OTP');

       -- 3. Verify Phone 15-minute sliding window rate limit (max 3):
       SELECT COUNT(*) AS phone_dispatches
       FROM otps
       WHERE phone = $1 AND purpose = $2 AND created_at > NOW() - INTERVAL '15 minutes';
       -- If phone_dispatches >= 3:
       --   ROLLBACK; throw TooManyRequestsException('Phone OTP request limit exceeded (max 3 per 15 minutes)');

       -- 4. Verify IP 15-minute sliding window rate limit (max 10):
       SELECT COUNT(*) AS ip_dispatches
       FROM audit_log
       WHERE action = 'OTP_SENT' AND ip_address = $3 AND created_at > NOW() - INTERVAL '15 minutes';
       -- If ip_dispatches >= 10:
       --   ROLLBACK; throw TooManyRequestsException('IP request limit exceeded (max 10 per 15 minutes)');

       -- 5. Invalidate prior active unconsumed OTPs for (phone, purpose):
       UPDATE otps SET is_consumed = TRUE WHERE phone = $1 AND purpose = $2 AND is_consumed = FALSE;

       -- 6. Atomically persist the newly issued OTP challenge:
       INSERT INTO otps (id, phone, purpose, code_hash, attempts, is_consumed, expires_at, created_at)
       VALUES ($4, $1, $2, $5, 0, FALSE, NOW() + INTERVAL '5 minutes', NOW());

       -- 7. Persist audit log entry capturing IP address for sliding-window rate tracking:
       INSERT INTO audit_log (id, actor_type, action, target_entity, target_id, ip_address, user_agent, diff_payload, created_at)
       VALUES (gen_random_uuid(), 'system', 'OTP_SENT', 'otps', $4, $3, $6, jsonb_build_object('phone', $1, 'purpose', $2), NOW());

       COMMIT;
       ```
     - **Required Concurrency Tests:**
       - **Phone Limit Concurrency Test:** 10 concurrent requests for same phone -> exactly 1 succeeds initially due to 60s cooldown; across 15m window max 3 succeed.
       - **IP Limit Concurrency Test:** 20 concurrent requests across distinct phone numbers from the same IP -> exactly 10 succeed, remaining 10 rejected with 429.
       - **Cooldown Concurrency Test:** Multiple concurrent requests within 60s window -> exactly 1 succeeds, all others rejected by cooldown.

  4. **Redis Acceleration Role (Non-Authoritative Fast-Path):**
     - Redis is used strictly for fast-path caching: resend cooldown (`otp:cooldown:<phone>:<purpose>`, TTL 60s), rapid Phone rate limit (`otp:ratelimit:phone:<phone>:<purpose>`, TTL 15m), and rapid IP rate limit (`otp:ratelimit:ip:<ip_address>`, TTL 15m).
     - Under any Redis outage, eviction, or network partition, fallback seamlessly and atomically routes to PostgreSQL without security degradation.

  5. **Topology Constraint:**
     No third Redis instance is introduced. The system strictly utilizes `redis_cache` (6379) and `redis_queue` (6380).

### 3.2 Decision 2: Refresh Token Family Lineage & Precise Concurrency
- **Context:** Storing only a single `familyId` on an active session record fails to detect reuse if predecessor token hashes are overwritten upon rotation. Furthermore, blanket revocation of all user sessions disrupts valid devices (e.g., desktop sessions).
- **Resolution:**
  1. **Persistent Token Lineage:**
     - Each issued refresh token corresponds to a persistent record in `user_sessions`.
     - When rotating Token A to Token B within `familyId`:
       - Token A's record is marked `is_revoked = TRUE` with `last_used_at = NOW()`. Its cryptographic hash `refreshTokenHash` is **retained permanently** (never deleted or overwritten).
       - Token B is inserted as a new record in `user_sessions` with the identical `familyId`.
  2. **Deterministic Replay Detection:**
     - When a refresh token is presented, the system hashes it and searches `user_sessions`.
     - If the matching record has `is_revoked == TRUE`:
       - **Unambiguous Token Reuse / Theft Detected.**
       - The server immediately revokes the **entire compromised family**:
         ```sql
         UPDATE user_sessions SET is_revoked = TRUE WHERE family_id = $1;
         ```
       - Spares unrelated session families on other devices belonging to the same user.
       - Records a high-severity `SECURITY_ALERT` in `audit_log`.
  3. **Concurrent Refresh Serialization & Zero Grace Window:**
     - Concurrent rotation requests are strictly serialized using a database row-level lock (`SELECT ... FOR UPDATE` on the active session record matching `refresh_token_hash`).
     - **Complete Removal of Grace Window:** The 5-second grace window is entirely eliminated. Replaying or reusing any consumed/rotated refresh token is strictly prohibited.
     - **No Plaintext Storage or Child Token Recovery:** The server never stores plaintext refresh tokens (only SHA-256 hashes are persisted) and never returns previously-minted child tokens upon presentation of an old token.
     - **Immediate Token Reuse Detection:** When two concurrent requests present the exact same refresh token:
       - The first request acquires the row lock, rotates the token (marks predecessor `is_revoked = TRUE` and commits a newly minted child token).
       - The second request, unblocked from `FOR UPDATE`, immediately reads `is_revoked == TRUE`.
       - This is treated instantly as a Token Reuse / Theft event: the entire token family is revoked (`UPDATE user_sessions SET is_revoked = TRUE WHERE family_id = $1`), a high-severity `SECURITY_ALERT` is logged to `audit_log`, and HTTP 401 Unauthorized is returned.
     - Any network failure during refresh requires the client to re-authenticate cleanly via Phone OTP. Security is never compromised for replay tolerance.

### 3.3 Decision 3: SMS Provider Decoupling & Safe Failure
- **Context:** Previous documentation presumed SMS Misr as the approved production provider. Provider selection requires commercial evaluation.
- **Resolution:**
  1. **Strict Port-and-Adapter Architecture:**
     - Core authentication depends exclusively on the `ISmsGatewayAdapter` interface.
     - `DevMockSmsAdapter`: Default adapter for development and testing. Captures OTPs in memory and logs them safely in local development.
  2. **Production Decoupling:**
     - SMS Misr is NOT assumed approved. Selection of the commercial provider (e.g., SMS Misr, Twilio, Infobip, VictoryLink) is documented as an open commercial decision.
     - Production adapter implementation will be injected via configuration once formal procurement is finalized.
  3. **Safe Failure in Production:**
     - In `production` environment (`NODE_ENV === 'production'`), if no approved production adapter is configured or if provider API credentials are absent, the system **fails safely**:
     - It logs a fatal configuration error and returns HTTP 503 `ServiceUnavailableException`.
     - Under no circumstances does production emit OTP codes to logs, console, or API response payloads.

### 3.4 Decision 4: Exclusion of Password Authentication
- **Context:** Previous drafts included `POST /api/v1/auth/password/login`. Deal One is an Egyptian mobile-first platform.
- **Resolution:**
  1. Password login is **completely removed** from Phase 03 scope.
  2. The `password_hash` column on `users` is retained strictly as an inactive schema field for future compatibility.
  3. No password endpoints, password hashing pipelines, or password DTOs will be implemented in Phase 03.
  4. Any future introduction of password authentication requires a formal RFC and explicit client approval.

### 3.5 Decision 5: Bounded Account Context Foundation & Direct PostgreSQL Membership Authorization
- **Context:** Multi-tenant account switching must not pull Phase 04/05 scope into Phase 03. Furthermore, caching tenant memberships in Redis to make authorization decisions introduces a severe distributed systems vulnerability: revoking a membership in the database while relying on cache invalidation (`redis.del()`) leaves a window of unauthorized access if cache deletion fails, is delayed, or if Redis undergoes network partitioning.
- **Resolution:**
  1. **PostgreSQL Direct Reference for Authorization in V1:**
     - In V1, PostgreSQL is the direct, authoritative reference for **every** Account Membership authorization decision.
     - `AccountTenantGuard` queries PostgreSQL `account_members` directly on every incoming request presenting an `X-Account-ID` header:
       ```sql
       SELECT am.role, a.is_active, a.deleted_at
       FROM account_members am
       JOIN accounts a ON a.id = am.account_id
       WHERE am.user_id = $userId 
         AND am.account_id = $accountId 
         AND a.is_active = TRUE 
         AND a.deleted_at IS NULL;
       ```
     - If the membership does not exist or the account is inactive/deleted, the request is immediately rejected with HTTP 403 Forbidden.
  2. **Zero Reliance on Redis Membership Cache for Access Control:**
     - The system does **not** consult Redis to permit access or verify membership status.
     - Redis cache is strictly restricted to non-security display information (e.g. `account:display:<accountId>` caching `{ displayName, slug, logoUrl }` with TTL 300s) to assist UI rendering without impacting security boundaries.
  3. **Rejection of the Dual-Write Cache Invalidation Fallacy:**
     - Any claim that deleting a Redis cache key after a database update guarantees "Atomic Immediate Revocation" is explicitly rejected. In a distributed architecture, database transactions and Redis commands cannot form an atomic two-phase commit without distributed transaction overhead. A network glitch or Redis failure during `redis.del()` leaves stale permissions active if access decisions consult the cache.
     - By making PostgreSQL the direct reference for all authorization checks in V1, immediate revocation is architecturally guaranteed: as soon as a membership is deleted or suspended in `account_members`, the very next database query sees the updated state and rejects access instantaneously with zero propagation lag.
  4. **Integration Tests for Immediate Revocation & Redis Outage Independence:**
     - Integration tests verify that revoking an account membership in PostgreSQL immediately denies access (HTTP 403 Forbidden) on the very next HTTP request.
     - Additional integration tests verify that this immediate revocation functions identically even when the Redis service is completely stopped/offline, proving zero security dependence on Redis availability.
  5. **In Scope for Phase 03:**
     - Automatic transactional creation of the default `individual` Account and `owner` membership in `account_members` upon first phone OTP verification.
     - `AccountContextInterceptor`: Extracts `X-Account-ID` header from incoming authenticated requests and binds context.
     - `AccountTenantGuard`: Enforces direct PostgreSQL authorization against `account_members`.
     - Minimal endpoint `GET /api/v1/accounts/my-accounts` to allow client applications to inspect available account contexts.
  6. **Out of Scope for Phase 03:**
     - Creation of company/store accounts, member invitations, role modifications, and team permissions (strictly reserved for Phase 04 and Phase 05).

### 3.6 Decision 6: OTP Purpose Isolation & Concurrency
- **Context:** An OTP generated for login must never be valid for phone verification or registration.
- **Resolution:**
  1. **Strict Purpose Domain:**
     - `REGISTRATION`: Permitted only for unverified or non-existent phone numbers.
     - `LOGIN`: Permitted only for existing, active users.
     - `PHONE_VERIFICATION`: Permitted for updating an authenticated user's phone number.
  2. **Logical Partitioning:**
     - All database queries filter strictly by `phone` AND `purpose`:
       ```sql
       SELECT * FROM otps 
       WHERE phone = $1 AND purpose = $2 AND is_consumed = FALSE 
       ORDER BY created_at DESC LIMIT 1;
       ```
     - Submitting an OTP generated for `PHONE_VERIFICATION` to the `LOGIN` endpoint results in an immediate 400 Bad Request.
  3. **Invalidation & Concurrency:**
     - Requesting a new OTP for `(phone, purpose)` immediately marks all prior unconsumed OTPs for that identical `(phone, purpose)` as consumed/superseded (`UPDATE otps SET is_consumed = TRUE WHERE phone = $1 AND purpose = $2 AND is_consumed = FALSE`).
     - OTP challenges for disparate purposes do not invalidate each other.
     - Verification queries lock the target record (`FOR UPDATE`), ensuring concurrent verification attempts are serialized.

---

## 4. Module Architecture & Boundaries

The authentication domain is structured into modular, single-responsibility components adhering strictly to NestJS conventions:

```
backend/src/
├── core/
│   ├── identity/
│   │   ├── phone-normalization.service.ts    # Centralized E.164 normalization (libphonenumber-js)
│   │   └── phone-normalization.service.spec.ts
│   └── security/
│       ├── security-audit.service.ts          # Append-only audit logger targeting audit_log
│       └── security-audit.service.spec.ts
└── modules/
    ├── auth/
    │   ├── adapters/
    │   │   ├── sms-gateway.interface.ts       # ISmsGatewayAdapter port
    │   │   └── mock-sms.adapter.ts            # Development/Testing mock adapter
    │   ├── services/
    │   │   ├── otp.service.ts                 # PostgreSQL-authoritative OTP lifecycle & Redis acceleration
    │   │   ├── session.service.ts             # Persistent token lineage, rotation, reuse detection
    │   │   └── auth.service.ts                # Orchestrator & public auth API facade
    │   ├── controllers/
    │   │   ├── auth.controller.ts             # OTP request, verify, refresh, logout
    │   │   └── session.controller.ts          # Session listing and selective termination
    │   ├── guards/
    │   │   ├── jwt-auth.guard.ts              # Validates 15-minute Bearer JWT
    │   │   └── account-tenant.guard.ts        # Validates X-Account-ID membership
    │   ├── interceptors/
    │   │   └── account-context.interceptor.ts # Binds validated AccountContext to request
    │   ├── dto/
    │   │   ├── send-otp.dto.ts                # Phone, purpose, turnstile token
    │   │   ├── verify-otp.dto.ts              # Phone, purpose, 6-digit code
    │   │   ├── refresh-token.dto.ts           # Refresh token string
    │   │   └── session-response.dto.ts        # Active session DTO
    │   └── auth.module.ts
    └── accounts/
        ├── accounts.controller.ts            # GET /accounts/my-accounts (minimal context foundation)
        └── accounts.service.ts
```

---

## 5. API Endpoints & Contract Matrix

| Method | Path | Auth | Rate Limit | Description |
|---|---|:---:|:---:|---|
| `POST` | `/api/v1/auth/otp/send` | Public | 3 req / 15m | Request 6-digit SMS OTP for specified `purpose` (`REGISTRATION`, `LOGIN`, `PHONE_VERIFICATION`). |
| `POST` | `/api/v1/auth/otp/resend` | Public | 60s cooldown | Resend OTP challenge enforcing 60s cooldown. |
| `POST` | `/api/v1/auth/otp/verify` | Public | 5 attempts (DB) | Authoritatively verify OTP; creates User + default Account if new; returns JWT + Refresh Token. |
| `POST` | `/api/v1/auth/token/refresh` | Public | 10 req / min | Rotate refresh token with persistent lineage and reuse detection. |
| `POST` | `/api/v1/auth/logout` | JWT | - | Revoke specific session identified by refresh token or current bearer session. |
| `POST` | `/api/v1/auth/sessions/terminate-all` | JWT | - | Revoke all active sessions for authenticated user. |
| `GET` | `/api/v1/auth/sessions` | JWT | - | List active sessions (device, IP, created at, last active) for authenticated user. |
| `GET` | `/api/v1/users/me` | JWT | - | Return authenticated user identity, phone status, and default account context. |
| `GET` | `/api/v1/accounts/my-accounts` | JWT | - | Return list of active accounts accessible to user for tenant context selection. |

*Note: All endpoints accept and validate `X-Account-ID` when present, bound via `AccountContextInterceptor`.*

---

## 6. Redis Key Structure & Topology Compliance

All Redis operations utilize `redis_cache` (Port 6379, `allkeys-lru`) strictly as an acceleration tier:

| Key Pattern | Type | TTL | Purpose | Outage Fallback |
|---|---|---|---|---|
| `otp:cooldown:<phone>:<purpose>` | String (`"1"`) | 60s | Fast-Path Acceleration: Resend cooldown between consecutive OTP requests. | Atomic PostgreSQL transaction + dual advisory locks (60s cooldown check). |
| `otp:ratelimit:phone:<phone>:<purpose>` | Integer | 15m | Fast-Path Acceleration: Max 3 requests per 15m window. | Atomic PostgreSQL transaction + dual advisory locks (max 3 count check). |
| `otp:ratelimit:ip:<ip_address>` | Integer | 15m | Fast-Path Acceleration: Max 10 requests per 15m window per IP. | Atomic PostgreSQL transaction + dual advisory locks (`audit_log` max 10 count check). |
| `account:display:<accountId>` | String (JSON) | 300s | Non-Security Display Cache: Caches public account metadata (`displayName`, `slug`, `logoUrl`) for UI rendering only. **Never used for authorization.** | Query `accounts` table directly in PostgreSQL. |

*Important Architectural Guardrail:* In V1, Account Membership Authorization **never** reads from Redis. `AccountTenantGuard` executes a direct PostgreSQL query against `account_members` for every request presenting `X-Account-ID`.  
*`redis_queue` (Port 6380, `noeviction` + AOF) is strictly reserved for BullMQ background jobs.*

---

## 7. Threat Model & Security Mitigations

| Threat Vector | Mitigation Strategy | Authoritative Mechanism |
|---|---|---|
| **OTP Brute Force** | Max 5 attempts enforced across distributed nodes under high concurrency. | **PostgreSQL:** Row-level locking (`SELECT ... FOR UPDATE`), atomic `attempts = attempts + 1`. Challenge locked permanently at 5 attempts. |
| **OTP Replay / Race Condition** | Prevent multiple simultaneous verifications of single OTP. | **PostgreSQL:** Serialized `FOR UPDATE` transaction + atomic `is_consumed = TRUE WHERE is_consumed = FALSE RETURNING id`. Single consumption guaranteed. |
| **Concurrent Invalid Attempt Collision** | Invalid attempt must not consume valid OTP challenge. | **PostgreSQL:** Row lock serializes attempts; invalid code only increments `attempts` and rolls back/commits without touching `is_consumed`. Valid attempt verifies and consumes cleanly. |
| **Cross-Purpose OTP Reuse** | Prevent using verification OTP for unauthorized login. | **Domain Logic + DB:** Strict `purpose` check in query. OTP generated for verification fails login. |
| **Refresh Token Replay & Theft** | Stolen refresh token presented after rotation. | **PostgreSQL:** Revoked hashes retained. Match on `is_revoked = TRUE` triggers **immediate family revocation**. No grace window. |
| **Concurrent Refresh Race** | Network jitter or concurrent duplicate refresh requests. | **PostgreSQL + Zero Grace:** Row-level `FOR UPDATE` lock. First request rotates token; any concurrent replay immediately detects reuse and revokes entire family. |
| **SMS Exhaustion & Bombing** | Malicious script spamming SMS gateway. | **Dual Layer:** Redis rate limiting accelerated + Atomic PostgreSQL fallback with independent advisory locks (`phone_lock`, `ip_lock`) acquired in fixed ascending order, enforcing 3/15m Phone, 10/15m IP, and 60s cooldown in the same transaction + Turnstile validation. |
| **Tenant Impersonation (IDOR)** | Attacker sending arbitrary `X-Account-ID`. | **Direct PostgreSQL Authority:** `AccountTenantGuard` validates active row in `account_members` joined with `accounts` directly in PostgreSQL on every request. |
| **Stale Membership Cache Exploitation** | Revoked member retains access via stale cache. | **Zero Cache Reliance for Access Control:** Redis is NEVER queried for authorization decisions. PostgreSQL is the direct reference; revoking membership takes effect immediately on the very next request, completely resilient to Redis outages. |
| **Secrets Exposure in Storage/Logs** | Leakage of OTPs or refresh tokens via DB or logs. | **Cryptographic Hashing:** OTPs hashed with SHA-256 + secret pepper; refresh tokens hashed with SHA-256; zero plaintext in storage/logs. |

---

## 8. Step-by-Step Implementation Sequence

1. **Step 1: Baseline Architecture Sign-Off**
   - Review and certify `31_PHASE_03_IMPLEMENTATION_PLAN.md`.
2. **Step 2: Core Identity & Normalization**
   - Implement `PhoneNormalizationService` with comprehensive Egyptian mobile prefix tests (`+2010`, `+2011`, `+2012`, `+2015`).
3. **Step 3: Decoupled SMS Gateway Adapter**
   - Implement `ISmsGatewayAdapter` and `DevMockSmsAdapter`. Configure production safe-failure guard.
4. **Step 4: PostgreSQL-Authoritative OTP Engine**
   - Implement `OtpService` with PostgreSQL atomic transactions:
     - **Verification:** Row-level locking (`SELECT ... FOR UPDATE`), constant-time `code_hash` comparison (`timingSafeEqual`), atomic attempt increment on failure, strict 5-attempt ceiling under concurrency, single-use atomic consumption, and isolation from invalid attempts.
     - **Dispatch:** Fast-path Redis rate limiting and cooldown, backed by atomic PostgreSQL fallback using independent Phone and IP advisory locks acquired in fixed ascending order (`ORDER BY k ASC`), enforcing 3 req/15m (Phone), 10 req/15m (IP), and 60s cooldown inside the same transaction.
5. **Step 5: Session Engine & Token Family Lineage (Zero Grace Window)**
   - Implement `SessionService` managing persistent token records, atomic rotation with row-level locking (`SELECT ... FOR UPDATE`), zero-grace replay defense, and family revocation upon reuse detection. Plaintext tokens are never stored or recovered.
6. **Step 6: Account Context Foundation & Direct PostgreSQL Membership Authorization**
   - Implement `AccountContextInterceptor` (extracts and binds `X-Account-ID`) and `AccountTenantGuard` (enforces direct PostgreSQL query against `account_members` with zero dependency on Redis cache for authorization).
   - Configure Redis cache solely for non-security account display metadata (`account:display:<accountId>`).
   - Update user registration transaction to atomically generate default `individual` account and `owner` membership.
   - Implement `GET /api/v1/accounts/my-accounts`.
   - Implement integration tests proving immediate revocation blocks access on the subsequent request, even when Redis is offline.
7. **Step 7: Security Audit Service**
   - Implement `SecurityAuditService` to record all authentication, rotation, reuse, and session termination events in `audit_log`.
8. **Step 8: Auth & Session Controllers**
   - Refactor `AuthController` (send, resend, verify, refresh, logout) and create `SessionController` (list, terminate-all).
9. **Step 9: Test Suite Execution**
   - Execute Unit Tests, Live PostgreSQL Integration Tests, Live Redis Cache Integration Tests, Concurrency Tests, and Fastify E2E Tests.
10. **Step 10: Final Security Audit & Verification Report**
    - Author `32_PHASE_03_AUTHENTICATION_SECURITY_REPORT.md` and certify Phase 03 in `BACKEND_PROJECT_STATUS.md`.

---

## 9. Comprehensive Acceptance Criteria Matrix

| Item | Requirement | Verification Method | Pass Criteria |
|---|---|---|---|
| **AC-01** | **PostgreSQL OTP Verification Authority & Row Locking** | Integration Test | Verification executes `SELECT ... FOR UPDATE` on OTP row. Attempt count persists in PostgreSQL. Evicting Redis cache or stopping Redis during verification has zero impact on attempt counting or brute-force lockout at 5 attempts. |
| **AC-02** | **Atomic OTP Consumption & Concurrency Isolation** | Concurrency Test | 10 concurrent requests with correct OTP code yield exactly 1 success (200 OK) and 9 rejections (400 Bad Request / Replay). Concurrent invalid attempt increments attempts but never consumes valid OTP challenge. |
| **AC-03** | **OTP Purpose Isolation** | Unit & E2E Test | OTP generated with `purpose: PHONE_VERIFICATION` is rejected with 400 Bad Request when submitted to `purpose: LOGIN`. |
| **AC-04** | **Atomic PostgreSQL Fallback & Redis Outage Concurrency** | Concurrency Integration Test | With Redis offline: (1) 10 concurrent OTP dispatch requests for same phone are serialized via advisory locks; max 3 requests allowed per 15m and 60s cooldown strictly enforced; (2) 20 concurrent requests across distinct phones from same IP yield exactly 10 successes and 10 rejections with 429; (3) Advisory locks acquired in deterministic sorted order (`ORDER BY k ASC`), proving zero deadlocks under high concurrency. |
| **AC-05** | **Dual-Redis Compliance** | Inspection | Only `redis_cache` (6379) and `redis_queue` (6380) connections exist; zero third Redis instances introduced. |
| **AC-06** | **Persistent Token Lineage** | Integration Test | Refresh token rotation marks predecessor `is_revoked = TRUE` while retaining hash and inserting new token with identical `family_id`. Plaintext tokens are never stored. |
| **AC-07** | **Token Family Revocation** | E2E Test | Presenting an already-revoked refresh token revokes all tokens sharing that `family_id`, leaving unrelated sessions active. |
| **AC-08** | **Zero-Grace Refresh Token Replay Prevention & Family Revocation** | Concurrency & Security Test | Presenting an already-consumed/rotated refresh token (even within milliseconds or with identical fingerprint) immediately triggers Token Reuse Detection, instantly revokes the entire token family (`is_revoked = TRUE`), logs a `SECURITY_ALERT` in `audit_log`, and returns 401 Unauthorized. No grace window, replay allowance, or child token recovery is permitted. |
| **AC-09** | **SMS Gateway Decoupling** | Unit Test | Core logic depends strictly on `ISmsGatewayAdapter`; `DevMockSmsAdapter` logs locally; production without credentials fails with 503. |
| **AC-10** | **SMS Misr Independence** | Blueprint Audit | No hardcoded assumption of SMS Misr approval; documented as open commercial decision. |
| **AC-11** | **Password Auth Exclusion** | Code & API Audit | Zero password login endpoints (`/auth/password/login`) or password auth handlers implemented in Phase 03. |
| **AC-12** | **Direct PostgreSQL Account Context Authorization** | Integration & E2E Test | Every request presenting `X-Account-ID` is verified directly against PostgreSQL `account_members` joined with `accounts` without consulting Redis cache. Returns 403 Forbidden for unauthorized or inactive tenant contexts. |
| **AC-13** | **Default Account Creation** | Integration Test | First-time phone OTP registration creates User, default `individual` Account, and `owner` membership in a single transaction. |
| **AC-14** | **Security Audit Trail** | Integration Test | Audit log records structured entries for `OTP_SENT`, `OTP_VERIFIED`, `TOKEN_ROTATED`, `TOKEN_REUSE_DETECTED`, and `SESSION_REVOKED`. |
| **AC-15** | **Zero Regressions & Scaffolding** | Build & Test Suite | TypeScript compiles with 0 errors (`npm run build`); linter passes (`npm run lint`); 0 changes to `market_space/` (Flutter). |
| **AC-16** | **Immediate Membership Revocation & Redis Outage Independence** | Integration Test | Revoking a user's membership in PostgreSQL `account_members` immediately blocks subsequent requests with `X-Account-ID` with 403 Forbidden on the very next HTTP request. Verified with Redis stopped/offline to prove zero security dependency on cache. |
| **AC-17** | **Strict Non-Security Redis Cache Boundary** | Inspection & Integration Test | Redis cache is never queried for authorization decisions and is strictly restricted to non-security display metadata (`account:display:<accountId>`). |
| **AC-18** | **OTP Verification Concurrency & Brute-Force 5-Attempt Ceiling** | Concurrency Test | 10 concurrent invalid OTP attempts increment attempts counter sequentially up to 5 and permanently lock the challenge. Subsequent attempts (even with correct code) are rejected with 401. |
