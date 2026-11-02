# Deal One — Comprehensive Pre-Implementation Technical Audit

## 1. Executive Summary & Audit Overview

- **Audited By:** Principal Backend Architect, Database Architect, Application Security Engineer & Independent Technical Auditor
- **Audit Date:** 2 November 2026
- **Audit Scope:**
  - `backend_blueprint/` (All 16 specifications, ADRs, diagrams, and OpenAPI schemas)
  - `backend_execution_prompts/` (Prompts 00 through 17)
  - `backend_tests/` (Python Pytest & Locust test infrastructure)
  - `backend/` (Existing NestJS + Fastify + Prisma codebase)
  - `market_space/lib/` (Flutter mobile client implementation)
  - `mock_data/` (Original requirements, SRS, and workflows)
- **Audit Objective:** Independent, adversarial validation of architectural consistency, data integrity, security boundaries, performance bottlenecks, and implementation readiness before any backend coding commences.

---

## 2. Database Consistency & Schema Forensic Audit

### 2.1 Table Recount & Discrepancy Reconciliation
- **Reported in Executive Summary:** "24 Relational Tables".
- **Actual Count in `02_DATABASE_DESIGN.md` Data Dictionary:** **28 Tables** total.
- **Root Cause of Discrepancy:**
  The 28 tables break down into:
  - 24 Core Domain & Engagement Tables: `governorates`, `cities`, `areas`, `users`, `user_sessions`, `user_devices`, `otps`, `accounts`, `account_members`, `account_verifications`, `branches`, `service_areas`, `projects`, `categories`, `category_fields`, `listings`, `listing_media`, `favorites`, `reports`, `conversations`, `messages`, `notifications`, `daily_quotas`, `platform_settings`.
  - 4 Administrative, Staff & Security Audit Tables: `staff_roles`, `staff_users`, `moderation_log`, `audit_log`.
- **Verdict & Alignment:** The official V1 schema count is formally certified as **28 tables**.

### 2.2 Comparison: Documented Design vs. Existing `backend/prisma/schema.prisma`
The existing `backend/prisma/schema.prisma` file in the workspace was inspected line-by-line and found to be **severely obsolete and inconsistent** with the approved architecture:
1. **Critical Entity Absence (B2B Multi-Tenancy):** `schema.prisma` completely lacks `Account`, `AccountMember`, and `AccountVerification`. It directly links `Listing` to `User` (`userId`), in direct violation of ADR-005.
2. **Collapsed Single Listing Status:** `schema.prisma` uses an old enum `ListingStatus` (DRAFT, PENDING_REVIEW, PUBLISHED, REJECTED, PAUSED, EXPIRED, SOLD, ARCHIVED) instead of the three orthogonal status axes mandated by ADR-007 (`moderation_status`, `publication_status`, `availability_status`).
3. **Out-of-Scope Modules Present:** `schema.prisma` includes `PromotionPackage` and `Payment` (Paymob), which ADR-008 explicitly deferred to V3.
4. **Missing Geographic & Audit Tables:** Missing `areas`, `branches`, `service_areas`, `projects`, `moderation_log`, `daily_quotas`, and `platform_settings`.
- **Action Required:** `schema.prisma` must be completely replaced in Phase 02 prior to generating database migrations.

### 2.3 PostGIS and Prisma ORM Critical Technical Constraint
- **Architectural Discovery:** Prisma ORM has **no native first-class support for PostGIS geometry types**. Spatial columns must be declared in Prisma schema as:
  ```prisma
  physicalLocation Unsupported("geometry(Point, 4326)") @map("physical_location")
  displayLocation  Unsupported("geometry(Point, 4326)") @map("display_location")
  ```
- **Consequence:** Spatial filtering operations (`ST_DWithin`, `ST_Distance`) **cannot be queried via standard Prisma Client methods** (`prisma.listing.findMany`).
- **Mandated Engineering Solution:** Spatial queries in `SearchService` must be executed using **`prisma.$queryRaw`** with strictly parameterized SQL templates to prevent SQL injection while utilizing PostGIS GIST spatial indexes.

---

## 3. API Consistency & Contract Verification

