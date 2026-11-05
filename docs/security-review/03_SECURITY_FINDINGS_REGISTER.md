# Deal One — Security Findings Register

**Document Reference:** `docs/security-review/03_SECURITY_FINDINGS_REGISTER.md`  
**Current Date:** 5 November 2026  
**Auditor:** Deal One Independent Security Reviewer (Agent 2)  
**Total Identified Findings:** 15  
**Critical:** 3 | **High:** 5 | **Medium:** 5 | **Low:** 2 | **Informational:** 0  
**Overall Release Gate:** **BLOCKED (CRITICAL & HIGH VULNERABILITIES MUST BE REMEDIATED)**  

---

## 1. Findings Register Summary Table

| Finding ID | Severity | Category | Affected Component & Endpoint | Status |
|---|:---:|---|---|:---:|
| **DO-SEC-001** | **CRITICAL** | Data Exposure / Privacy Violation | `listings.service.ts`, `search.service.ts` | **OPEN (BLOCKER)** |
| **DO-SEC-002** | **CRITICAL** | Broken Access Control / DoS | `video.service.ts` (`POST /media/video/webhook`) | **OPEN (BLOCKER)** |
| **DO-SEC-003** | **CRITICAL** | Business Logic / Broken Authentication | `payments.service.ts` (`POST /payments/webhook`) | **OPEN (BLOCKER)** |
| **DO-SEC-004** | **HIGH** | Business Logic / Moderation Bypass | `listings.service.ts` (`POST /listings`) | **OPEN (BLOCKER)** |
| **DO-SEC-005** | **HIGH** | Security Misconfiguration / Secret Leakage | `docker-compose.yml` (JWT & DB Credentials) | **OPEN (BLOCKER)** |
| **DO-SEC-006** | **HIGH** | Broken Access Control / Role Forgery | `jwt.strategy.ts`, `auth.service.ts` | **OPEN (BLOCKER)** |
| **DO-SEC-007** | **HIGH** | Lack of Rate Limiting / DoS Exposure | `RateLimitGuard`, Public Ingress Controllers | **OPEN (BLOCKER)** |
| **DO-SEC-008** | **HIGH** | Broken Object Authorization / Quota Bypass | `listings.controller.ts` (`POST /listings/:id/contact`) | **OPEN (BLOCKER)** |
| **DO-SEC-009** | **HIGH** | Concurrency / Brute-Force Bypass | `otp.service.ts` (`verifyOtp`) | **OPEN (BLOCKER)** |
| **DO-SEC-010** | **MEDIUM** | Broken Access Control / Tenant Isolation | `account-tenant.guard.ts` (Unused) | **OPEN** |
| **DO-SEC-011** | **MEDIUM** | Information Disclosure | `listings.service.ts` (`GET /listings/:id`) | **OPEN** |
| **DO-SEC-012** | **MEDIUM** | Improper Lifecycle / Data Retention | `users.service.ts` (`DELETE /users/me`) | **OPEN** |
| **DO-SEC-013** | **MEDIUM** | Environment Safety / Demo Leakage | `prisma/seeds/seed.ts` | **OPEN** |
| **DO-SEC-014** | **LOW** | Security Misconfiguration | `main.ts` (Global CSP Disabled) | **OPEN** |
| **DO-SEC-015** | **LOW** | Information Disclosure | `health.controller.ts` (`/health/live`, `/health/ready`) | **OPEN** |

---

## 2. Detailed Security Findings

### DO-SEC-001: Bulk Private Phone Number Leakage in Public Feed and Search APIs
- **Severity:** **CRITICAL**
- **Category:** Sensitive Data Exposure / PII Leakage / Business Quota Bypass
- **Location:** `backend/src/modules/listings/listings.service.ts` (lines 298, 346) & `backend/src/modules/search/search.service.ts` (lines 122, 150)
- **Evidence:**
  In `listings.service.ts`:
  ```typescript
  // Line 298: Relational query pulls owner phone number
  account: {
    select: {
      // ...
      owner: { select: { phone: true, fullName: true } },
    },
  }
  // Line 346: Mapped response outputs phone number into public feed
  sellerPhone: item.account.owner.phone,
  ```
  The identical pattern is repeated in `search.service.ts` line 150:
  ```typescript
  sellerPhone: item.account?.owner?.phone ?? '',
  ```
