# Report 03: Deal One Implementation Reality Report

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Scope:** In-depth source code, NestJS module, service, controller, and runtime artifact inspection.

---

## 1. Architectural Overview & Framework Reality

The Deal One backend application is built on **NestJS 10.x** with **TypeScript 5.9.3**, using **Prisma ORM 5.x**, **PostgreSQL 16 + PostGIS 3.4**, and dual **Redis 7.2** instances (Cache on port 6379, Queue on port 6380).

The application bootstrap in `backend/src/main.ts` sets up:
- Global `ValidationPipe` with `transform: true` and `whitelist: true`.
- Custom `HttpExceptionFilter` with correlation `X-Request-Id` tracing.
- Custom `TransformInterceptor` wrapping successful HTTP responses in `{ success: true, data: ..., meta: ... }`.
- Swagger / OpenAPI document builder exposing documentation at `/api/docs`.

### Overall Code Reality Classification

Every major backend component has been inspected and classified into one of five rigorous reality buckets:
1. **GENUINE IMPLEMENTED**: Production-grade code backed by database persistence and passing automated tests.
2. **PARTIALLY IMPLEMENTED**: Functional skeleton exists, but critical operations, validations, or integrations are incomplete.
3. **PLACEHOLDER / MOCKED ONLY**: Interfaces or mocked adapters exist without real downstream integrations or tests only mock external systems.
4. **COMPLETELY MISSING**: Documented extensively in blueprints/OpenAPI but has 0 lines of implementation.
5. **UNREQUESTED / OUT-OF-SCOPE**: Implemented in code contrary to ADR-008 and V1 product boundaries.

---

## 2. Component Categorization Master Table

| Backend Domain / Subsystem | NestJS Source Path | Reality Bucket | Audit Finding & Detailed Code Reality |
|:---|:---|:---:|:---|
| **Core Architecture & Middleware** | `src/core/*` | **GENUINE** | Request ID tracing, global exception filter, response transformer, env validation, and Redis service are fully functional. |
| **Authentication & Sessions** | `src/modules/auth/*` | **GENUINE** | OTP generation, rate limiting, bcrypt hashing, JWT issuance, and refresh token family rotation with reuse detection are implemented. |
| **SMS Gateway Adapters** | `src/modules/auth/adapters/*` | **PARTIAL** | Mock adapter and SmsMisr adapter exist. In production without valid credentials, SmsMisr falls back with an error; production SMS provider contract is not live. |
| **Categories & Dynamic Attributes** | `src/modules/categories/*` | **GENUINE** | Category retrieval, slug resolution, and dynamic field fetching (`category_fields`) are implemented and verified. |
| **Listing Creation & Retrieval** | `src/modules/listings/*` | **PARTIAL** | Core CRUD, media binding, dynamic attribute JSONB filtering, and slug generation work. However, update and soft-delete endpoints are missing. |
| **Listing Moderation Lifecycle** | `src/modules/listings/*`, `src/modules/moderation/*` | **FAIL / STUB** | **CRITICAL FLAW**: Listing creation bypasses human moderation by hardcoding status to `approved`/`published`. State machine exists only in a test file. No moderation decision API exists for listings. |
| **Seller Accounts & Profiles** | `src/modules/accounts/*` | **PARTIAL** | `GET /accounts/:id` and `GET /accounts/:id/branches` exist. However, `POST /accounts`, branch creation, and business profile updates are completely missing. |
| **Multi-Tenant Team RBAC** | `src/modules/accounts/*` | **MISSING** | `account_members` table exists in schema, but zero controller routes exist for team management (`GET /accounts/:id/members`, invite, delete). |
| **Search & Discovery** | `src/modules/search/*` | **GENUINE** | Arabic text normalization, dynamic JSONB filtering, PostGIS radius bounding box queries, and facet counts are operational. |
| **Favorites Management** | `src/modules/favorites/*` | **GENUINE** | Toggle favorite, list user favorites, and count aggregations are implemented with database foreign key constraints. |
| **Geographic Locations** | `src/modules/locations/*` | **GENUINE** | Egyptian governorates, cities, and areas with PostGIS centroids are seeded and queryable via public endpoints. |
| **Daily Contact Quota Engine** | `schema.prisma::DailyQuota` | **MISSING** | `daily_quotas` table has 0 rows. No service or controller tracks, enforces, or resets the 5-reveal daily quota. |
| **In-App Chat Messaging** | `src/modules/chat/*` | **PARTIAL** | Controller and service exist for conversations and messages, but table has 0 rows in database; WebSocket gateway is rudimentary and untested end-to-end. |
| **Push Notifications** | `src/modules/notifications/*` | **PARTIAL** | Token registration endpoint exists (`/notifications/device-token`), but FCM push delivery adapter is mocked; in-app notification feed endpoint is missing. |
| **Media Handling & EXIF Scrubbing**| `src/modules/media/*`, `src/workers/*` | **PARTIAL** | Pre-signed upload URL generation implemented. EXIF scrubbing worker logic exists in `worker.service.ts`, but direct confirmation webhook is stubbed. |
| **Admin Control Center** | `src/modules/moderation/*` | **PARTIAL** | Moderation controller only handles user report tickets (`/admin/moderation/queue`), not listing moderation queues or account verification decisions. |
| **Payments & Monetization** | `src/modules/payments/*` | **OUT_OF_SCOPE** | Paymob checkout, webhook verification, packages, and transaction models are implemented, directly violating ADR-008 V1 scope. |
| **Short-Form Video Feed** | `src/modules/video/*` | **OUT_OF_SCOPE** | Cloudflare Stream video upload, webhooks, and TikTok-style feed endpoints (`/video-feed`) are implemented, violating V1 focus. |

