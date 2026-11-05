# Deal One — Backend Implementation Changelog

**Document ID:** `31_BACKEND_IMPLEMENTATION_CHANGELOG.md`  
**Last Updated:** 5 November 2026  
**Implementation Lead:** Agent 1 (Senior Backend & DevOps Engineer)  
**Auditing Partner:** Agent 2 (Independent Security Auditor)  
**Standard Compliance:** ADR-001 through ADR-014, Fastify Clean Scaffolding, PostGIS 16, Dual Redis 7.2  

---

## 1. Traceable Implementation Changes

| Change ID | Files | Description | Reason | Tests | Review Status |
|---|---|---|---|---|---|
| **CHG-001** | `backend/Dockerfile`<br/>`backend/package.json` | Fixed production runtime command and package.json script to execute `dist/src/main.js` instead of `dist/main.js`. | Resolves **ISSUE-01**. Prevents container crash on startup when built with NestJS compiler. | Verified via container build and entrypoint execution. | Pending Agent 2 Review |
| **CHG-002** | `backend/prisma/schema.prisma`<br/>`backend/prisma/migrations/20261104230259_add_demo_marker_and_indexes`<br/>`backend/prisma/seeds/seed.ts`<br/>`backend/prisma/seeds/demo-listings-generator.ts` | Added `is_demo` boolean column with B-tree indexes to `listings`, `accounts`, and `users`. Seeded 340 realistic Egyptian listings with `is_demo: true` across 34 active leaf subcategories. | Resolves **ISSUE-02** & **ISSUE-10**. Isolates synthetic demo data from genuine user-generated listings. | 340 listings verified in PostgreSQL with `is_demo = true`. | Pending Agent 2 Review |
| **CHG-003** | `backend/src/modules/listings/dto/filter-listings.dto.ts`<br/>`backend/src/modules/listings/listings.service.ts`<br/>`backend/src/modules/search/dto/search-query.dto.ts`<br/>`backend/src/modules/search/search.service.ts` | Implemented dynamic category attribute filtering on JSONB column (`rooms`, `baths`, `finishing`, `furnished`, `brand`, `model`, `year`, `transmission`, `fuel_type`, `unit_type`, and custom `attributes` JSON map). Added PostGIS spatial radius bounding query (`lat`, `lng`, `radiusKm`) using `ST_DWithin` and distance sorting. | Resolves **ISSUE-16** & **ISSUE-21**. Enables mobile/web discovery filters without breaking `ValidationPipe` whitelist. | Unit tests in `listings.service.spec.ts` and `search.service.spec.ts`; direct database JSONB verification. | Pending Agent 2 Review |
| **CHG-004** | `backend/src/modules/search/arabic-normalizer.ts`<br/>`backend/src/modules/search/search.service.ts` | Enhanced Arabic normalizer with `generateArabicSearchVariants` to handle definite article ('ال') prefix stripping and addition, Alef variants, and common Egyptian phonetic substitutions (e.g. ذ/ز, ث/س). | Resolves **ISSUE-28**. Maximizes search recall for colloquial and formal Egyptian product titles. | Unit tests in `search.service.spec.ts`. | Pending Agent 2 Review |
| **CHG-005** | `backend/src/modules/listings/listings.controller.ts`<br/>`backend/src/modules/listings/listings.service.ts`<br/>`backend/src/modules/listings/listings.service.spec.ts` | Hardened seller phone reveal endpoint (`POST /listings/:id/contact` and alias `POST /listings/:id/reveal-contact`) with Redis-backed per-IP rate limiting (30 reveals/hour) and immutable security audit event logging (`CONTACT_REVEALED`). Generates pre-formatted WhatsApp link. | Resolves **ISSUE-13**. Thwarts automated web scraping of seller phone numbers while preserving friction-free contact. | Unit tests verifying phone reveal, rate-limit 429 rejection, and audit log generation in `listings.service.spec.ts`. | Pending Agent 2 Review |
| **CHG-006** | `backend/src/modules/listings/listings.service.ts`<br/>`backend/src/modules/listings/listings.service.spec.ts` | Injected `SecurityAuditService` into `ListingsService` and emitted structured `LISTING_STATUS_UPDATED` audit events whenever listing publication lifecycle state changes. | Resolves **ISSUE-24**. Ensures non-repudiation and moderation traceability. | Unit test verifying audit event logging in `listings.service.spec.ts`. | Pending Agent 2 Review |
| **CHG-007** | `backend/src/workers/worker.service.ts`<br/>`backend/src/core/health/health.controller.ts`<br/>`backend/src/core/health/health.controller.spec.ts` | Implemented `isHealthy()` worker probe and integrated background worker status (`checks.workers`) into `/health/ready` deep readiness probe. | Resolves **ISSUE-29**. Ensures load balancers and orchestrators monitor worker lifecycle health. | Unit test in `health.controller.spec.ts` passing. | Pending Agent 2 Review |
| **CHG-008** | `backend/src/modules/media/media.controller.ts`<br/>`backend/src/modules/listings/listings.controller.ts`<br/>`backend/src/modules/favorites/favorites.controller.ts`<br/>`backend/src/modules/categories/categories.service.ts` | Added route aliases for complete OpenAPI and Flutter client backward compatibility: `/media/presigned-url`, `/media/upload-urls`, `/listings/:id/reveal-contact`, `/listings/favorites`, `/listings/:id/favorite`. Added dual UUID/slug lookup in `CategoriesService`. | Resolves **ISSUE-05**, **ISSUE-06**, **ISSUE-19**. Ensures frontend and mobile consumers connect without 404 mismatches. | Verified against OpenAPI specification and live endpoint routing. | Pending Agent 2 Review |
| **CHG-009** | `docker-compose.yml` | Parameterized database and JWT credentials with environment defaults (`${...:-...}`) and added container healthcheck probe for `marketspace-api`. | Resolves **ISSUE-11** & **ISSUE-25**. Prevents cleartext production credentials from being hardcoded in repository config and enables Docker orchestrator health tracking. | Verified via `docker-compose.yml` schema and syntax check. | Pending Agent 2 Review |
| **CHG-010** | `scripts/backup-db.sh`<br/>`scripts/restore-db.sh` | Implemented automated database backup and restore scripts with gzip compression, checksum generation, timestamping, and 7-day retention pruning. | Resolves **ISSUE-22**. Provides production disaster recovery and point-in-time backup mechanism. | Verified by executing `./scripts/backup-db.sh` against live `marketspace-postgres` container. | Pending Agent 2 Review |
| **CHG-011** | `backend/src/modules/favorites/favorites.service.ts`<br/>`backend/src/modules/favorites/favorites.service.spec.ts`<br/>`backend/src/modules/locations/locations.service.spec.ts`<br/>`backend/src/modules/search/dto/search-query.dto.ts` | Cleaned up all unused variables, unused imports, and dead definitions across modules. Achieved 0 ESLint warnings and 0 TypeScript compilation errors. | Quality Gate enforcement. Guarantees code maintainability and documentation integrity. | `npm run lint` and `npm run build` passing with 0 warnings and 0 errors. | Pending Agent 2 Review |

---

## 2. Review Protocol with Agent 2 (Security Auditor)

As specified in project instructions:
1. All changes are tracked with unique IDs (`CHG-001` through `CHG-011`).
2. Changes have been committed or staged with unit and regression tests.
3. No security review status is marked as "Passed" prior to independent audit and certification by Agent 2.
4. Any confirmed security findings will be analyzed, remediated with regression tests, and re-submitted.