### 3.1 Endpoint Recount & Reconciliation
- **Documented in `03_API_SPECIFICATION.md` Inventory:** **55 REST Endpoints + 1 WebSocket Gateway** (Total: 56 interfaces).
  - Auth: 6 endpoints
  - Users: 4 endpoints
  - Accounts & RBAC: 7 endpoints
  - Locations & Branches: 5 endpoints
  - Categories: 2 endpoints
  - Listings: 8 endpoints
  - Search & Explore: 3 endpoints
  - Media: 2 endpoints
  - Chat: 4 endpoints + WebSocket `/chat`
  - Favorites & Reports: 4 endpoints
  - Quotas & Notifications: 3 endpoints
  - Admin & Moderation: 7 endpoints
- **Discrepancy in `15_OPENAPI/deal_one_openapi.yaml`:**
  The generated OpenAPI YAML contains detailed schemas for 14 core endpoints (Auth, Accounts, Listings, Search, Quotas), but omits the remaining 41 endpoints.
- **Action Required:** Phase 01 must expand `openapi/deal_one_openapi.yaml` to include the full schema definitions for all 55 endpoints before client code generation.

### 3.2 Flutter Workflow Mapping Verification
- **Verified Workflows:**
  - Login via OTP + Turnstile ➔ Mapped to `/auth/otp/send` and `/auth/otp/verify`.
  - Account Switcher Drawer ➔ Mapped to `/accounts/my-accounts`.
  - Category-Specific Faceted Search ➔ Mapped to `/search` with `category_slug`.
  - GPS Distance Sorting ➔ Mapped to PostGIS `/search?lat=...&lng=...&sort_by=nearest`.
  - GPS Permission Denied Fallback ➔ Mapped to `/locations/cities/{id}/areas` and `/search?area_id=...`.
  - In-App Chat ➔ Mapped to WebSocket `/chat` + `/chat/conversations`.
  - External Contact Reveal ➔ Mapped to `/listings/{id}/reveal-contact` with quota deduction.
  - Merchant Ad Management ➔ Mapped to `/accounts/{id}/listings` and `/listings/{id}/visibility`.

---

## 4. Architectural & Technology Stack Validation

### 4.1 NestJS 10 + Fastify Compatibility Audit
- **Findings:**
  - Fastify delivers ~30,000 req/sec compared to Express's ~14,000 req/sec in micro-benchmarks.
  - **Fastify Gotcha 1 (Payload Parsing):** Fastify requires `@fastify/formbody` for URL-encoded payloads and does not include an arbitrary file upload buffer by default. This confirms the validity of ADR-006: using direct S3/R2 presigned URLs avoids Fastify multipart memory buffering entirely.
  - **Fastify Gotcha 2 (Reply Object):** Interceptors and exception filters must use Fastify's native `FastifyReply` methods (`reply.status().send()`) rather than Express `res.status().json()`.

### 4.2 Redis & BullMQ Architecture Validation
- **Critical Memory Eviction Risk:**
  - BullMQ relies on Redis streams and atomic key-value operations. If Redis is configured with `maxmemory-policy allkeys-lru` and memory saturates, Redis may evict BullMQ internal job keys, corrupting queue state!
- **Mandated Mitigation:**
  - Configure Redis instance with **`maxmemory-policy noeviction`** or **`volatile-lru`** where only cache keys have explicit TTLs, while BullMQ keys remain persistent until processed.
  - Separate Cache keys (DB 0) from BullMQ queue keys (DB 1).

---

## 5. Security & Attack Surface Audit

### 5.1 Broken Object Level Authorization (BOLA / IDOR)
- **Audit Result:** **SECURE BY DESIGN**.
- The architectural mandate requiring `@TenantContext()` and forcing `WHERE id = :id AND account_id = :active_account_id` on all mutating operations eliminates BOLA.
- **Rule Enforced:** If a user attempts to access an entity belonging to another account, the backend returns `404 Not Found` (never `403 Forbidden`) to prevent resource enumeration.

### 5.2 Token Theft & Refresh Token Replay Protection
- **Audit Result:** **SECURE BY DESIGN**.
- Refresh tokens are stored as SHA-256 hashes in `user_sessions`.
- When a refresh token is reused after already being rotated, the server treats it as an active session hijack, immediately revoking **all** tokens for that user ID.