- **Impact:**
  Anyone on the internet without an account can query `GET /api/v1/listings` or `GET /api/v1/search` and scrape every marketplace seller's private mobile phone number in bulk. This violates Egyptian data privacy principles, exposes users to spam and telemarketing, and destroys Deal One's core business model where contact details are protected behind quota-restricted reveal actions (`POST /listings/:id/contact`, ADR-008, Decision 02).
- **Reproduction:**
  ```bash
  curl -s -X GET "http://localhost:3000/api/v1/listings?limit=5" | jq '.data[] | {id: .id, title: .title, sellerPhone: .sellerPhone}'
  ```
  Observe that valid mobile numbers (e.g., `+201001122331`) are returned without any authentication or quota deduction.
- **Recommended Fix:**
  1. Remove `owner.phone` from the Prisma select clause in `listings.service.ts` and `search.service.ts`.
  2. Strip `sellerPhone` from feed and search item mappings.
  3. Enforce that seller contact information is exclusively obtainable via the authoritative `POST /api/v1/listings/:id/contact` endpoint.
- **Regression Test:**
  Assert that `GET /api/v1/listings` and `GET /api/v1/search` payloads do not contain `sellerPhone` or `phone` keys, and that tests verify these fields are `undefined`.
- **Status:** **OPEN**

---

### DO-SEC-002: Unauthenticated Webhook Signature Bypass & Mass Record Tampering (Cloudflare Stream)
- **Severity:** **CRITICAL**
- **Category:** Broken Access Control / Insecure Deserialization / Mass Tampering
- **Location:** `backend/src/modules/video/video.controller.ts` (lines 42-51) & `backend/src/modules/video/video.service.ts` (lines 49-65)
- **Evidence:**
  ```typescript
  // video.service.ts
  async handleWebhook(payload: any, _signatureHeader?: string) {
    // In production, verifies webhook secret signature (NOT IMPLEMENTED)
    const uid = payload?.uid || payload?.data?.uid;
    const readyToStream = payload?.readyToStream || payload?.data?.readyToStream;

    if (uid) {
      await this.prisma.listingMedia.updateMany({
        where: { storageKey: { contains: uid } },
        data: {
          processingStatus: readyToStream ? 'ready' : 'failed',
        },
      });
    }

    return { received: true };
  }
  ```
- **Impact:**
  1. The endpoint `POST /api/v1/media/video/webhook` requires zero authentication and completely discards `_signatureHeader`.
  2. The database query uses `storageKey: { contains: uid }`. If an attacker passes `{ "uid": "cloudflare-stream", "readyToStream": false }` or `{ "uid": "", "readyToStream": false }`, **every single video and image in the entire marketplace database will be updated to `processingStatus: 'failed'`**, instantly breaking all video feeds and listings across the platform.
- **Reproduction:**
  ```bash
  curl -X POST "http://localhost:3000/api/v1/media/video/webhook" \
    -H "Content-Type: application/json" \
    -d '{"uid": "cloudflare-stream", "readyToStream": false}'
  ```
- **Recommended Fix:**
  1. Verify the Cloudflare Stream webhook signature using HMAC-SHA256 with `CLOUDFLARE_STREAM_WEBHOOK_SECRET` and timestamp validation (to prevent replay attacks).
  2. If signature is invalid or absent, immediately reject with `401 Unauthorized`.
  3. Validate that `uid` is an exact UUID regex format (`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$` or Cloudflare 32-char hex).
  4. Use exact storage key matching (`where: { storageKey: `cloudflare-stream/${uid}` }`) rather than wildcard substring `contains`.
- **Regression Test:**
  Unit and integration tests sending requests without signature header, with invalid signature header, or with non-UUID payloads, verifying `401 Unauthorized` and `400 Bad Request`.
- **Status:** **OPEN**

---

### DO-SEC-003: Paymob Payment Webhook HMAC Verification Bypass & Free Promotions
- **Severity:** **CRITICAL**
- **Category:** Business Logic Vulnerability / Authentication Bypass / Financial Fraud
- **Location:** `backend/src/modules/payments/payments.service.ts` (lines 141-147, line 240)
- **Evidence:**
  ```typescript
  // payments.service.ts
  async handlePaymobWebhook(payload: any, incomingHmac?: string) {
    const obj = payload?.obj || payload;

    // In production with PAYMOB_HMAC_SECRET configured, validates SHA512 signature
    if (incomingHmac && this.hmacSecret !== 'test_hmac_secret') {
      const isValid = this.verifyHmac(obj, incomingHmac);
      if (!isValid) {
        throw new UnauthorizedException('Invalid Paymob HMAC signature');
      }
    }
    // Execution continues to mark payment as SUCCESS!
  ```
