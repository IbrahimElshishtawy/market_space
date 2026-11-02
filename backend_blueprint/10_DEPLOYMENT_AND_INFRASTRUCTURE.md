# Deal One — Deployment, Infrastructure & DevOps Engineering

## 1. Production Infrastructure Topology

Deal One is deployed using containerized micro-architectural topologies on dedicated Linux infrastructure with edge CDN acceleration.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          EDGE & PERIMETER TIER                              │
│  Cloudflare Enterprise DNS + WAF + DDoS Mitigation + SSL Strict Mode        │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Public IPv4 / IPv6
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     HOST SERVER (Ubuntu 22.04 LTS / 24.04)                  │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Nginx Reverse Proxy (SSL Termination, Rate Limiting, Gzip/Brotli)    │   │
│   └──────────────────┬───────────────────────────────┬──────────────────┘   │
│                      │ Unix Socket / Port 3001-3004  │                      │
│                      ▼                               ▼                      │
│   ┌─────────────────────────────────────┐ ┌─────────────────────────────┐   │
│   │ 4x Stateless NestJS API Containers  │ │ 1x BullMQ Asynchronous      │   │
│   │ (Cluster Mode, 0.5 vCPU, 512MB ea)  │ │ Background Worker Container │   │
│   └──────────────────┬──────────────────┘ └──────────────┬──────────────┘   │
│                      │                                   │                  │
│                      ▼                                   ▼                  │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Persistence Containers (Isolated Docker Bridge Network)             │   │
│   │  • PostgreSQL 16 Enterprise + PostGIS 3.4 (Dedicated Volume)        │   │
│   │  • Redis 7 In-Memory Cache & Message Broker (AOF + RDB Enabled)     │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ S3 API
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     EXTERNAL CLOUD SERVICES                                 │
│  • Cloudflare R2 Object Storage (Zero-Egress Image Bucket)                   │
│  • Firebase Cloud Messaging (FCM HTTP v1 API)                               │
│  • Offsite Encrypted Backup Bucket (Nightly pg_dump with GPG)               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Environment Definitions

| Environment | Purpose | URL / Gateway | Database Configuration |
|---|---|---|---|
| **Development (`local`)** | Developer laptops & feature branches | `http://localhost:3000/api/v1` | Local Docker Compose (PostgreSQL 16 + Redis 7), hot-reload enabled. |
| **Testing (`ci`)** | Automated GitHub Actions CI test suite | `http://127.0.0.1:3000/api/v1` | Ephemeral test database spun up and torn down per test run. |
| **Staging (`stage`)** | Pre-production testing, QA automation, Locust load tests | `https://staging-api.deal-one.eg/api/v1` | Identical configuration to production with sanitized test data. |
| **Production (`prod`)** | Live public production traffic | `https://api.deal-one.eg/api/v1` | High-availability PostgreSQL with WAL archiving and redundant Redis. |

---

## 3. Production Docker Compose Architecture (`docker-compose.prod.yml`)

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.25-alpine
    container_name: deal_one_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - deal_one_public
      - deal_one_internal

  api:
    image: deal-one-backend:latest
    container_name: deal_one_api
    restart: unless-stopped
    deploy:
      replicas: 4
      resources:
        limits:
          cpus: '1.0'
          memory: 1024M
    environment:
      - NODE_ENV=production
      - PORT=3000
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
      redis_cache:
        condition: service_healthy
      redis_queue:
        condition: service_healthy
    networks:
      - deal_one_internal

  worker:
    image: deal-one-backend:latest
    container_name: deal_one_worker
    restart: unless-stopped
    command: ["node", "dist/workers/main.js"]
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1024M
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
      redis_queue:
        condition: service_healthy
    networks:
      - deal_one_internal

  postgres:
    image: postgis/postgis:16-3.4-alpine
    container_name: deal_one_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - deal_one_internal

  redis_cache:
    image: redis:7.2-alpine
    container_name: deal_one_redis_cache
    restart: unless-stopped
    command: [
      "redis-server",
      "--maxmemory", "512mb",
      "--maxmemory-policy", "allkeys-lru",
      "--requirepass", "${REDIS_CACHE_PASSWORD}"
    ]
    volumes:
      - redis_cache_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_CACHE_PASSWORD}", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - deal_one_internal

  redis_queue:
    image: redis:7.2-alpine
    container_name: deal_one_redis_queue
    restart: unless-stopped
    command: [
      "redis-server",
      "--appendonly", "yes",
      "--appendfsync", "everysec",
      "--maxmemory", "512mb",
      "--maxmemory-policy", "noeviction",
      "--requirepass", "${REDIS_QUEUE_PASSWORD}"
    ]
    volumes:
      - redis_queue_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_QUEUE_PASSWORD}", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - deal_one_internal

