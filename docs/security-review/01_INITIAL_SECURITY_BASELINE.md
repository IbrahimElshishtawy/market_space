# Deal One Backend — Initial Security Baseline Audit

**Document Reference:** `docs/security-review/01_INITIAL_SECURITY_BASELINE.md`  
**Evaluation Date:** 5 November 2026  
**Auditor:** Deal One Independent Security Reviewer (Agent 2) — Principal Application Security Engineer & Security Architect  
**Target System:** Deal One Classifieds Marketplace Backend (`market_space/backend`)  
**Architecture Baseline:** NestJS 10 + Fastify + PostgreSQL 16 (PostGIS 3.4) + Dual Redis 7.2  
**Baseline Security Status:** **SECURITY BLOCKED (CRITICAL VULNERABILITIES IDENTIFIED)**  

---

## 1. Executive Security Summary

An independent, source-code-level application security baseline audit of the Deal One backend repository was performed. The audit reviewed authentication, authorization, session management, database architecture, input validation, external integration webhooks, cryptography, rate limiting, and infrastructure configuration across the 28-table Modular Monolith codebase.

While foundational architectural patterns (Argon2id password hashing, E.164 phone normalization, refresh token family rotation, Fastify Helmet integration, and structured Pino logging) have been established, **the current implementation exhibits critical security defects and architectural disconnects that block production release.**