- **Impact:**
  An attacker can trigger `POST /api/v1/payments/webhook` without appending the `?hmac=` parameter in the query string. The entire HMAC signature check is bypassed. The endpoint marks the target transaction as `SUCCESS`, granting paid features (Bump to Top, 7-day featured ad, 14-day featured ad) without any payment verification. In addition, line 240 uses non-constant-time equality (`calculated === incomingHmac`), which is susceptible to timing attacks.
- **Reproduction:**
  ```bash
  curl -X POST "http://localhost:3000/api/v1/payments/webhook" \
    -H "Content-Type: application/json" \
    -d '{"obj": {"id": 999999, "success": true, "order": {"id": "<PENDING_PAYMENT_UUID>"}}}'
  ```
- **Recommended Fix:**
  1. Make `hmac` query parameter strictly mandatory.
  2. Reject all webhook requests where `hmac` is missing or where `PAYMOB_HMAC_SECRET` is unset with `401 Unauthorized`.
  3. Use `crypto.timingSafeEqual` for all HMAC comparisons.
- **Regression Test:**
  Send webhook requests with omitted HMAC, malformed HMAC, and mismatched HMAC, verifying that each returns `401 Unauthorized` and that payment status remains `PENDING`.
- **Status:** **OPEN**

---

### DO-SEC-004: Automatic Bypass of Listing Content Moderation Upon Creation
- **Severity:** **HIGH**
- **Category:** Business Logic / Broken Moderation Workflow
- **Location:** `backend/src/modules/listings/listings.service.ts` (lines 121-122)
- **Evidence:**
  ```typescript
  const listing = await tx.listing.create({
    data: {
      accountId: account.id,
      categoryId: dto.categoryId,
      areaId: area.id,
      title: dto.title,
      description: dto.description,
      price: dto.price,
      currency: 'EGP',
      listingKind: 'sale',
      contactChannel: 'in_app',
      moderationStatus: 'approved',   // <-- AUTOMATIC APPROVAL
      publicationStatus: 'published', // <-- AUTOMATIC PUBLICATION
      availabilityStatus: 'available',
      attributes: (dynamicAttrs as any) ?? {},
      expiresAt,
    },
  });
  ```
- **Impact:**
  Every listing created by any regular user is immediately marked as approved and published, bypassing human moderation and automated spam/prohibited-goods filters. This enables immediate public propagation of spam, prohibited items (weapons, drugs, counterfeit items), or malicious content.
- **Reproduction:**
  Submit `POST /api/v1/listings` with any user token. Observe that the returned record immediately has `moderationStatus: "approved"` and `publicationStatus: "published"`.
- **Recommended Fix:**
  Default newly created listings to:
  ```typescript
  moderationStatus: 'pending',
  publicationStatus: 'unpublished',
  ```
  Only move to `approved` and `published` following review or according to verified seller trust tiers codified in ADR-004.
- **Regression Test:**
  Ensure `createListing` returns a record with `moderationStatus: 'pending'` and that it does not appear in the public feed until approved.
- **Status:** **OPEN**

---

### DO-SEC-005: Committed Production Secrets & Credentials in Git Repository
- **Severity:** **HIGH**
- **Category:** Security Misconfiguration / Credential Exposure
- **Location:** `docker-compose.yml` (lines 28, 33-34, 52)
- **Evidence:**
  ```yaml
  environment:
    - NODE_ENV=production
    - PORT=3000
    - DATABASE_URL=postgresql://marketspace_app:secretpassword@postgres:5432/marketspace?schema=public
    - JWT_ACCESS_SECRET=production_super_strong_jwt_access_secret_1234567890
    - JWT_REFRESH_SECRET=production_super_strong_jwt_refresh_secret_1234567890
  ```
- **Impact:**
  Anyone with read access to the Git repository possesses the production JWT secret keys and database credentials. They can forge arbitrary JWT access tokens with any `sub` (User ID) or `role: "SUPER_ADMIN"`, bypassing all authentication controls and gaining complete database access.
- **Reproduction:**
  Inspect `docker-compose.yml` in repository.
- **Recommended Fix:**
  1. Replace hardcoded values in `docker-compose.yml` with environment variable interpolations:
     ```yaml
     JWT_ACCESS_SECRET: ${JWT_ACCESS_SECRET:?JWT_ACCESS_SECRET must be set}
     JWT_REFRESH_SECRET: ${JWT_REFRESH_SECRET:?JWT_REFRESH_SECRET must be set}
     DATABASE_URL: ${DATABASE_URL:?DATABASE_URL must be set}
     ```
  2. Rotate all exposed keys and database passwords immediately before any staging or production deployment.
