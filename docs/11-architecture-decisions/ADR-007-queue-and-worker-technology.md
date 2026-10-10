# ADR-007: Background Queue and Asynchronous Task Worker

## Status
Approved

## Context
Market Space requires asynchronous task processing for:
- Dispatching FCM mobile push notifications.
- Reconciling Paymob webhook callbacks.
- Cleaning up orphaned S3/R2 presigned upload files.
- Executing daily listing expiration and renewal alert crons.

Options:
1. **In-Memory Timers / Process Promises:** Unreliable; jobs are lost if the Node.js process restarts.
2. **PostgreSQL-Based Job Queue (e.g., Graphile Worker / pg-boss):** Leverages existing DB, but increases transaction lock contention and database polling load.
3. **Redis-Backed Queue (BullMQ):** Industry-standard Node.js/TypeScript queue framework, high throughput, robust retry with exponential backoff, dead-letter queue (DLQ) support, and parent-child task flows.

## Decision
We select **BullMQ backed by Redis 7** running as a dedicated background worker process (`marketspace-worker`) alongside the API process.

## Consequences
- **Positive:**
  - Non-blocking: API response latencies remain under 150ms as heavy jobs are offloaded to BullMQ.
  - Automatic retries with exponential backoff for transient failures (e.g. FCM network timeouts).
  - Clear monitoring via Bull-Board in the Next.js administrative dashboard.
- **Negative:**
  - Requires maintaining a Redis 7 instance, already included in the deployment topology for rate limiting.
