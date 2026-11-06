# Report 07: Deal One Architecture & ADR Compliance Audit

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Scope:** Systematic evaluation of all 14 Architecture Decision Records (ADRs) against the actual NestJS codebase, database schema, and runtime behavior.

---

## 1. Architecture Decision Records Compliance Scorecard

| ADR ID | Decision Title | Stated Policy / Architecture Rule | Actual Implementation Status | Compliance Verdict | Audit Evidence & Deviation Analysis |
|:---|:---|:---|:---:|:---:|:---|
| **ADR-001** | Modular Monolith & PostgreSQL/PostGIS | Single deployable NestJS service with Postgres 16 & PostGIS spatial indexing. | `app.module.ts`, `schema.prisma`, PostGIS 3.4 container | **COMPLIANT** | High fidelity. Clean modular boundaries, Prisma schema, PostGIS GIST indexes verified. |
| **ADR-002** | Dual Redis Architecture | Redis Cache (Port 6379) separated from Redis BullMQ Queue (Port 6380). | `docker-compose.yml`, `redis.service.ts` | **COMPLIANT** | Verified. Separate containerized Redis instances with dedicated connection pooling. |
| **ADR-003** | Auth & Session Management | OTP-based phone login with JWT access token (15m) and refresh family rotation. | `modules/auth/*`, `session.service.ts` | **COMPLIANT** | Verified. Reuse detection triggers instant family revocation; bcrypt hashing applied. |
| **ADR-004** | Dynamic Category Attributes | Category-specific fields stored in JSONB column with GIN containment index. | `schema.prisma::Listing.attributes`, GIN index | **COMPLIANT** | Verified. Dynamic schema validation in `listings.service.ts` and GIN index active. |
| **ADR-005** | Media Direct Uploads & EXIF | Pre-signed S3 URLs with async background worker stripping EXIF coordinates. | `media.service.ts`, `worker.service.ts` | **PARTIAL** | Pre-signed URL generation works. Missing upload confirmation endpoint (`POST /media/confirm-upload`). |
| **ADR-006** | Multi-Tenant Accounts & RBAC | Merchant accounts with branches and team roles (Owner, Admin, Member). | `schema.prisma`, `accounts.controller.ts` | **PARTIAL** | Tables exist; `AccountTenantGuard` active. But team management and branch creation APIs are missing. |
| **ADR-007** | Two-Tier Listing Moderation | Draft listings require automated checks and human review before public visibility. | `listings.service.ts:127-129`, `moderation_log` | **CONTRADICTED** | **MAJOR VIOLATION**: Listings hardcode `approved`/`published` upon creation, completely bypassing human moderation! |
| **ADR-008** | V1 Strict Classifieds Scope | 100% Free classifieds. Strictly NO online checkout, payments, or order processing in V1. | `modules/payments/*`, `PaymentsController` | **CONTRADICTED** | **MAJOR VIOLATION**: Paymob checkout, webhooks, and package transactions implemented in direct violation of ADR-008. |
| **ADR-009** | Daily Contact Reveal Quotas | Reveal seller contact subject to 5 free reveals/day, resetting midnight Cairo. | `daily_quotas` (0 rows), `listings.service.ts` | **CONTRADICTED** | **MAJOR VIOLATION**: Quota balance never decremented; public feeds leak raw phone numbers without quota checks. |
| **ADR-010** | Egyptian Geographic Hierarchy | Normalized 3-tier geography (Governorates -> Cities -> Areas) with centroids. | `locations.service.ts`, `areas` PostGIS table | **COMPLIANT** | Complete Egyptian dataset (27 gov, 17 cities, 43 areas) with PostGIS centroids. |
| **ADR-011** | Transactional Outbox Pattern | Domain events written to `outbox_events` table within same DB transaction. | `schema.prisma::OutboxEvent`, `worker.service.ts` | **PARTIAL** | Table exists, worker polls table, but domain services do NOT write events to `outbox_events`. |
| **ADR-012** | Unified API Envelope & Tracing | Standard envelope `{ success, data, meta }` with `X-Request-Id` correlation. | `transform.interceptor.ts`, `request-id.middleware.ts` | **COMPLIANT** | Verified. Every response wrapped in standard envelope and tagged with correlation UUID. |
| **ADR-013** | Redis Sliding Window Throttling | Distributed rate limiting on sensitive routes using Redis atomic transactions. | `listings.service.ts`, `redis.service.ts` | **COMPLIANT** | Verified. Rate limiting active on contact click logging and OTP request endpoints. |
| **ADR-014** | Observability & Health Probes | Structured JSON logging, correlation IDs, and deep multi-dependency health probes. | `health.controller.ts`, `winston` logging | **COMPLIANT** | Verified. `GET /health` checks PostgreSQL, Redis Cache, Redis Queue, and Worker readiness. |