---

## 3. Deep-Dive Domain Inspections

### 3.1 Domain 1: Categories and Dynamic Attributes
- **Code Assets:** `categories.module.ts`, `categories.controller.ts`, `categories.service.ts`.
- **Database Assets:** `categories` (52 rows), `category_fields` (86 rows).
- **Reality Assessment:**
  - Dynamic fields are persisted with types (`text`, `number`, `select`, `boolean`), mandatory flags, and JSON options (e.g. car makes, property types).
  - Validation logic in `listings.service.ts` successfully parses incoming listing attributes against required fields.
  - **Discrepancy:** The `section` column specified in ADR-001/ADR-004 is absent from the `categories` database table. Instead, 10 top-level categories exist directly in the database without an explicit section grouping.

### 3.2 Domain 2: Listing Lifecycle & Moderation Bypass
- **Code Assets:** `listings.service.ts:127-129`:
  ```typescript
  moderationStatus: 'approved',
  publicationStatus: 'published',
  availabilityStatus: 'available',
  ```
- **Reality Assessment:**
  - This is the **most egregious architectural violation** in the codebase.
  - ADR-007 and SRS Section 4 explicitly mandate that every user-created listing must be created in `draft` or `pending` status, undergo automated checks, and await human moderator approval before being visible in public feeds.
  - In actual code, the listing is published immediately upon creation.
  - Furthermore, `moderation_log` table contains **0 rows**, proving human moderation has never executed.

### 3.3 Domain 3: Multi-Tenant Accounts & RBAC
- **Code Assets:** `accounts.controller.ts`, `account-tenant.guard.ts`.
- **Reality Assessment:**
  - `AccountTenantGuard` correctly verifies that the user belongs to the requested account header `x-account-id`.
  - However, all seller account management APIs are missing: there is no endpoint to create a merchant account (`POST /accounts`), add a branch (`POST /accounts/{id}/branches`), configure service areas (`PUT /accounts/{id}/service-areas`), or manage team members (`POST /accounts/{id}/members/invite`).
  - As a result, commercial merchants cannot manage their profiles via API.

### 3.4 Domain 4: PII Leakage & Quota Engine
- **Code Assets:** `listings.service.ts:162`, `search.service.ts:108`:
  ```typescript
  sellerPhone: item.account.owner.phone,
  ```
- **Reality Assessment:**
  - ADR-008 and ADR-009 specify that seller phone numbers and WhatsApp links must be masked in public feeds and only revealed when an authenticated buyer clicks `POST /listings/:id/reveal-contact`, which decrements a daily quota.
  - In the actual codebase, both `GET /listings` and `GET /search` serialize the seller's raw telephone number directly in public payloads.
  - This renders the contact reveal endpoint and daily quota mechanism completely redundant and causes severe PII leakage.

### 3.5 Domain 5: Out-of-Scope Implementations (Payments & Video)
- **Code Assets:** `backend/src/modules/payments/*`, `backend/src/modules/video/*`.
- **Reality Assessment:**
  - **Payments:** `PaymentsModule` contains 5 files, implementing Paymob iframe URLs, webhook HMAC verification, package purchases, and transaction records. ADR-008 clearly states: *"V1 is strictly free classifieds; no payment gateway integration allowed."*
  - **Video:** `VideoModule` contains Cloudflare Stream direct upload and video feed endpoints. This was built ahead of approved V1 classifieds deliverables.
  - **Impact:** Engineering resources were diverted into out-of-scope features while core V1 features (moderation workflows, account onboarding, team RBAC) were left completely unimplemented.

---

## 4. Summary of Code Reality

| Category | Count | Percentage |
|:---|:---:|:---:|
| Genuine Implemented Modules | 6 | 33.3% |
| Partially Implemented Modules | 7 | 38.9% |
| Missing Subsystems / Capabilities | 2 | 11.1% |
| Out-of-Scope / Prohibited Modules | 2 | 11.1% |
| Completely Failed Workflows | 1 | 5.6% |
| **Total Analyzed Subsystems** | **18** | **100.0%** |

