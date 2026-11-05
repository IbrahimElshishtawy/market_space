# Deal One — Database & Media Security Deep-Dive Audit

**Document Reference:** `docs/security-review/05_DATABASE_AND_MEDIA_SECURITY.md`  
**Auditor:** Deal One Independent Security Reviewer (Agent 2)  
**Date:** 5 November 2026  
**Focus:** PostgreSQL 16 Schema Integrity, PostGIS 3.4 Spatial Safety, Prisma Scoping, Transaction Isolation, Cloudflare R2 / S3 Storage, Media Upload Hardening, and Sensitive Data Serialization  

---

## 1. Database Architecture & Schema Integrity Audit

### 1.1 Schema Sizing & Relational Constraints
- **Database Engine:** PostgreSQL 16 with PostGIS 3.4 spatial extension.
- **Relational Tables:** 28 core domain tables + 1 Outbox event ledger (`outbox_events`).
- **Primary Keys:** Standardized across all dynamic entities on `UUIDv4` (`@id @default(uuid()) @db.Uuid`), eliminating sequential ID enumeration and predictive parameter tampering.
- **Administrative Divisions:** `governorates` and `cities` use incremental integer IDs for localized hierarchical navigation, with composite unique constraints (`uq_city_gov_slug [governorate_id, slug]`).
- **Referential Integrity & Cascading Policies:**
  - `User` cascade deletes `UserSession`, `UserDevice`, `Favorite`, `Notification`.
  - `Account` restrict deletes `User` (prevents deleting a user account while active seller accounts exist).
  - `Category` restrict deletes child subcategories (`parent_id`) and active listings (`category_id`).
  - `ListingMedia` cascade deletes with `Listing`.
  - Foreign key constraints are enforced at the PostgreSQL engine level (`onDelete: Restrict / Cascade / SetNull`).

### 1.2 Multi-Tenant Data Isolation
- **Account Scoping:**
  - Entities belonging to merchant accounts (`listings`, `branches`, `service_areas`, `projects`, `conversations`) maintain foreign key relations to `Account(id)`.
  - Individual users own a default individual account (`account_type: 'individual'`).
  - Team members join accounts via `AccountMember` with composite unique constraint `uq_account_user [account_id, user_id]`.
- **Query Scoping Evaluation:**
  - All write operations (`createListing`, `updateListingStatus`, `sendMessage`, `addFavorite`) verify tenancy through explicit relational filters.
  - No raw unparameterized SQL strings (`$queryRawUnsafe`) were detected in application services. Prisma parameterized queries are utilized consistently, preventing SQL injection.

### 1.3 Concurrency & Transaction Safety
- **Listing Creation:** Wrapped in `this.prisma.$transaction(async (tx) => ...)`. Inserts listing and all associated media records atomically.
- **User Registration via OTP:** Wrapped in `this.prisma.$transaction(async (tx) => ...)`. Creates `User`, `Account`, and `AccountMember` in a single ACID transaction.
- **Message Dispatch:** Wrapped in `this.prisma.$transaction(async (tx) => ...)`. Creates message and updates conversation `lastMessageText` and `lastMessageAt` atomically.
- **Defect Identified (DO-SEC-009):** `OtpService.verifyOtp` does not execute within an atomic transaction with row locking (`FOR UPDATE`), allowing concurrent OTP brute-force bypass.

### 1.4 Soft-Delete & Data Retention Evaluation
- **Soft-Delete Columns:** `deletedAt TIMESTAMPTZ` exists on `users`, `accounts`, and `listings`.
- **Feed & Search Filtering:**
  - `getListingsFeed` filters `deletedAt: null`.
  - `searchListings` filters `deletedAt: null`.
  - `getMyAccounts` filters `deletedAt: null`.
- **Deficiency (DO-SEC-012):** When a user executes `DELETE /users/me`, only the `users` row receives `deletedAt = now()`. Owned `Account` records, active published `Listing` records, and active `UserSession` records are not updated, leaving orphaned published records in the database.

