# Deal One — Observability, Monitoring & Site Reliability Engineering (SRE)

## 1. Observability Architecture & Tooling Stack

To ensure high availability, proactive detection of anomalies, and rapid root cause analysis, Deal One adopts an industry-standard observability stack centered on the three pillars: **Metrics**, **Logs**, and **Traces**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       OBSERVABILITY INFRASTRUCTURE                          │
├─────────────────────┬─────────────────────────────┬─────────────────────────┤
│   1. METRICS        │   2. LOGS                   │   3. TRACES & ERRORS    │
│   Prometheus        │   Pino JSON (stdout)        │   OpenTelemetry         │
│   Grafana Dashboards│   Vector / Loki Aggregator  │   Sentry Error Monitor  │
└─────────┬───────────┴──────────────┬──────────────┴────────────┬────────────┘
          │                          │                           │
          ▼                          ▼                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NESTJS + FASTIFY PRODUCTION WORKERS                      │
│   • /health/liveness        • Correlation ID Middleware   • Sentry Interc.  │
│   • /health/readiness       • Fastify Request Logger      • Span Context    │
│   • /metrics (Prometheus)   • Prisma Query Logger         • BullMQ Metrics  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Service Level Objectives (SLOs) & Service Level Indicators (SLIs)

| Service Area | Service Level Indicator (SLI) | Target Objective (SLO) | Measurement Method |
|---|---|---|---|
| **API Availability** | Percentage of non-5xx HTTP requests | **>= 99.9%** (Monthly) | `sum(rate(http_requests_total{status!~"5.."}[5m])) / sum(rate(http_requests_total[5m]))` |
| **API Latency (Read)** | Latency of public feed and listing endpoints | **p95 < 150ms** | Histogram `http_request_duration_seconds_bucket{route="/api/v1/listings"}` |
| **Search Latency** | Latency of PostGIS spatial search queries | **p95 < 300ms** | Histogram `http_request_duration_seconds_bucket{route="/api/v1/search"}` |
| **Chat Message Delivery** | Time from WebSocket publish to client delivery receipt | **p95 < 200ms** | OpenTelemetry custom span `chat.message.delivery_duration` |
| **Database Health** | PostgreSQL connection pool saturation | **< 80% capacity** | `pg_stat_activity` / PgBouncer connection gauge |
| **Worker Processing** | Media processing queue lag time | **p95 < 10 seconds** | `bullmq_job_wait_duration_seconds{queue="process-media"}` |

---

## 3. Health, Liveness & Readiness Probes

### 3.1 Liveness Probe (`GET /health/liveness`)
- **Purpose:** Verifies that the Node.js event loop is responsive and Fastify is processing requests.
- **Checks:** Lightweight memory check (RSS < 1.5GB). Does not perform external network calls.
- **Success Response:** `200 OK {"status": "ok", "uptime": 84210}`
- **Failure Action:** Container runtime restarts the deadlocked container.

### 3.2 Readiness Probe (`GET /health/readiness`)
- **Purpose:** Verifies that all persistence dependencies are connected and capable of accepting production traffic.
- **Checks:**
  1. **PostgreSQL:** Executes `SELECT 1;` (Timeout: 2000ms).
  2. **Redis:** Executes `PING` (Timeout: 1000ms).
  3. **BullMQ:** Checks queue connection state.
- **Success Response (200 OK):**
  ```json
  {
    "status": "ready",
    "timestamp": "2026-11-02T14:30:00Z",
    "checks": {
      "database": "up",
      "redis": "up",
      "workers": "up"
    }
  }
  ```
- **Failure Action:** Load balancer immediately pulls the node from upstream traffic rotation.

---

## 4. Structured JSON Logging Specification

Deal One mandates **Pino** for zero-overhead, asynchronous JSON logging formatted for automated ingestion.