- **Regression Test:**
  Verify with a secret scanning hook that `docker-compose.yml` contains zero literal secret strings.
- **Status:** **OPEN**

---

### DO-SEC-006: Decoupled Admin RBAC & Stateless Role Claim Forgery
- **Severity:** **HIGH**
- **Category:** Broken Access Control / Privilege Escalation
- **Location:** `backend/src/modules/auth/strategies/jwt.strategy.ts` (lines 59-61), `backend/src/modules/auth/auth.service.ts` (lines 196, 283), `backend/prisma/schema.prisma` (lines 524-540)
- **Evidence:**
  1. In `JwtStrategy.validate`:
     ```typescript
     return {
       id: user.id,
       phone: user.phone,
       fullName: user.fullName,
       role: payload.role || 'USER', // <-- Relies solely on JWT claim!
       status: user.isActive ? 'ACTIVE' : 'SUSPENDED',
     };
     ```
  2. In `AuthService`, all logins create sessions with hardcoded `'USER'`. No mechanism exists for staff to log in.
  3. The database defines a separate `StaffUser` and `StaffRole` table, but the authentication layer does not authenticate against it.
- **Impact:**
  - Legitimate administrators cannot log in through the system API.
  - If an attacker gains knowledge of `JWT_ACCESS_SECRET`, they can forge an access token with `{ "role": "SUPER_ADMIN" }`. `JwtStrategy` validates this token against the regular `User` table and trusts the `role` claim without checking whether the user is a staff member, granting full administrative access to moderation and categories management.
- **Reproduction:**
  Sign a JWT token with `role: "SUPER_ADMIN"` and a valid `sub` of any regular user using `JWT_ACCESS_SECRET`. Query `GET /api/v1/admin/moderation/queue`. The endpoint returns `200 OK`.
- **Recommended Fix:**
  1. Implement dedicated staff authentication against the `StaffUser` table, issuing tokens with a distinct issuer/audience (e.g., `deal-one-admin`).
  2. In `JwtStrategy`, verify the user's authoritative role from PostgreSQL rather than trusting the unverified token payload claim.
- **Regression Test:**
  Ensure a regular user token with forged `role: "SUPER_ADMIN"` is rejected by `RolesGuard` or `JwtStrategy` with `403 Forbidden`.
- **Status:** **OPEN**

---

### DO-SEC-007: Absence of Rate Limiting on Ingress Endpoints & IP Spoofing Risk
- **Severity:** **HIGH**
- **Category:** Denial of Service / Lack of Rate Limiting
- **Location:** `backend/src/core/guards/rate-limit.guard.ts` (lines 43-47) and all controller classes
- **Evidence:**
  1. `RateLimitGuard` exists in `core/guards`, but is not registered globally in `main.ts` or decorated on any public controller (`ListingsController`, `SearchController`, `CategoriesController`, `LocationsController`).
  2. In `RateLimitGuard`:
     ```typescript
     const ip =
       request.headers['x-forwarded-for']?.toString().split(',')[0].trim() ||
       request.ip ||
       '127.0.0.1';
     ```
     Fastify is initialized in `main.ts` without `trustProxy: true`. Blindly parsing `x-forwarded-for` allows attackers to bypass IP-based throttlers by sending arbitrary spoofed headers (`X-Forwarded-For: 10.0.0.X`).
- **Impact:**
  The backend is completely unprotected against resource exhaustion, automated scraping, brute-force enumeration, and volumetric denial-of-service attacks.
- **Reproduction:**
  Send 500 rapid requests in a loop to `GET /api/v1/listings`. All 500 requests are processed without encountering HTTP 429.
- **Recommended Fix:**
  1. Register `RateLimitGuard` globally or configure `@fastify/rate-limit`.
  2. Configure Fastify adapter with `trustProxy: true` (or upstream IP range).
  3. Apply default rate limits: 60 req/min for unauthenticated public reads, 20 req/min for search.
- **Regression Test:**
  Execute automated curl loop exceeding limit and assert `429 Too Many Requests`.
- **Status:** **OPEN**

---

