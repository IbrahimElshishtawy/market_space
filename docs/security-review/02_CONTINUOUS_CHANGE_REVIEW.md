# Deal One — Continuous Change Review & Checkpoint Audit

**Document Reference:** `docs/security-review/02_CONTINUOUS_CHANGE_REVIEW.md`  
**Review Agent:** Deal One Independent Security Reviewer (Agent 2)  
**Implementation Agent:** Agent 1 (Backend & Flutter Mobile Integration)  
**Audit Scope:** All commits and working tree modifications through Checkpoint 5 Nov 2026  

---

## 1. Checkpoint Review Summary

This document records the independent security review of modifications introduced across recent backend commits and current working-tree changes by Agent 1.

| Checkpoint / Commit | Focus Area | Files Impacted | Security Verdict | Key Observations |
|---|---|:---:|:---:|---|
| **Checkpoint 01 (b4939ff)** | Git Tracking of DB Migrations | `.gitignore` | **PASS** | Ensures all SQL migrations are version-controlled and auditable. |
| **Checkpoint 02 (dd6d534)** | 3-Axis Orthogonal Lifecycle | `listings-state-machine.ts` | **PASS** | Strict transition matrices for moderation, publication, and availability. |
| **Checkpoint 03 (Migration 20261104230259)** | Demo Marker & Indexes | `schema.prisma`, SQL migration | **PASS** | Adds `is_demo` boolean and spatial/FK indexes on `listings`, `accounts`, `users`. |
| **Checkpoint 04 (Locations & Favorites)** | Missing API Route Remediation | `locations/`, `favorites/` | **PASS** | Implemented missing endpoints. Favorites strictly scoped to authenticated user ID. |
| **Checkpoint 05 (Search & Feed Envelope Fixes)** | Response Structure & Category Slug | `listings.service.ts`, `search.service.ts` | **FAIL (BLOCKED)** | Standardized envelope for Flutter, but introduced/preserved **raw seller phone leakage** (`sellerPhone`). |
| **Checkpoint 06 (133d713 & bd5d944)** | Demo Dataset & Taxonomy Expansion | `prisma/seeds/`, `demo-listings-generator.ts` | **CONDITIONAL** | 340 Egyptian items seeded with `isDemo: true`. Seeder logic error fails to halt in production. |
| **Checkpoint 07 (Working Tree)** | Flutter Remote Repositories Integration | `deal one app/lib/` | **PASS** | Wires real `ApiClient` to mobile features; changes foreign Gulf currencies to Egyptian Pound (EGP). |

---

## 2. Checkpoint-by-Checkpoint Forensic Audit

### 2.1 Checkpoint 03: Demo Data Marker & Schema Indexing
- **Commit / Migration:** `20261104230259_add_demo_marker_and_indexes`
- **Files Modified:** `backend/prisma/schema.prisma`, `backend/prisma/migrations/20261104230259_add_demo_marker_and_indexes/migration.sql`
- **Security Analysis:**
  - Added `is_demo BOOLEAN NOT NULL DEFAULT false` to `users`, `accounts`, and `listings` tables.
  - Added indexes: `idx_users_is_demo`, `idx_accounts_is_demo`, `idx_listings_is_demo`.
  - Added foreign key indexes: `listings_branch_id_idx`, `listings_project_id_idx`.
- **Verdict:** **PASS.** Resolves ISSUE-02 and ISSUE-17 from the production readiness audit. Ensures real user records can be programmatically differentiated from synthetic demo data.

---

### 2.2 Checkpoint 04: Missing Core Modules (Locations & Favorites)
- **Files Added:**
  - `backend/src/modules/locations/locations.controller.ts`
  - `backend/src/modules/locations/locations.service.ts`
  - `backend/src/modules/favorites/favorites.controller.ts`
  - `backend/src/modules/favorites/favorites.service.ts`
- **Security Analysis:**
  - `LocationsController`: Read-only queries for active governorates and cities. Input parameters validated using NestJS `ParseIntPipe`. No PII or privileged data exposed.
  - `FavoritesController`:
    - All routes protected by `@UseGuards(JwtAuthGuard)`.
    - Listing bookmarks are isolated per user via `@CurrentUser() user: AuthenticatedUser`.
    - `getMyFavorites` queries `where: { userId: user.id }`. An authenticated user cannot query or view another user's favorite bookmarks.
    - Idempotent upsert and deletion using composite unique constraint `uq_user_favorite [userId, listingId]`.
