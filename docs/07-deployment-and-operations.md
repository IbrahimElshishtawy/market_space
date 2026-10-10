# Deployment, Operations and Runbooks — Market Space

---

## 1. Environment Architecture & Infrastructure

Market Space employs three isolated environments:
1. **Local Development (`local`):** Docker Compose hosting PostgreSQL 16, Redis 7, and LocalStack (or MinIO) for S3 emulation.
2. **Staging (`staging`):** Dedicated VPS mirroring production specs with automated deployment on `develop` branch merges.
3. **Production (`production`):** Hardened Ubuntu 24.04 VPS with automated TLS, automated offsite database backups, and health monitoring.

---

## 2. Docker & Compose Deployment Topology

### 2.1 Multi-Container Compose Configuration (`docker-compose.prod.yml`)
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.25-alpine
    container_name: marketspace-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/certs:/etc/letsencrypt:ro
    depends_on:
      - api
      - admin

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    container_name: marketspace-api
    restart: always
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    expose:
      - "3000"

  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    container_name: marketspace-worker
    restart: always
    command: ["node", "dist/workers/main.js"]
    env_file:
      - .env.production
    depends_on:
      - postgres
      - redis

  admin:
    build:
      context: ./admin
      dockerfile: Dockerfile
      target: production
    container_name: marketspace-admin
    restart: always
    expose:
      - "3001"

  postgres:
    image: postgres:16-alpine
    container_name: marketspace-postgres
    restart: always
    environment:
      POSTGRES_DB: marketspace
      POSTGRES_USER: marketspace_app
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U marketspace_app -d marketspace"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: marketspace-redis
    restart: always
    command: ["redis-server", "--appendonly", "yes", "--requirepass", "${REDIS_PASSWORD}"]
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

---

## 3. Environment Variable Inventory (Placeholders Only)

```ini
# Application Configuration
NODE_ENV=production
PORT=3000
API_BASE_URL=https://api.marketspace.eg/api/v1
CORS_ORIGIN=https://admin.marketspace.eg

# Database & Cache
DATABASE_URL=postgresql://marketspace_app:STRONG_PASSWORD_HERE@postgres:5432/marketspace?schema=public
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=STRONG_REDIS_PASSWORD_HERE

# Security & Tokens
JWT_ACCESS_SECRET=GENERATE_64_CHAR_HEX_SECRET_HERE
JWT_REFRESH_SECRET=GENERATE_64_CHAR_HEX_SECRET_HERE
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d

# SMS Gateway (Egypt)
SMS_PROVIDER=SMS_MISR
SMS_MISR_USERNAME=PROD_USERNAME_HERE
SMS_MISR_PASSWORD=PROD_PASSWORD_HERE
SMS_MISR_SENDER_ID=MarketSpace

# Storage & CDN (Cloudflare R2)
R2_ACCOUNT_ID=CLOUDFLARE_ACCOUNT_ID
R2_ACCESS_KEY_ID=R2_ACCESS_KEY_ID
R2_SECRET_ACCESS_KEY=R2_SECRET_ACCESS_KEY
R2_BUCKET_NAME=marketspace-media-prod
R2_PUBLIC_DOMAIN=https://cdn.marketspace.eg

# Video (Cloudflare Stream)
CLOUDFLARE_STREAM_API_TOKEN=STREAM_API_TOKEN
CLOUDFLARE_STREAM_ACCOUNT_ID=STREAM_ACCOUNT_ID
CLOUDFLARE_STREAM_WEBHOOK_SECRET=STREAM_WEBHOOK_SECRET

# Payments (Paymob Egypt)
PAYMOB_API_KEY=PAYMOB_API_KEY_HERE
PAYMOB_INTEGRATION_ID_CARD=123456
PAYMOB_INTEGRATION_ID_WALLET=123457
PAYMOB_HMAC_SECRET=PAYMOB_HMAC_SECRET_HERE

# Push Notifications (FCM)
FIREBASE_PROJECT_ID=marketspace-prod
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@marketspace-prod.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
```

---

## 4. Database Migrations & Backup Strategy

### 4.1 Migration Execution Protocol
1. Migrations run inside CI/CD before container rollover using:
   ```bash
   npx prisma migrate deploy
   ```
2. **Zero Downtime Rule:** Breaking column drops are conducted via multi-stage deprecation (Expand-Contract pattern):
   - *Phase 1:* Add new column / nullability.
   - *Phase 2:* Deploy application dual-writing to new column.
   - *Phase 3:* Backfill historical data via worker script.
   - *Phase 4:* Remove old column in subsequent release.

### 4.2 Automated Daily Offsite Backups
- A cron job executes daily at 03:00 AM Cairo Time:
  ```bash
  #!/usr/bin/env bash
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_FILE="/tmp/marketspace_db_${TIMESTAMP}.sql.gz"
  
  docker exec -t marketspace-postgres pg_dump -U marketspace_app -d marketspace | gzip > ${BACKUP_FILE}
  aws s3 cp ${BACKUP_FILE} s3://marketspace-backups-offsite/database/ --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
  rm ${BACKUP_FILE}
  ```
- Retention: Daily backups kept for 30 days; weekly snapshots kept for 90 days.

---

## 5. Health Checks & Observability

### 5.1 Health Endpoints
- `GET /health/live`: Lightweight process liveness returning `200 OK`.
- `GET /health/ready`: Dependency readiness verifying:
  - PostgreSQL connection query (`SELECT 1`).
  - Redis ping (`PONG`).
  - Disk storage threshold (< 90% utilization).

---

## 6. Operational Incident Runbooks

### Runbook 1: API Outage or Unresponsive Node
1. **Diagnosis:** Check container statuses and logs:
   ```bash
   docker ps
   docker logs --tail 100 marketspace-api
   ```
2. **Remediation:** If memory leak or event loop lockup occurred:
   ```bash
   docker restart marketspace-api
   ```
3. Inspect structured logs for fatal unhandled promise rejections or memory spikes.

### Runbook 2: Stuck Video Processing Webhook
1. **Diagnosis:** Inspect pending media in database:
   ```sql
   SELECT id, listing_id, stream_uid, created_at FROM listing_media 
   WHERE media_type = 'VIDEO' AND processing_status = 'PENDING' 
     AND created_at < NOW() - INTERVAL '15 minutes';
   ```
2. **Remediation:** Query Cloudflare Stream API via curl using `stream_uid`. If the video is ready on Cloudflare, dispatch a manual status update or re-trigger the webhook worker task.

### Runbook 3: Paymob Webhook Verification Failures
1. **Diagnosis:** Check recent entries in `payments` table with `status = 'PENDING'` where users reported completed payments.
2. **Remediation:** Cross-check the transaction ID in the Paymob Merchant Portal. If confirmed paid, trigger the manual reconciliation CLI tool:
   ```bash
   npm run cli:reconcile-payment -- --transactionId=12345678
   ```
