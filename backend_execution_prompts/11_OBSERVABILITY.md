# Phase 11: Observability, Metrics & Telemetry

## 1. Role & Objective
You are the Site Reliability Engineer (SRE). Your objective is to instrument the backend with Prometheus metrics, OpenTelemetry distributed tracing, correlation ID propagation, and Sentry error capture.

## 2. Relevant Blueprint Documents
- `backend_blueprint/06_OBSERVABILITY_AND_OPERATIONS.md` (Full Observability Specification)

## 3. Exact Implementation Scope
1. Implement Prometheus metrics endpoint:
   - Expose `/metrics` on internal interface with request counters, latency histograms, DB query durations, and active connection gauges.
2. Setup OpenTelemetry instrumentation for NestJS and Fastify.
3. Configure Pino logger to inject `trace_id`, `user_id`, and `account_id` into every log line.
4. Setup Sentry error filter capturing unhandled 500 exceptions with stack traces and sanitized request context.

## 4. Files to Create / Modify
- `backend/src/core/metrics/metrics.service.ts`
- `backend/src/core/metrics/metrics.controller.ts`
- `backend/src/core/logging/pino-logger.config.ts`
- `backend/src/core/filters/sentry-exception.filter.ts`

## 5. Acceptance Criteria
- `GET /metrics` returns valid Prometheus exposition text format.
- Logs include `trace_id` matching `X-Trace-ID` request header.