---

## 2. Quantitative ADR Compliance Summary

- **Total ADRs Evaluated:** 14 ADRs
- **COMPLIANT:** **8 ADRs (57.1%)**
- **PARTIALLY COMPLIANT:** **3 ADRs (21.4%)**
- **CONTRADICTED / VIOLATED:** **3 ADRs (21.4%)**

---

## 3. Deep Analysis of ADR Contradictions

### 3.1 Contradiction 1: ADR-007 (Two-Tier Human Moderation)
- **ADR-007 Stated Policy:**
  > *"Every user listing must be created in 'draft' status. Once submitted by the user, it transitions to 'pending' and enters the human moderation queue. Only after an administrative staff member reviews and approves the listing does it transition to 'approved' and 'published'."*
- **Actual Code Reality (`listings.service.ts`):**
  ```typescript
  const listing = await this.prisma.listing.create({
    data: {
      ...
      moderationStatus: 'approved',
      publicationStatus: 'published',
      availabilityStatus: 'available',
      ...
    }
  });
  ```
- **Conclusion:** The code operates 180 degrees opposite to ADR-007. Human moderation does not exist at runtime.

### 3.2 Contradiction 2: ADR-008 (V1 Strict Scope Prohibition)
- **ADR-008 Stated Policy:**
  > *"Deal One V1 is strictly a classifieds marketplace. Online checkout, payment gateways, shopping carts, and order fulfillment are categorically out of scope for V1 to ensure focus and rapid deployment."*
- **Actual Code Reality:**
  - `backend/src/modules/payments/payments.controller.ts`: 3 endpoints (`/payments/packages`, `/payments/checkout`, `/payments/webhook`).
  - `backend/src/modules/payments/payments.service.ts`: Complete Paymob iframe transaction generation and HMAC SHA512 signature validation.
  - `schema.prisma`: Models `PaymentTransaction`, `PaymentPackage`.
- **Conclusion:** Engineering effort was misdirected into building out-of-scope commerce features while basic classifieds requirements (e.g. `PUT /listings/:id`, `DELETE /listings/:id`) were abandoned.

### 3.3 Contradiction 3: ADR-009 (Daily Contact Quota)
- **ADR-009 Stated Policy:**
  > *"To protect seller privacy and establish monetization paths in future phases, seller phone numbers and WhatsApp links must remain hidden behind an unmask button, restricted by a 5-reveal daily quota per account."*
- **Actual Code Reality:**
  - `daily_quotas` table has **0 rows**.
  - `listings.service.ts` serializes `sellerPhone: item.account.owner.phone` into every item in the public feed.
- **Conclusion:** ADR-009 is completely invalidated by code that directly exposes phone numbers to all unauthenticated clients.

---

## 4. Architectural Pattern Adherence

- **Modular Monolith Integrity:** **HIGH**. The NestJS module boundaries are clean; modules interact via injected services rather than circular references.
- **Layered Clean Architecture:** **HIGH**. Clear separation between Controllers (HTTP/DTO), Services (Business Logic), Prisma Client (Data Access), and Entities/DTOs.
- **Transactional Outbox Adherence:** **LOW**. While the architectural intent was documented in ADR-011 and a worker service was created, transactional writes to `outbox_events` were never wired into domain entity updates.
- **Idempotency Adherence:** **MODERATE**. OTP generation, seed execution, and refresh token rotation are idempotent; however, listing creation lacks an `Idempotency-Key` header guard.

