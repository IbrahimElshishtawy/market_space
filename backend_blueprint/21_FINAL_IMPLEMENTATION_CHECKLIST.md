# Deal One — Final Implementation Execution Checklist

**Version:** `1.0.0-PROD-READY`  
**Purpose:** Strict sequential execution checklist for the automated implementation of Deal One backend.  
**Execution Rule:** No phase may proceed if the preceding phase's verification gates and automated tests fail.

---

## Pre-Implementation Phase Gates (Phase 00) — [COMPLETED & CERTIFIED]

- [x] Complete 16 blueprint architectural specifications generated in `backend_blueprint/`.
- [x] 14 Architecture Decision Records (ADRs) approved and signed off.
- [x] 28-table PostgreSQL + PostGIS schema designed with spatial GIST indexes and two-tier coordinates.
- [x] 55 REST endpoints + 1 WebSocket gateway documented in `03_API_SPECIFICATION.md`.
- [x] Complete OpenAPI 3.1.0 specification generated and certified via `openapi-spec-validator`.
- [x] Physical separation of Redis cache (`allkeys-lru`) and Redis queue (`noeviction`) configured in `docker-compose.prod.yml`.
- [x] Atomic Lua daily quota script designed with Cairo midnight (`00:00:00 Africa/Cairo`) TTL.
- [x] 20 automated security tests implemented and passing 100% across all 9 OWASP/ASVS threat dimensions.
- [x] Initial business decisions approved and codified in `19_OPEN_DECISIONS.md`.

---

## Phased Implementation Roadmap (Phases 01 to 17)

### [ ] Phase 01: Project Foundation & Fastify Clean Scaffolding
- Prompt: `backend_execution_prompts/01_PROJECT_FOUNDATION.md`
- [ ] Initialize NestJS 10 with Fastify HTTP adapter (`@nestjs/platform-fastify`).
- [ ] Implement `TransformInterceptor` for `{ success: true, data: ..., meta: ... }`.
- [ ] Implement `HttpExceptionFilter` with unique UUID `trace_id` error envelopes.
- [ ] Setup Pino structured logging with token and phone number masking.
- [ ] Configure health probes: `/health/liveness` and `/health/readiness`.
- [ ] **Verification Gate:** `curl http://localhost:3000/health/liveness` returns `200 OK`.

### [ ] Phase 02: Infrastructure, Docker & Database Setup
- Prompt: `backend_execution_prompts/02_DATABASE_IMPLEMENTATION.md`
- [ ] Replace obsolete `backend/prisma/schema.prisma` with certified 28-table schema.
- [ ] Spin up `deal_one_postgres`, `deal_one_redis_cache`, and `deal_one_redis_queue`.
- [ ] Run initial non-destructive migration: `npx prisma migrate dev --name init_deal_one_production_schema`.
- [ ] Execute database seeder `seed.ts` populating Egypt governorates, cities, categories, and test accounts.
- [ ] **Verification Gate:** Database connected, PostGIS extension verified, 28 tables populated.

### [ ] Phase 03: Authentication, SMS OTP & Session Tokens
- Prompt: `backend_execution_prompts/03_AUTHENTICATION_IMPLEMENTATION.md`
- [ ] Implement `AuthModule` with SMS OTP dispatch, rate limiting (3/15 min), and Turnstile verification.
- [ ] Implement JWT access tokens (15-min lifespan) and single-use refresh token rotation with theft detection.
- [ ] Implement password sign-in for staff and administrative users with Argon2id hashing.
- [ ] **Verification Gate:** `pytest backend_tests/functional/test_authentication.py` passes 100%.

### [ ] Phase 04: Multi-Tenant Authorization & Team RBAC
- Prompt: `backend_execution_prompts/04_RBAC_MULTI_TENANCY.md`
- [ ] Implement `AccountsModule` with multi-tenant context extraction (`@TenantContext()`, `X-Account-ID`).
- [ ] Enforce team RBAC guards (`Owner`, `Manager`, `Lister`, `Responder`).
- [ ] Implement account switching: `/api/v1/accounts/my-accounts`.
- [ ] **Verification Gate:** `pytest backend_tests/security/test_account_isolation.py` & `test_role_escalation.py` pass.

### [ ] Phase 05: Geographic Locations, Branches & Service Areas
- Prompt: `backend_execution_prompts/05_CORE_BUSINESS_MODULES.md`
- [ ] Implement `LocationsModule` returning Egypt governorates, cities, and granular neighborhood areas.
- [ ] Implement commercial branch management with PostGIS Point coordinates.
- [ ] Implement service provider coverage area configuration.
- [ ] **Verification Gate:** PostGIS spatial indexes active; `/locations/governorates` returns 27 entities.

### [ ] Phase 06: Categories Taxonomy & Dynamic Fields
- Prompt: `backend_execution_prompts/05_CORE_BUSINESS_MODULES.md`
- [ ] Implement `CategoriesModule` with 2-level hierarchical category taxonomy.
- [ ] Implement dynamic field metadata retrieval (`/categories/{id}/fields`) with validation schema output.
- [ ] **Verification Gate:** Category tree returns 6 root sectors with dynamic attribute definitions.

### [ ] Phase 07: Listings Core & 3-Axis Lifecycle
- Prompt: `backend_execution_prompts/06_LISTINGS_CORE.md`
- [ ] Implement `ListingsModule` enforcing the 3 orthogonal status axes (`moderation`, `publication`, `availability`).
- [ ] Implement two-tier geographic coordinate privacy (`physical_location` confidential, `display_location` public).
- [ ] Enforce Category-driven price modes (mandatory price vs `price_on_inquiry: true`).
- [ ] Enforce strict BOLA protection (`WHERE id = :id AND account_id = :active_account_id`).
- [ ] **Verification Gate:** `pytest backend_tests/security/test_bola.py` passes 100%.