### DO-SEC-008: Unauthenticated & Unthrottled Phone Reveal Endpoint
- **Severity:** **HIGH**
- **Category:** Broken Object Authorization / Quota Bypass / Data Exposure
- **Location:** `backend/src/modules/listings/listings.controller.ts` (lines 87-95) & `listings.service.ts` (lines 454-480)
- **Evidence:**
  ```typescript
  @Post(':id/contact')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Record buyer contact action and reveal seller phone number' })
  async contactSeller(@Param('id') id: string) {
    return this.listingsService.recordContactAction(id);
  }
  ```
- **Impact:**
  `recordContactAction` does not require authentication (`JwtAuthGuard` is missing). It does not enforce user or account daily quotas (Decision 02: 15 for individuals, 100 for businesses). Any unauthenticated bot can invoke this endpoint on every listing in the database, extracting phone numbers while inflating `contactRevealsCount`.
- **Reproduction:**
  ```bash
  curl -X POST "http://localhost:3000/api/v1/listings/<LISTING_UUID>/contact"
  ```
  Returns `{"phone": "+201...", "sellerName": "..."}` without any authentication token.
- **Recommended Fix:**
  1. Require `@UseGuards(JwtAuthGuard)` on `POST /listings/:id/contact`.
  2. Enforce atomic daily quota check against `DailyQuota` or Redis Cairo midnight Lua script.
  3. If daily reveal quota is exceeded, reject with `429 Quota Exceeded`.
- **Regression Test:**
  Verify unauthenticated requests return `401 Unauthorized`, and requests beyond daily quota limit return `429`.
- **Status:** **OPEN**

---

### DO-SEC-009: OTP Verification Race Condition Under Concurrency
- **Severity:** **HIGH**
- **Category:** Concurrency / Brute-Force Protection Bypass
- **Location:** `backend/src/modules/auth/services/otp.service.ts` (lines 228-307)
- **Evidence:**
  `verifyOtp` queries the active OTP challenge with `findFirst`, checks `activeOtp.attempts >= this.maxAttempts`, compares the code hash, and if incorrect, updates `attempts: { increment: 1 }`.
  Because this sequence is not wrapped in a database transaction with a row-level lock (`SELECT ... FOR UPDATE`), multiple concurrent HTTP requests can execute `findFirst` simultaneously before `attempts` increments, bypassing the 5-attempt brute-force ceiling.
- **Impact:**
  An attacker can execute a concurrent burst of guesses against a 6-digit OTP code, circumventing the intended brute-force lockout protection.
- **Reproduction:**
  Dispatch 20 concurrent HTTP requests with differing invalid 6-digit codes to `POST /api/v1/auth/otp/verify` in parallel. Observe that more than 5 attempts are evaluated before lockout triggers.
- **Recommended Fix:**
  Wrap the OTP lookup and attempt increment within a Prisma transaction using raw SQL `SELECT * FROM otps WHERE ... FOR UPDATE`, or enforce an atomic Redis attempt counter (`INCR`) prior to evaluating the code.
- **Regression Test:**
  Send 10 concurrent verification requests with invalid codes and assert that exactly 5 are evaluated and the 6th immediately returns `400 Maximum attempts exceeded`.
- **Status:** **OPEN**

---

### DO-SEC-010: Multi-Tenant `AccountTenantGuard` Unbound Across Controllers
- **Severity:** **MEDIUM**
- **Category:** Broken Access Control / Tenant Boundary Architecture
- **Location:** `backend/src/modules/auth/guards/account-tenant.guard.ts`
- **Evidence:**
  `AccountTenantGuard` is defined and unit-tested, but is never applied to any controller (`ListingsController`, `AccountsController`, `ChatController`). Furthermore, line 37 returns `true` if `X-Account-ID` header is omitted, meaning even if mounted, requests omitting the header silently bypass tenant membership validation.
- **Impact:**
  Sellers with multiple accounts or team members cannot operate under verified tenant contexts, and branch/account isolation is not enforced at the route boundary.
- **Recommended Fix:**
  1. Mount `AccountTenantGuard` on routes requiring account context.
  2. Ensure that for merchant endpoints, `X-Account-ID` is mandatory rather than optional.
- **Status:** **OPEN**

---

### DO-SEC-011: Information Disclosure — Draft and Rejected Listings Accessible via ID Lookup
- **Severity:** **MEDIUM**
- **Category:** Information Disclosure / Broken Access Control
- **Location:** `backend/src/modules/listings/listings.service.ts` (lines 399-401)
- **Evidence:**
  ```typescript
  if (!listing || listing.publicationStatus === 'archived') {
    throw new NotFoundException('Listing not found or has been removed');
  }
  ```
  `getListingById` only excludes `'archived'`. It returns listings with `publicationStatus: 'unpublished'`, `hidden`, or `moderationStatus: 'rejected'` / `'pending'` to any unauthenticated caller who knows or guesses the UUID.
