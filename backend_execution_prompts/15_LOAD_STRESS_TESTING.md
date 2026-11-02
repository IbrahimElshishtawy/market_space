# Phase 15: Concurrent Load & Stress Testing (100 to 10,000 CCU)

## 1. Role & Objective
You are the Performance & Load Testing Engineer. Your objective is to execute the Python Locust load testing suite against the staging backend across all concurrency tiers (100, 500, 1,000, 5,000, and 10,000 CCU) and measure real system latency and throughput.

## 2. Relevant Blueprint Documents
- `backend_blueprint/07_PERFORMANCE_TESTING.md` (Scenarios SCN-01 to SCN-06)
- `backend_blueprint/06_OBSERVABILITY_AND_OPERATIONS.md` (SLOs and Latency Targets)

## 3. Exact Implementation Scope
1. Execute Locust test scenarios via terminal:
   - Baseline Load (100 CCU, ramp 10/s, duration 5m): `locust -f backend_tests/performance/locustfile.py --headless -u 100 -r 10 -t 5m --host http://localhost:3000`
   - Normal Traffic (1,000 CCU, ramp 50/s, duration 10m)
   - Peak Spatial Search Stress (5,000 CCU, ramp 100/s, duration 10m)
   - Maximum Boundary Test (10,000 CCU)
2. Monitor server CPU, memory, and database connections.
3. Generate Locust HTML and CSV summary reports in `backend_tests/reports/`.

## 4. Acceptance Criteria
- 1,000 CCU sustained: Error rate < 0.1%, p95 latency < 150ms.
- 5,000 CCU sustained: Error rate < 1.0%, p95 latency < 350ms.
- Primary system bottleneck identified with actionable scaling recommendations.