### Key Threat Vectors & High-Risk Baseline Deficiencies:
1. **Public PII Exposure (Bulk Scraping Vulnerability):** The public listings feed (`GET /api/v1/listings`) and search endpoint (`GET /api/v1/search`) return the seller's raw private phone number (`sellerPhone`) on every result item without authentication, bypassing the monetization model and contact quotas (ADR-008).
2. **Unauthenticated Webhook Bypass & Arbitrary Data Tampering (Cloudflare Stream):** The video webhook endpoint (`POST /api/v1/media/video/webhook`) completely ignores signature headers. An unauthenticated attacker can forge callbacks and execute arbitrary mass database updates on `listingMedia` records using substring matching.
3. **Unauthenticated Payment Webhook Bypass (Paymob):** In `payments.service.ts`, HMAC signature verification is bypassed if the `hmac` query parameter is omitted or if default secrets are in place. Attackers can forge payment success notifications and obtain free listing promotions.
4. **Bypassed Content Moderation:** `createListing` automatically sets `moderationStatus: 'approved'` and `publicationStatus: 'published'`, allowing any user to publish arbitrary content without Trust & Safety review.
5. **Committed Secrets in Version Control:** Production credentials (`JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, PostgreSQL passwords) are hardcoded in `docker-compose.yml`.
6. **Decoupled Admin RBAC & Role Forgery:** The database defines `StaffUser` and `StaffRole` tables, but `JwtStrategy` validates against the `User` table and trusts the JWT `payload.role` string directly. No admin login flow exists in the API, yet anyone holding the JWT secret can forge a `SUPER_ADMIN` token that is blindly accepted.
7. **Complete Absence of Ingress Rate Limiting:** Although `RateLimitGuard` exists in `core/guards`, it is not applied globally or to public feed/search endpoints, exposing the system to scrapers and DoS attacks.
8. **Incomplete Demo Data Guard in Production Seeder:** The database seed script (`seed.ts`) logs a warning when run in production without `ALLOW_DEMO_SEEDING`, but fails to halt, continuing to seed demo accounts and listings directly into the database.

---

## 2. In-Depth Baseline Security Evaluation

### 2.1 Authentication & Session Management
- **Phone OTP Flow:**
  - Egyptian mobile normalization conforms to E.164 (`+201[0125]XXXXXXXX`).
  - OTP codes are generated via `crypto.randomInt(100000, 999999)` (6-digit cryptographically secure).
  - Codes are stored as SHA-256 hashes with application pepper.
  - Expiry is set to 180 seconds (3 minutes) with a 60-second resend cooldown enforced via Redis.
  - **Vulnerability Identified (DO-SEC-009):** The 5-attempt ceiling in `verifyOtp` is vulnerable to concurrent race conditions because lookup and increment operations are not performed under row-level database locking (`SELECT ... FOR UPDATE`).
- **JWT & Session Security:**
  - Token signing uses HMAC-SHA256 with 15-minute access token expiry and 30-day refresh token expiry.
  - Refresh token rotation employs family IDs with reuse detection. When a reused token is detected, all sessions in the family are revoked (`isRevoked: true`).
  - Refresh tokens are stored as SHA-256 hashes in the `user_sessions` table.
  - **Defect Identified (DO-SEC-006):** Token issuance hardcodes `role: 'USER'`. `JwtStrategy.validate` relies purely on `payload.role || 'USER'` without checking any database staff record.
- **Password Hashing:**
  - Fallback password login utilizes `argon2id` via the `argon2` npm package.
  - Password hashes are stored in `User.passwordHash` (`VARCHAR(255)`).
- **Logout & Invalidation:**
  - `POST /auth/logout` allows revoking a session by refresh token. However, the endpoint lacks `@UseGuards(JwtAuthGuard)`, relying on client-supplied token hashes.

### 2.2 Authorization & Access Control
- **Role-Based Access Control (RBAC):**
  - Enforced via `@Roles(...)` decorator and `RolesGuard`.
  - Roles defined: `USER`, `MODERATOR`, `SUPER_ADMIN`.
  - Admin endpoints (`/admin/categories`, `/admin/moderation/queue`, `/admin/audit-logs`) require `SUPER_ADMIN` or `MODERATOR`.
  - **Defect:** No mechanism exists for legitimate administrators to authenticate via API, creating complete operational reliance on mock tokens or direct database intervention.
- **Tenant Isolation & Team RBAC:**
  - Multi-tenant model defined in `schema.prisma` (`Account`, `AccountMember`, `Branch`).
  - Roles defined: `owner`, `manager`, `lister`, `responder`.
  - `AccountTenantGuard` was implemented with Redis caching and role permission resolution, but **is not attached to any controller in the application**.
- **Object-Level Authorization (IDOR):**
  - `updateListingStatus` verifies `listing.account.ownerUserId === userId` (Pass).
  - `getMyAccounts` filters by `userId` (Pass).
  - `getMyFavorites` filters by `userId` (Pass).
  - `getMessages` and `sendMessage` check `conversation.buyerUserId === userId || conversation.sellerAccount.ownerUserId === userId` (Pass for owner, but blocks legitimate team members).
  - **Vulnerability Identified (DO-SEC-011):** `getListingById` only excludes `publicationStatus === 'archived'`. Any unauthenticated user can view draft, pending review, or rejected listings by UUID.

### 2.3 Input Validation & Data Handling
- **DTO Validation:**
  - Global `ValidationPipe` configured in `main.ts` with `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`.
  - DTOs enforce `class-validator` rules (`@IsUUID()`, `@IsString()`, `@IsNumber()`, `@Min()`, `@MaxLength()`).
- **Dynamic Attributes:**
  - Category dynamic fields are validated in `listings.service.ts` against `CategoryField.isRequired`.
- **Search Query:**
  - Keyword `q` is normalized via `arabic-normalizer.ts` (normalizing alef forms, taa marbuta, stripping diacritics).

### 2.4 File Uploads & Media Security
- **Image Presigned Uploads:**
  - Presigned upload requests require authentication (`@UseGuards(JwtAuthGuard)`).
  - Content types restricted to `image/jpeg`, `image/png`, `image/webp`. SVG is prohibited (mitigating SVG XSS).
  - Storage key namespace is isolated per user: `uploads/images/${YYYY-MM}/${userId}/${uuid}.${ext}`.
  - `createListing` validates that all submitted `mediaKeys` contain `/${userId}/`, preventing users from hijacking other users' uploaded images.
  - **Architectural Gap:** Presigned URLs are mocked with random tokens; real AWS S3 / Cloudflare R2 SDK is uninstalled.
- **Video Direct Uploads & Webhook:**
  - Requesting an upload token requires JWT authentication.
  - Maximum duration is capped at 30 seconds.
  - **Critical Vulnerability (DO-SEC-002):** The processing webhook does not authenticate caller or verify Cloudflare Stream signatures.

### 2.5 Database & Data Isolation
- **PostgreSQL 16 & PostGIS 3.4:**
  - 28 relational tables migrated with strict foreign key constraints and cascade rules.
  - Spatial indexes (`GiST`) created on `areas.centroid`, `branches.location`, `listings.physicalLocation`, `listings.displayLocation`.
  - GIN index created on `listings.attributes`.
  - Multi-column index created on `listings(moderationStatus, publicationStatus, availabilityStatus, categoryId, refreshedAt)`.
- **Demo Data Isolation:**
  - Schema includes `is_demo` boolean flags with index on `users`, `accounts`, `listings`.
  - Dedicated seed reset script (`npm run prisma:seed:reset-demo`) selectively deletes records where `isDemo: true`.
  - **Defect (DO-SEC-013):** Production safety check in `seed.ts` does not stop execution before demo insertion.

### 2.6 External Integrations
- **SMS Gateway:**
  - `SmsMisrAdapter` and `MockSmsAdapter` configured via `SMS_GATEWAY_ADAPTER` interface.
  - `MockSmsAdapter` throws an error if executed in `NODE_ENV=production` (Security Defense in Depth - Pass).
- **Paymob Payment Gateway:**
  - `PaymentsService` implements checkout initiation and webhook processing.
  - **Critical Vulnerability (DO-SEC-003):** Webhook signature verification is conditionally bypassed if query parameter `hmac` is missing.
  - Database tables for payments (`payments`, `promotion_packages`) do not exist in `schema.prisma`.

### 2.7 Infrastructure, Networking & Operational Security
- **CORS:**
  - Configured in `main.ts` with `credentials: true`.
  - Defaults to `CORS_ORIGIN=*`. In Fastify CORS, setting `origin: true` mirrors the Request Origin, permitting arbitrary sites to make credentialed requests.
- **HTTP Security Headers:**
  - Helmet enabled, but `contentSecurityPolicy: false` disabled globally.
- **Container Privileges:**
  - `Dockerfile` runs as non-root user `USER node` (Pass).
  - Entrypoint fixed to `dist/src/main.js` (Pass).
- **Secrets Management:**
  - Critical production secrets committed directly in `docker-compose.yml` (Critical Failure).

---

## 3. Security Scorecard by Domain

| Domain | Status | Critical Issues | High Issues | Medium Issues | Notes |
|---|:---:|:---:|:---:|:---:|---|
| **Authentication & Tokens** | CONDITIONAL | 0 | 1 | 1 | Zero-grace rotation solid; OTP race condition under concurrency. |
| **Authorization & RBAC** | FAILED | 0 | 2 | 1 | AccountTenantGuard unbound; Admin RBAC decoupled from DB. |
| **Data Privacy & PII** | FAILED | 1 | 1 | 0 | Phone numbers leaked in public feed and search results. |
| **Listing Moderation** | FAILED | 0 | 1 | 1 | Listings auto-approved upon creation; draft/rejected readable. |
| **Media & Webhooks** | FAILED | 1 | 0 | 0 | Unauthenticated video webhook allows bulk data tampering. |
| **Payments & Billing** | FAILED | 1 | 0 | 0 | HMAC validation bypassed when hmac parameter omitted. |
| **Rate Limiting & DoS** | FAILED | 0 | 1 | 0 | RateLimitGuard not mounted; IP spoofing via X-Forwarded-For. |
| **Database & Demo Safety** | CONDITIONAL | 0 | 0 | 1 | is_demo schema present, but seed script lacks production halt. |
| **Infrastructure & Secrets**| FAILED | 0 | 1 | 1 | Committed secrets in docker-compose.yml; CSP disabled. |
| **OVERALL BASELINE** | **BLOCKED** | **3** | **7** | **5** | **15 Active Findings — Production Gate Blocked** |

---

## 4. Immediate Remediation Priorities

1. **Patch PII Exposure Immediately:** Strip `sellerPhone` and owner phone queries from `listings.service.ts` and `search.service.ts`.
2. **Secure Video & Payment Webhooks:** Require strict HMAC/signature verification; reject any webhook call lacking a valid signature header or token.
3. **Restore Moderation Controls:** Default new listings to `moderationStatus: 'pending'` and `publicationStatus: 'unpublished'`.
4. **Enforce Rate Limiting:** Mount `RateLimitGuard` globally and configure Fastify `trustProxy` properly.
5. **Sanitize Configuration:** Purge hardcoded secrets from `docker-compose.yml` and enforce mandatory environment variable injection.
6. **Implement Staff Authentication:** Connect administrative guards to the existing `StaffUser` and `StaffRole` schema.
