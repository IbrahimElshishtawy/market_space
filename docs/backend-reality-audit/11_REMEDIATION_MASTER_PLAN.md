# Report 11: Deal One Remediation Master Plan

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Purpose:** Actionable, prioritized engineering roadmap to eliminate all audit findings, close the documentation-reality gap, and achieve true production readiness.

---

## 1. Remediation Priority Framework

Remediation tasks are structured into four rigorous urgency tiers:
- **P0: Immediate Release Blockers** (Must be resolved before any public beta or staging deployment).
- **P1: Critical Contract & Scope Rectifications** (Required to achieve API contract compliance and remove unauthorized modules).
- **P2: Workflow & Integrity Enhancements** (Complete multi-tenant operations, outbox events, and media processing).
- **P3: Technical Hygiene & Documentation Alignment** (Archive obsolete specs, update status matrices, add E2E tests).

---

## 2. P0: Immediate Release Blockers

### REM-P0-01: Eliminate Auto-Approval & Restore Two-Tier Human Moderation Gate
- **Finding ID:** SEC-CRIT-01 / DOC-ARCH-005 / DOC-BIZ-001
- **Affected Files:**
  - `backend/src/modules/listings/listings.service.ts`
  - `backend/src/modules/moderation/moderation.controller.ts`
  - `backend/src/modules/moderation/moderation.service.ts`
- **Required Implementation:**
  1. In `listings.service.ts::createListing`, change default status from `approved`/`published` to `moderationStatus: 'pending'`, `publicationStatus: 'draft'`, `availabilityStatus: 'pending_review'`.
  2. Implement endpoint `POST /listings/:id/submit` to transition a listing from `draft` to `pending`.
  3. Implement admin moderation endpoints in `moderation.controller.ts`:
     - `GET /admin/moderation/listings` (Paginated pending queue).
     - `POST /admin/moderation/listings/:id/decision` (Accepts `{ action: 'approve' | 'reject', rejectionReason?: string }`).
  4. Write every decision to `moderation_log` table within a Prisma transaction, recording moderator ID, action, timestamp, and notes.
- **Acceptance Criteria:**
  - Newly created listing is NEVER visible in `GET /listings` or `GET /search`.
  - Admin decision `approve` sets status to `approved`/`published` and makes the listing visible in public feeds.
  - Rejection notifies the seller and keeps the listing hidden.
- **Estimated Effort:** 8 hours.

---

### REM-P0-02: Remediate PII Leakage and Enforce Contact Reveal Masking
- **Finding ID:** SEC-CRIT-02 / DOC-SEC-002 / DOC-ARCH-009
- **Affected Files:**
  - `backend/src/modules/listings/listings.service.ts`
  - `backend/src/modules/search/search.service.ts`
  - `backend/src/modules/listings/dto/listing-response.dto.ts`
- **Required Implementation:**
  1. In `listings.service.ts` (lines 162, 284) and `search.service.ts` (line 108), remove `sellerPhone: item.account.owner.phone` from all public feed serializers. Replace with masked string (e.g. `+2010*****67`) or boolean flag `hasContactAvailable: true`.
  2. In `listings.service.ts::revealContact`, require authenticated JWT session.
  3. Wire the daily quota check: query `daily_quotas` table for authenticated user. If quota >= 5, throw `403 Forbidden` (`QUOTA_EXCEEDED`).
  4. Deduct quota atomically in PostgreSQL, log reveal event, and return the unmasked phone number and direct WhatsApp link.
- **Acceptance Criteria:**
  - Public feeds (`GET /listings`, `GET /search`) do NOT contain full seller phone numbers.
  - Calling `POST /listings/:id/reveal-contact` without authentication returns 401.
  - Authenticated user cannot reveal more than 5 contacts per day.
- **Estimated Effort:** 6 hours.

---

### REM-P0-03: Implement Missing Core Listing and Account APIs
- **Finding ID:** DOC-API-002 / DOC-API-007 / DOC-API-008
- **Affected Files:**
  - `backend/src/modules/listings/listings.controller.ts`
  - `backend/src/modules/listings/listings.service.ts`
  - `backend/src/modules/accounts/accounts.controller.ts`
  - `backend/src/modules/accounts/accounts.service.ts`
- **Required Implementation:**
  1. Implement `PUT /listings/:id` to allow sellers to update listing title, description, price, attributes, and media.
  2. Implement `DELETE /listings/:id` to perform soft-delete (`deletedAt = now()`, `publicationStatus = 'archived'`).
  3. Implement `PATCH /listings/:id/availability` to toggle `available` / `sold` / `reserved`.
  4. Implement `POST /accounts` to allow verified phone users to register an individual or commercial merchant account.
  5. Implement `POST /accounts/:id/branches` to allow adding physical store showrooms.
- **Acceptance Criteria:**
  - Sellers can edit, withdraw, and mark listings as sold via API.
  - Merchants can register store accounts and add branches.
- **Estimated Effort:** 12 hours.

---

## 3. P1: Critical Contract Alignment & Scope Cleansing

### REM-P1-01: Synchronize NestJS Controller Routes with OpenAPI Contracts
- **Finding ID:** DOC-API-004 / DOC-API-010 / DOC-API-012
- **Affected Files:**
  - `backend/src/modules/categories/categories.controller.ts`
  - `backend/src/modules/chat/chat.controller.ts`
  - `backend/src/modules/users/users.controller.ts`
  - `backend/src/modules/notifications/notifications.controller.ts`