### [ ] Phase 08: PostGIS Spatial Search & Filtering
- Prompt: `backend_execution_prompts/07_SEARCH_AND_POSTGIS.md`
- [ ] Implement `SearchService` using parameterized `prisma.$queryRaw` with `ST_DWithin` and `<->` distance operator.
- [ ] Implement cursor-based pagination keyset `[refreshed_at, id]` returning max 50 items.
- [ ] Implement GPS permission denied fallback to granular `area_id` centroid search.
- [ ] **Verification Gate:** Spatial queries execute in < 25ms against test database with 10,000 listings.

### [ ] Phase 09: Media Engine & Cloudflare R2 Presigned Uploads
- Prompt: `backend_execution_prompts/08_MEDIA_AND_STORAGE.md`
- [ ] Implement `MediaModule` generating signed Cloudflare R2 upload URLs (10MB limit, image/video whitelist).
- [ ] Implement BullMQ image processing worker with `sharp` to strip EXIF GPS coordinates and generate WebP thumbnails.
- [ ] Connect BullMQ worker to `deal_one_redis_queue` with `noeviction` policy.
- [ ] **Verification Gate:** Upload confirms, EXIF metadata is completely stripped, thumbnails generated.

### [ ] Phase 10: Real-Time Chat & WebSocket Gateway
- Prompt: `backend_execution_prompts/06_LISTINGS_CORE.md`
- [ ] Implement WebSocket gateway `/chat` with JWT authentication on handshake.
- [ ] Implement listing-bound conversation channels with participant authorization.
- [ ] Implement HTTP fallback endpoints for sending and retrieving messages.
- [ ] **Verification Gate:** `pytest backend_tests/security/test_chat_auth.py` passes 100%.

### [ ] Phase 11: Daily Quotas Engine (Cairo Midnight Reset)
- Prompt: `backend_execution_prompts/09_NOTIFICATIONS_AND_QUOTAS.md`
- [ ] Implement atomic Redis Lua quota script in `QuotaService` running against `deal_one_redis_cache`.
- [ ] Enforce Cairo midnight (`00:00:00 Africa/Cairo`) TTL with daylight saving awareness.
- [ ] Wire quota deductions to contact reveals (`reveal-contact`) and new listing submissions.
- [ ] **Verification Gate:** `pytest backend_tests/functional/test_quotas_concurrency.py` passes 100%.

### [ ] Phase 12: Operational Notifications (FCM)
- Prompt: `backend_execution_prompts/09_NOTIFICATIONS_AND_QUOTAS.md`
- [ ] Implement Firebase Cloud Messaging (FCM HTTP v1) integration.
- [ ] Implement in-app notification center feed with unread count and read receipts.
- [ ] **Verification Gate:** Notifications dispatches on moderation approval and new chat messages.

### [ ] Phase 13: Admin Control Center & Moderation
- Prompt: `backend_execution_prompts/10_ADMIN_CONTROL_CENTER.md`
- [ ] Implement Admin RBAC (`Super Admin`, `Admin`, `Moderator`, `Support`) isolated from public users.
- [ ] Implement pending listing moderation queue and decision endpoints (`approve` / `reject`).
- [ ] Implement dynamic platform settings update (`PUT /admin/platform-settings`).
- [ ] Enforce append-only immutable audit trail in `moderation_log` and `audit_log`.
- [ ] **Verification Gate:** `pytest backend_tests/security/test_admin_permissions.py` passes 100%.

### [ ] Phase 14: Observability, Logging & Prometheus Metrics
- Prompt: `backend_execution_prompts/11_OBSERVABILITY_MONITORING.md`
- [ ] Expose Prometheus metrics endpoint `/metrics` tracking HTTP request duration, queue depth, and DB pool stats.
- [ ] Configure Pino structured JSON logging with correlation `trace_id`.
- [ ] **Verification Gate:** Prometheus scrapes `/metrics` successfully; logs formatted in JSON.

### [ ] Phase 15: Security Hardening & Penetration Testing
- Prompt: `backend_execution_prompts/12_SECURITY_HARDENING.md`
- [ ] Configure Helmet security headers, CORS origins, and request body size caps.
- [ ] Run full automated security suite in `backend_tests/security/`.
- [ ] **Verification Gate:** Zero P0/P1 security findings.

### [ ] Phase 16: Performance Optimization & Locust Load Testing
- Prompt: `backend_execution_prompts/13_PERFORMANCE_OPTIMIZATION.md` & `15_CONCURRENT_LOAD_TESTING.md`
- [ ] Execute Locust performance tests in `backend_tests/performance/locustfile.py`.
- [ ] Verify 100 CCU baseline: p95 latency < 150ms, error rate < 0.1%.
- [ ] Verify 1,000 CCU stress test: p95 latency < 500ms, zero worker restarts.
- [ ] **Verification Gate:** Load testing reports distinguish simulated users from successful requests.

### [ ] Phase 17: Production Staging Verification & Release Gate
- Prompt: `backend_execution_prompts/16_DEPLOYMENT_STAGING.md` & `17_FINAL_SECURITY_AUDIT.md`
- [ ] Verify production Docker Compose deployment on staging server.
- [ ] Validate automated backup script `scripts/backup-db.sh` and disaster recovery restore.
- [ ] Sign off on production release gate.