### 1.5 Sensitive Fields & Serializer Data Leakage
- **Password Hashes:** `User.passwordHash` is never selected in `UsersService.getProfile` or returned in controllers.
- **Refresh Token Hashes:** Stored as SHA-256 hashes in `user_sessions.refresh_token_hash`.
- **OTP Codes:** Stored as SHA-256 peppered hashes in `otps.code_hash`. Raw codes are never persisted or returned.
- **Audit Logs:** `SecurityAuditService.sanitizeMetadata` recursively strips sensitive keys (`password`, `token`, `secret`, `hash`, `code`, `otp`, `authorization`, `cookie`, `credential`).
- **CRITICAL LEAKAGE IDENTIFIED (DO-SEC-001):** `listings.service.ts` and `search.service.ts` select `owner.phone` and serialize `sellerPhone` in all public responses, leaking seller PII in bulk.

---

## 2. Media Engine & File Upload Security

### 2.1 Presigned Upload Security Architecture
- **Protocol:** Direct-to-storage presigned upload using Cloudflare R2 / S3 compatible APIs.
- **Endpoint:** `POST /api/v1/media/images/upload-url` (and mobile alias `/media/upload-urls`).
- **Authentication:** Enforced via `JwtAuthGuard`. Anonymous callers cannot request upload targets.
- **Allowed MIME Types:**
  - `image/jpeg`
  - `image/png`
  - `image/webp`
- **SVG Protection:**
  - `image/svg+xml` is strictly excluded from `AllowedImageMime`. This prevents stored Cross-Site Scripting (XSS) via embedded `<script>` or event handlers in uploaded SVG files.
- **Storage Key Isolation:**
  - Keys are generated deterministically with user UUID partitioning:
    `uploads/images/${YYYY-MM}/${userId}/${UUIDv4}.${ext}`
  - `createListing` enforces that every item in `mediaKeys` must contain `/${userId}/`. A user cannot reference or steal another user's uploaded images.

### 2.2 Video Engine Security & Webhooks
- **Protocol:** Cloudflare Stream direct-to-creator video uploads.
- **Max Duration Limit:** Enforced at 30 seconds (`maxDurationSeconds: 30`).
- **CRITICAL DEFECT (DO-SEC-002):** The asynchronous encoding webhook `POST /api/v1/media/video/webhook` fails to verify the incoming Cloudflare webhook signature. An unauthenticated attacker can forge webhook events and update arbitrary `listingMedia` records to `failed` status via substring matching.

### 2.3 Media Cleanup & Orphan File Management
- **Processor:** `MediaCleanupProcessor` runs every 6 hours via `WorkerService`.
- **Logic:** Identifies media files uploaded more than 24 hours ago that have never been attached to an active listing (`listingId IS NULL`), scheduling them for deletion from storage.
- **Status:** **PASS.** Mitigates storage resource exhaustion and prevents abandoned file buildup.

---

## 3. Database & Media Vulnerability Remediation Table

| Vulnerability ID | Root Cause | Impact | Actionable Remediation |
|---|---|---|---|
| **DO-SEC-001** | `owner.phone` in feed query | Bulk seller phone harvesting | Remove `owner.phone` from Prisma query; strip `sellerPhone` from output. |
| **DO-SEC-002** | Unauthenticated video webhook | Arbitrary record tampering / DoS | Validate Cloudflare Stream HMAC signature; validate exact UUID. |
| **DO-SEC-009** | Concurrency in `verifyOtp` | OTP brute-force ceiling bypass | Wrap verification in row-locked transaction (`FOR UPDATE`). |
| **DO-SEC-011** | Incomplete status check on listing detail | Draft/rejected listing leakage | Enforce `publicationStatus === 'published' && moderationStatus === 'approved'`. |
| **DO-SEC-012** | Incomplete user soft deletion | Orphaned listings & active sessions | Atomically revoke sessions, archive listings, and deactivate accounts. |
| **DO-SEC-013** | Seed script lacks production halt | Accidental demo data insertion | Add explicit return guard when running in production. |
