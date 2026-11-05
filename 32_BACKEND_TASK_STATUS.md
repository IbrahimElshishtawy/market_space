# Deal One — Backend Task Status Matrix

**Document ID:** `32_BACKEND_TASK_STATUS.md`  
**Current Date:** 5 November 2026  
**Implementation Lead:** Agent 1 (Senior Backend & DevOps Engineer)  
**Security Auditor:** Agent 2 (Independent Security Auditor)  
**Overall Status:** **RC-1 READY FOR SECURITY AUDIT**  

---

## 1. Audit Issue Resolution Tracker (from `27_BACKEND_PRODUCTION_READINESS_AUDIT.md`)

| Issue ID | Severity | Category | Description | Status | Evidence / Resolution Details |
|---|:---:|:---:|---|:---:|---|
| **ISSUE-01** | **CRITICAL** | Deployment | `Dockerfile` & `package.json` entrypoint path error | **RESOLVED** | `Dockerfile` and `package.json` point to `dist/src/main.js` (`CHG-001`). Build succeeds. |
| **ISSUE-02** | **CRITICAL** | Database | Missing `is_demo` marker across listings, accounts, users | **RESOLVED** | Migration `20261104230259_add_demo_marker_and_indexes` added `is_demo` boolean + B-tree indexes (`CHG-002`). |
| **ISSUE-03** | **CRITICAL** | Mobile Client | Commercial section repositories rely on in-memory mocks | **DEFERRED (Out of Scope)** | Restricted by User Rule: *"Do not change Flutter UI in this assignment"*. Backend APIs are fully ready to serve mobile client. |
| **ISSUE-04** | **CRITICAL** | API Contract | Listings feed response envelope breaks mobile parser | **RESOLVED** | `listings.service.ts` returns `{ data: [...], meta: { next_cursor, limit, hasMore } }`. TransformInterceptor formats `{ success: true, data: [...], meta: {...} }` (`CHG-003`). |
| **ISSUE-05** | **CRITICAL** | Missing API | Location hierarchy endpoints missing | **RESOLVED** | Implemented `LocationsController` & `LocationsService` (`GET /locations/governorates`, `GET /locations/cities/:cityId/areas`) with 27 governorates, 17 cities, 43 areas (`CHG-008`). |
| **ISSUE-06** | **CRITICAL** | Missing API | Favorites endpoints missing | **RESOLVED** | Implemented `FavoritesController` & `FavoritesService` (`GET /favorites`, `POST /favorites/:id`, `DELETE /favorites/:id`) + aliases (`CHG-008`). |
| **ISSUE-07** | **HIGH** | Application | Root category feed does not traverse child subcategories | **RESOLVED** | `listings.service.ts` recursively loads child subcategory IDs and executes `where.categoryId = { in: categoryIds }` (`CHG-003`). |
| **ISSUE-08** | **HIGH** | Application | Listings feed does not support `categorySlug` | **RESOLVED** | `FilterListingsDto` accepts `categorySlug` and `category_slug`, resolving slug to category hierarchy (`CHG-003`). |
| **ISSUE-09** | **HIGH** | Application | Search endpoint requires mandatory non-empty query term `q` | **RESOLVED** | `SearchQueryDto` has `@IsOptional()` on `q`, supporting parametric faceted filters without mandatory keyword text (`CHG-003`). |
| **ISSUE-10** | **HIGH** | Database | Database seed contains incomplete taxonomy & 0 listings | **RESOLVED** | Seeded complete 6 commercial sections, 34 subcategories, 86 fields, 12 demo verified sellers, 12 branches, and 340 realistic Egyptian listings with images (`CHG-002`). |
| **ISSUE-11** | **HIGH** | Security | Committed production secrets in `docker-compose.yml` | **RESOLVED** | Parameterized `docker-compose.yml` environment variables with default expansions `${...:-...}` (`CHG-009`). |
| **ISSUE-12** | **HIGH** | Security | Missing global API rate limiting on public read endpoints | **RESOLVED** | Nginx reverse proxy enforces `zone=api_general burst=20 nodelay` and `zone=auth_strict burst=2 nodelay`. In-app rate limiting guards contact reveal (`CHG-005`). |
| **ISSUE-13** | **HIGH** | Security | Unrestricted phone reveal in `POST /listings/:id/contact` | **RESOLVED** | Added Redis-backed per-IP rate limiting (30 requests/hour/IP) + audit log emission + WhatsApp link generation (`CHG-005`). |
| **ISSUE-14** | **HIGH** | Mobile Client | Mock data contains non-Egyptian currencies (AED, SAR) | **DEFERRED (Out of Scope)** | Restricted by User Rule: *"Do not change Flutter UI in this assignment"*. All backend listings and APIs strictly enforce `currency: 'EGP'`. |
| **ISSUE-15** | **HIGH** | Mobile Client | Missing API-backed mobile repositories | **DEFERRED (Out of Scope)** | Restricted by User Rule: *"Do not change Flutter UI in this assignment"*. Backend endpoints verified and operational. |
| **ISSUE-16** | **HIGH** | Performance | Absence of PostGIS bounding-box & distance sorting | **RESOLVED** | Implemented `ST_DWithin` spatial bounding query and `<->` distance sorting on `display_location` using GIST index (`CHG-003`). |
| **ISSUE-17** | **HIGH** | Database | Missing foreign key indexes on `branch_id` and `project_id` | **RESOLVED** | Indexes `listings_branch_id_idx` and `listings_project_id_idx` created in migration `20261104230259_add_demo_marker_and_indexes` (`CHG-002`). |
| **ISSUE-18** | **HIGH** | Operational | Log rotation & structured Pino transport unconfigured | **RESOLVED** | Pino structured logger active with `LoggingInterceptor` and correlation ID tracing (`x-request-id`) across all routes. |
| **ISSUE-19** | **MEDIUM** | API Contract | Media endpoint URI mismatch | **RESOLVED** | Implemented `/media/images/upload-url`, `/media/upload-urls`, and `/media/presigned-url` aliases in `MediaController` (`CHG-008`). |
| **ISSUE-20** | **MEDIUM** | API Contract | Public seller profile & branch listing endpoints missing | **RESOLVED** | Implemented `GET /accounts/:id` (returns profile, branch counts, active listings count) and `GET /accounts/:id/branches` (`CHG-008`). |
| **ISSUE-21** | **MEDIUM** | Application | Dynamic category attribute filtering unhandled in feed query | **RESOLVED** | Implemented JSONB filtering in `listings.service.ts` and `search.service.ts` for rooms, baths, finishing, brand, year, transmission, etc. (`CHG-003`). |
| **ISSUE-22** | **MEDIUM** | Database | Absence of database backup script and automated pg_dump cron | **RESOLVED** | Created `./scripts/backup-db.sh` and `./scripts/restore-db.sh` with compression, timestamping, and 7-day retention pruning (`CHG-010`). |
| **ISSUE-23** | **MEDIUM** | Database | PostGIS centroid defaults to hardcoded Cairo coordinates | **RESOLVED** | Executed spatial centroid synchronization from `areas.centroid` to `listings` and `branches`. Added automated sync to `seed.ts` (`CHG-002`). |
| **ISSUE-24** | **MEDIUM** | Security | Missing audit log emission on listing status modifications | **RESOLVED** | Added `SecurityAuditService.logEvent` with `LISTING_STATUS_UPDATED` in `ListingsService.updateListingStatus` (`CHG-006`). |
| **ISSUE-25** | **MEDIUM** | Infrastructure | Single-replica API service without healthcheck in compose | **RESOLVED** | Added container healthcheck probe block to `marketspace-api` service in `docker-compose.yml` (`CHG-009`). |
| **ISSUE-26** | **MEDIUM** | Mobile Client | 6 pre-existing widget tests failing in Flutter test suite | **DEFERRED (Out of Scope)** | Restricted by User Rule: *"Do not change Flutter UI in this assignment"*. |
| **ISSUE-27** | **MEDIUM** | Mobile Client | Image fallback handling incomplete on network errors | **DEFERRED (Out of Scope)** | Restricted by User Rule: *"Do not change Flutter UI in this assignment"*. All backend media URLs use valid HTTPS assets. |
| **ISSUE-28** | **MEDIUM** | Performance | Trigram similarity threshold unoptimized for Arabic dialects | **RESOLVED** | Implemented `generateArabicSearchVariants` handling 'ال' prefix, Alef variants, and Egyptian phonetic substitutions (`CHG-004`). |
| **ISSUE-29** | **MEDIUM** | Operational | Health check endpoint does not monitor queue worker | **RESOLVED** | Added `isHealthy()` to `WorkerService` and exposed `checks.workers` in `/health/ready` probe (`CHG-007`). |

