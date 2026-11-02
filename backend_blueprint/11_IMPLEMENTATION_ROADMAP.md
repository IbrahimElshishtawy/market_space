# Deal One — Backend Implementation Roadmap (17 Phased Engineering Plan)

## 1. Roadmap Architecture & Execution Philosophy

The Deal One backend implementation is structured into **17 sequential, strictly decoupled phases**. Each phase builds directly upon verified foundations, contains mandatory test gates, and cannot proceed until all acceptance criteria are met.

```
PHASE 01: Architecture Approval & Project Foundation
   │
   ▼
PHASE 02: Infrastructure, Docker & Database Setup (PostgreSQL + PostGIS + Redis)
   │
   ▼
PHASE 03: Complete Database Schema Migration (24 Relational Tables)
   │
   ▼
PHASE 04: Authentication, SMS OTP & Session Token Rotation
   │
   ▼
PHASE 05: Multi-Tenant Authorization, Accounts & Team RBAC
   │
   ▼
PHASE 06: Geographic Locations, Branches & Service Areas
   │
   ▼
PHASE 07: Categories Taxonomy & Dynamic Attribute Schemas
   │
   ▼
PHASE 08: Listings Core & 3-Axis Orthogonal Lifecycle Engine
   │
   ▼
PHASE 09: PostGIS Spatial Geo-Search & Faceted Filtering
   │
   ▼
PHASE 10: Media Engine & Cloudflare R2 Presigned S3 Uploads
   │
   ▼
PHASE 11: Real-Time Chat Engine & WebSocket Gateway
   │
   ▼
PHASE 12: Daily Quotas Engine (Redis Cairo Midnight Reset)
   │
   ▼
PHASE 13: Operational Notifications & Firebase Cloud Messaging (FCM)
   │
   ▼
PHASE 14: Admin Control Center, Moderation Queues & Audit Trails
   │
   ▼
PHASE 15: Observability, Pino Logging & Prometheus Telemetry
   │
   ▼
PHASE 16: Automated Python Quality & 10k CCU Locust Load Testing
   │
   ▼
PHASE 17: Production Staging Verification & Final Release Gate
```

---

## 2. Phase-by-Phase Technical Specifications

### Phase 01: Project Foundation & Clean Architecture Scaffolding
- **Objective:** Establish the NestJS + Fastify Modular Monolith boilerplate with TypeScript strictness, Pino logger, validation pipes, and global error filters.
- **Dependencies:** None.
- **Tasks:**
  - Initialize clean NestJS 10 application configured with `@nestjs/platform-fastify`.
  - Configure Zod / class-validator global validation pipes with `forbidNonWhitelisted: true`.
  - Implement uniform `ApiResponse<T>` and `ApiErrorResponse` serialization interceptors.
- **Acceptance Criteria:** `npm run build` succeeds with zero errors; `/health/liveness` returns 200 OK.

### Phase 02: Infrastructure & Local Docker Environment
- **Objective:** Containerize PostgreSQL 16 with PostGIS 3.4, Redis 7, and Nginx reverse proxy.
- **Dependencies:** Phase 01.
- **Tasks:**
  - Create `docker-compose.yml` with health checks for Postgres and Redis.
  - Setup initialization scripts enabling PostGIS extension (`CREATE EXTENSION IF NOT EXISTS postgis;`).
- **Acceptance Criteria:** `docker compose up -d` brings up all services healthy in under 15 seconds.

### Phase 03: Database Schema Implementation & Migrations
- **Objective:** Model and migrate all 24 core tables defined in `02_DATABASE_DESIGN.md`.
- **Dependencies:** Phase 02.
- **Tasks:**
  - Draft complete `schema.prisma` replacing the legacy schema draft.
  - Generate Prisma client and apply initial baseline migration `20261102000000_init_deal_one_schema`.
  - Implement deterministic database seeder for Egypt's 27 governorates, major cities, and test accounts.
- **Acceptance Criteria:** `npx prisma migrate dev` executes cleanly; seeder populates tables without errors.

### Phase 04: Authentication & Session Token Rotation
- **Objective:** Implement SMS OTP, Argon2id hashing, Turnstile bot verification, and 15-minute JWT + 30-day single-use refresh token rotation.
- **Dependencies:** Phase 03.
- **APIs:** `/auth/otp/send`, `/auth/otp/verify`, `/auth/token/refresh`, `/auth/logout`.
- **Security:** Rate limiting (3 OTP/15 min); automatic session revocation upon refresh token reuse.
- **Acceptance Criteria:** Functional tests prove token rotation and theft detection.

### Phase 05: Multi-Tenant Accounts & Team RBAC
- **Objective:** Implement independent seller accounts, account switching, and team roles (`owner`, `manager`, `lister`, `responder`).
- **Dependencies:** Phase 04.
- **APIs:** `/accounts/my-accounts`, `/accounts`, `/accounts/{id}/members`.
- **Security:** Strict `@TenantContext()` guard preventing cross-tenant data leaks.
- **Acceptance Criteria:** BOLA integration test confirms User A cannot access Account B's members.