networks:
  deal_one_public:
    driver: bridge
  deal_one_internal:
    internal: true

volumes:
  postgres_data:
  redis_cache_data:
  redis_queue_data:
```

---

## 4. Production Environment Variables Blueprint (`.env.production.example`)

```ini
# Application Core
NODE_ENV=production
PORT=3000
API_PREFIX=/api/v1
TZ=Africa/Cairo

# PostgreSQL & PostGIS
DATABASE_URL=postgresql://deal_one_app:SecureDBPassword_2026@postgres:5432/deal_one_prod?schema=public&connection_limit=25&pool_timeout=10

# Redis Cache & Queues
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=SecureRedisAuthToken_2026!
REDIS_DB=0

# Security & Cryptography
JWT_ACCESS_SECRET=SuperSecretHighEntropyAccessKey2026_AtLeast64CharsLong_MustBeRotated
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d
ARGON2_MEMORY_COST=65536
ARGON2_TIME_COST=3

# Cloudflare Bot Defense & CDN
CLOUDFLARE_TURNSTILE_SECRET_KEY=0x4AAAAAAAXyZ...
CLOUDFLARE_R2_ACCOUNT_ID=d9a8f7e6...
CLOUDFLARE_R2_ACCESS_KEY_ID=r2_access_key...
CLOUDFLARE_R2_SECRET_ACCESS_KEY=r2_secret_key...
CLOUDFLARE_R2_BUCKET_NAME=deal-one-media-prod
CLOUDFLARE_R2_PUBLIC_URL=https://media.deal-one.eg

# Firebase Cloud Messaging
FIREBASE_PROJECT_ID=deal-one-prod
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@deal-one-prod.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBA...=\n-----END PRIVATE KEY-----"

# Observability
SENTRY_DSN=https://xxxxxxxx@sentry.io/123456
LOG_LEVEL=info
```

---

## 5. Zero-Downtime Deployment & Rollback Protocol

### 5.1 Blue/Green Rolling Update Procedure
1. Build and tag the production container image: `docker build -t deal-one-backend:$COMMIT_SHA .`
2. Run database migrations: `docker run --rm --env-file .env.production deal-one-backend:$COMMIT_SHA npx prisma migrate deploy`
3. Execute rolling update of API container replicas without stopping Nginx:
   ```bash
   docker compose -f docker-compose.prod.yml up -d --no-deps --build api
   ```
4. Verify health via readiness probe: `curl -f http://localhost:3000/health/readiness`
5. If health check succeeds, deployment is complete.

### 5.2 Rollback Procedure
If any unexpected 5xx spike occurs post-deployment:
1. Revert container image to previous release tag:
   ```bash
   docker compose -f docker-compose.prod.yml down api
   docker tag deal-one-backend:previous_stable deal-one-backend:latest
   docker compose -f docker-compose.prod.yml up -d api
   ```
2. Revert backward-compatible database migration if necessary.

---

## 6. Disaster Recovery & Automated Backup Strategy

1. **Nightly Encrypted Physical Database Backups:**
   - At 02:00 AM Cairo Time, a cron task executes `pg_dump` with gzip compression, encrypts the archive with GPG (AES-256), and streams it to an isolated Cloudflare R2 backup bucket with a 90-day lifecycle retention policy.
2. **Point-In-Time Recovery (PITR):**
   - PostgreSQL Write-Ahead Logs (WAL) are continuously archived every 10 minutes to offsite cloud storage. In the event of catastrophic data corruption, the database can be restored to any specified minute in time.
3. **Monthly Disaster Recovery Simulation:**
   - On the first Sunday of every calendar month, an automated script restores the latest backup dump into a fresh staging container and runs verification integrity queries.