### 5.3 Unproven Security Assumption (Turnstile in Local/Test Environments)
- **Identified Gap:** Cloudflare Turnstile blocks automated test scripts unless a test key is provided.
- **Resolution:** In non-production environments (`NODE_ENV !== 'production'`), the Turnstile verification service accepts the official Cloudflare dummy testing secret (`1x0000000000000000000000000000000AA`) which always evaluates to valid.

---

## 6. Performance & Load Capacity Audit

### 6.1 Capacity Claims vs. Engineering Realities
The architectural documents properly describe 100, 1,000, 5,000, and 10,000 CCU as **engineering test targets**, not pre-guaranteed capacities.
- **Identified Bottlenecks:**
  1. **PostGIS CPU Contention:** Computing `ST_Distance` across 50,000 listings without spatial bounding boxes (`ST_DWithin`) will saturate database vCPUs at > 1,500 RPS.
  2. **Mitigation:** The search query MUST always apply a spatial bounding box filter (`ST_DWithin`) before sorting by distance (`<->` operator), and results must be capped at 50 per page.
  3. **Cairo Midnight Quota Reset Spike:** If 500,000 users' quotas are reset simultaneously in SQL, it would lock the database.
  4. **Mitigation:** Quotas are stored in Redis with per-key `EXPIREAT` timestamps; no mass update query is executed. Historical archiving is batched asynchronously.

---

## 7. Testing Infrastructure & Harness Audit

- **Audit of `backend_tests/`:**
  - The Python test harness (`pytest` + `httpx` + `locust`) is decoupled, modular, and functional.
  - Fixtures correctly mock Turnstile bypass and handle token injection.
  - Locust scenarios correctly separate consumer browsing (weight 50) from heavy spatial searches (weight 15) and seller uploads (weight 10).
  - **Required Enhancement:** Test suites for all 55 endpoints must be progressively populated as each corresponding implementation phase is executed.

---

## 8. Execution Prompts Audit (00 through 17)

All 18 execution prompts in `backend_execution_prompts/` were reviewed for dependency ordering:
- Phase 01: Project Foundation (No dependencies)
- Phase 02: Database & Migrations (Depends on Phase 01)
- Phase 03: Authentication (Depends on Phase 02)
- Phase 04: Multi-Tenant RBAC (Depends on Phase 03)
- Phase 05: Core Business Modules (Depends on Phase 04)
- Phase 06: Listings Core (Depends on Phase 05)
- Phase 07: Search & PostGIS (Depends on Phase 06)
- Phase 08: Media & Storage (Depends on Phase 06)
- Phase 09: Notifications & Quotas (Depends on Phase 06)
- Phase 10: Admin Control Center (Depends on Phase 04, 06)
- Phase 11: Observability (Depends on Phase 10)
- Phase 12: Security Hardening (Depends on Phase 11)
- Phase 13: Performance Optimization (Depends on Phase 12)
- Phase 14: Automated Functional Testing (Depends on Phase 13)
- Phase 15: Concurrent Load Testing (Depends on Phase 14)
- Phase 16: Deployment & Staging (Depends on Phase 15)
- Phase 17: Final Security Audit (Final release gate)
- **Audit Verdict:** The execution dependency chain is strictly sequential, acyclic, and logically sound.

---

## 9. Final Pre-Implementation Verdict

### **VERDICT: READY WITH CONDITIONS**

The architecture, system design, database models, security specifications, and testing frameworks are production-grade and ready for implementation, subject to satisfying the following three mandatory conditions:

### Mandatory Conditions Before Coding:
1. **Condition 1 (Database Alignment):** In Phase 02, completely overwrite the legacy `backend/prisma/schema.prisma` with the 28-table schema defined in `02_DATABASE_DESIGN.md`, declaring PostGIS geometry fields as `Unsupported("geometry(Point, 4326)")`.
2. **Condition 2 (OpenAPI Completion):** In Phase 01, expand `openapi/deal_one_openapi.yaml` to include all 55 REST endpoints documented in `03_API_SPECIFICATION.md`.
3. **Condition 3 (Redis Separation):** In Phase 02, configure Redis to use separate database indices for Cache (`db: 0`) and BullMQ queues (`db: 1`) with `maxmemory-policy noeviction` on queue keys.