### Mandatory Log Record Schema:
```json
{
  "level": "info",
  "time": 1762093800123,
  "pid": 4821,
  "hostname": "api-worker-01",
  "trace_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "user_id": "usr-889911-cairo",
  "account_id": "acc-445566-nasr",
  "req": {
    "method": "POST",
    "url": "/api/v1/listings",
    "ip": "197.38.12.89",
    "user_agent": "DealOne-Flutter/1.0.0 (Android 14)"
  },
  "res": {
    "status_code": 201,
    "duration_ms": 42.8
  },
  "msg": "Listing draft created successfully"
}
```

### Sensitive Data Redaction Rules:
The logger automatically masks:
- Passwords (`password`, `password_hash`, `new_password`)
- Phone numbers in public logs (except sanitized last 4 digits: `+2010****2095`)
- Refresh token values and JWT authorization headers
- OTP codes (`code`, `otp_code`)

---

## 5. Key Prometheus Metrics Catalog

### 5.1 HTTP & API Gateway Metrics
- `deal_one_http_requests_total{method, route, status}`: Counter of all requests.
- `deal_one_http_request_duration_seconds{method, route}`: Histogram tracking latency distribution.
- `deal_one_http_active_connections`: Gauge tracking concurrent HTTP/WebSocket connections.

### 5.2 Database & Cache Telemetry
- `deal_one_db_query_duration_seconds{operation, table}`: Histogram of query execution times.
- `deal_one_db_connections_active`: Active connections vs max pool size.
- `deal_one_redis_hits_total` / `deal_one_redis_misses_total`: Cache efficiency ratio.
- `deal_one_redis_quota_evaluations_total{quota_type, status}`: Daily quota checks.

### 5.3 Asynchronous Queue Metrics
- `deal_one_bullmq_queue_length{queue_name}`: Number of pending jobs.
- `deal_one_bullmq_job_duration_seconds{queue_name}`: Time required to process media/FCM tasks.
- `deal_one_bullmq_job_failures_total{queue_name, error_reason}`: Failed jobs counter.

---

## 6. Incident Response & On-Call Playbook

### Severity Classifications

| Severity | Definition | Examples | Response Time | Escalation Path |
|---|---|---|:---:|---|
| **P0 — Critical** | Total platform outage or severe data breach. Core workflows (search, login, listings) down for > 5% of users. | Database down; WAF blocking all Egyptian traffic; JWT signing key leaked. | **< 15 minutes** | Immediate automated call to Lead Architect & DevOps on-call. War room initiated. |
| **P1 — High** | Major feature impaired with significant user impact; no immediate workaround. | Image upload pipeline failing; FCM push notifications failing; PostGIS query timeouts. | **< 1 hour** | Senior Backend Engineer + SRE alerted via PagerDuty. |
| **P2 — Medium** | Non-critical component degraded; workaround exists. | Admin moderation queue sorting bug; slow dashboard analytics; isolated quota calculation issue. | **< 4 hours** | Next business day or assigned to engineering sprint. |
| **P3 — Low** | Minor cosmetic defect or documentation error. | Typo in error message; minor admin export delay. | Regular sprint | Logged in backlog. |

### Incident Recovery Standard Operating Procedure (SOP):
1. **Triage & Containment:** Inspect Grafana dashboards (`/health/readiness` error status) and Sentry error spikes.
2. **Rollback Trigger:** If incident was caused by a recent deployment, trigger instantaneous rollback via Docker image tag revert:
   ```bash
   docker compose -f docker-compose.prod.yml pull backend:previous_stable
   docker compose -f docker-compose.prod.yml up -d --no-deps backend
   ```
3. **Database Failover (if Primary DB crashes):**
   - Promote read-replica using `pg_ctl promote`.
   - Update `DATABASE_URL` connection string via dynamic DNS or container restart.
4. **Post-Mortem:** Conduct blameless root cause analysis (5 Whys) within 48 hours, publishing action items to prevent recurrence.