- **Required Implementation:**
  1. Update `categories.controller.ts`: Add `GET /categories/:id/fields` in addition to `:slug/fields`.
  2. Update `chat.controller.ts`: Mount controller at `@Controller('chat/conversations')` to match OpenAPI specification.
  3. Update `users.controller.ts`: Add `@Patch('me')` matching OpenAPI spec.
  4. Update `notifications.controller.ts`: Mount token registration at `POST /users/devices` (or document alias).
  5. Harmonize path parameter naming: Standardize on `:id` or `{accountId}` across both documentation and controllers.
- **Estimated Effort:** 6 hours.

---

### REM-P1-02: Deactivate or Quarantine Out-of-Scope Modules (Payments & Video)
- **Finding ID:** DOC-ARCH-006 / SEC-HIGH-01
- **Affected Files:**
  - `backend/src/app.module.ts`
  - `backend/src/modules/payments/`
  - `backend/src/modules/video/`
- **Required Implementation:**
  1. Unload `PaymentsModule` and `VideoModule` from `app.module.ts` imports for the V1 release build, or gate them behind environment feature flags:
     ```typescript
     ...(process.env.ENABLE_V2_PAYMENTS === 'true' ? [PaymentsModule] : []),
     ...(process.env.ENABLE_V2_VIDEO === 'true' ? [VideoModule] : []),
     ```
  2. Isolate Paymob credentials and remove unauthenticated webhook endpoints from the public ingress router until V2 monetization is scheduled.
- **Estimated Effort:** 3 hours.

---

## 4. P2: Workflow & Integrity Enhancements

### REM-P2-01: Implement Multi-Tenant Team RBAC Endpoints
- **Finding ID:** DOC-API-003 / DOC-SEC-004
- **Affected Files:** `backend/src/modules/accounts/accounts.controller.ts`, `accounts.service.ts`
- **Required Implementation:**
  - Add `GET /accounts/:id/members` to list staff/agents.
  - Add `POST /accounts/:id/members/invite` to invite staff members by phone number.
  - Add `DELETE /accounts/:id/members/:userId` to revoke team access.
  - Protect all routes with `AccountTenantGuard` and `@Roles('owner', 'admin')`.
- **Estimated Effort:** 8 hours.

---

### REM-P2-02: Wire Transactional Outbox Pattern into Domain Entity Services
- **Finding ID:** DOC-ARCH-002 / DOC-ARCH-011
- **Affected Files:**
  - `backend/src/modules/listings/listings.service.ts`
  - `backend/src/modules/moderation/moderation.service.ts`
  - `backend/src/workers/worker.service.ts`
- **Required Implementation:**
  - Within every Prisma transaction updating listing status or user registration, insert an event into `outbox_events` (`eventType: 'LISTING_SUBMITTED'`, `'LISTING_APPROVED'`, etc.).
  - Configure `WorkerService` to poll `outbox_events` and dispatch jobs to BullMQ queue for push notifications, search index sync, and SMS alerts.
- **Estimated Effort:** 6 hours.

---

### REM-P2-03: Implement Direct Upload Confirmation Hook & EXIF Scrubbing
- **Finding ID:** SEC-HIGH-03 / DOC-OPS-003
- **Affected Files:** `backend/src/modules/media/media.controller.ts`, `media.service.ts`, `worker.service.ts`
- **Required Implementation:**
  - Implement `POST /media/confirm-upload` taking `{ s3Key, listingId }`.
  - Dispatch asynchronous BullMQ job to download image from S3, run `sharp().rotate().withMetadata({ exif: false })` to scrub GPS tags, re-upload, and save verified media record to `listing_media`.
- **Estimated Effort:** 6 hours.

---

## 5. P3: Technical Hygiene & Documentation Alignment

### REM-P3-01: Archive Obsolete Specs and Synchronize Status Documentation
- **Finding ID:** DOC-CAT-045 / DOC-CAT-030 / Report 09
- **Required Actions:**
  1. Archive `docs/openapi.yaml` into `docs/archive/legacy_gen1_openapi.yaml`.
  2. Remove redundant duplicate file `backend_blueprint/15_OPENAPI/deal_one_openapi.yaml`.
  3. Update `BACKEND_PROJECT_STATUS.md` and `30_PHASE_02_FINAL_VERIFICATION.md` to accurately report the true implementation counts: 19 fully matched operations, 36 pending implementation, 8 distinct reality scores.
  4. Create an automated CI check: `npm run lint:contracts` that compiles controllers and validates route coverage against `deal_one_openapi.yaml`.
- **Estimated Effort:** 4 hours.

---

### REM-P3-02: Introduce HTTP End-to-End (E2E) Test Suite
- **Finding ID:** DOC-TEST-001 / Report 08
- **Required Actions:**
  - Implement real Supertest HTTP integration test suites in `backend/test/` exercising live routes against containerized PostgreSQL and Redis.
  - Test listing creation, pending moderation state, approval gate, and masked contact reveal.
- **Estimated Effort:** 10 hours.

---

## 6. Remediation Timeline & Resource Summary

| Tier | Items | Focus Area | Total Effort (Hours) |
|:---|:---:|:---|:---:|
| **P0** | 3 Items | Moderation Gate, PII Redaction, Missing CRUD APIs | 26 hrs (~3.5 days) |
| **P1** | 2 Items | OpenAPI Synchronization, Scope Cleansing | 9 hrs (~1.5 days) |
| **P2** | 3 Items | Team RBAC, Outbox Wiring, EXIF Worker | 20 hrs (~2.5 days) |
| **P3** | 2 Items | Doc Cleanup, CI Contract Linter, E2E Tests | 14 hrs (~2 days) |
| **TOTAL** | **10 Items** | **Full Remediation to Production Certification** | **69 hrs (~9-10 engineering days)** |

