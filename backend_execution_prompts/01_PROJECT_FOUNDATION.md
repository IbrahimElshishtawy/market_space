# Phase 01: Project Foundation & Clean Scaffolding

## 1. Role & Objective
You are the Lead Backend Engineer. Your objective is to configure the NestJS + Fastify Modular Monolith foundation, TypeScript strict compilation, global validation pipes, standardized API envelope interceptors, and Pino structured logging.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Sections 1.1, 1.4, 1.5)
- `backend_blueprint/03_API_SPECIFICATION.md` (Section 1.3 Uniform Envelopes)
- `backend_blueprint/06_OBSERVABILITY_AND_OPERATIONS.md` (Section 4 Pino Logging)

## 3. Exact Implementation Scope
1. Verify and update `backend/package.json` with all required dependencies.
2. Configure `backend/tsconfig.json` with strict type checking (`strict: true`, `noImplicitAny: true`).
3. Setup global `TransformInterceptor` wrapping all successful responses in `{ success: true, data: ..., meta: ... }`.
4. Setup global `HttpExceptionFilter` formatting all errors into `{ success: false, error: { code, message, details, trace_id } }`.
5. Implement `RequestIdMiddleware` generating UUID `X-Trace-ID` / `X-Request-ID`.
6. Implement `/health/liveness` and `/health/readiness` endpoints.

## 4. Files to Create / Modify
- `backend/src/main.ts`
- `backend/src/app.module.ts`
- `backend/src/core/interceptors/transform.interceptor.ts`
- `backend/src/core/filters/http-exception.filter.ts`
- `backend/src/core/middleware/request-id.middleware.ts`
- `backend/src/core/health/health.controller.ts`

## 5. Acceptance Criteria
- `npm run build` succeeds with zero TypeScript errors.
- `GET /health/liveness` returns 200 OK.
- Unhandled exceptions return standard JSON error envelope with `trace_id`.
