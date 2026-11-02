# Deal One — Performance & Load Testing Architecture

## 1. Load Testing Philosophy & Safety Rules

Performance testing for **Deal One** is grounded in actual empirical measurement against live, running servers. We explicitly reject simulated mock tests or virtual concurrency claims unsupported by actual HTTP roundtrips.

### Mandatory Testing Safety Protocols:
1. **Isolated Environments:** Stress tests are strictly executed against dedicated Staging or Performance Test environments (`staging-api.deal-one.eg` or local isolated Docker clusters). Testing against production requires explicit written authorization.
2. **Synthetic Data Only:** Under no circumstances is real user or merchant data used in load test suites. All phone numbers, emails, and listings are generated synthetically using deterministic seeders (prefixed with `+20109999xxxx` and `test_deal_one_`).
3. **Automated Circuit Breaker (Safety Abort):** Load testing harnesses immediately abort if:
   - Target server error rate exceeds **5%**.
   - Database connection pool wait times exceed **2,000ms**.
   - App server CPU utilization exceeds **90%** for more than 30 consecutive seconds.
4. **Clean Tear Down:** All synthetic listings, sessions, and test accounts created during load execution are scrubbed at test conclusion.

---

## 2. Load Testing Framework: Python + Locust + Pytest

The testing harness resides in a dedicated folder: `backend_tests/`.

### Technology Stack:
- **Python 3.11+:** Execution runtime.
- **Locust:** Distributed, scriptable Python load generation with gevent coroutines capable of generating tens of thousands of concurrent simulated user behaviors.
- **HTTPX:** Modern, asynchronous HTTP client with HTTP/2 and connection pooling support.
- **Pytest:** Functional, integration, and security assertion runner.

---

## 3. Concurrency Tiers & Validation Scenarios

```
    Target Concurrency Ramps:
    Tier 1:  100 CCU  ──► Baseline Validation (Ramp: 10 users/sec)
    Tier 2:  500 CCU  ──► Typical Evening Traffic (Ramp: 25 users/sec)
    Tier 3: 1,000 CCU ──► High Activity Campaign (Ramp: 50 users/sec)
    Tier 4: 5,000 CCU ──► Peak Flash Traffic / TV Ad (Ramp: 100 users/sec)
    Tier 5: 10,000 CCU ──► National Peak Stress Boundary (Ramp: 200 users/sec)
```

### 3.1 Scenario Definitions

| Scenario ID | Traffic Profile | User Mix & Actions | Pass / Fail Thresholds |
|---|---|---|---|
| **SCN-01: Normal Discovery Traffic** | Sustained load (100 to 1,000 CCU) | 70% Home feed & category browsing; 20% Search queries with filters; 10% Listing details. | • Error rate < 0.1%<br/>• p95 Latency < 150ms<br/>• Server CPU < 50% |
| **SCN-02: Peak Geo-Search Stress** | Rapid ramp-up to 5,000 CCU | 60% PostGIS spatial distance searches (`radius_km=15`, GPS coordinates around Cairo & Giza); 40% Faceted attribute filtering. | • Error rate < 1.0%<br/>• p95 Latency < 350ms<br/>• DB Connection Pool < 75% |
| **SCN-03: Concurrent Authentication Spike** | Sudden spike to 2,000 CCU in 60s | 100% Simultaneous OTP requests and verification cycles simulating a marketing push. | • Rate limiters trigger correctly with 429<br/>• Zero 500 errors<br/>• Redis latency < 5ms |
| **SCN-04: Concurrent Seller Publishing** | Sustained 500 CCU | 100% Active merchants submitting listing drafts, requesting presigned URLs, and submitting for moderation. | • p95 Latency < 300ms<br/>• Zero duplicate records or deadlocks |
| **SCN-05: Real-Time Chat & WebSocket Load** | 5,000 Concurrent WebSockets | Continuous message exchange between buyer and seller personas with typing indicators and delivery ACKs. | • Message delivery latency p95 < 200ms<br/>• Zero dropped WebSocket connections |
| **SCN-06: Maximum Capacity Boundary (10,000 CCU)** | Step-up load test to locate breaking point | Full mixed platform traffic increasing by 1,000 CCU every 2 minutes until failure or stability. | • Measurable identification of primary bottleneck (DB CPU, memory, or bandwidth) |

---

## 4. Key Performance Telemetry to Measure

During all load test runs, the harness captures:
1. **Requests Per Second (RPS):** Sustained throughput.
2. **Latency Distributions:**
   - Minimum, Average, Maximum.
   - **p50 (Median):** General user experience.
   - **p95:** Real-world tail latency.
   - **p99:** Extreme edge-case latency under resource contention.
3. **HTTP Status Code Breakdown:** Total counts of 2xx, 3xx, 4xx (especially 429 Rate Limits), and 5xx (Internal Errors).
4. **Hardware Telemetry:**
   - API Pod CPU & RAM utilization.
   - PostgreSQL active connections, cache hit ratio, and slow queries log (`pg_stat_statements`).
   - Redis memory footprint and operations per second (`instantaneous_ops_per_sec`).
   - BullMQ queue backlog depth.

---

## 5. Load Testing Locust Implementation Blueprint

The Locust scenarios simulate realistic user personas:
- **`BrowsingConsumer` (Weight: 60):** Browses home feed, clicks category chips, views listing details, and occasionally saves favorites.
- **`SpatialSearcher` (Weight: 25):** Performs radius-based PostGIS searches around Cairo, Alexandria, and Giza, adjusting price sliders and dynamic category attributes.
- **`ActiveMerchant` (Weight: 10):** Uploads images via presigned URLs, creates drafts, and checks daily quota balance.
- **`ChattyBuyer` (Weight: 5):** Opens chat conversations, reveals phone numbers (triggering quota checks), and sends messages.