- **Impact:**
  Public users can view pending, hidden, or rejected listings that should not be visible.
- **Recommended Fix:**
  Enforce that unauthenticated or non-owner requests only return listings where `publicationStatus === 'published' && moderationStatus === 'approved'`. If the caller is authenticated as the owner or staff, allow viewing non-public statuses.
- **Status:** **OPEN**

---

### DO-SEC-012: Incomplete Account Soft-Deletion Lifecycle
- **Severity:** **MEDIUM**
- **Category:** Incomplete Lifecycle / Privacy & Session Retention
- **Location:** `backend/src/modules/users/users.service.ts` (lines 57-72)
- **Evidence:**
  `softDeleteAccount` updates `User.isActive = false`, `deletedAt = now()`, and `fullName = 'Deleted Account'`. However:
  1. It does not revoke the user's active sessions in `user_sessions`.
  2. It does not unpublish or archive the user's active listings.
  3. It does not deactivate owned `Account` records.
  4. It retains the user's plain phone number in the database.
- **Impact:**
  Deleted accounts can leave orphaned published listings active on the marketplace and retain active sessions until access token expiration.
- **Recommended Fix:**
  Execute soft deletion inside a database transaction that:
  - Revokes all sessions (`user_sessions.isRevoked = true`).
  - Archives all owned listings (`publicationStatus = 'archived'`).
  - Deactivates owned accounts (`accounts.isActive = false`).
  - Hashes/anonymizes the phone number.
- **Status:** **OPEN**

---

### DO-SEC-013: Production Seed Script Fails to Halt Demo Insertion
- **Severity:** **MEDIUM**
- **Category:** Operational Safety / Demo Data Isolation
- **Location:** `backend/prisma/seeds/seed.ts` (lines 64-73, line 248)
- **Evidence:**
  ```typescript
  if (isProd && !allowDemoSeedingInProd) {
    if (isResetOnly) {
      throw new Error('PRODUCTION SAFETY BLOCK...');
    }
    console.warn(
      '⚠️ Notice: Production environment detected. Seeding only base taxonomy and administrative reference data.',
    );
  }
  ```
  The script warns when run in production, but contains no `return` statement after taxonomy seeding. It continues to execute step 4 and step 5, inserting 15 demo sellers and 340 demo listings into the production database.
- **Impact:**
  Accidental execution of `npm run prisma:seed` in production populates fake sellers, fake listings, and demo phone numbers into live production.
- **Recommended Fix:**
  Add an explicit guard after taxonomy seeding:
  ```typescript
  if (isProd && !allowDemoSeedingInProd) {
    console.log('🛑 Halting seed before demo data insertion (Production Mode).');
    return;
  }
  ```
- **Status:** **OPEN**

---

### DO-SEC-014: Global Content Security Policy (CSP) Disabled
- **Severity:** **LOW**
- **Category:** Security Misconfiguration
- **Location:** `backend/src/main.ts` (lines 32-34)
- **Evidence:**
  ```typescript
  await app.register(helmet, {
    contentSecurityPolicy: false, // Allow Swagger UI
  });
  ```
- **Impact:**
  CSP is disabled globally across all API routes to accommodate Swagger UI inline assets, weakening defense-in-depth against XSS.
- **Recommended Fix:**
  Disable CSP only for the `/api/docs` route, or configure explicit nonce/hashes for Swagger assets while enforcing strict CSP on all other endpoints.
- **Status:** **OPEN**

---

### DO-SEC-015: Information Disclosure in Health Readiness Probes
- **Severity:** **LOW**
- **Category:** Information Disclosure
- **Location:** `backend/src/core/health/health.controller.ts` (lines 20-25, lines 51-54)
- **Evidence:**
  `/health/live` exposes internal process memory (`memoryRssMb`) and uptime. `/health/ready` exposes the exact PostGIS version string (`up (3.4.2)`).
- **Impact:**
  Discloses internal system metrics and component versions to unauthenticated callers, assisting attackers in fingerprinting server infrastructure.
- **Recommended Fix:**
  Return simple binary status indicators (`status: "ok"`) on public health routes, restricting diagnostic telemetry to internal metrics scrapers or authenticated admin health endpoints.
- **Status:** **OPEN**