### Phase 06: Geographic Locations, Branches & Service Areas
- **Objective:** Implement Egypt administrative location hierarchies, merchant branch GPS coordinates, and delivery polygons.
- **Dependencies:** Phase 05.
- **APIs:** `/locations/taxonomy`, `/locations/cities/{id}/areas`, `/accounts/{id}/branches`, `/accounts/{id}/service-areas`.
- **Acceptance Criteria:** PostGIS point geometry correctly stored for commercial branches.

### Phase 07: Categories Taxonomy & Dynamic Attribute Schemas
- **Objective:** Implement hierarchical category trees for the 6 core sectors and subcategory dynamic field schemas.
- **Dependencies:** Phase 03.
- **APIs:** `/categories`, `/categories/{id}/fields`.
- **Acceptance Criteria:** Categories return in < 50ms with subcategories nested.

### Phase 08: Listings Core & 3-Axis Orthogonal Lifecycle
- **Objective:** Implement listing creation, dynamic attribute validation against category schema, and the three orthogonal status axes.
- **Dependencies:** Phase 05, 06, 07.
- **APIs:** `/listings`, `/listings/{id}/submit`, `/listings/{id}/visibility`, `/listings/{id}/availability`.
- **Security:** Two-tier coordinate generation: exact `physical_location` kept confidential; fuzzed `display_location` generated automatically.
- **Acceptance Criteria:** Transitioning listing status records an immutable entry in `moderation_log`.

### Phase 09: PostGIS Spatial Geo-Search & Faceted Filtering
- **Objective:** Build high-throughput spatial search engine sorting results by proximity (`ST_Distance`) and JSONB attribute filters.
- **Dependencies:** Phase 08.
- **APIs:** `/search`, `/explore/feed`.
- **Performance:** Keyset cursor pagination; p95 latency < 200ms on 10,000 synthetic listings.
- **Acceptance Criteria:** Searches with and without GPS coordinates succeed seamlessly.

### Phase 10: Media Engine & Cloudflare R2 Direct Uploads
- **Objective:** Implement presigned S3/R2 direct upload URLs and asynchronous image thumbnailing with EXIF GPS stripping.
- **Dependencies:** Phase 08.
- **APIs:** `/media/presigned-url`, `/listings/{id}/media`.
- **Security:** Upload URL enforces maximum 10MB limit and whitelisted MIME types.
- **Acceptance Criteria:** Uploaded photo EXIF metadata is completely scrubbed.

### Phase 11: Real-Time Chat & WebSocket Gateway
- **Objective:** Implement secure bidirectional in-app chat with Redis Pub/Sub message distribution and read receipts.
- **Dependencies:** Phase 05, 08.
- **APIs:** `/chat/conversations`, `/chat/conversations/{id}/messages`, WebSocket `/chat`.
- **Acceptance Criteria:** Messages delivered between two connected clients in < 150ms.

### Phase 12: Daily Quotas Engine (Cairo Midnight Reset)
- **Objective:** Implement Redis sliding window rate limits and daily quotas for listings, chat starts, and contact reveals.
- **Dependencies:** Phase 04, 08.
- **APIs:** `/quotas/my-usage`, `/listings/{id}/reveal-contact`.
- **Business Rule:** Automated midnight reset at `00:00:00 Africa/Cairo` timezone.
- **Acceptance Criteria:** Consuming 6th listing on a 5-listing quota returns HTTP 429.

### Phase 13: Operational Notifications (FCM)
- **Objective:** Implement push notifications for moderation decisions, new chat messages, and quota warnings via Firebase Cloud Messaging.
- **Dependencies:** Phase 08, 11.
- **APIs:** `/notifications`, `/notifications/mark-read`.
- **Acceptance Criteria:** Approving a listing immediately triggers FCM multicast to seller's devices.

### Phase 14: Admin Control Center & Moderation Queues
- **Objective:** Implement internal moderation queue APIs, document verification review, account suspensions, and audit logging.
- **Dependencies:** Phase 05, 08.
- **APIs:** `/admin/moderation/*`, `/admin/verifications/*`, `/admin/accounts/{id}/status`, `/admin/audit-logs`.
- **Security:** Dedicated `staff_users` authentication with mandatory role check.
- **Acceptance Criteria:** Banning an account hides all its listings from public search instantly.

### Phase 15: Observability, Logging & Telemetry
- **Objective:** Instrument Prometheus metrics, Pino correlation IDs, and health check endpoints.
- **Dependencies:** All previous phases.
- **APIs:** `/health/liveness`, `/health/readiness`, `/metrics`.
- **Acceptance Criteria:** Prometheus scrapes `/metrics` successfully; logs contain `trace_id`.

### Phase 16: Automated Python Quality & Load Testing
- **Objective:** Run complete automated functional, integration, BOLA security, and 10,000 CCU Locust stress tests.
- **Dependencies:** All previous phases.
- **Harness:** `backend_tests/` suite.
- **Acceptance Criteria:** All Pytest functional and security tests pass 100%; Locust confirms p95 latency < 350ms under peak load.

### Phase 17: Production Staging Verification & Release Gate
- **Objective:** Deploy to staging environment, execute smoke verification, and audit against all quality release gates.
- **Dependencies:** Phase 16.
- **Deliverables:** Final deployment sign-off and production release tag `v1.0.0`.
- **Acceptance Criteria:** Zero P0/P1 issues remaining; production approval granted.
