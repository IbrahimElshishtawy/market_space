# Deal One — Architectural Risk Assessment & Mitigation Register

**Document ID:** `BLU-22-ARA`  
**Version:** `1.0.0-PROD`  
**Scope:** Deal One Modular Monolith (Fastify + PostgreSQL 16 + PostGIS + Redis 7 + Cloudflare R2)

This register documents all technical, infrastructural, and operational risks identified during pre-implementation architecture audits, complete with defense-in-depth mitigations and fail-safe designs.

---

## Risk Matrix Overview

| Risk ID | Category | Risk Description | Severity | Likelihood | Mitigation Strategy |
|---|---|---|:---:|:---:|---|
| **RSK-01** | Infrastructure | BullMQ queue job loss due to Redis memory eviction | **CRITICAL (P0)** | Low (Mitigated) | Physical container separation (`redis_queue` uses `noeviction` policy). |
| **RSK-02** | Database / CPU | Spatial query saturation during radius searches | **HIGH (P1)** | Medium | Mandatory indexed `ST_DWithin` bounding box filter before `<->` distance sort; max 50 items/page. |
| **RSK-03** | Security | BOLA / IDOR cross-tenant resource tampering | **CRITICAL (P0)** | Low (Mitigated) | Mandatory `@TenantContext()` and `account_id` where-clause constraints on all mutations; returns 404. |
| **RSK-04** | Security | Refresh token theft & session replay | **HIGH (P1)** | Low (Mitigated) | SHA-256 hashed single-use token rotation; replay triggers immediate revocation of all user sessions. |
| **RSK-05** | Performance | Cairo midnight quota reset thundering herd | **MEDIUM (P2)** | Low (Mitigated) | Dynamic per-key Redis `EXPIREAT` expiry; zero mass SQL update queries executed at midnight. |
| **RSK-06** | Privacy | Exposure of seller precise physical home/shop coordinates | **HIGH (P1)** | Low (Mitigated) | Two-tier location model: `physical_location` confidential; `display_location` fuzzed by 200–500m. |
| **RSK-07** | Operational | Fastify file upload memory buffer exhaustion | **MEDIUM (P2)** | Low (Mitigated) | Direct client-to-storage presigned uploads via Cloudflare R2; zero upload bytes pass through Fastify. |
| **RSK-08** | Business / Fraud | Automated scraper draining seller phone numbers | **HIGH (P1)** | Medium | Cloudflare Turnstile bot verification + Redis daily quota cap (15/day for individuals, 100/day for business). |
| **RSK-09** | Testing / CI | Turnstile blocking automated CI test runners | **MEDIUM (P2)** | High | Official Cloudflare test key bypass enabled only when `NODE_ENV !== 'production'`. |
| **RSK-10** | Database | Prisma ORM lack of native PostGIS spatial query support | **HIGH (P1)** | Guaranteed | Parameterized `prisma.$queryRaw` template pattern mandated for all radius and nearest searches. |

---

## Deep Dive into Critical Mitigations

### 1. RSK-01: Redis Cache vs Queue Eviction
- **Failure Mode:** In a single Redis instance with `maxmemory-policy allkeys-lru`, heavy caching of listing feeds would evict BullMQ internal job tokens, silently dropping media processing and SMS dispatch jobs without raising an alert.
- **Architectural Defense:**
  - `redis_cache` container handles HTTP caching, platform settings, and session caches with `allkeys-lru` and 512MB limit.
  - `redis_queue` container runs as an independent process with `noeviction`, AOF persistence enabled (`appendfsync everysec`), and 512MB limit. If memory fills, BullMQ throws an explicit OOM error rather than losing jobs.

### 2. RSK-02: PostGIS Search Query Optimization
- **Failure Mode:** Executing `ORDER BY physical_location <-> ST_SetSRID(ST_Point(lng, lat), 4326)` across 50,000 listings without a spatial filter triggers a full table distance calculation, saturating database vCPUs at > 1,500 RPS.
- **Architectural Defense:**
  - Every spatial query MUST first filter using the GIST-indexed spatial boundary:
    ```sql
    WHERE ST_DWithin(
      display_location,
      ST_SetSRID(ST_Point($1, $2), 4326)::geography,
      $3 * 1000
    )
    ```
  - Only the pre-filtered subset is sorted by distance.
  - Cursor pagination caps results to 50 items per page.

### 3. RSK-05: Cairo Midnight Quota Reset Spike
- **Failure Mode:** If 500,000 active accounts have their daily quota reset via a batch SQL `UPDATE daily_quotas SET used = 0 WHERE date = CURRENT_DATE` at 00:00:00 Cairo time, the database experiences severe lock contention and replication lag.
- **Architectural Defense:**
  - Daily quotas are stored as transient keys in `redis_cache`:
    `quota:{accountId}:{dimension}:{cairoDate}`.
  - The key's TTL is set at creation to the exact number of seconds remaining until midnight Africa/Cairo.
  - At midnight, Redis naturally expires the key. The first request on the new day creates a fresh counter starting at 1. No batch update query is ever executed.

### 4. RSK-06: Geographic Privacy Protection
- **Failure Mode:** A private individual listing a vehicle or jewelry from their home has their exact GPS apartment coordinates exposed in the JSON API, compromising personal safety.
- **Architectural Defense:**
  - Database stores both `physical_location` (confidential, accessed only for internal distance sorting) and `display_location` (fuzzed by a random offset of 200–500 meters within the neighborhood boundary).
  - Public serializers in `ListingTransformer` strictly exclude `physical_location` from API responses.

---

## Fail-Safe Emergency Protocols

1. **Database Failover:** Nightly GPG-encrypted pg_dump backups uploaded to an offsite S3/R2 bucket with 30-day retention and point-in-time recovery (PITR) via WAL archiving.
2. **Redis Outage:** If `redis_cache` is temporarily unavailable, Fastify falls back to direct database reads with rate limits enforced in memory.
3. **Queue Backpressure:** If `deal_one_redis_queue` depth exceeds 5,000 pending jobs, Prometheus fires an alert to scale worker replicas from 1 to 4 instances.