- **Verdict:** **PASS.** High standard of authorization and data isolation.

---

### 2.3 Checkpoint 05: Listings Feed & Search Query Enhancements
- **Files Modified:**
  - `backend/src/modules/listings/listings.service.ts`
  - `backend/src/modules/search/search.service.ts`
  - `backend/src/modules/listings/dto/filter-listings.dto.ts`
  - `backend/src/modules/search/dto/search-query.dto.ts`
- **14-Question Security Checklist:**
  1. *Does it introduce a security vulnerability?* **YES.** Exposes raw seller phone numbers on every result item in public feeds.
  2. *Does it weaken existing authorization?* No, query remains public, but data exposure is severe.
  3. *Can a user access another user's data?* Yes, private seller phone numbers are harvested without quota or auth.
  4. *Can a seller modify another seller's listing?* No, `updateListingStatus` enforces `ownerUserId === userId`.
  5. *Can an unapproved seller publish listings?* Yes (pre-existing in `createListing`, not resolved in this checkpoint).
  6. *Can a normal user access administrative operations?* No.
  7. *Can malicious input bypass validation?* No, DTO filters are typed.
  8. *Can uploaded files execute?* Media keys are checked for user UUID path.
  9. *Can sensitive data appear in logs?* Phone numbers appear in query/response payloads.
  10. *Can requests bypass rate limits?* Yes, endpoints have no rate limits attached.
  11. *Can pagination or filtering expose unintended records?* `getListingById` returns unpublished/rejected listings.
  12. *Can demo records affect real users?* Demo items appear in feed unless explicitly filtered.
  13. *Can an error expose internal implementation details?* Handled by `HttpExceptionFilter`.
  14. *Can the modification break an existing security control?* **YES.** Bypasses `POST /listings/:id/contact` reveal quota control.
- **Verdict:** **FAIL (SECURITY BLOCKED — FINDING DO-SEC-001).** Must be remediated before production.

---

### 2.4 Checkpoint 06: Demo Marketplace Dataset & Idempotent Seeding
- **Files Modified:**
  - `backend/prisma/seeds/seed.ts`
  - `backend/prisma/seeds/demo-sellers-data.ts`
  - `backend/prisma/seeds/demo-listings-generator.ts`
  - `backend/prisma/seeds/taxonomy-data.ts`
  - `backend/prisma/seeds/geography-data.ts`
- **Security Analysis:**
  - 340 realistic Egyptian listings generated with realistic Cairo/Giza/Alexandria PostGIS centroids.
  - All synthetic users, accounts, and listings set `isDemo: true`.
  - Passwords for demo users are set to `null` (preventing credential brute force).
  - Phone numbers use reserved Egyptian blocks (`+201001122331`, etc.).
  - `resetDemoData()` safely isolates deletions to `where: { isDemo: true }` without touching genuine records.
  - **Defect Identified (DO-SEC-013):** Line 64 in `seed.ts` prints a warning when `NODE_ENV=production && !ALLOW_DEMO_SEEDING`, but fails to exit or return, continuing to run the full demo seed.
- **Verdict:** **CONDITIONAL PASS.** Logic bug in `seed.ts` must be patched.

---

### 2.5 Checkpoint 07: Flutter Mobile Remote Repositories Integration (Working Tree)
- **Files Modified:**
  - `deal one app/lib/app/app_dependencies.dart`
  - `deal one app/lib/bootstrap/bootstrap.dart`
  - `deal one app/lib/features/home_services/data/repositories/home_services_repository.dart`
  - `deal one app/lib/shared/data/market_repository.dart`
  - `deal one app/lib/shared/widgets/market_home_screen.dart`
- **Security Analysis:**
  - Replaces mock repositories with `ApiRealEstateRepository`, `ApiHomeAppliancesRepository`, `ApiCarsRepository`, `ApiFashionRepository`, `ApiHomeServicesRepository`.
  - All HTTP requests route through `DioApiClient` configured with `AuthInterceptor` (attaching Bearer JWT tokens securely from `SecureStorageService`).
  - Default city display corrected from foreign Gulf locations (`الرياض / دبي`) to Egyptian market (`القاهرة / الجيزة`).
  - No secrets or keys hardcoded into client Dart files.
- **Verdict:** **PASS.**