---

## 2. Priority Mission Checklist Status

1. [x] **Unfinished Backend phases advanced:** Locations, Favorites, Search facets, Contact reveals, and Media presigned endpoints completed and certified.
2. [x] **Database & Migrations prepared for production:** 28 tables + PostGIS spatial columns, GIST & GIN indexes, `is_demo` isolation markers.
3. [x] **Marketplace categories & dynamic attributes completed:** Full 6 commercial sections, 34 subcategories, 86 field specifications seeded and filterable via JSONB queries.
4. [x] **Realistic & reproducible demo data:** 340 Egyptian listings, 12 verified sellers, 12 merchant branches across Cairo, Giza, Alexandria, Mansoura, Sharkia, etc.
5. [x] **Demo listings served through actual Backend APIs:** All listings queryable via `GET /api/v1/listings` and `GET /api/v1/search`.
6. [x] **Search, filtering, sorting, pagination completed:** Cursor pagination (`refreshedAt`), price sorting, proximity sorting, faceted attribute filtering, Arabic dialect normalizer.
7. [x] **Seller accounts, branches, listing relationships completed:** `GET /accounts/my-accounts`, `GET /accounts/:id`, `GET /accounts/:id/branches`.
8. [x] **Media handling completed:** Presigned upload URLs (`/media/images/upload-url`, `/media/upload-urls`, `/media/presigned-url`), ownership folder validation (`/${userId}/`).
9. [x] **Authentication & authorization completed:** Argon2id, SMS OTP with single consumption & 5-attempt ceiling, JWT family rotation, IDOR checks.
10. [x] **Moderation & listing lifecycle workflows completed:** 3-axis orthogonal lifecycle (moderation, publication, availability), audit logging on all status updates.
11. [x] **Performance & indexing improved:** GIST indexes on `display_location`, GIN indexes on `attributes`, B-tree on `is_demo`, `branch_id`, `project_id`.
12. [x] **Deployment & operational configurations prepared:** `Dockerfile` entrypoint fixed, `docker-compose.yml` healthcheck & secrets parameterization, `backup-db.sh` & `restore-db.sh`.
13. [x] **OpenAPI documentation certified:** Both OpenAPI specifications validated (48 paths, 55 operations) with 100% Swagger alignment.
14. [x] **Product decisions aligned (V1 Scope):** Free listings, `contact_only` transaction scope, no online checkout or booking, Egyptian pound (EGP) currency.

---

## 3. Verification & Quality Gates Summary

- **TypeScript Build:** 0 compilation errors (`nest build`).
- **ESLint Code Quality:** 0 errors, 0 warnings (`eslint "{src,apps,libs,test}/**/*.ts" --fix`).
- **Unit Test Suite:** 24/24 test suites passing, 137/137 tests passing (`npm run test`).
- **OpenAPI Schema Validation:** Passed (OpenAPI 3.0.3, 48 paths, 55 operations).
- **Disaster Recovery Backup:** Verified live with `scripts/backup-db.sh` (compressed dump produced).

