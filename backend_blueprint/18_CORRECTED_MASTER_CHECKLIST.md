# Deal One — Corrected Master Architecture Checklist

## 1. Official Reconciled Metrics & Standards

| Metric / Dimension | Documented Baseline | Reconciled & Audited Standard | Notes |
|---|---|---|---|
| **Database Tables (V1)** | 24 core tables | **28 Relational Tables** | 24 Domain tables + 4 Staff/Audit tables |
| **API Endpoints (V1)** | 52 endpoints | **55 REST Endpoints + 1 WebSocket** | Full inventory documented in `03_API_SPECIFICATION.md` |
| **Listing Lifecycle Statuses** | Single collapsed enum | **3 Orthogonal Status Axes** | `moderation_status`, `publication_status`, `availability_status` |
| **Geographic Privacy** | Single raw coordinate | **Two-Tier (Physical vs. Display)** | Confidential PostGIS Point vs. public fuzzed Point |
| **Transaction Scope (V1)** | Online Payments & Cart | **Strict `contact_only` Scope** | Payments & Booking strictly deferred to V3 |
| **Multi-Tenancy** | Single User per listing | **Independent Accounts & RBAC** | `accounts` + `account_members` (`owner, manager, lister, responder`) |
| **Quota Engine** | Static daily limits | **Redis Lua Atomic Counter** | Resets at `00:00:00 Africa/Cairo` timezone |

---

## 2. Database Entity Implementation Checklist (28 Tables)

- [ ] **1. `governorates`**: Egypt's 27 governorates with Arabic/English names and slugs.
- [ ] **2. `cities`**: Administrative cities linked to governorates (`ON DELETE RESTRICT`).
- [ ] **3. `areas`**: Granular neighborhoods with administrative centroid PostGIS Point.
- [ ] **4. `users`**: Master user identity with unique E.164 phone and Argon2id hash.
- [ ] **5. `user_sessions`**: Refresh token rotation records with SHA-256 hash and theft detection.
- [ ] **6. `user_devices`**: FCM device tokens and mobile platform tracking.
- [ ] **7. `otps`**: Short-lived SMS OTP hashes with 5-minute expiry and attempt limit.
- [ ] **8. `accounts`**: Independent seller entities with `account_type` and verification status.
- [ ] **9. `account_members`**: Team memberships with explicit RBAC roles.
- [ ] **10. `account_verifications`**: Uploaded commercial registers, tax cards, and licenses.
- [ ] **11. `branches`**: Commercial store/showroom locations with PostGIS Point.
- [ ] **12. `service_areas`**: Operational coverage polygons for service providers.
- [ ] **13. `projects`**: Real estate compounds grouping individual listings.
- [ ] **14. `categories`**: Two-level taxonomy for the 6 core vertical sectors.
- [ ] **15. `category_fields`**: Subcategory dynamic attribute definitions and validation rules.
- [ ] **16. `listings`**: Core advertisement entity with 3-axis statuses and 2-tier locations.
- [ ] **17. `listing_media`**: Listing images and video metadata with sort orders.
- [ ] **18. `favorites`**: User bookmarked listings with live availability tracking.
- [ ] **19. `reports`**: User abuse reports against listings or accounts.
- [ ] **20. `conversations`**: Listing-bound bidirectional chat rooms.
- [ ] **21. `messages`**: Granular messages with sent/delivered/read timestamps.
- [ ] **22. `notifications`**: In-app notification center records.
- [ ] **23. `daily_quotas`**: Historical consumption ledger for daily quotas.
- [ ] **24. `platform_settings`**: Dynamically editable system parameters and default quotas.
- [ ] **25. `staff_roles`**: Administrative roles (`super_admin, admin, moderator, support`).
- [ ] **26. `staff_users`**: Internal operators distinct from public users.
- [ ] **27. `moderation_log`**: Append-only immutable content and account moderation history.
- [ ] **28. `audit_log`**: Append-only immutable administrative audit trail.

---

## 3. Pre-Flight Implementation Checklist (Phase 01 & 02)

### Architecture & Runtime Verification
- [ ] Node.js v20 LTS active in runtime environment.
- [ ] Fastify HTTP engine configured with `@fastify/cors` and `@fastify/helmet`.
- [ ] Global `TransformInterceptor` producing standard `{ success: true, data: ..., meta: ... }` responses.
- [ ] Global `HttpExceptionFilter` producing standard `{ success: false, error: { code, message, details, trace_id } }` responses.
- [ ] Pino logger configured with automatic masking of passwords, tokens, and phone numbers.

### Database & ORM Verification
- [ ] PostgreSQL 16 active with PostGIS 3.4 extension loaded.
- [ ] Prisma schema updated with all 28 tables.
- [ ] PostGIS spatial columns configured with `Unsupported("geometry(Point, 4326)")`.
- [ ] Spatial queries routed through `prisma.$queryRaw` using parameterized templates.
- [ ] Seeder populates Egypt governorates, categories, and test accounts.

### Security Verification
- [ ] Argon2id configured for password hashing.
- [ ] Turnstile verification implemented with test-key bypass for automated CI runs.
- [ ] Access token lifetime capped at 15 minutes.
- [ ] Single-use refresh token rotation with immediate reuse breach revocation.
- [ ] Mandatory `@TenantContext()` and `account_id` constraints applied to all mutating operations.
- [ ] Presigned Cloudflare R2 upload URLs enforce max 10MB image limit.
- [ ] Image processing worker strips EXIF GPS coordinates using `sharp`.

### Quality & Testing Verification
- [ ] Pytest functional test suite passes against running backend.
- [ ] Locust load test suite verifies 100 CCU baseline with p95 < 150ms.
- [ ] CI pipeline blocks merges if test failures or P0/P1 security vulnerabilities exist.
